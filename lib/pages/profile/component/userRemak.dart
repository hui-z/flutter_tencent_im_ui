import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/arrowRight.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/pages/profile/component/textWithCommonStyle.dart';
import 'package:flutter_tencent_im_ui/pages/userNick/userNick.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';

class UserRemark extends StatelessWidget {
  UserRemark(this.userInfo, this.getUserInfo);
  final V2TimFriendInfoResult? userInfo;
  final Function getUserInfo;
  getNickName() {
    if (userInfo!.friendInfo!.friendRemark == '' ||
        userInfo!.friendInfo!.friendRemark == null) {
      return '暂无备注';
    } else {
      return userInfo!.friendInfo!.friendRemark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return Container();
    }
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => UserNick(userInfo!, getUserInfo),
              ),
            );
          },
          child: Container(
            height: 55,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                TextWithCommonStyle(
                  text: '备注',
                ),
                Expanded(
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ArrowRight(),
                      Expanded(
                        child: Text(
                          getNickName(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: CommonColors.getTextWeakColor(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
