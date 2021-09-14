import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:flutter_tencent_im_ui/common/images.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/utils/string_util.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class AdvanceMsg extends StatefulWidget {
  AdvanceMsg(
      {Key? key,
      required this.toUser,
      required this.type,
      this.sendText,
      required this.sendTextMsgSuc,
      required this.moreBtnClick})
      : super(key: key);
  final String? sendText;
  final String toUser;
  final int type;
  final VoidCallback sendTextMsgSuc;
  final VoidCallback moreBtnClick;

  @override
  AdvanceMsgState createState() => AdvanceMsgState();
}

class AdvanceMsgState extends State<AdvanceMsg> {
  final picker = ImagePicker();
  String? sendText;
  @override
  void initState() {
    sendText = widget.sendText;
    super.initState();
  }

  void updateSendButtonStatus(String? text) {
    setState(() {
      sendText = text;
    });
  }

  sendTextMsg(context) async {
    if (sendText == '' || sendText == null) {
      return;
    }
    V2TimValueCallback<V2TimMessage> sendRes;
    if (widget.type == ConversationType.c2c) {
      sendRes = await TencentImSDKPlugin.v2TIMManager
          .sendC2CTextMessage(text: sendText!, userID: widget.toUser);
    } else {
      sendRes = await TencentImSDKPlugin.v2TIMManager.sendGroupTextMessage(
          text: sendText!, groupID: widget.toUser, priority: 1);
    }

    if (sendRes.code == 0) {
      String key = StringUtil.appendConversionType(widget.toUser, widget.type);
      List<V2TimMessage> list = List.empty(growable: true);
      list.add(sendRes.data!);
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, list);
      widget.sendTextMsgSuc();
      updateSendButtonStatus(null);
    } else {
      Utils.toast("发送失败 ${sendRes.code} ${sendRes.desc}");
    }
  }

  Widget build(BuildContext context) {
    return sendText == null || sendText == ''
        ? InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                  child: Image(
                      image: assetImage('images/icon_add.png'),
                      width: 36,
                      height: 36)),
            ),
            onTap: widget.moreBtnClick,
          )
        : Container(
            padding: EdgeInsets.only(right: 12),
            width: 60,
            height: 30,
            child: CupertinoButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () {
                  sendTextMsg(context);
                },
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                color: CommonColors.getGreenColor(),
                child: Text('发送',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
          );
  }
}
