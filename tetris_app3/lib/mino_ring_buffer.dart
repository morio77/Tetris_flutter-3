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
  MinoModel getCurrentMinoModel() {
    return minoModelList[pointer % minoModelList.length];
  }

  /// ミノモデルを返す
  MinoModel getMinoModel([int forwardCountFromPointer = 0]) {
    return minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length];
  }

  /// 指定された方向へミノを移動させる
  /// <return>true:移動できた, false:移動できなかった</return>
  bool moveIfCan(int moveXPos, int moveYPos, List<List<MinoType>> fixedMinoArrangement, [int forwardCountFromPointer = 0]) {
    // 移動したものを適用してみてダメなら戻す。OKならそのまま。
    MinoModel minoModel = minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length];
    MinoModel _moveMinoModel = minoModel.copyWith(xPos: minoModel.xPos + moveXPos, yPos: minoModel.yPos + moveYPos);

    // 衝突チェック
    if (_moveMinoModel.hasCollision(fixedMinoArrangement)) {
      return false;
    }
    else {
      minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length] = _moveMinoModel;
      return true;
    }
  }

  /// 指定された角度だけミノを回転させる
  /// <return>true:回転できた, false:回転できなかった</return>
  bool rotateIfCan(MinoAngleCW minoAngleCW, List<List<MinoType>> fixedMinoArrangement, [int forwardCountFromPointer = 0]) {
    // 回転したものを適用してみてダメなら戻す。OKならそのまま。
    MinoModel minoModel = minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length];

    List<MinoModel> minoModelListWithSRS = _getMinoModelListWithSRS(minoModel, minoAngleCW);

    for (MinoModel rotationMinoModel in minoModelListWithSRS) {
      if (!rotationMinoModel.hasCollision(fixedMinoArrangement)) {
        minoModelList[(pointer + forwardCountFromPointer) % minoModelList.length] = rotationMinoModel;
        return true;
      }
    }

    return false;
  }

  List<MinoModel> _getMinoModelListWithSRS(MinoModel minoModel, MinoAngleCW minoAngleCW) {

    MinoAngleCW _afterRotationAngleCW = MinoAngleCW.values[(minoModel.minoAngleCW.index + minoAngleCW.index) % 4];
    MinoModel _rotationMinoModel = minoModel.copyWith(minoAngleCW: _afterRotationAngleCW);

    var minoModelListWithSRS = List<MinoModel>();
    minoModelListWithSRS.add(_rotationMinoModel);

    if (minoModel.minoType == MinoType.O) { /// Oミノは何もしない
      // 何もしない
    }
    else if (minoModel.minoType == MinoType.I) { /// Iミノ
      switch (_afterRotationAngleCW) {
        case MinoAngleCW.arg0:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 0, yPos: 2));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: -3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: -1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: 3));
          }
          break;
        case MinoAngleCW.arg90:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: 1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: -3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 1, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: 2));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: -3));
          }
          break;
        case MinoAngleCW.arg180:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -1, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: -2));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: 3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 1, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 0, yPos: 1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: -3));
          }
          break;
        case MinoAngleCW.arg270:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 3, yPos: -1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -3, yPos: 3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -1, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: -2));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: 3));
          }
          break;
      }
    }
    else { /// Oミノ、Iミノ以外
      switch (_afterRotationAngleCW) {
        case MinoAngleCW.arg0:
        case MinoAngleCW.arg180:
          int adjustX;
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            adjustX = -1;
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            adjustX = 1;
          }
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: adjustX, yPos: 0));
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 0, yPos: 1));
          minoModelListWithSRS.add(minoModelListWithSRS[1]  .moveWith(xPos: 0, yPos: -1));
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: adjustX, yPos: 0));
          break;
        case MinoAngleCW.arg90:
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -1, yPos: 0));
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 0, yPos: -1));
          minoModelListWithSRS.add(minoModelListWithSRS[1]  .moveWith(xPos: 0, yPos: 1));
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: -1, yPos: 0));
          break;
        case MinoAngleCW.arg270:
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 1, yPos: 0));
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 0, yPos: -1));
          minoModelListWithSRS.add(minoModelListWithSRS[1]  .moveWith(xPos: 0, yPos: 1));
          minoModelListWithSRS.add(minoModelListWithSRS.last.moveWith(xPos: 1, yPos: 0));
          break;
      }
    }

    return minoModelListWithSRS;

  }

  /// ポインタを進める
  void forwardPointer() {
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