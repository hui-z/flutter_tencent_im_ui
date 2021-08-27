import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class CurrentMessageListModel with ChangeNotifier, DiagnosticableTreeMixin {
  Map<String, List<V2TimMessage>> _messageMap = new Map();

  get messageMap => _messageMap;

  clear() {
    _messageMap = new Map();
    notifyListeners();
  }

  updateC2CMessageByUserId(String userid) {
    String key = "c2c_$userid";
    if (_messageMap.containsKey(key)) {
      List<V2TimMessage>? msgList = _messageMap[key];
      msgList!.forEach((element) {
        element.isPeerRead = true;
      });
      _messageMap[key] = msgList;
      notifyListeners();
    } else {
    }
  }

  addMessage(String key, List<V2TimMessage> value) {
    if (_messageMap.containsKey(key)) {
      _messageMap[key]!.addAll(value);
    } else {
      List<V2TimMessage> messageList = List.empty(growable: true);
      messageList.addAll(value);
      _messageMap[key] = messageList;
    }
    //去重
    Map<String, V2TimMessage> rebuildMap = new Map<String, V2TimMessage>();
    _messageMap[key]!.forEach((element) {
      rebuildMap[element.msgID!] = element;
    });
    _messageMap[key] = rebuildMap.values.toList();
    rebuildMap.clear();
    _messageMap[key] = updateCustomMsg(_messageMap[key]!);
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
    notifyListeners();
  }

  addOneMessageIfNotExits(String key, V2TimMessage message) {
    if (_messageMap.containsKey(key)) {
      bool hasMessage =
          _messageMap[key]!.any((element) => element.msgID == message.msgID);
      if (hasMessage) {
        int idx = _messageMap[key]!
            .indexWhere((element) => element.msgID == message.msgID);
        _messageMap[key]![idx] = message;
      } else {
        _messageMap[key]!.add(message);
      }
    } else {
      List<V2TimMessage> messageList = List.empty(growable: true);
      messageList.add(message);
      _messageMap[key] = messageList;
    }
    _messageMap[key] = updateCustomMsg(_messageMap[key]!);
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
    notifyListeners();
    return _messageMap;
  }

  List<V2TimMessage> updateCustomMsg(List<V2TimMessage> list) {
    var updateMsgList = <V2TimMessage>[];
    var newList = <V2TimMessage>[];
    list.forEach((element) {
      if (element.elemType == MessageElemType
          .V2TIM_ELEM_TYPE_CUSTOM) {
        Map? data = json.decode(element.customElem?.data ?? '');
        if (data?['action'] == 'update') {
          updateMsgList.add(element);
        } else {
          newList.add(element);
        }
      } else {
        newList.add(element);
      }
    });
    newList.forEach((element1) {
      if (element1.elemType == MessageElemType
          .V2TIM_ELEM_TYPE_CUSTOM) {
        updateMsgList.forEach((element2) {
          Map? data1 = json.decode(element1.customElem?.data ?? '');
          Map? data2 = json.decode(element2.customElem?.data ?? '');
          if (data2?['id'] == data1?['id']) {
            data2?['id'] = '';
            data2?['action'] = '';
            element1.customElem?.data = json.encode(data2);
          }
        });
      }
    });
    return newList;
  }

  deleteMessage(String key) {
    _messageMap.remove(key);
    notifyListeners();
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('messageMap', messageMap));
  }
}
