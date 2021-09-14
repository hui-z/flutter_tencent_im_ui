import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_widgets/custom_widget/check_list.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:flutter_tencent_im_ui/common/images.dart';
import 'package:flutter_tencent_im_ui/models/AtMessageModel.dart';
import 'package:flutter_tencent_im_ui/provider/user.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SelectMembers extends StatefulWidget {
  const SelectMembers({Key? key, required this.type, this.groupId, this.toUser})
      : super(key: key);
  final int type;
  final String? groupId;
  final String? toUser;

  @override
  _SelectMembersState createState() => _SelectMembersState();
}

class _SelectMembersState extends State<SelectMembers> {
  Color _titleColor = hexToColor('1E1E1E');

  bool _isMultipleSelected = false;
  String _nextSeq = '0';
  List<V2TimGroupMemberFullInfo?>? _memberInfoList;
  late bool _isLoadMore;
  List<V2TimUserFullInfo>? _userList;
  late bool _isC2C;
  final ScrollController _scrollController = ScrollController();
  List<CheckListData> _checkedData = [];

  @override
  void initState() {
    super.initState();
    _isC2C = widget.type == ConversationType.c2c;
    _isLoadMore = !_isC2C;
    if (_isC2C) {
      getUsersInfo();
    } else {
      getGroupMembersInfo();
    }
    if (_isLoadMore) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 44) {
          if (_isLoadMore) {
            getGroupMembersInfo();
          }
        }
      });
    }
  }

  void getGroupMembersInfo() async {
    V2TimValueCallback<V2TimGroupMemberInfoResult> list =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: widget.groupId ?? '',
              filter: GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL,
              nextSeq: _nextSeq, //第一次从0开始拉
            );
    if (list.code == 0) {
      setState(() {
        _memberInfoList = list.data?.memberInfoList;
        _nextSeq = list.data?.nextSeq ?? '0';
        _isLoadMore = _nextSeq != '0';
      });
    } else {
      Utils.toast("获取群成员信息失败 ${list.code} ${list.desc}");
    }
  }

  void getUsersInfo() async {
    V2TimUserFullInfo? userInfo =
        Provider.of<UserModel>(context, listen: false).info;
    V2TimValueCallback<List<V2TimUserFullInfo>> list =
        await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
            userIDList: [widget.toUser ?? '', userInfo?.userID ?? '']);
    if (list.code == 0) {
      setState(() {
        _userList = list.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQueryData.fromWindow(window).padding;
    return Padding(
      padding: padding,
      child: GestureDetector(
        child: Column(
          children: [
            _buildTitleBar(),
            // _buildSearchBar(),
            Expanded(child: _buildMemberList())
          ],
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
      ),
    );
  }

  Widget _buildTitleBar() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          child: IconButton(
              icon: Icon(
                Icons.close,
                size: 25,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        Expanded(
            child: Center(
          child: Text(
            '选择成员',
            style: TextStyle(
              color: _titleColor,
              fontSize: 20,
            ),
          ),
        )),
        InkWell(
          child: Container(
            padding: EdgeInsets.only(right: 16.0, top: 12, bottom: 12),
            width: 80,
            height: 44,
            child: Text(
              _isMultipleSelected
                  ? _checkedData.isEmpty
                      ? '单选'
                      : '确定(${_checkedData.length})'
                  : '多选',
              style: TextStyle(color: _titleColor, fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
          onTap: () {
            if (_checkedData.isEmpty) {
              setState(() {
                _isMultipleSelected = !_isMultipleSelected;
              });
            } else {
              List<AtMessageModel> result = [];
              if (_isC2C) {
                result = _checkedData.map((e) {
                  var member = _userList?[int.parse(e.id)];
                  return AtMessageModel(
                      userID: member?.userID, nickName: member?.nickName);
                }).toList();
              } else {
                result = _checkedData.map((e) {
                  var member = _memberInfoList?[int.parse(e.id)];
                  return AtMessageModel(
                      userID: member?.userID, nickName: member?.nickName);
                }).toList();
              }
              Navigator.pop(context, result);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: hexToColor('DEE4EC'), borderRadius: BorderRadius.circular(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(
                Icons.search,
                size: 25,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          Expanded(
            flex: 1,
            child: TextField(
              onChanged: (text) {},
              style: TextStyle(fontSize: 14, color: hexToColor('1E1E1E')),
              decoration: InputDecoration(
                  hintText: '搜索',
                  hintStyle: TextStyle(
                    color: hexToColor('8E8E8E'),
                    fontSize: 14,
                  ),
                  border: InputBorder.none),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList() {
    var memberCount =
        (_isC2C ? _userList?.length : _memberInfoList?.length) ?? 0;
    return ListView.separated(
        controller: _scrollController,
        itemBuilder: _buildMemberItem,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            indent: 68,
          );
        },
        itemCount: memberCount +
            (_isC2C || _isMultipleSelected ? 0 : 1) +
            (_isLoadMore ? 1 : 0));
  }

  Widget _buildMemberItem(BuildContext context, int index) {
    var memberCount =
        (_isC2C ? _userList?.length : _memberInfoList?.length) ?? 0;
    var isShowAll = !_isC2C && !_isMultipleSelected;
    if (_isLoadMore && index == memberCount + (isShowAll ? 1 : 0)) {
      return Container(
        height: 44,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    var dataIndex = !_isC2C && !_isMultipleSelected ? index - 1 : index;
    String? nickName;
    String? faceUrl;
    String? userId;
    if (isShowAll && index == 0) {
      nickName = '所有人';
      userId = '所有人';
    } else if (_isC2C) {
      userId = _userList?[dataIndex].userID;
      nickName = _userList?[dataIndex].nickName ?? userId;
      faceUrl = _userList?[dataIndex].faceUrl;
    } else {
      userId = _memberInfoList?[dataIndex]?.userID;
      nickName = _memberInfoList?[dataIndex]?.nickName ?? userId;
      faceUrl = _memberInfoList?[dataIndex]?.faceUrl;
    }
    var item = Container(
      height: 60,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ClipOval(
                child: faceUrl == null || faceUrl.isEmpty
                    ? Image(
                        image: assetImage('images/person.png'),
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36)
                    : CachedNetworkImage(
                        imageUrl: faceUrl.replaceFirst('http:', 'https:'),
                        placeholder: (context, url) =>
                            Center(child: CupertinoActivityIndicator()),
                        width: 36,
                        height: 36)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              nickName?.isNotEmpty == true ? nickName! : userId ?? '',
              style: TextStyle(
                color: _titleColor,
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
    if (_isMultipleSelected) {
      var checkListData = CheckListData(id: dataIndex.toString(), child: item);
      final onChecked = (bool? isChecked, CheckListData? item) {
        setState(() {
          if (isChecked == true) {
            _checkedData.add(item!);
          } else {
            _checkedData.removeWhere((element) => element.id == item!.id);
          }
        });
      };
      return CheckListItem(
          CheckType.multiple, checkListData, onChecked, _checkedData,
          crossAxisAlignment: CrossAxisAlignment.start);
    }
    return InkWell(
      child: item,
      onTap: () {
        List<AtMessageModel> result = [];
        if (isShowAll && index == 0) {
          result.add(AtMessageModel(userID: userId, nickName: nickName, isAll: true, members: _memberInfoList
              ?.map((e) =>
              AtMessageModel(userID: e?.userID, nickName: e?.nickName, isAll: true))
              .toList() ??
              []));
        } else {
          result.add(AtMessageModel(userID: userId, nickName: nickName));
        }
        Navigator.pop(context, result);
      },
    );
  }
}
