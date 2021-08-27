import 'dart:ui';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/provider/conversion.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/provider/friend.dart';
import 'package:flutter_tencent_im_ui/provider/friendApplication.dart';
import 'package:flutter_tencent_im_ui/provider/groupApplication.dart';
import 'package:flutter_tencent_im_ui/provider/user.dart';
import 'package:flutter_tencent_im_ui/tim_manager.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

import '../GenerateTestUserSig.dart';
import '../home/home.dart';

var timLogo = AssetImage("images/logo.png");

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isinit = false;
  String? oppoRegId;

  void initState() {
    super.initState();
    init();
  }

  init() async {
    await initSDK();
    setState(() {
      isinit = true;
    });
    await islogin();
    // await toHomePage();
    // await setOfflinepush();
  }

  offlinePushCallback(data) {
    if (data['name'] == 'onRegister') {
      if (data['responseCode'] == 0) {
        setState(() {
          oppoRegId = data['data'];
        });
        TencentImSDKPlugin.v2TIMManager
            .getOfflinePushManager()
            .setOfflinePushConfig(businessID: 7005, token: data['data'])
            .then((res) {
          if (res.code == 0) {
            Utils.toast("设置推送成功");
          } else {
            Utils.toast("设置推送失败${res.desc}");
          }
        }).catchError((err) {
          Utils.toast("设置推送失败$err");
          print("设置推送失败$err");
        });
      }
    }
  }


  islogin() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? token = prefs.getString("token");
    String? sessionId = prefs.getString("sessionId");
    String? phone = prefs.getString("phone");
    String? code = prefs.getString("code");

    if (token != null && sessionId != null && phone != null && code != null) {
      Dio dio = new Dio();
      Response response = await dio.get(
        "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms",
        queryParameters: {
          "phone": "86$phone",
          "method": "login",
          "sessionId": sessionId,
          "token": token,
          "code": code
        },
      );
      print(response);
      if (response.data['errorCode'] == 0) {
        //登录成功
        String userId = response.data['data']['userId'];
        String userSig = response.data['data']['userSig'];
        String avatar = response.data['data']['avatar'];

        V2TimCallback data = await TencentImSDKPlugin.v2TIMManager.login(
          userID: userId,
          userSig: userSig,
        );

        if (data.code != 0) {
          print('登录失败${data.desc}');
          setState(() {
            isinit = true;
          });
          return;
        } else {
          print("登录成功");
        }

        // await Tools.setOfflinepush(context);

        V2TimValueCallback<List<V2TimUserFullInfo>> infos =
            await TencentImSDKPlugin.v2TIMManager
                .getUsersInfo(userIDList: [userId]);
        if (infos.code == 0) {
          if (infos.data![0].nickName == null ||
              infos.data![0].faceUrl == null ||
              infos.data![0].nickName == '' ||
              infos.data![0].faceUrl == '') {
            await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
              userFullInfo: V2TimUserFullInfo.fromJson(
                {
                  "nickName": userId,
                  "faceUrl": avatar,
                },
              ),
            );
          }
          Provider.of<UserModel>(context, listen: false)
              .setInfo(infos.data![0]);
        } else {}
        try {
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) {
                return HomePage();
              },
            ),
          );
        } catch (err) {
          print(err);
        }
      } else {}
    } else {}
    setState(() {
      isinit = true;
    });
  }

  void onSelfInfoUpdated() async {
    //自己信息更新，从新获取自己的信息；
    V2TimValueCallback<String> usercallback =
        await TencentImSDKPlugin.v2TIMManager.getLoginUser();
    V2TimValueCallback<List<V2TimUserFullInfo>> infos = await TencentImSDKPlugin
        .v2TIMManager
        .getUsersInfo(userIDList: [usercallback.data!]);
    if (infos.code == 0) {
      Provider.of<UserModel>(context, listen: false).setInfo(infos.data![0]);
    }
  }

  void onKickedOffline() async {
// 被踢下线
    // 清除本地缓存，回到登录页TODO
    try {
      Provider.of<ConversionModel>(context, listen: false).clear();
      Provider.of<UserModel>(context, listen: false).clear();
      Provider.of<CurrentMessageListModel>(context, listen: false).clear();
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
    print("被踢下线了");
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
      ModalRoute.withName('/'),
    );
  }

  void onReceiveJoinApplicationonMemberEnter() async {
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.code == 0) {
        if (res.data!.groupApplicationList!.length > 0) {
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(res.data!.groupApplicationList);
        }
      }
    } else {
      print("获取加群申请失败${res.desc}");
    }
  }

  void onRecvNewMessage(V2TimMessage message) {
    try {
      List<V2TimMessage> messageList = List.empty(growable: true);

      messageList.add(message);

      print("c2c_${message.sender}");
      String key;
      if (message.groupID == null) {
        key = "c2c_${message.sender}";
      } else {
        key = "group_${message.groupID}";
      }
      print("conterkey_$key");
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, messageList);
    } catch (err) {
      print(err);
    }
  }

  void onRecvC2CReadReceipt(List<V2TimMessageReceipt> list) {
    print('收到了新消息 已读回执');
    list.forEach((element) {
      print("已读回执${element.userID} ${element.timestamp}");
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .updateC2CMessageByUserId(element.userID);
    });
  }

  void onSendMessageProgress(V2TimMessage message, int progress) {
// 消息进度
    String key;
    if (message.groupID == null) {
      key = "c2c_${message.userID}";
    } else {
      key = "group_${message.groupID}";
    }
    try {
      Provider.of<CurrentMessageListModel>(
        context,
        listen: false,
      ).addOneMessageIfNotExits(
        key,
        message,
      );
    } catch (err) {
      print("error $err");
    }
    print(
        "消息发送进度 $progress ${message.timestamp} ${message.msgID} ${message.timestamp} ${message.status}");
  }

  void
      onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo>? newList = friendRes.data;
      if (newList != null && newList.length > 0) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(newList);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(List.empty(growable: true));
      }
    }
  }

  void onFriendApplicationListAdded(List<V2TimFriendApplication> list) {
    // 收到加好友申请,添加双向好友时双方都会周到这个回调，这时要过滤掉type=2的不显示
    print("收到加好友申请");
    List<V2TimFriendApplication> newlist = List.empty(growable: true);
    list.forEach((element) {
      if (element.type != 2) {
        newlist.add(element);
      }
    });
    if (newlist.isNotEmpty) {
      Provider.of<FriendApplicationModel>(context, listen: false)
          .setFriendApplicationResult(newlist);
    }
  }

  Map<String, V2TimConversation> conversationlistToMap(
      List<V2TimConversation> list) {
    Map<int, V2TimConversation> convsersationMap = list.asMap();
    Map<String, V2TimConversation> newConversation = new Map();
    convsersationMap.forEach((key, value) {
      newConversation[value.conversationID] = value;
    });
    return newConversation;
  }

  initSDK() async {
    await TIMManager.instance.initSDK(
      sdkAppID: 1400563106,
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: new V2TimSDKListener(
        onConnectFailed: (code, error) {},
        onConnectSuccess: () {},
        onConnecting: () {},
        onKickedOffline: () {
          onKickedOffline();
        },
        onSelfInfoUpdated: (info) {
          onSelfInfoUpdated();
        },
        onUserSigExpired: () {},
      ),
    );

    print("initSDK");

    //简单监听
    TIMManager.instance.addSimpleMsgListener(
      listener: new V2TimSimpleMsgListener(
        onRecvC2CCustomMessage: (msgID, sender, customData) {},
        onRecvC2CTextMessage: (msgID, userInfo, text) {},
        onRecvGroupCustomMessage: (msgID, groupID, sender, customData) {},
        onRecvGroupTextMessage: (msgID, groupID, sender, customData) {},
      ),
    );

    //群组监听
    TIMManager.instance.setGroupListener(
      listener: new V2TimGroupListener(
        onApplicationProcessed: (groupID, opUser, isAgreeJoin, opReason) {},
        onGrantAdministrator: (groupID, opUser, memberList) {},
        onGroupAttributeChanged: (groupID, groupAttributeMap) {},
        onGroupCreated: (groupID) {},
        onGroupDismissed: (groupID, opUser) {},
        onGroupInfoChanged: (groupID, changeInfos) {},
        onGroupRecycled: (groupID, opUser) {},
        onMemberEnter: (groupID, memberList) {
          onReceiveJoinApplicationonMemberEnter();
        },
        onMemberInfoChanged: (groupID, v2TIMGroupMemberChangeInfoList) {},
        onMemberInvited: (groupID, opUser, memberList) {},
        onMemberKicked: (groupID, opUser, memberList) {},
        onMemberLeave: (groupID, member) {},
        onQuitFromGroup: (groupID) {},
        onReceiveJoinApplication: (groupID, member, opReason) {
          onReceiveJoinApplicationonMemberEnter();
        },
        onReceiveRESTCustomData: (groupID, customData) {},
        onRevokeAdministrator: (groupID, opUser, memberList) {},
      ),
    );
    //高级消息监听
    TIMManager.instance.getMessageManager().addAdvancedMsgListener(
          listener: new V2TimAdvancedMsgListener(
            onRecvC2CReadReceipt: (receiptList) {
              onRecvC2CReadReceipt(receiptList);
            },
            onRecvMessageRevoked: (msgID) {},
            onRecvNewMessage: (msg) {
              onRecvNewMessage(msg);
            },
            onSendMessageProgress: (message, progress) {
              onSendMessageProgress(message, progress);
            },
          ),
        );

    TIMManager.instance.getFriendshipManager().setFriendListener(
          listener: new V2TimFriendshipListener(
            onBlackListAdd: (infoList) {},
            onBlackListDeleted: (userList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendApplicationListAdded: (applicationList) {
              onFriendApplicationListAdded(applicationList);
            },
            onFriendApplicationListDeleted: (userIDList) {},
            onFriendApplicationListRead: () {},
            onFriendInfoChanged: (infoList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendListAdded: (users) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
            onFriendListDeleted: (userList) {
              onFriendListAddedonFriendListDeletedonFriendInfoChangedonBlackListDeleted();
            },
          ),
        );
    //会话监听
    TIMManager.instance.getConversationManager().setConversationListener(
          listener: new V2TimConversationListener(
            onConversationChanged: (conversationList) {
              try {
                Provider.of<ConversionModel>(context, listen: false)
                    .setConversionList(conversationList);
                //如果当前会话在使用中，也更新一下

              } catch (e) {}
            },
            onNewConversation: (conversationList) {
              try {
                Provider.of<ConversionModel>(context, listen: false)
                    .setConversionList(conversationList);
                //如果当前会话在使用中，也更新一下

              } catch (e) {}
            },
            onSyncServerFailed: () {},
            onSyncServerFinish: () {},
            onSyncServerStart: () {},
          ),
        );
    TIMManager.instance.getSignalingManager().addSignalingListener(
          listener: new V2TimSignalingListener(
            onInvitationCancelled: (inviteID, inviter, data) {},
            onInvitationTimeout: (inviteID, inviteeList) {},
            onInviteeAccepted: (inviteID, invitee, data) {},
            onInviteeRejected: (inviteID, invitee, data) {},
            onReceiveNewInvitation:
                (inviteID, inviter, groupID, inviteeList, data) {},
          ),
        );
    print("初始化完成了");
  }

  @override
  Widget build(BuildContext context) {
    return (!isinit) ? new WaitHomeWidget() : new HomeWidget();
  }
}

class WaitHomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WaitHomeWidgetState();
}

class WaitHomeWidgetState extends State<WaitHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new AppLayout(),
    );
  }
}

class AppLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppLogo(),
        Expanded(
          child: LoginForm(),
        )
      ],
    );
  }
}

class AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192.0,
      color: CommonColors.getThemeColor(),
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        top: 108.0,
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 90,
            width: 90,
            child: Image(
              image: timLogo,
              width: 90.0,
              height: 90.0,
            ),
          ),
          Container(
            height: 90.0,
            padding: EdgeInsets.only(
              top: 10,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  '登录·即时通信',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 28,
                  ),
                ),
                Text(
                  '体验群组聊天，音视频对话等IM功能',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 12,
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          )
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  void initState() {
    super.initState();
    this.setTel();
  }

  bool isGeted = false;
  String tel = '';
  String pwd = '';
  String token = '';
  String sessionId = '';
  bool checkboxSelected = false;
  TextEditingController userSigEtController = TextEditingController();
  TextEditingController telEtController = TextEditingController();
  void getHttp() async {
    try {
      Response response = await Dio().get(
        "https://service-qr8jjnpm-1256635546.gz.apigw.tencentcs.com/release/getUserSig?userId=xingchenhe",
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }

  setTel() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await _prefs;
    String? userId = prefs.getString("flutter_userID") != null
        ? prefs.getString("flutter_userID")
        : "";
    telEtController.value = new TextEditingValue(
      text: userId!,
    );
    setState(() {
      tel = userId;
    });
  }

  unSelectedPrivacy() {
    Utils.toast("需要同意隐私与用户协议");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Form(
        child: Column(
          children: [
            TextField(
              autofocus: false,
              controller: telEtController,
              decoration: InputDecoration(
                labelText: "用户名",
                hintText: "请输入用户名",
                icon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                setState(() {
                  tel = v;
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(
                top: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      unselectedWidgetColor: Colors.grey,
                    ),
                    child: Checkbox(
                      value: checkboxSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          checkboxSelected = value!;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 300,
                    child: Text.rich(
                      TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                                text: "我已阅读并同意",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "<<隐私协议>>",
                                style: TextStyle(
                                  color: Color.fromRGBO(0, 110, 253, 1),
                                ),),
                            TextSpan(
                                text: "和",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text: "<<用户协议>>",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 110, 253, 1),
                              ),
                            ),
                            TextSpan(
                              text: "，并授权腾讯云使用该IM账号（昵称、头像、电话号码）进行统一管理",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ]),
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.clip,
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 28,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text("登录"),
                      onPressed: !checkboxSelected // 需要隐私协议勾选才可以登陆
                          ? () => unSelectedPrivacy()
                          : () async {
                              print("Confhhh,$tel");
                              if (tel == '') {
                                return;
                              }

                              /*  这段代码是当你不需要手机验证码时使用(打包生产)  */
                              /*productEnv这个是为了tencent内部打包时可以直接打包手机验证登陆, 只在登陆方式这里使用，*/

                              // 不时生产环境走，自己测试即不需要手机验证即可登陆
                              GenerateTestUserSig usersig =
                              new GenerateTestUserSig(
                                sdkappid: 1400563106,
                                key: 'ad21af71cf910d1426a59ee9d3c27040220ee7c7d5d745ae871c531ad56754a4',
                              );
                              String pwdStr = usersig.genSig(
                                  identifier: tel, expire: 86400);
                              TIMManager.instance
                                  .login(
                                userID: tel,
                                userSig: pwdStr,
                              )
                                  .then((res) async {
                                if (res.code == 0) {
                                  V2TimValueCallback<List<V2TimUserFullInfo>>
                                  infos = await TencentImSDKPlugin
                                      .v2TIMManager
                                      .getUsersInfo(userIDList: [tel]);

                                  if (infos.code == 0) {
                                    Provider.of<UserModel>(context,
                                        listen: false)
                                        .setInfo(infos.data![0]);
                                  }
                                  Future<SharedPreferences> _prefs =
                                  SharedPreferences.getInstance();
                                  SharedPreferences prefs = await _prefs;

                                  prefs.setString("flutter_userID", tel);

                                  // 加个群
                                  await TencentImSDKPlugin.v2TIMManager
                                      .joinGroup(
                                    groupID: "@TGS#2FGN3DHHB",
                                    message: "大家好",
                                  );
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => HomePage(),
                                    ),
                                  );
                                } else {
                                  Utils.toast("${res.code} ${res.desc}");
                                }
                              });

                              userSigEtController.clear();
                              telEtController.clear();
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}