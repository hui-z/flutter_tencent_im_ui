import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/hexToColor.dart';
import 'package:flutter_tencent_im_ui/pages/conversion/dataInterface/advanceMsgList.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'advance_msg_item.dart';

class MoreSendFunction extends StatelessWidget {
  MoreSendFunction(
      {Key? key,
      required this.toUser,
      required this.type,
      required this.picker,
      required this.height})
      : super(key: key);
  final String toUser;
  final int type;
  final ImagePicker picker;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: hexToColor('ededed'),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
        ),
        children: [
          new AdvanceMsgList(
            name: '相册',
            icon: Icon(
              Icons.insert_photo,
              size: 30,
            ),
            onPressed: () async {
              sendImageMsg(context, 1);
            },
          ),
          new AdvanceMsgList(
            name: '拍摄',
            icon: Icon(
              Icons.camera_alt,
              size: 30,
            ),
            onPressed: () {
              sendImageMsg(context, 0);
            },
          ),
          new AdvanceMsgList(
            name: '视频',
            icon: Icon(
              Icons.video_call,
              size: 30,
            ),
            onPressed: () {
              sendVideoMsg(context);
            },
          ),
          new AdvanceMsgList(
            name: '文件',
            icon: Icon(
              Icons.insert_drive_file,
              size: 30,
            ),
            onPressed: () async {
              sendFile(context);
            },
          ),
          new AdvanceMsgList(
            name: '自定义',
            icon: Icon(Icons.topic),
            onPressed: () {
              sendCustomData(context);
            },
          ),
        ].map((e) => AdvanceMsgItem(e)).toList(),
      ),
    );
  }

  sendVideoMsg(context) async {
    final video = await picker.getVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (video == null) {
      return;
    }
    String tempPath = (await getTemporaryDirectory()).path;

    String? thumbnail = await VideoThumbnail.thumbnailFile(
      video: video.path,
      thumbnailPath: tempPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    // 获取视频文件大小(默认为字节)
    var file = File(video.path);
    int size = await file.length();
    if (size >= 104857600) {
      Utils.toast("发送失败,视频不能大于100MB");
      return;
    }

    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendVideoMessage(
          videoFilePath: video.path,
          receiver: type == 1 ? toUser : "",
          groupID: type == 2 ? toUser : "",
          type: 'mp4',
          snapshotPath: thumbnail == null ? "" : thumbnail,
          onlineUserOnly: false,
          duration: 10,
        );

    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      V2TimMessage? msg = res.data;
      // 添加新消息

      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addOneMessageIfNotExits(key, msg!);
      } catch (err) {
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendImageMsg(context, checktype) async {
    final image = await picker.getImage(
        source: checktype == 0 ? ImageSource.camera : ImageSource.gallery);
    if (image == null) {
      return;
    }
    String path = image.path;
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendImageMessage(
          imagePath: path,
          receiver: type == 1 ? toUser : "",
          groupID: type == 2 ? toUser : "",
          onlineUserOnly: false,
        );

    if (res.code == 0) {
      String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
      V2TimMessage? msg = res.data;
      // 添加新消息
      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addOneMessageIfNotExits(key, msg!);
      } catch (err) {
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendCustomData(context) async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendCustomMessage(
          data: json.encode({
            'widget': 'Column',
            'children': [
              {
                'widget': 'Text',
                'xVar': {
                  'data': '再惠合同续约提醒',
                  'style': {
                    'color': 'FF000000',
                    'fontWeight': 'bold',
                    'fontSize': 16.0
                  }
                },
              },
              {
                'widget': 'Row',
                'children': [
                  {
                    'widget': 'Text',
                    'xVar': {
                      'data': '亲爱的商户',
                      'style': {'color': 'FF9E9E9E', 'fontSize': 14.0}
                    }
                  },
                  {
                    'widget': 'RawMaterialButton',
                    'child': {
                      'widget': 'Text',
                      'xVar': {
                        'data': '加了个按钮',
                        'style': {'color': 'FF4CAF50', 'fontSize': 14.0}
                      }
                    }
                  },
                ]
              },
              {
                'widget': 'Text',
                'xVar': {
                  'data': '您与再惠合作的服务即将到期，请尽快沟通续约事宜',
                  'style': {'color': 'FF9E9E9E', 'fontSize': 14.0}
                },
              },
              {
                'widget': 'RawMaterialButton',
                'child': {
                  'widget': 'Text',
                  'xVar': {
                    'data': '确认续约',
                    'style': {'color': 'FF2196F3', 'fontSize': 16.0}
                  },
                }
              },
            ]
          }),
          receiver: type == 1 ? toUser : "",
          groupID: type == 2 ? toUser : "",
        );
    if (res.code == 0) {
      String key = (type == 1 ? "c2c_${toUser}" : "group_${toUser}");
      List<V2TimMessage> list = new List.empty(growable: true);
      V2TimMessage? msg = res.data;
      // 添加新消息

      list.add(msg!);

      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addMessage(key, list);
      } catch (err) {
      }
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendFile(context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? path = result.files.single.path;
      V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin
          .v2TIMManager
          .getMessageManager()
          .sendFileMessage(
            fileName: path!.split('/').last,
            filePath: path,
            receiver: type == 1 ? toUser : "",
            groupID: type == 2 ? toUser : "",
            onlineUserOnly: false,
          );
      if (res.code == 0) {
        String key = (type == 1 ? "c2c_$toUser" : "group_$toUser");
        List<V2TimMessage> list = new List.empty(growable: true);
        V2TimMessage? msg = res.data;
        // 添加新消息

        list.add(msg!);
        try {
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(key, list);
        } catch (err) {
        }
      } else {
        Utils.toast("发送失败 ${res.code} ${res.desc}");
      }
    } else {
      // User canceled the picker
    }
  }
}
