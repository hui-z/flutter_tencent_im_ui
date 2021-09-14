import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:flutter_tencent_im_ui/common/images.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
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
  late AudioPlayer audioPlayer;
  //实例化对象
  FlutterPluginRecord recordPlugin = new FlutterPluginRecord();
  late Duration _duration;



  void initState() {
    super.initState();
    AudioPlayer.logEnabled = true;
    audioPlayer = AudioPlayer(playerId: widget.message.msgID);
    _duration = Duration(seconds: widget.message.soundElem?.duration ?? 0);

    //  当录音播放完成时
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        isPlay = false;
        _duration = Duration(seconds: widget.message.soundElem?.duration ?? 0);
      });
    });
    audioPlayer.onPlayerStateChanged.listen((event) {
      if(event != PlayerState.PLAYING) {
        isPlay = false;
      }
    });
    audioPlayer.onPlayerError.listen((event) {
      Utils.toast(event);
    });
    audioPlayer.onAudioPositionChanged.listen((event) {
      if (_duration < Duration(seconds: widget.message.soundElem?.duration ?? 0)) {
        if (event - _duration >= Duration(seconds: 1)) {
          setState(() {
            _duration = event;
          });
        }
      } else {
        setState(() {
          _duration = event;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.release();
    super.dispose();
  }

  play() async {
    isPlay = !isPlay;
    String? url = widget.message.soundElem!.url;
    if (isPlay) {
      if (_duration.compareTo(Duration(seconds: widget.message.soundElem?.duration ?? 0)) < 0) {
        audioPlayer.resume();
      } else {
        if (url != null) {
          int result = await audioPlayer.play(url);
          if (result != 1) {
            Utils.toast('请检查网络');
          }
        }
      }
    } else {
      audioPlayer.pause();
    }
  }

  void deactivate() {
    super.deactivate();
    recordPlugin.dispose();
    audioPlayer.release();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        play();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
      Center(
          child: Image(
              image: assetImage('images/icon_play.png'),
              width: 30,
              height: 30)),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 16),
        child: Center(
            child: Image(
                image: assetImage('images/icon_play_process.png'),
                width: 106,
                height: 29)),
      ),
      Text(" ${_duration.toString().split('.')[0]}")
        ],
      ),
    );
  }
}
