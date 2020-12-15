import 'mino_controller.dart';
import 'mino_model.dart';

/// 出てくるミノタイプを表すクラス
class MinoRingBuffer {
  int pointer;
  MinoRingBuffer() {
    pointer = -1;
    _generateSevenMino(startGeneratePositionFromPointer: 1);
  }

  // ミノモデルのリスト（リングバッファ）
  List<MinoModel> minoModelList = List<MinoModel>(14);

  // ポインタが7の倍数になったときに、7種のミノモデルを生成する
  final checkPoint = 7;

  // シャッフル用のミノタイプリスト(7種のミノタイプを生成してリストに保持しておく)
  final tmpMinoTypeList = List.generate(7, (i) => MinoType.values[i + 1]);


  /// 7種のミノを生成してリングバッファに詰める
  void _generateSevenMino({int startGeneratePositionFromPointer = 1}) {
    tmpMinoTypeList.shuffle();
    for (var i = 0 ; i < 7 ; i++) {
      minoModelList[(pointer + startGeneratePositionFromPointer + i) % minoModelList.length] = MinoModel(tmpMinoTypeList[i], MinoAngleCW.values[random.nextInt(4)], 4, 0);
    }
  }


  /// ================
  /// 他から呼ばれる関数
  /// ================

  /// 落下中のミノモデルを返す
  MinoModel getFallingMinoModel() => getMinoModelAt(0);

  /// 指定されたIndexのミノモデルを返す
  MinoModel getMinoModelAt(int index) {
    return minoModelList[(pointer + index) % minoModelList.length];
  }

  /// ポインタを進める
  void goForwardPointer() {
    pointer++;

    // 7種のミノが1巡したら、次の7種のミノを生成して詰める
    if ((pointer % checkPoint) == 0) {
      _generateSevenMino(startGeneratePositionFromPointer: 7);
    }
  }

  /// 落下中のミノモデルを任意のミノモデルに置き換える
  void changeFallingMinoModel(MinoModel minoModel) {
    minoModelList[pointer % minoModelList.length] = minoModel.copyWith();
  }
}