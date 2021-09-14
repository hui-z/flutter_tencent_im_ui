import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/images.dart';
import 'package:flutter_tencent_im_ui/provider/keybooad_show.dart';
import 'package:provider/provider.dart';

class VoiceMsg extends StatefulWidget {
  VoiceMsg(this.toUser, this.type);
  final String toUser;
  final int type;
  @override
  State<StatefulWidget> createState() => VoiceMsgState();
}

class VoiceMsgState extends State<VoiceMsg> {
  String? toUser;
  int? type;
  bool keybordShow = true;
  toggleKeyBord() {
    setState(() {
      keybordShow = !keybordShow;
    });
    Provider.of<KeyBoradModel>(context, listen: false).setStatus(keybordShow);
  }

  void initState() {
    this.toUser = widget.toUser;
    this.type = widget.type;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool show = Provider.of<KeyBoradModel>(context).show;
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Center(
            child: Image(
                image: assetImage(show
                    ? 'images/icon_keyboard_voice.png'
                    : 'images/icon_keyboard.png'),
                width: 44,
                height: 44)),
      ),
      onTap: () {
        toggleKeyBord();
      },
    );
  }
}
