import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/arrowRight.dart';
import 'package:url_launcher/url_launcher.dart';

import 'textWithCommonStyle.dart';

class Buy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        launch('https://cloud.tencent.com/act/618go/renew');
      },
      child: Container(
        height: 55,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Row(
          children: [
            TextWithCommonStyle(
              text: "立即购买",
            ),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  ArrowRight(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
