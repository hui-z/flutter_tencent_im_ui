import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/common/advance_msg_list.dart';

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
              child: IconButton(
                icon: list.icon,
                onPressed: _onPressed,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                list.name,
                style: TextStyle(
                  fontSize: 12,
                  color: CommonColors.getTextWeakColor(),
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
