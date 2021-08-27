import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

import 'send_msg.dart';

class ConversationInner extends StatefulWidget {
  ConversationInner(Key key, this.conversationID, this.type, this.userID,
      this.groupID, this.scrollListener)
      : super(key: key);
  final String conversationID;
  final int type;
  final String? userID;
  final String? groupID;
  final VoidCallback scrollListener;

  @override
  State<StatefulWidget> createState() => ConversationInnerState();
}

class ConversationInnerState extends State<ConversationInner>
    with WidgetsBindingObserver {
  List<V2TimMessage>? currentMessageList = List.empty(growable: true);
  ScrollController scrollController =
      new ScrollController(initialScrollOffset: 0.0);
  double _preBottom = 0.0;
  double _bottom = 0.0;
  bool _didChangeMetrics = false;

  @override
  void didChangeMetrics() {
    _didChangeMetrics = true;

    super.didChangeMetrics();
    WidgetsBinding.instance?.addPersistentFrameCallback((timeStamp) {
      if (!_didChangeMetrics) {
        return;
      }

      _preBottom = _bottom;
      _bottom = MediaQuery.of(context).viewInsets.bottom;

      if (_preBottom != _bottom) {
        WidgetsBinding.instance?.scheduleFrame();
        return;
      }

      _didChangeMetrics = false;
      scrollToBottom();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    scrollController.addListener(widget.scrollListener);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    scrollController.removeListener(widget.scrollListener);
    super.dispose();
  }

  void scrollToBottom() {
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(
          milliseconds: 300,
        ),
        curve: Curves.decelerate);
  }

  getHistoryList(currentMessageMap, messageList) {
    if (currentMessageMap != null) {
      messageList = currentMessageMap[widget.conversationID];
    }
    if (messageList == null) {
      return Center(
        child: LoadingIndicator(
          indicatorType: Indicator.lineSpinFadeLoader,
          color: Colors.black26,
        ),
      );
    }

    bool hasNoRead = messageList.any((element) {
      return !element.isSelf && !element.isRead;
    });
    setState(() {
      currentMessageList = messageList;
    });
    if (widget.type == 2) {
      // 如果有未读，设置成已读，否者会触发
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
    Map<String, List<V2TimMessage>> currentMessageMap =
        Provider.of<CurrentMessageListModel>(context).messageMap;
    List<V2TimMessage> messageList = List.empty(growable: true);
    getHistoryList(currentMessageMap, messageList);
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        controller: scrollController,
        reverse: currentMessageList!.length > 6, //注意设置为反向
        padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children:
              (currentMessageList == null || currentMessageList!.length == 0)
                  ? [Container()]
                  : currentMessageList!.map(
                      (e) {
                        return SendMsg(e, Key(e.msgID ?? ""));
                      },
                    ).toList(),
        ),
      ),
    );
  }
}
