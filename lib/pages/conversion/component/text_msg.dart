import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/models/AtMessageModel.dart';
import 'package:flutter_tencent_im_ui/pages/conversion/component/select_members.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/provider/keybooad_show.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';

class TextMsg extends StatefulWidget {
  final String toUser;
  final int type;
  final bool recordBackStatus;
  final setRecordBackStatus;
  final ValueChanged<String> onChanged;

  TextMsg(
      {Key? key,
      required this.toUser,
      required this.type,
      required this.recordBackStatus,
      this.setRecordBackStatus,
      required this.onChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TextMsgState();
}

class TextMsgState extends State<TextMsg> {
  bool _isRecording = false;
  bool _isSend = true;
  int _count = 0;
  TextEditingController _inputController = new TextEditingController();
  final _audioRecorder = Record();
  String _soundPath = '';
  late Timer? _timer;
  OverlayEntry? _overlayEntry;
  String _voiceIco = "images/voice_volume_1.png";
  String _oldText = '';
  List<AtMessageModel> _atMsgList = [];
  FocusNode _node = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _audioRecorder.stop();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    _audioRecorder.hasPermission().then((value) {});
  }

// 动画循环（Demo使用的api因为兼容性问题无法监听音量因此直接使用循环动画）
  loopAnimationTimer() {
    List<String> list = [
      "images/voice_volume_1.png",
      "images/voice_volume_2.png",
      "images/voice_volume_3.png",
      "images/voice_volume_4.png",
      "images/voice_volume_5.png",
      "images/voice_volume_6.png",
      "images/voice_volume_7.png"
    ];
    // 定义一个函数，将定时器包裹起来
    _timer = Timer.periodic(Duration(milliseconds: 1200), (t) {
      if (_count > 6) _count = 0;

      setState(() {
        _voiceIco = list[_count];
      });
      _count++;
      if (_overlayEntry != null) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  cancelLoopAnimationTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  buildOverLayView(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = new OverlayEntry(builder: (content) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.5 - 80,
          left: MediaQuery.of(context).size.width * 0.5 - 80,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xff77797A),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: new Image.asset(
                          _voiceIco,
                          width: 100,
                          height: 100,
                          package: 'flutter_plugin_record',
                        ),
                      ),
                      Container(
                        child: Text(
                          "手指上滑,取消发送",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  addAtText() {
    final oldOffset = _inputController.selection.extentOffset;
    _inputController.text = _inputController.text + '@';
    if (!_node.hasFocus) {
      _node.requestFocus();
    } else {
      _inputController.selection =
          TextSelection.fromPosition(TextPosition(offset: oldOffset + 1));
    }
    widget.onChanged(_appendSendAtMagInfo(_inputController.text));
    _checkoutAtMsg(_inputController.text);
  }

  clearInput() {
    _inputController.clear();
    _atMsgList = [];
  }

  String _appendSendAtMagInfo(String text) {
    return text +
        (_atMsgList.isEmpty
            ? ''
            : '_atMsgListJson: ${json.encode(_atMsgList.map((e) => e.toJson()).toList())}');
  }

  _checkoutAtMsg(String text) {
    if (text.length > 0) {
      var lastStr = text.substring(text.length - 1);
      if (lastStr == '@') {
        showModalBottomSheet(
                context: context,
                builder: (context) => SelectMembers(
                      type: widget.type,
                      groupId: widget.toUser,
                      toUser: widget.toUser,
                    ),
                isScrollControlled: true)
            .then((value) {
          if (value == null) {
            return;
          }
          var result = value as List<AtMessageModel>?;
          int index = 0;
          result?.forEach((element) {
            var disPlayName = element.toShowString();
            if (index == 0) {
              text += '$disPlayName ';
            } else {
              text += '@$disPlayName ';
            }
            index++;
          });
          if (result?.isNotEmpty == true) {
            _atMsgList.addAll(result!);
            _inputController.text = text;
            _oldText = text;
            widget.onChanged(_appendSendAtMagInfo(text));
          }
        });
      }
    }
  }

  // 1 可以跳转， 0 禁止
  _setGoBackForbid(status) {
    widget.setRecordBackStatus(status);
  }

  // 发送音频
  _sendRecord(recordPath) async {
    var d = await flutterSoundHelper.duration(recordPath);
    double _duration = d != null ? d.inMilliseconds / 1000.0 : 0.00;
    if (_isSend) {
      if (_duration > 3) {
        TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendSoundMessage(
          soundPath: recordPath,
          receiver: (widget.type == 1 ? widget.toUser : ""),
          groupID: (widget.type == 2 ? widget.toUser : ""),
          duration: _duration.ceil(),
        )
            .then((sendRes) {
          // 发送成功
          if (sendRes.code == 0) {
            String key = (widget.type == 1
                ? "c2c_${widget.toUser}"
                : "group_${widget.toUser}");
            List<V2TimMessage> list = new List.empty(growable: true);
            list.add(sendRes.data!);
            Provider.of<CurrentMessageListModel>(context, listen: false)
                .addMessage(key, list);
          }
        });
      } else {
        Utils.toast('说话时间太短了');
      }
    }
  }

  // 开始录音
  _start() async {
    String tempPath = (await getTemporaryDirectory()).path;
    int random = new Random().nextInt(1000);
    String path = "$tempPath/sendSoundMessage_$random.aac";
    File soundFile = new File(path);
    soundFile.createSync();
    _setGoBackForbid(false);
    try {
      await _audioRecorder.start(path: path);
    } catch (err) {}
    setState(() {
      _isRecording = true;
      _soundPath = path;
    });
  }

  // 结束录音
  _stop() async {
    final lastPath = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });
    cancelLoopAnimationTimer();
    _setGoBackForbid(true);
    return _soundPath;
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboradShow = Provider.of<KeyBoradModel>(context).show;
    return Expanded(
      child: isKeyboradShow
          ? PhysicalModel(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                constraints: BoxConstraints(
                    maxHeight: 132.0,
                    minHeight: 44.0,),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: CommonColors.grayBgColor,
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  onChanged: (text) {
                    if (text.length < _oldText.length) {
                      var focusIndex = _inputController.selection.extentOffset;
                      var atIndex = text.substring(0, focusIndex).lastIndexOf('@');
                      var spaceIndex = _oldText.substring(0, focusIndex).lastIndexOf(' ');
                      if (atIndex > spaceIndex && atIndex < text.length - 1 && _atMsgList.length > 0) {
                        _inputController.text = text.substring(0, atIndex) + text.substring(focusIndex, text.length);
                        _inputController.selection = TextSelection.fromPosition(
                            TextPosition(offset: atIndex));
                        text = _inputController.text;
                        int removeIndex = 0;
                        while(atIndex > 0) {
                          atIndex = text.substring(0, atIndex).lastIndexOf('@');
                          var spaceIndex = text.substring(0, atIndex).lastIndexOf(' ');
                          if (atIndex > spaceIndex && atIndex > -1) {
                            removeIndex++;
                          }
                        }
                        _atMsgList.removeAt(removeIndex);
                      }
                    } else {
                      _checkoutAtMsg(text);
                    }
                    _oldText = text;
                    widget.onChanged(_appendSendAtMagInfo(text));
                  },
                  focusNode: _node,
                  autocorrect: false,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  cursorColor: CommonColors.getThemeColor(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    isDense: true,
                    hintText: '编辑信息',
                    hintStyle: TextStyle(
                        fontSize: 16,
                        color: CommonColors.frameColor
                    ),
                    contentPadding: EdgeInsets.only(
                      top: 9,
                      bottom: 0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: CommonColors.blackTextColor
                  ),
                  minLines: 1,
                ),
              ),
            )
          : GestureDetector(
              onLongPressStart: (e) async {
                setState(() {
                  _isRecording = true;
                  _isSend = true;
                });
                buildOverLayView(context); //显示图标
                loopAnimationTimer();
                await _start();
              },
              onLongPressEnd: (e) async {
                bool isSendLocal = true;
                if (e.localPosition.dx < 0 ||
                    e.localPosition.dy < 0 ||
                    e.localPosition.dy > 40) {
                  // 取消了发送
                  isSendLocal = false;
                }
                try {
                  if (_overlayEntry != null) {
                    _overlayEntry!.remove();
                    _overlayEntry = null;
                  }
                } catch (err) {}
                setState(() {
                  _isRecording = false;
                  _isSend = isSendLocal;
                });
                await _stop();
                _sendRecord(_soundPath);
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _isRecording
                      ? CommonColors.blueBgColor
                      : CommonColors.blueTextColor,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '按住说话',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
