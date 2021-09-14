import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/utils/string_util.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

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
      : textDirection =
            msgObj.isSelf == true ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment = msgObj.isSelf == true
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        padding = msgObj.isSelf == true
            ? EdgeInsets.only(right: 12, left: 54)
            : EdgeInsets.only(left: 12, right: 54),
        super(key: key);

  reSendMsg(BuildContext context) async {
    V2TimValueCallback<V2TimMessage>? sendRes;
    switch (msgObj.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendTextMessage(
                text: msgObj.textElem?.text ?? '',
                receiver:
                    type == ConversationType.c2c ? msgObj.userID ?? '' : '',
                groupID:
                    type == ConversationType.group ? msgObj.groupID ?? '' : '');
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendCustomMessage(
                data: msgObj.customElem?.data ?? '',
                receiver:
                    type == ConversationType.c2c ? msgObj.userID ?? '' : '',
                groupID:
                    type == ConversationType.group ? msgObj.groupID ?? '' : '');
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendImageMessage(
                imagePath: msgObj.imageElem?.path ?? '',
                receiver:
                    type == ConversationType.c2c ? msgObj.userID ?? '' : '',
                groupID:
                    type == ConversationType.group ? msgObj.groupID ?? '' : '');
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        var d = await flutterSoundHelper.duration(msgObj.soundElem?.path ?? '');
        double _duration = d != null ? d.inMilliseconds / 1000.0 : 0.00;
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendSoundMessage(
              soundPath: msgObj.soundElem?.path ?? '',
              receiver: type == ConversationType.c2c ? msgObj.userID ?? '' : '',
              groupID:
                  type == ConversationType.group ? msgObj.groupID ?? '' : '',
              duration: _duration.ceil(),
            );
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendVideoMessage(
              videoFilePath: msgObj.videoElem?.videoPath ?? '',
              receiver: type == ConversationType.c2c ? msgObj.userID ?? '' : '',
              groupID:
                  type == ConversationType.group ? msgObj.groupID ?? '' : '',
              type: 'mp4',
              snapshotPath: msgObj.videoElem?.snapshotPath ?? '',
              onlineUserOnly: false,
              duration: msgObj.videoElem?.duration ?? 10,
            );
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendFileMessage(
                filePath: msgObj.fileElem?.path ?? '',
                fileName: msgObj.fileElem?.fileName ?? '',
                receiver:
                    type == ConversationType.c2c ? msgObj.userID ?? '' : '',
                groupID:
                    type == ConversationType.group ? msgObj.groupID ?? '' : '');
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendLocationMessage(
                desc: msgObj.locationElem?.desc ?? '',
                latitude: msgObj.locationElem?.latitude ?? 0,
                longitude: msgObj.locationElem?.longitude ?? 0,
                receiver:
                    type == ConversationType.c2c ? msgObj.userID ?? '' : '',
                groupID:
                    type == ConversationType.group ? msgObj.groupID ?? '' : '');
        break;
      case MessageElemType.V2TIM_ELEM_TYPE_FACE:
        sendRes = await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .sendFaceMessage(
                index: msgObj.faceElem?.index ?? 0,
                data: msgObj.faceElem?.data ?? '',
                receiver:
                    type == ConversationType.c2c ? msgObj.userID ?? '' : '',
                groupID:
                    type == ConversationType.group ? msgObj.groupID ?? '' : '');
        break;
    }

    if (sendRes?.code == 0) {
      String key = StringUtil.appendConversionType(
          msgObj.userID ?? msgObj.groupID ?? '', type);
      List<V2TimMessage> list = List.empty(growable: true);
      list.add(sendRes!.data!);
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, list);
    } else {
      Utils.toast("发送失败 ${sendRes?.code} ${sendRes?.desc}");
    }
  }

  Widget getHandleBar(BuildContext context) {
    Widget wid = new Container();

    if (msgObj.isSelf != null) {
      if (msgObj.status == MessageStatus.V2TIM_MSG_STATUS_SEND_FAIL) {
        wid = GestureDetector(
          child: Text(
            '发送失败，点击重新发送',
            style: TextStyle(color: CommonColors.redTextColor),
          ),
          onTap: () {
            reSendMsg(context);
          },
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
    return wid;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      type == ConversationType.group
          ? Row(
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
            )
          : SizedBox(),
      Container(
        margin: EdgeInsets.only(top: type == ConversationType.group ? 4 : 0),
        child: PhysicalModel(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: msgObj.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE ? 0 : 12.0, horizontal: msgObj.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE ? 0 : 16.0),
            decoration: BoxDecoration(
              color: msgObj.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE ? null : msgObj.isSelf == true
                  ? CommonColors.blueBgColor
                  : CommonColors.grayBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: msgObj.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE //图片
                ? ImageMessage(message: msgObj)
                : msgObj.elemType == MessageElemType.V2TIM_ELEM_TYPE_FACE //表情
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
                                : msgObj.elemType ==
                                        MessageElemType
                                            .V2TIM_ELEM_TYPE_TEXT //文字
                                    ? _textMessage()
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
                                                          ConversationType.c2c
                                                      ? hexToColor('171538')
                                                      : hexToColor('000000'),
                                                ),
                                              ),
          ),
        ),
      ),
      getHandleBar(context),
    ];
    return Expanded(
      child: Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      ),
    );
  }

  Widget _textMessage() {
    if (message.contains('_atMsgListJson: ')) {
      var showMessage = message.split('_atMsgListJson: ').first;
      List<String> spiltList = [];
      var temp = '';
      for (var i = 0; i < showMessage.length; i++) {
        if (temp.startsWith('@')) {
          if (showMessage[i] == ' ') {
            spiltList.add(temp + ' ');
            temp = '';
          } else if (showMessage[i] == '@') {
            spiltList.add(temp);
            temp = showMessage[i];
          } else {
            temp += showMessage[i];
          }
        } else {
          if (showMessage[i] == '@') {
            spiltList.add(temp);
            temp = showMessage[i];
          } else {
            temp += showMessage[i];
          }
        }
      }
      if (temp.isNotEmpty) {
        spiltList.add(temp);
      }
      return RichText(
          text: TextSpan(
              children: spiltList
                  .map((e) => TextSpan(
                      text: e,
                      style: TextStyle(
                          color: e.startsWith('@') && e.endsWith(' ')
                              ? Colors.blue
                              : hexToColor('171538'),
                          fontSize: 16)))
                  .toList()));
    } else {
      return Text(
        message,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 16,
          color: type == ConversationType.c2c
              ? hexToColor('171538')
              : hexToColor('000000'),
        ),
      );
    }
  }
}
