import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/avatar.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class FileMessage extends StatelessWidget {
  final V2TimMessage message;
  FileMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        var url = message.fileElem?.url;
        Utils.toast("长按开始下载...");
        if (url != null) {
          _launchURL(url);
        }
      },
      child: Container(
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileElem!.fileName!,
                      style: TextStyle(
                          fontSize: 16,
                          color: CommonColors.blackTextColor,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getShowSize(message.fileElem!.fileSize ?? 0),
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 12,
                        color: CommonColors.getTextWeakColor(),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Avatar(
              width: 40,
              height: 40,
              avtarUrl: 'images/icon_file.png',
              radius: 0,
            )
          ],
        ),
      ),
      onTap: () {
        var title = message.fileElem?.fileName;
        var url = message.fileElem?.url;
        if (title != null && url != null) {
          cacheAndLaunch(context, url, title);
        }
      },
    );
  }

  String _getShowSize(int fileSize) {
    String size = '';
    if (fileSize < 0.1 * 1024) {
      size = '$fileSize B';
    } else if (fileSize < 0.1 * 1024 * 1024) {
      size = (fileSize / 1024).toString();
      size = size.substring(0, size.indexOf('.') + 3) + ' KB';
    } else if (fileSize < 0.1 * 1024 * 1024 * 1024) {
      size = (fileSize / (1024 * 1024)).toString();
      size = size.substring(0, size.indexOf('.') + 3) + ' MB';
    } else if (fileSize < 0.1 * 1024 * 1024 * 1024 * 1024) {
      size = (fileSize / (1024 * 1024 * 1024)).toString();
      size = size.substring(0, size.indexOf('.') + 3) + ' GB';
    }
    return size;
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '无法启动 $url';
    }
  }

  Future<String> cache(String url, String filename) async {
    String dir = (await getApplicationSupportDirectory())
        .path; //getExternalStorageDirectory
    File file = File('$dir/$filename');
    log(" 保存位置：${file.path}");
    if (await file.exists()) return file.path;
    await file.create(recursive: true);
    var response =
        await http.get(Uri.parse(url)).timeout(Duration(seconds: 60));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }
    throw 'Cache $url failed';
  }

  void cacheAndLaunch(BuildContext context, String url, String filename) {
    cache(url, filename).then((String path) {
      OpenFile.open(path);
    });
  }
}
