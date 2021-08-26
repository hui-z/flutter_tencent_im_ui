import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/pages/conversationInfo/conversationInfo.dart';
import 'package:flutter_tencent_im_ui/pages/userProfile/userProfile.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

import 'component/addFaceMsg.dart';
import 'component/conversationInner.dart';
import 'component/more_send_function.dart';
import 'component/msgInput.dart';

class Conversion extends StatefulWidget {
  Conversion(this.conversationID);
  final String conversationID;
  @override
  State<StatefulWidget> createState() => ConversionState(conversationID);
}

class ConversionState extends State<Conversion> {
  String conversationID;
  int type = 1;
  String lastMessageId = '';
  String? userID;
  String? groupID;
  List<V2TimMessage> msgList = List.empty(growable: true);

  Icon? rightTopIcon;
  bool isReverse = true;
  bool recordBackStatus = true; // 录音键按下时无法返回
  List<V2TimMessage> currentMessageList = List.empty(growable: true);
  ConversionState(this.conversationID);
  double? keyboardHeight;
  bool _isShowBottomView = false;
  Widget? bottomView;
  final _picker = ImagePicker();

  void initState() {
    super.initState();

    getConversion();
  }

  openProfile(context) {
    String? id = type == 1 ? userID : groupID;
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) =>
        type == 1 ? UserProfile(id!) : ConversationInfo(id!, type),
      ),
    );
  }

  getConversion() async {
    V2TimValueCallback<V2TimConversation> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    late String? _msgID;
    late int _type;
    late String? _groupID;
    late String? _userID;
    if (data.code == 0) {
      print("!!!${data.data!.lastMessage == null}");
      if (data.data!.lastMessage == null)
        _msgID = "";
      else
        _msgID = data.data!.lastMessage!.msgID!;
      _type = data.data!.type!;
      _groupID = data.data!.groupID == null ? "" : data.data!.groupID;
      _userID = data.data!.userID == null ? "" : data.data!.userID;
      print("_type $_type");
      print('_userID $_userID');
      print('_groupID $_groupID');
      setState(() {
        type = _type;
        lastMessageId = _msgID!;
        groupID = _groupID;
        userID = _userID;
        rightTopIcon = _type == 1
            ? Icon(
          Icons.account_box,
          color: CommonColors.getWitheColor(),
        )
            : Icon(
          Icons.supervisor_account,
          color: CommonColors.getWitheColor(),
        );
      });
    }

    //判断会话类型，c2c or group

    if (_type == 1) {
      // c2c
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(
        userID: _userID == null ? "" : _userID,
        count: 100,
      )
          .then((listRes) {
        if (listRes.code == 0) {
          List<V2TimMessage> list = listRes.data!;
          if (list.length == 0) {
            print('没有消息啊！！！');
            list = List.empty(growable: true);
          }
          print("conversationID $conversationID 消息数量 ${listRes.data!.length}");
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(conversationID, list);
        } else {
          print('conversationID 获取历史消息失败 ${listRes.desc}');
        }
      });
    } else if (_type == 2) {
      // group
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getGroupHistoryMessageList(
        groupID: _groupID == null ? "" : _groupID,
        count: 100,
      )
          .then((listRes) {
        if (listRes.code == 0) {
          print(
              "conversationID listRes.data ${listRes.data!.length} $_groupID ");
          List<V2TimMessage> list = listRes.data!;
          if (list.length == 0) {
            print('conversationID 没有消息啊！！！');
            list = List.empty(growable: true);
          } else {
            Provider.of<CurrentMessageListModel>(context, listen: false)
                .addMessage(conversationID, list);
          }
          print("conversationID $conversationID 消息数量 ${listRes.data!.length}");
        } else {
          print('conversationID 获取历史消息失败');
        }
      });
    }
  }

  void setRecordBackStatus(bool status) {
    setState(() {
      recordBackStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => recordBackStatus,
        child: Scaffold(
            resizeToAvoidBottomInset: !_isShowBottomView,
            appBar: AppBar(
              title: Text("会话"),
              backgroundColor: CommonColors.getThemeColor(),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.account_box,
                    color: CommonColors.getWitheColor(),
                  ),
                  onPressed: () {
                    if (recordBackStatus) {
                      openProfile(context);
                    }
                  },
                )
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        child: ConversationInner(
                            conversationID, type, userID, groupID, () {
                          if (_isShowBottomView) {
                            setState(() {
                              _isShowBottomView = false;
                            });
                          }
                        }),
                        onTap: () {
                          if (MediaQuery.of(context).viewInsets.bottom >= 50) {
                            if (keyboardHeight == null) {
                              keyboardHeight =
                                  MediaQuery.of(context).viewInsets.bottom;
                            }
                            FocusScope.of(context).requestFocus(FocusNode());
                          }
                          if (_isShowBottomView) {
                            setState(() {
                              _isShowBottomView = false;
                            });
                          }
                        },
                      ),
                    ),
                    type == 0
                        ? Container()
                        : Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Center(
                        child: MsgInput(
                            type == 1 ? userID! : groupID!,
                            type,
                            recordBackStatus,
                            setRecordBackStatus, () {
                          FocusScope.of(context)
                              .requestFocus(FocusNode());
                          bottomView = MoreSendFunction(
                            toUser: type == 1 ? userID! : groupID!,
                            type: type,
                            picker: _picker,
                            height: keyboardHeight ?? 301,
                          );
                          setState(() {
                            _isShowBottomView = true;
                          });
                        }, () {
                          FocusScope.of(context)
                              .requestFocus(FocusNode());
                          bottomView = FaceMsg(
                              type == 1 ? userID! : groupID!,
                              type,
                              keyboardHeight ?? 301);
                          setState(() {
                            _isShowBottomView = true;
                          });
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                          height: _isShowBottomView
                              ? keyboardHeight ?? 301
                              : MediaQuery.of(context).padding.bottom),
                    )
                  ],
                ),
                _isShowBottomView
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Column(
                      children: [bottomView ?? SizedBox(),],
                    )

                  ],
                )
                    : SizedBox()
              ],
            )));
  }
}
