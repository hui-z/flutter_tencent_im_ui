import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/models/emoji/emoji.dart';
import 'package:flutter_tencent_im_ui/utils/emojiData.dart';

class FaceMsg extends StatelessWidget {
  FaceMsg(
      {Key? key,
      required this.toUser,
      required this.type,
      required this.height})
      : super(key: key);
  final String toUser;
  final int type;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: hexToColor('EDEDED'),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
        ),
        children: emojiData.map(
          (e) {
            var item = Emoji.fromJson(e);
            return new EmojiItem(
              name: item.name,
              unicode: item.unicode,
              toUser: toUser,
              type: type,
            );
          },
        ).toList(),
      ),
    );
  }
}
