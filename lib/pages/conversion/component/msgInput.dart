import 'package:flutter/widgets.dart';

import 'addAdvanceMsg.dart';
import 'addFaceMsg.dart';
import 'addTextMsg.dart';
import 'addVoiceMsg.dart';

class MsgInput extends StatelessWidget {
  MsgInput(
      this.toUser, this.type, this.recordBackStatus, this.setRecordBackStatus);
  final String toUser;
  final int type;
  bool recordBackStatus;
  final setRecordBackStatus;
  @override
  Widget build(BuildContext context) {
    print("toUser$toUser $type ***** MsgInput");

    return Container(
      height: 55,
      child: Row(
        children: [
          VoiceMsg(toUser, type),
          TextMsg(toUser, type, recordBackStatus, setRecordBackStatus),
          FaceMsg(toUser, type),
          AdvanceMsg(toUser, type),
        ],
      ),
    );
  }
}
