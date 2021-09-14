import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/advance_msg_list.dart';
import 'package:flutter_tencent_im_ui/common/constants.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/utils/string_util.dart';
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
      color: CommonColors.dividerColor,
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
            icon: 'images/icon_insert_photo.png',
            onPressed: () async {
              sendImageMsg(context, 1);
            },
          ),
          new AdvanceMsgList(
            name: '拍摄',
            icon: 'images/icon_camera_alt.png',
            onPressed: () {
              sendImageMsg(context, 0);
            },
          ),
          new AdvanceMsgList(
            name: '语音通话',
            icon: 'images/icon_video_call.png',
            onPressed: () {
              Utils.toast('功能尚未开通');
            },
          ),
          new AdvanceMsgList(
            name: '文件',
            icon: 'images/icon_insert_drive_file.png',
            onPressed: () async {
              sendFile(context);
            },
          ),
        ].map((e) => AdvanceMsgItem(e)).toList(),
      ),
    );
  }

  sendVideoMsg(context) async {
    final video = await picker.pickVideo(
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
          receiver: type == ConversationType.c2c ? toUser : "",
          groupID: type == ConversationType.group ? toUser : "",
          type: 'mp4',
          snapshotPath: thumbnail == null ? "" : thumbnail,
          onlineUserOnly: false,
          duration: 10,
        );

    if (res.code == 0) {
      String key = StringUtil.appendConversionType(toUser, type);
      V2TimMessage? msg = res.data;
      // 添加新消息

      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addMessage(key, [msg!]);
      } catch (err) {}
    } else {
      Utils.toast("发送失败 ${res.code} ${res.desc}");
    }
  }

  sendImageMsg(context, checkType) async {
    final image = await picker.pickImage(
        source: checkType == 0 ? ImageSource.camera : ImageSource.gallery);
    if (image == null) {
      return;
    }
    String path = image.path;
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendImageMessage(
          imagePath: path,
          receiver: type == ConversationType.c2c ? toUser : "",
          groupID: type == ConversationType.group ? toUser : "",
          onlineUserOnly: false,
        );

    if (res.code == 0) {
      String key = StringUtil.appendConversionType(toUser, type);
      V2TimMessage? msg = res.data;
      // 添加新消息
      try {
        Provider.of<CurrentMessageListModel>(context, listen: false)
            .addMessage(key, [msg!]);
      } catch (err) {}
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
            receiver: type == ConversationType.c2c ? toUser : "",
            groupID: type == ConversationType.group ? toUser : "",
            onlineUserOnly: false,
          );
      if (res.code == 0) {
        String key = StringUtil.appendConversionType(toUser, type);
        List<V2TimMessage> list = new List.empty(growable: true);
        V2TimMessage? msg = res.data;
        // 添加新消息

        list.add(msg!);
        try {
          Provider.of<CurrentMessageListModel>(context, listen: false)
              .addMessage(key, list);
        } catch (err) {}
      } else {
        Utils.toast("发送失败 ${res.code} ${res.desc}");
      }
    } else {
      // User canceled the picker
    }
  }
}
