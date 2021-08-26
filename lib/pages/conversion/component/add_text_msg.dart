import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/provider/keybooad_show.dart';
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

  TextMsg(Key key, this.toUser, this.type, this.recordBackStatus,
      this.setRecordBackStatus, this.onChanged)
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TextMsgState();
}

class TextMsgState extends State<TextMsg> {
  bool isRecording = false;
  bool isSend = true;
  bool isShowSendBtn = false;
  int _count = 0;
  TextEditingController inputController = new TextEditingController();
  final _audioRecorder = Record();
  String soundPath = '';
  late Timer? _timer;
  OverlayEntry? overlayEntry;
  String voiceIco = "images/voice_volume_1.png";

  late DateTime startTime;
  late DateTime endTime;

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
    _audioRecorder.hasPermission().then((value) {
    });
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
        voiceIco = list[_count];
      });
      _count++;
      if (overlayEntry != null) {
        overlayEntry!.markNeedsBuild();
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
    if (overlayEntry == null) {
      overlayEntry = new OverlayEntry(builder: (content) {
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
                          voiceIco,
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
      Overlay.of(context)!.insert(overlayEntry!);
    }
  }

  clearInput() {
    inputController.clear();
  }

  // 1 可以跳转， 0 禁止
  setGoBackForbid(status) {
    widget.setRecordBackStatus(status);
  }

  // 发送音频
  sendRecord(recordPath) async {
    var d = await flutterSoundHelper.duration(recordPath);
    double _duration = d != null ? d.inMilliseconds / 1000.0 : 0.00;
    if (isSend) {
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
    }
  }

  // 开始录音
  start() async {
    String tempPath = (await getTemporaryDirectory()).path;
    int random = new Random().nextInt(1000);
    String path = "$tempPath/sendSoundMessage_$random.aac";
    File soundFile = new File(path);
    soundFile.createSync();
    setGoBackForbid(false);
    try {
      await _audioRecorder.start(path: path);
    } catch (err) {
    }
    setState(() {
      isRecording = true;
      soundPath = path;
      startTime = DateTime.now();
    });
  }

  // 结束录音
  stop() async {
    final lastPath = await _audioRecorder.stop();

    setState(() {
      isRecording = false;
      endTime = DateTime.now();
    });
    cancelLoopAnimationTimer();
    setGoBackForbid(true);
    return soundPath;
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
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: inputController,
                  onChanged: (text) {
                    widget.onChanged(text);
                  },
                  focusNode: _node,
                  autocorrect: false,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.newline,
                  cursorColor: CommonColors.getThemeColor(),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    isDense: true,
                    contentPadding: EdgeInsets.only(
                      top: 9,
                      bottom: 0,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  minLines: 1,
                ),
              ),
            )
          : GestureDetector(
              onLongPressStart: (e) async {
                setState(() {
                  isRecording = true;
                  isSend = true;
                });
                buildOverLayView(context); //显示图标
                loopAnimationTimer();
                await start();
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
                  if (overlayEntry != null) {
                    overlayEntry!.remove();
                    overlayEntry = null;
                  }
                } catch (err) {}
                setState(() {
                  isRecording = false;
                  isSend = isSendLocal;
                });
                await stop();
                sendRecord(soundPath);
              },
              child: Container(
                height: 34,
                color: isRecording
                    ? CommonColors.getGapColor()
                    : CommonColors.getWitheColor(),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '按住说话',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
