import 'package:flutter/material.dart';
import 'package:tetris_app3/mino_ring_buffer.dart';

/// ミノモデル（落下中ミノ・Nextミノ・Holdミノに使う）
class MinoModel {

  MinoModel(this.minoType, this.minoAngleCW, this.xPos, this.yPos)
      :minoArrangement = minoArrangementList[minoType.index][minoAngleCW.index];

  final MinoType minoType;
  final MinoAngleCW minoAngleCW;
  final int xPos; // 左上が原点
  final int yPos; // 左上が原点
  final List<List<MinoType>> minoArrangement; // 配置図

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
    // fixedミノチェック（これですべてのチェックになっているばず）
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
            debugPrint(e.toString());
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

  /// 指定された方向へミノを移動させる
  /// <return>true:移動できた, false:移動できなかった</return>
  bool movePossible(int moveXPos, int moveYPos, List<List<MinoType>> fixedMinoArrangement, MinoRingBuffer minoRingBuffer) {
    // 移動したものを適用してみてダメなら戻す。OKならそのまま。
    final _moveMinoModel = copyWith(xPos: xPos + moveXPos, yPos: yPos + moveYPos);

    // 衝突チェック
    if (_moveMinoModel.hasCollision(fixedMinoArrangement)) {
      return false;
    }
    else {
      minoRingBuffer.changeFallingMinoModel(_moveMinoModel);
      return true;
    }
  }

  /// 指定された角度だけミノを回転させる
  /// <return>true:回転できた, false:回転できなかった</return>
  bool rotatePossible(MinoAngleCW minoAngleCW, List<List<MinoType>> fixedMinoArrangement, MinoRingBuffer minoRingBuffer) {
    // 回転したものを適用してみてダメなら戻す。OKならそのまま。
    final fallingMinoModel = copyWith();
    final minoModelListWithSRS = _getMinoModelListWithSRS(fallingMinoModel, minoAngleCW);

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
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 0, yPos: 2));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: -3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: -1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: 3));
          }
          break;
        case MinoAngleCW.arg90:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: 1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: -3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 1, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: 2));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: -3));
          }
          break;
        case MinoAngleCW.arg180:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -1, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: -2));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: 3));
          }
          else if (minoAngleCW == MinoAngleCW.arg270) { // 左回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 1, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 0, yPos: 1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: -3));
          }
          break;
        case MinoAngleCW.arg270:
          if (minoAngleCW == MinoAngleCW.arg90) { // 右回転しようとしたとき
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 2, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: 0));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 3, yPos: -1));
            minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -3, yPos: 3));
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
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: adjustX, yPos: 0));
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 0, yPos: 1));
          minoModelListWithSRS.add(minoModelListWithSRS[1]  .copyWith(xPos: 0, yPos: -1));
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: adjustX, yPos: 0));
          break;
        case MinoAngleCW.arg90:
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -1, yPos: 0));
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 0, yPos: -1));
          minoModelListWithSRS.add(minoModelListWithSRS[1]  .copyWith(xPos: 0, yPos: 1));
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: -1, yPos: 0));
          break;
        case MinoAngleCW.arg270:
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 1, yPos: 0));
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 0, yPos: -1));
          minoModelListWithSRS.add(minoModelListWithSRS[1]  .copyWith(xPos: 0, yPos: 1));
          minoModelListWithSRS.add(minoModelListWithSRS.last.copyWith(xPos: 1, yPos: 0));
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
      default:
        return 0;
    }
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
      default:
        return 0;
    }
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