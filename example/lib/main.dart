import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dynamic_widgets/dynamic_widgets/basic/widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tencent_im_ui/provider/conversion.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/provider/friend.dart';
import 'package:flutter_tencent_im_ui/provider/friendApplication.dart';
import 'package:flutter_tencent_im_ui/provider/groupApplication.dart';
import 'package:flutter_tencent_im_ui/provider/keybooad_show.dart';
import 'package:flutter_tencent_im_ui/provider/user.dart';
import 'package:provider/provider.dart';

import 'login/login.dart';

// 应用初始化时就加在登录页

void main() {
  // 先设置状态栏样式
  SystemUiOverlayStyle style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  );
  DynamicWidgetBuilder.registerSysWidgets();
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
        home: LoginPage(),
        builder: EasyLoading.init(),
      ),
    ),
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class CustomAnimation extends EasyLoadingAnimation {
  CustomAnimation();

  @override
  Widget buildWidget(
      Widget child,
      AnimationController controller,
      AlignmentGeometry alignment,
      ) {
    return Opacity(
      opacity: controller.value,
      child: RotationTransition(
        turns: controller,
        child: child,
      ),
    );
  }
}
