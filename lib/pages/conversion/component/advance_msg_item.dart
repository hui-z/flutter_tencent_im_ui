import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/advance_msg_list.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/images.dart';

class AdvanceMsgItem extends StatelessWidget {
  AdvanceMsgItem(this.list, {Key? key}) : super(key: key);
  final AdvanceMsgList list;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: InkWell(
                  child: Image(
                image: assetImage(list.icon),
                width: 30,
                height: 30,
              ), onTap: _onPressed,),
            ),
            Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                list.name,
                style: TextStyle(
                  fontSize: 14,
                  color: CommonColors.lightBlackTextColor,
                ),
              ),
            )
          ],
        ));
  }

  _onPressed() {
    list.onPressed();
  }
}
