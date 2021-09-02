import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/avatar.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'msg_body.dart';

class SendMsg extends StatelessWidget {
  SendMsg(
      {Key? key,
      required this.message,
      this.onMessageRqSuc,
      this.onMessageRqFail})
      : super(key: key);
  final V2TimMessage message;
  final Function(Response response, V2TimMessage message)? onMessageRqSuc;
  final Function(DioError error)? onMessageRqFail;

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

  @override
  Widget build(BuildContext context) {
    if (message.msgID == null || message.msgID == '') {
      return Container();
    }
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
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
              width: 40,
              height: 40,
              radius: 4.8,
            ),
          ),
          MsgBody(
            type:
                message.isSelf! ? ConversationType.c2c : ConversationType.group,
            name: _getShowName(),
            message: _getShowMessage(),
            msgObj: message,
            onMessageRqSuc: onMessageRqSuc,
            onMessageRqFail: onMessageRqFail,
          ),
          Container(
            width: 52,
            height: 40,
          )
        ],
      ),
    );
  }
}
