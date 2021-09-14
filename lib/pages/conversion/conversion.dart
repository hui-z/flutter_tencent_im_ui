import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

import 'component/face_msg.dart';
import 'component/conversation_inner.dart';
import 'component/more_send_function.dart';
import 'component/msg_input.dart';

class Conversion extends StatefulWidget {
  Conversion(
      {Key? key,
      required this.conversationID,
      this.appBar,
      this.onMessageRqSuc,
      this.onMessageRqFail})
      : super(key: key);

  final String conversationID;
  final PreferredSizeWidget? appBar;
  final Function(Response response, V2TimMessage message)? onMessageRqSuc;
  final Function(DioError error)? onMessageRqFail;

  @override
  State<StatefulWidget> createState() => ConversionState(conversationID);
}

class ConversionState extends State<Conversion> {
  ConversionState(this.conversationID);

  final String conversationID;

  int _type = ConversationType.c2c;
  String? _userID = '';
  String? _groupID = '';
  bool _recordBackStatus = true; // 录音键按下时无法返回
  double? _keyboardHeight;
  double _defaultKeyboardHeight = 301;
  bool _isShowBottomView = false;
  Widget? _bottomView;
  final _picker = ImagePicker();
  GlobalKey<ConversationInnerState> _conversationInnerKey = GlobalKey();
  Timer? _timer;
  bool _isAutoScroll = false;
  bool _isNoMoreData = true;
  String _lastMsgID = '';

  @override
  void initState() {
    super.initState();
    getConversion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  getConversion() async {
    V2TimValueCallback<V2TimConversation> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    if (data.code == 0) {
      _type = data.data!.type!;
      _groupID = data.data!.groupID == null ? "" : data.data!.groupID;
      _userID = data.data!.userID == null ? "" : data.data!.userID;
      getHistoryMessageList();
    }
  }

  getHistoryMessageList() {
    if (_type == ConversationType.c2c) {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(
            userID: _userID!,
            count: msgQuerySize,
          )
          .then((listRes) {
        if (listRes.code == 0) {
          List<V2TimMessage> list = listRes.data ?? [];
          _isNoMoreData = list.length < msgQuerySize;
          if (list.length > 0) {
            _lastMsgID = list.last.msgID ?? '';
          }
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(widget.conversationID, list);
          setState(() {});
        }
      });
    } else if (_type == ConversationType.group) {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getGroupHistoryMessageList(
            groupID: _groupID!,
            count: msgQuerySize,
          )
          .then((listRes) {
        if (listRes.code == 0) {
          List<V2TimMessage> list = listRes.data ?? [];
          _isNoMoreData = list.length < msgQuerySize;
          if (list.length > 0) {
            _lastMsgID = list.last.msgID ?? '';
          }
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(widget.conversationID, list);
          setState(() {});
        }
      });
    }
  }

  void setRecordBackStatus(bool status) {
    setState(() {
      _recordBackStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => _recordBackStatus,
        child: Scaffold(
            resizeToAvoidBottomInset: !_isShowBottomView,
            appBar: widget.appBar,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: ConversationInner(
                            key: _conversationInnerKey,
                            conversationID: conversationID,
                            type: _type,
                            userID: _userID,
                            groupID: _groupID,
                            scrollListener: () {
                              if (_isShowBottomView && !_isAutoScroll) {
                                setState(() {
                                  _isShowBottomView = false;
                                });
                              }
                            },
                            onMessageRqSuc: widget.onMessageRqSuc,
                            onMessageRqFail: widget.onMessageRqFail,
                            isNoMoreData: _isNoMoreData,
                            lastMsgID: _lastMsgID),
                        onTap: () {
                          if (MediaQuery.of(context).viewInsets.bottom >= 50) {
                            if (_keyboardHeight == null) {
                              _keyboardHeight =
                                  MediaQuery.of(context).viewInsets.bottom;
                            }
                            FocusScope.of(context).requestFocus(FocusNode());
                          }
                          if (_isShowBottomView) {
                            setState(() {
                              _isShowBottomView = false;
                            });
                          }
                        },
                      ),
                    ),
                    Divider(color: CommonColors.dividerColor, height: 1,),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Center(
                        child: MsgInput(
                            toUser: _type == ConversationType.c2c
                                ? _userID!
                                : _groupID!,
                            type: _type,
                            recordBackStatus: _recordBackStatus,
                            setRecordBackStatus: setRecordBackStatus,
                            moreBtnClick: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              _isAutoScroll = true;
                              _conversationInnerKey.currentState
                                  ?.scrollToBottom();
                              _bottomView = MoreSendFunction(
                                toUser: _type == ConversationType.c2c
                                    ? _userID!
                                    : _groupID!,
                                type: _type,
                                picker: _picker,
                                height:
                                    _keyboardHeight ?? _defaultKeyboardHeight,
                              );
                              setState(() {
                                _isShowBottomView = true;
                              });
                              _timer = Timer(Duration(milliseconds: 400), () {
                                _isAutoScroll = false;
                              });
                            },
                            faceBtnClick: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              _isAutoScroll = true;
                              _conversationInnerKey.currentState
                                  ?.scrollToBottom();
                              _bottomView = FaceMsg(
                                  toUser: _type == ConversationType.c2c
                                      ? _userID!
                                      : _groupID!,
                                  type: _type,
                                  height: _keyboardHeight ?? _defaultKeyboardHeight);
                              setState(() {
                                _isShowBottomView = true;
                              });
                              _timer = Timer(Duration(milliseconds: 400), () {
                                _isAutoScroll = false;
                              });
                            },
                            atBtnClick: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            sendTextMsgSuc: () {
                              _conversationInnerKey.currentState
                                  ?.scrollToBottom();
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        color: Colors.white,
                          height: _isShowBottomView
                              ? _keyboardHeight ?? _defaultKeyboardHeight
                              : MediaQuery.of(context).padding.bottom),
                    )
                  ],
                ),
                _isShowBottomView
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              _bottomView ?? SizedBox(),
                            ],
                          )
                        ],
                      )
                    : SizedBox()
              ],
            )));
  }
}
