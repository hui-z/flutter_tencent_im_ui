import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/config/event_name.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageType {
  static const String update = 'update';
}

class EventRouter {
  static EventRouter get instance => _getInstance();

  static EventRouter? _instance;

  static EventRouter _getInstance() {
    if (_instance == null) {
      _instance = EventRouter();
    }
    return _instance!;
  }

  Dio? rest;

  static handleEvent(
      EventInfo event,
      BuildContext context,
      Function(Response response)? onSuc,
      Function(DioError error)? onFail) async {
    if (event.action == EventAction.push && event.page != null) {
      Navigator.pushNamed(context, event.page!, arguments: event.arguments);
    } else if (event.action == EventAction.openUrl && event.url != null) {
      launch(event.url!, enableJavaScript: true, enableDomStorage: true);
    } else if (event.action == EventAction.request && event.method != null) {
      try {
        Response? response;
        if (event.path != null) {
          switch (event.method) {
            case 'get':
              response = await EventRouter.instance.rest?.get(event.path!,
                  queryParameters:
                      event.queryParameters as Map<String, dynamic>?);
              break;
            case 'post':
              response = await EventRouter.instance.rest?.post(event.path!,
                  queryParameters:
                      event.queryParameters as Map<String, dynamic>?,
                  data: event.bodyData);
              break;
            case 'put':
              response = await EventRouter.instance.rest?.put(event.path!,
                  queryParameters:
                      event.queryParameters as Map<String, dynamic>?,
                  data: event.bodyData);
              break;
            case 'patch':
              response = await EventRouter.instance.rest?.patch(event.path!,
                  queryParameters:
                      event.queryParameters as Map<String, dynamic>?,
                  data: event.bodyData);
              break;
            case 'delete':
              response = await EventRouter.instance.rest?.delete(event.path!,
                  queryParameters:
                      event.queryParameters as Map<String, dynamic>?,
                  data: event.bodyData);
              break;
          }
        } else if (event.url != null) {
          var uri = Uri.parse(event.url!);
          switch (event.method) {
            case 'get':
              response = await EventRouter.instance.rest?.getUri(uri);
              break;
            case 'post':
              response = await EventRouter.instance.rest
                  ?.postUri(uri, data: event.bodyData);
              break;
            case 'put':
              response = await EventRouter.instance.rest
                  ?.putUri(uri, data: event.bodyData);
              break;
            case 'patch':
              response = await EventRouter.instance.rest
                  ?.patchUri(uri, data: event.bodyData);
              break;
            case 'delete':
              response = await EventRouter.instance.rest
                  ?.deleteUri(uri, data: event.bodyData);
              break;
          }
        }
        if (onSuc != null && response != null) {
          onSuc(response);
        }
      } on DioError catch (error) {
        if (onFail != null) {
          onFail(error);
        }
      }
    }
  }
}
