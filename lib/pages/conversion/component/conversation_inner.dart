import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

import 'send_msg.dart';

class ConversationInner extends StatefulWidget {
  ConversationInner(
      {Key? key,
      required this.conversationID,
      required this.type,
      this.userID,
      this.groupID,
      required this.scrollListener,
      this.onMessageRqSuc,
      this.onMessageRqFail,
      required this.isNoMoreData,
      required this.lastMsgID})
      : super(key: key);
  final String conversationID;
  final int type;
  final String? userID;
  final String? groupID;
  final bool isNoMoreData;
  final String lastMsgID;
  final VoidCallback scrollListener;
  final Function(Response response, V2TimMessage message)? onMessageRqSuc;
  final Function(DioError error)? onMessageRqFail;

  @override
  State<StatefulWidget> createState() => ConversationInnerState();
}

class ConversationInnerState extends State<ConversationInner>
    with WidgetsBindingObserver {
  List<V2TimMessage> _currentMessageList = List.empty(growable: true);
  ScrollController scrollController = ScrollController();
  bool _didChangeMetrics = false;
  bool isReversed = false;
  Timer? _timer;
  bool _isNoMoreData = false;
  String _lastMsgID = '';
  bool _isLoading = false;
  


  @override
  void didChangeMetrics() {
    _didChangeMetrics = true;

    super.didChangeMetrics();
    WidgetsBinding.instance?.addPostFrameCallback((_){
      if (_didChangeMetrics) {
        _didChangeMetrics = false;
        scrollToBottom();
      }

    });
  }

  @override
  void initState() {
    _isNoMoreData = widget.isNoMoreData;
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    scrollController.addListener(() {
      widget.scrollListener();
      if (scrollController.position.pixels >
          scrollController.position.maxScrollExtent + 5 && !_isLoading && !_isNoMoreData) {
        _isLoading = true;
        getHistoryMessageList();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ConversationInner oldWidget) {
    _isNoMoreData = widget.isNoMoreData;
    if (scrollController.position.maxScrollExtent > 0) {
      isReversed = true;
      _timer = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    scrollController.removeListener(widget.scrollListener);
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void scrollToBottom() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(
          milliseconds: 300,
        ),
        curve: Curves.decelerate);
  }

  getHistoryMessageList() {
    if (widget.type == ConversationType.c2c) {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(
              userID: widget.userID!,
              count: msgQuerySize,
              lastMsgID: _lastMsgID.isEmpty ? widget.lastMsgID : _lastMsgID)
          .then((listRes) {
        if (listRes.code == 0) {
          List<V2TimMessage> list = listRes.data ?? [];
          _isNoMoreData = list.length < msgQuerySize;
          if (list.length > 0) {
            _lastMsgID = list.last.msgID ?? '';
          }
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(widget.conversationID, list);
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else if (widget.type == ConversationType.group) {
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getGroupHistoryMessageList(
              groupID: widget.groupID!,
              count: msgQuerySize,
              lastMsgID: _lastMsgID.isEmpty ? widget.lastMsgID : _lastMsgID)
          .then((listRes) {
        if (listRes.code == 0) {
          List<V2TimMessage> list = listRes.data!;
          _isNoMoreData = list.length < msgQuerySize;
          if (list.length > 0) {
            _lastMsgID = list.last.msgID ?? '';
          }
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(widget.conversationID, list);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  processingHistoryList() {
    Map<String, List<V2TimMessage>> currentMessageMap =
        Provider.of<CurrentMessageListModel>(context).messageMap;
    _currentMessageList = currentMessageMap[widget.conversationID] ?? [];
    if (_currentMessageList.length >= 10 || (scrollController.hasClients && scrollController.position.maxScrollExtent > 0)) {
      isReversed = true;
    } else {
      _currentMessageList =
          currentMessageMap[widget.conversationID]?.reversed.toList() ?? [];
    }
    bool hasNoRead = _currentMessageList.any((element) {
      return element.isSelf == false && element.isRead == false;
    });
    if (widget.type == 2) {
      // ???????????????????????????????????????????????????
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .markGroupMessageAsRead(groupID: widget.groupID!)
          .then((res) {
        if (res.code == 0) {
        } else {}
      });
    }
    if (hasNoRead) {
      if (widget.type == 1) {
        TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .markC2CMessageAsRead(userID: widget.userID!)
            .then((res) {
          if (res.code == 0) {
          } else {}
        });
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    processingHistoryList();

    if (scrollController.hasClients && scrollController.position.maxScrollExtent > 0 && _currentMessageList.length <= 10) {
      scrollToBottom();
    }
    List<Widget> slivers = [
      SliverSafeArea(
          sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          V2TimMessage? message;
          V2TimMessage? lastMsg;
          if (_isNoMoreData) {
            message = _currentMessageList[index];
            if (index > 0) {
              lastMsg = _currentMessageList[index - 1];
            }
            return SendMsg(
                key: Key(message.msgID ?? ""),
                isReversed: isReversed,
                message: message,
                type: widget.type,
                lastMsgTime: lastMsg?.timestamp != null ? lastMsg!.timestamp! * 1000 : null,
                isShowMsgTime: index == _currentMessageList.length - 1,
                onMessageRqSuc: widget.onMessageRqSuc,
                onMessageRqFail: widget.onMessageRqFail);
          } else {
            if (isReversed) {
              if (index == _currentMessageList.length) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              } else {
                message = _currentMessageList[index];
                if (index > 0) {
                  lastMsg = _currentMessageList[index - 1];
                }
              }
            } else {
              if (index == 0) {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              } else {
                message = _currentMessageList[index - 1];
                if (index > 1) {
                  lastMsg = _currentMessageList[index - 1 -1];
                }
              }
            }
            return SendMsg(
                key: Key(message.msgID ?? ""),
                isReversed: isReversed,
                message: message,
                type: widget.type,
                onMessageRqSuc: widget.onMessageRqSuc,
                lastMsgTime: lastMsg?.timestamp != null ? lastMsg!.timestamp! * 1000 : null,
                onMessageRqFail: widget.onMessageRqFail);
          }
        },
            childCount:
                _currentMessageList.length + (_isNoMoreData ? 0 : 1)),
      ))
    ];
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        controller: scrollController,
        physics: RefreshScrollPhysics(),
        reverse: isReversed,
        slivers: slivers,
      ),
    );
  }
}

/// - ?????????ScrollPhysics(????????? BouncingScrollPhysics?????????shouldAcceptUserOffset copy from AlwaysScrollableScrollPhysics)
///      - CustomScrollView??????physics??? BouncingScrollPhysics ??????????????????????????????????????????
///      - CustomScrollView??????physics??? AlwaysScrollableScrollPhysics ??????android??????????????????
/// - ????????? [?????????ScrollPhysics](https://github.com/baoolong/PullToRefresh_Flutter/blob/master/lib/pulltorefresh_flutter.dart)
class RefreshScrollPhysics extends BouncingScrollPhysics {
  const RefreshScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }
}
