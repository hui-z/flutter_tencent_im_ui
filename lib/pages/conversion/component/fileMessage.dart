import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/avatar.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class FileMessage extends StatelessWidget {
  final V2TimMessage message;
  FileMessage(this.message);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Utils.toast("下载功能，业务可自行实现");
      },
      child: Container(
        color: CommonColors.getWitheColor(),
        child: Row(
          textDirection:
              message.isSelf! ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.fileElem!.fileName!,
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 12,
                        color: CommonColors.getTextWeakColor(),
                      ),
                    ),
                    Text(
                      "${message.fileElem!.fileSize} KB",
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
              width: 50,
              height: 50,
              avtarUrl: 'images/file.png',
              radius: 0,
            )
          ],
        ),
      ),
    );
  }
}
