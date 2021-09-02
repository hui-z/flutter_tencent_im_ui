import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

import 'system_message.dart';
import 'custom_message.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'sound_message.dart';
import 'video_message.dart';

class MsgBody extends StatelessWidget {
  final TextDirection textDirection;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final EdgeInsetsGeometry padding;
  final int type;
  final String name;
  final String message;
  final V2TimMessage msgObj;
  final Function(Response response, V2TimMessage message)? onMessageRqSuc;
  final Function(DioError error)? onMessageRqFail;

  MsgBody(
      {Key? key,
      required this.message,
      required this.type,
      required this.name,
      required this.msgObj,
      this.textAlign = TextAlign.left,
      this.onMessageRqSuc,
      this.onMessageRqFail})
      : textDirection = type == ConversationType.c2c
            ? TextDirection.rtl
            : TextDirection.ltr,
        crossAxisAlignment = type == ConversationType.c2c
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        padding = type == ConversationType.c2c
            ? EdgeInsets.only(
                right: 12,
              )
            : EdgeInsets.only(
                left: 12,
              ),
        super(key: key);

  String getMessageTime() {
    String time = '';
    int timestamp = msgObj.timestamp! * 1000;
    DateTime timeDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateTime now = DateTime.now();

    if (now.day == timeDate.day) {
      time =
          "${timeDate.hour.toString().padLeft(2, '0')}:${timeDate.minute.toString().padLeft(2, '0')}:${timeDate.second.toString().padLeft(2, '0')}";
    } else {
      time =
          "${timeDate.month.toString().padLeft(2, '0')}-${timeDate.day.toString().padLeft(2, '0')} ${timeDate.hour.toString().padLeft(2, '0')}:${timeDate.minute.toString().padLeft(2, '0')}:${timeDate.second.toString().padLeft(2, '0')}";
    }
    return time;
  }

  Widget getHandleBar() {
    Widget wid = new Container();

    if (msgObj.isSelf != null) {
      if (msgObj.status == MessageStatus.V2TIM_MSG_STATUS_SEND_SUCC) {
        if (msgObj.isPeerRead != null && (msgObj.groupID == '')) {
          //c2c消息已读
          wid = Text(
            "已读",
            style: TextStyle(
              fontSize: 10,
              color: CommonColors.getTextWeakColor(),
            ),
          );
        }
        if (msgObj.isPeerRead == false &&
            (msgObj.groupID == null || msgObj.groupID == '')) {
          //c2c未读
          wid = Text(
            "未读",
            style: TextStyle(
              fontSize: 10,
              color: CommonColors.getThemeColor(),
            ),
          );
        }
      }
      if (msgObj.status == MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL) {
        wid = Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              size: 14,
              color: CommonColors.getReadColor(),
            ),
            Text(
              "发送失败",
              style: TextStyle(
                fontSize: 10,
                color: CommonColors.getReadColor(),
                height: 1.4,
              ),
            ),
          ],
        );
      }
      if (msgObj.status == MessageStatus.V2TIM_MSG_STATUS_SENDING) {
        wid = Text(
          "发送中...",
          style: TextStyle(
            fontSize: 10,
            color: CommonColors.getThemeColor(),
          ),
        );
      }
    }
    // 非自己消息不作处理
    return wid;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Row(
              textDirection: textDirection,
              children: [
                Text(
                  name,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: 12,
                    color: CommonColors.getTextWeakColor(),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 4),
              child: PhysicalModel(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: type == ConversationType.c2c
                        ? hexToColor('006eff').withOpacity(0.1)
                        : hexToColor('f8f8f8').withOpacity(1),
                    border: Border.all(
                      width: 0.5,
                      style: BorderStyle.solid,
                      color: type == ConversationType.c2c
                          ? hexToColor('006eff').withOpacity(0.3)
                          : hexToColor('e8e8e8').withOpacity(1),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: msgObj.elemType ==
                          MessageElemType.V2TIM_ELEM_TYPE_IMAGE //图片
                      ? ImageMessage(message: msgObj)
                      : msgObj.elemType ==
                              MessageElemType.V2TIM_ELEM_TYPE_FACE //表情
                          ? Container(
                              child: Text("表情 ${msgObj.faceElem!.data}"),
                            )
                          : msgObj.elemType ==
                                  MessageElemType.V2TIM_ELEM_TYPE_SOUND //语音
                              ? SoundMessage(msgObj)
                              : msgObj.elemType ==
                                      MessageElemType.V2TIM_ELEM_TYPE_VIDEO //视频
                                  ? VideoMessage(msgObj)
                                  : msgObj.elemType ==
                                          MessageElemType
                                              .V2TIM_ELEM_TYPE_CUSTOM //自定义消息
                                      ? CustomMessage(
                                          message: msgObj,
                                          onMessageRqSuc: onMessageRqSuc,
                                          onMessageRqFail: onMessageRqFail)
                                      : msgObj.elemType == 1 //文字
                                          ? Text(
                                              message,
                                              textAlign: textAlign,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    type == ConversationType.c2c
                                                        ? hexToColor('171538')
                                                        : hexToColor('000000'),
                                              ),
                                            )
                                          : msgObj.elemType ==
                                                  MessageElemType
                                                      .V2TIM_ELEM_TYPE_GROUP_TIPS //系统消息
                                              ? SystemMessage(msgObj)
                                              : msgObj.elemType ==
                                                      MessageElemType
                                                          .V2TIM_ELEM_TYPE_FILE //文件消息
                                                  ? FileMessage(message: msgObj)
                                                  : Text(
                                                      "未解析消息${msgObj.elemType}",
                                                      textAlign: textAlign,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: type ==
                                                                ConversationType
                                                                    .c2c
                                                            ? hexToColor(
                                                                '171538')
                                                            : hexToColor(
                                                                '000000'),
                                                      ),
                                                    ),
                ),
              ),
            ),
            getHandleBar(),
            Row(
              children: [
                Expanded(
                    child: Text(
                  getMessageTime(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: CommonColors.getTextWeakColor(),
                    height: 1.6,
                  ),
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
