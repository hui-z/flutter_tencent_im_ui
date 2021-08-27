import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/basic/widget.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/config/widget_config.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class CustomMessage extends StatefulWidget {
  CustomMessage(this.message);
  final V2TimMessage message;

  @override
  State<StatefulWidget> createState() => CustomMessageState();
}

class CustomMessageState extends State<CustomMessage> {
  V2TimMessage? message;
  @override
  void initState() {
    this.message = widget.message;
    super.initState();
  }

  Widget showMessage() {
    Widget? res;

    Map? data = json.decode(message?.customElem?.data ?? '');
    res = DynamicWidgetBuilder.buildWidget(DynamicWidgetConfig.fromJson(data ?? {}), context: context, event: (eventName) {
        if (eventName.contains('update')) {
          sendCustomData(context);
        }
    });
    return res ?? SizedBox();
  }

  sendCustomData(context) async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendCustomMessage(
      data: json.encode({
        'widget': 'Column',
        'action': 'update',
        'id': 1,
        'children': [
          {
            'widget': 'Text',
            'xVar': {
              'data': '再惠合同续约提醒',
              'style': {
                'color': 'FF000000',
                'fontWeight': 'bold',
                'fontSize': 16.0
              }
            },
          },
          {
            'widget': 'Row',
            'children': [
              {
                'widget': 'Text',
                'xVar': {
                  'data': '亲爱的商户',
                  'style': {'color': 'FF9E9E9E', 'fontSize': 14.0}
                }
              },
            ]
          },
          {
            'widget': 'Text',
            'xVar': {
              'data': '您与再惠合作的服务即将到期，请尽快沟通续约事宜',
              'style': {'color': 'FF9E9E9E', 'fontSize': 14.0}
            },
          },
          {
            'widget': 'Text',
            'xVar': {
              'data': '续约成功',
              'style': {'color': 'FF9E9E9E', 'fontSize': 16.0}
            },
          }
        ]
      }),
      receiver: message?.userID ?? '',
      groupID: message?.groupID ?? '',
    );
    if (res.code == 0) {
      String key = (message?.userID != null ? "c2c_${message?.userID}" : "group_${message?.groupID}");
      List<V2TimMessage> list = new List.empty(growable: true);
      V2TimMessage? msg = res.data;
      // 添加新消息

      list.add(msg!);

      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addMessage(key, list);
      } catch (err) {
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return Container(
        child: Text('null'),
      );
    }
    return showMessage();
  }
}