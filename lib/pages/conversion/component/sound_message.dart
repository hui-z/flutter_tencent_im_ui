import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundMessage extends StatefulWidget {
  SoundMessage(this.message, {Key? key}) : super(key: key);

  final V2TimMessage message;

  @override
  State<StatefulWidget> createState() => SoundMessageState();
}

class SoundMessageState extends State<SoundMessage> {
  bool isPlay = false;
  AudioPlayer audioPlayer = AudioPlayer();
  //实例化对象
  FlutterPluginRecord recordPlugin = new FlutterPluginRecord();

  void initState() {
    super.initState();
    AudioPlayer.logEnabled = true;

    //  当录音播放完成时
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        isPlay = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  play() async {
    String? url = widget.message.soundElem!.url;
    if (url != null) {
      setState(() {
        isPlay = !isPlay;
      });
      int result = await audioPlayer.play(url);
      if (result == 1) {
        // success
      }
    }
  }

  void deactivate() {
    super.deactivate();
    recordPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        play();
      },
      child: Container(
        child: Row(
          children: [
            Icon(Icons.volume_up),
            Text(isPlay ? '正在播放...' : '点击播放'),
            Expanded(
              child: Container(),
            ),
            Text(" ${widget.message.soundElem!.duration} s")
          ],
        ),
      ),
    );
  }
}
