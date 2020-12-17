// 以下をインポート
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart'; // AudioPlayerインスタンスを使う場合

class SoundsController {

// AudioCacheインスタンスの初期化（１度だけ）
static final AudioCache _player = AudioCache();

final a = 'a'; // 警告でないためにいれてあるだけ

  static Future<void> playSound(SoundType soundType) async {
    var soundFileName = '';
    var playSoundTimeMillisec = 0;

    switch (soundType) {
      case SoundType.rotate:
        soundFileName = 'rotate.mp3';
        playSoundTimeMillisec = 100;
        break;
      case SoundType.fix:
        soundFileName = 'fix.mp3';
        playSoundTimeMillisec = 100;
        break;
      case SoundType.deleteLine:
        soundFileName = 'deleteLine.mp3';
        playSoundTimeMillisec = 100;
        break;
    }

    final _audioPlayer = await _player.play(soundFileName);
    final waitTime = Duration(milliseconds: playSoundTimeMillisec);
    await Future<void>.delayed(waitTime);
    _audioPlayer.stop();

  }


}

enum SoundType {
  rotate,
  fix,
  deleteLine,
}