import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'addAdvanceMsg.dart';
import 'addTextMsg.dart';
import 'addVoiceMsg.dart';

class MsgInput extends StatefulWidget {
  MsgInput(this.toUser, this.type, this.recordBackStatus,
      this.setRecordBackStatus, this.moreBtnClick, this.faceBtnClick);
  final String toUser;
  final int type;
  final bool recordBackStatus;
  final setRecordBackStatus;
  final VoidCallback moreBtnClick;
  final VoidCallback faceBtnClick;

  @override
  _MsgInputState createState() => _MsgInputState();
}

class _MsgInputState extends State<MsgInput> {
  String? sendText;
  GlobalKey<AdvanceMsgState> _advanceMsgKey = GlobalKey();
  GlobalKey<TextMsgState> _textMsgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    print("toUser${widget.toUser} ${widget.type} ***** MsgInput");

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
              AdvanceMsg(_advanceMsgKey, widget.toUser, widget.type, sendText,
                      () {
                    sendText = null;
                    _textMsgKey.currentState?.clearInput();
                  }, widget.moreBtnClick),
            ],
          )
        ],
      ),
    );
  }
}