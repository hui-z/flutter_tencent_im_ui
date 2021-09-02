import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/basic/widget.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/config/widget_config.dart';
import 'package:flutter_tencent_im_ui/common/event_router.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class CustomMessage extends StatefulWidget {
  CustomMessage(
      {Key? key,
      required this.message,
      this.onMessageRqSuc,
      this.onMessageRqFail})
      : super(key: key);
  final V2TimMessage message;
  final Function(Response response, V2TimMessage message)? onMessageRqSuc;
  final Function(DioError error)? onMessageRqFail;

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
    res = DynamicWidgetBuilder.buildWidget(
        DynamicWidgetConfig.fromJson(data ?? {}),
        context: context, event: (eventInfo) {
      EventRouter.handleEvent(eventInfo, context, (response) {
        if (widget.onMessageRqSuc != null) {
          widget.onMessageRqSuc!(response, widget.message);
        }
      }, widget.onMessageRqFail);
    });
    return res ?? SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return Container();
    }
    return showMessage();
  }
}
