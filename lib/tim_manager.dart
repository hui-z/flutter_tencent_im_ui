
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

import 'provider/conversion.dart';
import 'provider/currentMessageList.dart';
import 'provider/friend.dart';
import 'provider/friendApplication.dart';
import 'provider/groupApplication.dart';
import 'provider/user.dart';

class TIMManager {

 static V2TIMManager get instance => _getInstance();

 static V2TIMManager? _instance;

 static V2TIMManager _getInstance()  {
   if (_instance == null) {
     _instance = TencentImSDKPlugin.v2TIMManager;
   }
   return _instance!;
 }

 void initSDK({required sdkAppID, required int loglevel, required V2TimSDKListener listener}) async {
   await instance.initSDK(sdkAppID: sdkAppID, loglevel: loglevel, listener: listener);
 }

 void logout(BuildContext context, VoidCallback? result) async {
   V2TimCallback res = await instance.logout();
   if (res.code == 0) {
     try {
       Provider.of<ConversionModel>(context, listen: false).clear();
       Provider.of<UserModel>(context, listen: false).clear();
       Provider.of<CurrentMessageListModel>(context, listen: false)
           .clear();
       Provider.of<FriendListModel>(context, listen: false).clear();
       Provider.of<FriendApplicationModel>(context, listen: false).clear();
       Provider.of<GroupApplicationModel>(context, listen: false).clear();
       // 去掉存的一些数据
       Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
       SharedPreferences prefs = await _prefs;
       prefs.remove('token');
       prefs.remove('sessionId');
       prefs.remove('phone');
       prefs.remove('code');
     } catch (err) {
       print("someError");
       print(err);
     }
     if (result != null) {
       result();
     }
   }
 }
}