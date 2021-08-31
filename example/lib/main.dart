import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/basic/widget.dart';
import 'package:flutter_tencent_im_ui/common/event_router.dart';
import 'package:flutter_tencent_im_ui/provider/conversion.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/provider/friend.dart';
import 'package:flutter_tencent_im_ui/provider/friendApplication.dart';
import 'package:flutter_tencent_im_ui/provider/groupApplication.dart';
import 'package:flutter_tencent_im_ui/provider/keybooad_show.dart';
import 'package:flutter_tencent_im_ui/provider/user.dart';
import 'package:provider/provider.dart';

import 'conversationInfo/conversationInfo.dart';
import 'login/login.dart';

// 应用初始化时就加在登录页

void main() {
  // 先设置状态栏样式
  SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  DynamicWidgetBuilder.registerSysWidgets();
  EventRouter.instance.rest = Dio();
  SystemChrome.setSystemUIOverlayStyle(style);
  // 看看有没有sessionID和token;如果有，直接登录了
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConversionModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => CurrentMessageListModel()),
        ChangeNotifierProvider(create: (_) => FriendListModel()),
        ChangeNotifierProvider(create: (_) => FriendApplicationModel()),
        ChangeNotifierProvider(create: (_) => GroupApplicationModel()),
        ChangeNotifierProvider(create: (_) => KeyBoradModel()),
      ],
      child: MaterialApp(
          initialRoute: LoginPage.routeName,
          onGenerateRoute: (setting) {
            if (setting.name == LoginPage.routeName) {
              return PageRouteBuilder(
                  settings: RouteSettings(
                      name: LoginPage.routeName),
                  pageBuilder: (_, __, ___) => LoginPage());
            }
          if ((setting.name ?? '') == ConversationInfo.routeName) {
            Map? arguments = setting.arguments as Map?;
            return PageRouteBuilder(
                settings: RouteSettings(
                    name: ConversationInfo.routeName),
                pageBuilder: (_, __, ___) => ConversationInfo(arguments?['id'] ?? '', arguments?['type'] ?? 0));
          }
          throw ('invalid routeName');
        },
      ),
    ),
  );
}
