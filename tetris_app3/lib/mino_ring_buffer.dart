import 'package:flutter/material.dart';

import 'mino_controller.dart';
import 'mino_model.dart';

/// 出てくるミノタイプを表すクラス
class MinoRingBuffer {
  final int checkPoint = 7;

  List<MinoModel> minoModelList; // ミノモデルのリスト（リングバッファ）
  int pointer;

  List<MinoType> tmpMinoTypeList; // シャッフル用のミノタイプリスト

  // コンストラクタ
  MinoRingBuffer() {
    pointer = -1;
    minoModelList = List<MinoModel>(14);

    // 7種1巡の法則で7個のミノモデルを生成して、リストに保持
    tmpMinoTypeList = List.generate(7, (i) => MinoType.values[i + 1]);

    tmpMinoTypeList.shuffle();
    for (int i = 0 ; i < 7 ; i++) {
      minoModelList[i] = MinoModel(tmpMinoTypeList[i], MinoAngleCW.values[random.nextInt(4)], 4, 0);
    }
  }

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
      tmpMinoTypeList.shuffle();

      for (int i = 0 ; i < 7 ; i++) {
        minoModelList[(pointer + i + 7) % minoModelList.length] = MinoModel(tmpMinoTypeList[i], MinoAngleCW.values[random.nextInt(4)], 4, 0);
      }
    }
  }

  /// 今のミノモデルを任意のミノモデルに置き換える
  void changeFallingMinoModel(MinoModel minoModel) {
    minoModelList[pointer % minoModelList.length] = minoModel.copyWith();
  }
}