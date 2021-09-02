import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      required this.sendTextMsgSuc})
      : super(key: key);
  final String toUser;
  final int type;
  final bool recordBackStatus;
  final setRecordBackStatus;
  final VoidCallback moreBtnClick;
  final VoidCallback faceBtnClick;
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
      child: Column(
        children: [
          Row(
            children: [
              VoiceMsg(widget.toUser, widget.type),
              TextMsg(_textMsgKey, widget.toUser, widget.type,
                  widget.recordBackStatus, widget.setRecordBackStatus, (text) {
                _advanceMsgKey.currentState?.updateSendButtonStatus(text);
              }),
              Container(
                width: 44,
                height: 44,
                child: IconButton(
                    icon: Icon(
                      Icons.tag_faces,
                      size: 30,
                      color: Colors.black,
                    ),
                    onPressed: widget.faceBtnClick),
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
