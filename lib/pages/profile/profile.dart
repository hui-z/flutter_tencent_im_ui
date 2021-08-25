import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/provider/user.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

import 'component/addFriendSetting.dart';
import 'component/blog.dart';
import 'component/buy.dart';
import 'component/contact.dart';
import 'component/exonerate.dart';
import 'component/listGap.dart';
import 'component/privacy.dart';
import 'component/profilePanel.dart';
import 'component/userSign.dart';

class Profile extends StatefulWidget {
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  int type = 0; // 0 1 2,0=>自己打开个人中心，1=>单聊资料卡，2=>群聊资料卡

  Widget build(BuildContext context) {
    V2TimUserFullInfo? info = Provider.of<UserModel>(context).info;
    // print("个人信息${info.toJson()}");
    if (info == null) {
      return Container();
    }

    return ListView(
      children: [
        ProfilePanel(info, true),
        ListGap(),
        UserSign(info),
        ListGap(),
        // if (type == 0) NewMessageSetting(info),
        if (type == 0) AddFriendSetting(info),
        if (type == 0) ListGap(),
        if (type == 0) Blog(),
        if (type == 0) Buy(),
        if (type == 0) ListGap(),
        Privacy(),
        Exonerate(),
        if (type == 0) ListGap(),
        if (type == 0) Contact(),
      ],
    );
  }
}
