import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/images.dart';

import 'advance_msg.dart';
import 'text_msg.dart';
import 'voice_msg.dart';

class MsgInput extends StatefulWidget {
  MsgInput(
      {Key? key,
      required this.toUser,
      required this.type,
      required this.recordBackStatus,
      this.setRecordBackStatus,
      required this.moreBtnClick,
      required this.faceBtnClick,
      required this.sendTextMsgSuc,
      required this.atBtnClick})
      : super(key: key);
  final String toUser;
  final int type;
  final bool recordBackStatus;
  final setRecordBackStatus;
  final VoidCallback moreBtnClick;
  final VoidCallback faceBtnClick;
  final VoidCallback atBtnClick;
  final VoidCallback sendTextMsgSuc;

  @override
  _MsgInputState createState() => _MsgInputState();
}

class _MsgInputState extends State<MsgInput> {
  String? sendText;
  GlobalKey<AdvanceMsgState> _advanceMsgKey = GlobalKey();
  GlobalKey<TextMsgState> _textMsgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              VoiceMsg(widget.toUser, widget.type),
              TextMsg(
                  key: _textMsgKey,
                  toUser: widget.toUser,
                  type: widget.type,
                  recordBackStatus: widget.recordBackStatus,
                  setRecordBackStatus: widget.setRecordBackStatus,
                  onChanged: (text) {
                    _advanceMsgKey.currentState?.updateSendButtonStatus(text);
                  }),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Center(
                      child: Image(
                          image: assetImage('images/icon_face.png'), width: 36, height: 36)),
                ),
                onTap: widget.faceBtnClick,
              ),
              AdvanceMsg(
                  key: _advanceMsgKey,
                  toUser: widget.toUser,
                  type: widget.type,
                  sendText: sendText,
                  sendTextMsgSuc: () {
                    sendText = null;
                    _textMsgKey.currentState?.clearInput();
                  },
                  moreBtnClick: widget.moreBtnClick),
            ],
          )
        ],
      ),
    );
  }
}
