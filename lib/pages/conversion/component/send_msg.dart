import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/avatar.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'msg_body.dart';

class SendMsg extends StatelessWidget {
  SendMsg(
      {Key? key,
      required this.message,
      this.onMessageRqSuc,
      this.onMessageRqFail,
      required this.type,
      required this.isReversed,
      this.lastMsgTime,
      this.isShowMsgTime})
      : super(key: key);

  final V2TimMessage message;
  final Function(Response response, V2TimMessage message)? onMessageRqSuc;
  final Function(DioError error)? onMessageRqFail;
  final int type;
  final bool isReversed;
  final int? lastMsgTime;
  final bool? isShowMsgTime;

  _getShowMessage() {
    String msg = '';
    switch (message.elemType) {
      case 1:
        msg = message.textElem?.text ?? "";
        break;
      case 2:
        msg = message.customElem?.data ?? "";
        break;
      case 3:
        msg = message.imageElem?.path ?? "";
        break;
      case 4:
        msg = message.soundElem?.path ?? "";
        break;
      case 5:
        msg = message.videoElem?.videoPath ?? "";
        break;
      case 6:
        msg = message.fileElem?.fileName ?? "";
        break;
      case 7:
        msg = message.locationElem?.desc ?? "";
        break;
      case 8:
        msg = message.faceElem?.data ?? "";
        break;
      case 9:
        msg = "系统消息";
        break;
    }

    return msg;
  }

  _getShowName() {
    return message.friendRemark == null || message.friendRemark == ''
        ? message.nickName == null || message.nickName == ''
            ? message.sender
            : message.nickName
        : message.friendRemark;
  }

  String _getMessageTime() {
    String time = '';
    int timestamp = message.timestamp! * 1000;
    DateTime timeDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();
    int compareTime = lastMsgTime ?? now.millisecondsSinceEpoch;

    if (compareTime - timestamp >= 30 * 60 * 1000 || isShowMsgTime == true) {
      time =
          '${timeDate.year.toString()}年${timeDate.month.toString().padLeft(2, '0')}月'
          '${timeDate.day.toString().padLeft(2, '0')}日 '
          '${timeDate.hour.toString().padLeft(2, '0')}:'
          '${timeDate.minute.toString().padLeft(2, '0')}';
    } else {
      time = '';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    if (message.msgID == null || message.msgID == '') {
      return Container();
    }
    List<Widget> children = [
      Row(
        textDirection: message.isSelf! ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (!message.isSelf!) {
                // 区分群内消息和普通好友消息
              }
            },
            child: Avatar(
              avtarUrl: message.faceUrl == null || message.faceUrl == ''
                  ? 'images/logo.png'
                  : message.faceUrl,
              width: 44,
              height: 44,
              radius: 22,
            ),
          ),
          MsgBody(
            type: type,
            name: _getShowName(),
            message: _getShowMessage(),
            msgObj: message,
            onMessageRqSuc: onMessageRqSuc,
            onMessageRqFail: onMessageRqFail,
          )
        ],
      ),
    ];
    String time = _getMessageTime();
    var timeLabel = time.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  time,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: CommonColors.grayTextColor,
                  ),
                ))
              ],
            ),
          )
        : SizedBox();
    if (!isReversed) {
      children.add(timeLabel);
    } else {
      children.insert(0, timeLabel);
    }
    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: children,
      ),
    );
  }
}
