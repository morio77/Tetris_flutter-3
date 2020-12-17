import 'package:flutter/material.dart';
import 'package:tetris_app3/mino_ring_buffer.dart';

import 'sound_controller.dart';

/// ミノモデル（落下中ミノ・Nextミノ・Holdミノに使う）
@immutable
class MinoModel {
  final MinoType minoType;
  final MinoAngleCW minoAngleCW;
  final int xPos; // 左上が原点
  final int yPos; // 左上が原点
  final List<List<MinoType>> minoArrangement; // 配置図

  MinoModel(this.minoType, this.minoAngleCW, this.xPos, this.yPos)
      :minoArrangement = minoArrangementList[minoType.index][minoAngleCW.index];

  MinoModel copyWith({
    final MinoType minoType,
    final MinoAngleCW minoAngleCW,
    final int xPos, // 左上が原点
    final int yPos, // 左上が原点
  }) {
    return MinoModel(
      minoType ?? this.minoType,
      minoAngleCW ?? this.minoAngleCW,
      xPos ?? this.xPos,
      yPos ?? this.yPos,
    );
  }

  /// フィックスしたミノと衝突しているか調べる
  /// <return>true:衝突している, false:衝突していない
  bool hasCollision(List<List<MinoType>> fixedMinoArrangement) {
    // fixedミノチェック
    var y = yPos;
    for (final line in minoArrangement) {
      var x = xPos;
      for (final minoType in line) {
        if (minoType != MinoType.none) {
          try {
            if (fixedMinoArrangement[y][x] != MinoType.none) {
              return true;
            }
          }
          catch (e) {
            return true;
          }
        }
        x++;
      }
      y++;
    }

    // ここまで来たら衝突していない
    return false;
  }

  /// ミノが下端もしくは、フィックスしたミノに設置しているか調べる
  /// <return>true:設置している, false:設置していない
  bool checkIsGrounded(List<List<MinoType>> fixedMinoArrangement) {
    final oneStepDownMinoModel = copyWith(yPos: yPos + 1);
    return oneStepDownMinoModel.hasCollision(fixedMinoArrangement);
  }

  /// 指定された方向へミノを移動させる
  /// <return>true:移動できた, false:移動できなかった</return>
  bool moveBy(int x, int y, List<List<MinoType>> fixedMinoArrangement, MinoRingBuffer minoRingBuffer) {
    // 移動したものを適用してみてダメなら戻す。OKならそのまま。
    final _moveMinoModel = copyWith(xPos: xPos + x, yPos: yPos + y);

    // 衝突したら移動できない
    if (_moveMinoModel.hasCollision(fixedMinoArrangement)) {
      return false;
    }
    // 衝突しなかったら移動を適用する
    else {
      minoRingBuffer.changeFallingMinoModel(_moveMinoModel);
      return true;
    }
  }

  /// 指定された角度だけミノを回転させる
  /// <return>true:回転できた, false:回転できなかった</return>
  bool rotateMino(MinoAngleCW minoAngleCW, List<List<MinoType>> fixedMinoArrangement, MinoRingBuffer minoRingBuffer) {
    // 回転したものを適用してみてダメなら戻す。OKならそのまま。
    final fallingMinoModel = copyWith();
    final minoModelListWithSRS = _getMinoModelListWithSRS(fallingMinoModel, minoAngleCW);

    // SRSを適用して回転したミノを1つずつ適用して、衝突しなかった時点で適用する。
    for (final rotationMinoModel in minoModelListWithSRS) {
      if (!rotationMinoModel.hasCollision(fixedMinoArrangement)) {
        minoRingBuffer.changeFallingMinoModel(rotationMinoModel);
        return true;
      }
    }

    return false;
  }

  /// ミノモデルと回転方向から、SRSを適用した時のミノモデルのリストを返却する
  List<MinoModel> _getMinoModelListWithSRS(MinoModel minoModel, MinoAngleCW minoAngleCW) {

    // まずは普通に回転したものをリストに詰める
    final _afterRotationAngleCW = MinoAngleCW.values[(minoModel.minoAngleCW.index + minoAngleCW.index) % 4];
    final _rotationMinoModel = minoModel.copyWith(minoAngleCW: _afterRotationAngleCW);
    final minoModelListWithSRS = <MinoModel>[]
    ..add(_rotationMinoModel);

    // SRSを適用したミノモデルを詰めていく
    if (minoModel.minoType == MinoType.O) { /// Oミノは何もしない
      // 何もしない
    }
    else if (minoModel.minoType == MinoType.I) { /// Iミノ
      switch (_afterRotationAngleCW) {
        case MinoAngleCW.arg0:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -2, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 0, yPos: yPos + 2))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + -3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 2, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + -1))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + 3));
          }
          break;
        case MinoAngleCW.arg90:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -2, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + 1))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + -3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 1, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + 2))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + -3));
          }
          break;
        case MinoAngleCW.arg180:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -1, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + -2))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + 3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 1, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 0, yPos: yPos + 1))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + -3));
          }
          break;
        case MinoAngleCW.arg270:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 2, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + -1))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + 3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -1, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + 0))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -3, yPos: yPos + -2))
              ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 3, yPos: yPos + 3));
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
          minoModelListWithSRS
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + adjustX, yPos: yPos + 0))
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 0, yPos: yPos + 1))
            ..add(minoModelListWithSRS[1]  .copyWith(xPos: xPos + 0, yPos: yPos + -1))
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + adjustX, yPos: yPos + 0));
          break;
        case MinoAngleCW.arg90:
          minoModelListWithSRS
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -1, yPos: yPos + 0))
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 0, yPos: yPos + -1))
            ..add(minoModelListWithSRS[1]  .copyWith(xPos: xPos + 0, yPos: yPos + 1))
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + -1, yPos: yPos + 0));
          break;
        case MinoAngleCW.arg270:
          minoModelListWithSRS
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 1, yPos: yPos + 0))
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 0, yPos: yPos + -1))
            ..add(minoModelListWithSRS[1]  .copyWith(xPos: xPos + 0, yPos: yPos + 1))
            ..add(minoModelListWithSRS.last.copyWith(xPos: xPos + 1, yPos: yPos + 0));
          break;
      }
    }

    return minoModelListWithSRS;

  }
}



enum MinoType {
  none, // 0
  I,    // 1
  O,    // 2
  S,    // 3
  Z,    // 4
  J,    // 5
  L,    // 6
  T,    // 7
}

extension MinoTypeExt on MinoType {
  int get index {
    switch (this) {
      case MinoType.none:
        return 0;
        break;
      case MinoType.I:
        return 1;
        break;
      case MinoType.O:
        return 2;
        break;
      case MinoType.S:
        return 3;
        break;
      case MinoType.Z:
        return 4;
        break;
      case MinoType.J:
        return 5;
        break;
      case MinoType.L:
        return 6;
        break;
      case MinoType.T:
        return 7;
        break;
    }
    return 0;
  }
}

enum MinoAngleCW {
  arg0,
  arg90,
  arg180,
  arg270,
}


extension MinoAngleCWExt on MinoAngleCW {
  int get index {
    switch (this) {
      case MinoAngleCW.arg0:
        return 0;
        break;
      case MinoAngleCW.arg90:
        return 1;
        break;
      case MinoAngleCW.arg180:
        return 2;
        break;
      case MinoAngleCW.arg270:
        return 3;
        break;
    }
    return 0;
  }
}


const List<List<List<List<MinoType>>>> minoArrangementList = [
  [], // 0番目なので何もなし
  [ /// Iミノ
    [ // 0度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.I, MinoType.I, MinoType.I, MinoType.I],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.I, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.I, MinoType.I, MinoType.I, MinoType.I],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.I, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Oミノ
    [ // 0度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.O, MinoType.O, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Sミノ
    [ // 0度
      [MinoType.none, MinoType.S, MinoType.S, MinoType.none],
      [MinoType.S, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.S, MinoType.S, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.S, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.S, MinoType.S, MinoType.none],
      [MinoType.S, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.S, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.S, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.S, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Zミノ
    [ // 0度
      [MinoType.Z, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.none, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.Z, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.Z, MinoType.Z, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.Z, MinoType.Z, MinoType.none, MinoType.none],
      [MinoType.Z, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Jミノ
    [ // 0度
      [MinoType.none, MinoType.none, MinoType.J, MinoType.none],
      [MinoType.J, MinoType.J, MinoType.J, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.J, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.J, MinoType.J, MinoType.J, MinoType.none],
      [MinoType.J, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.J, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.J, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Lミノ
    [ // 0度
      [MinoType.L, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.L, MinoType.L, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.L, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.L, MinoType.L, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.L, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.L, MinoType.L, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
  [ /// Tミノ
    [ // 0度
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.T, MinoType.T, MinoType.T, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 90度
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.T, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 180度
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
      [MinoType.T, MinoType.T, MinoType.T, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
    [ // 270度
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.T, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.T, MinoType.none, MinoType.none],
      [MinoType.none, MinoType.none, MinoType.none, MinoType.none],
    ],
  ],
];