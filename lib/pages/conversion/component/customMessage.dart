import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/basic/widget.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/config/widget_config.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

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

    });
    return res ?? SizedBox();
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