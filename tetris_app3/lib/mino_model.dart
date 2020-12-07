/// ミノモデル（落下中ミノ・Nextミノ・Holdミノに使う）
class MinoModel {
  final MinoType minoType;
  final MinoAngleCW minoAngleCW;
  final int xPos; // 左上が原点
  final int yPos; // 左上が原点
  final List<List<MinoType>> minoArrangement; // 配置図

  MinoModel(this.minoType, this.minoAngleCW, this.xPos, this.yPos)
      :this.minoArrangement =minoArrangementList[minoType.index][minoAngleCW.index];

  MinoModel copyWith({
    final MinoType minoType,
    final MinoAngleCW minoAngleCW,
    final int xPos, // 左上が原点
    final int yPos, // 左上が原点
    // List<List<MinoType>> minoArrangement, // 配置図
  }) {
    return MinoModel(
      minoType ?? this.minoType,
      minoAngleCW ?? this.minoAngleCW,
      xPos ?? this.xPos,
      yPos ?? this.yPos,
    );
  }

  MinoModel moveWith({
    final int xPos, // 左上が原点
    final int yPos, // 左上が原点
    // List<List<MinoType>> minoArrangement, // 配置図
  }) {
    return MinoModel(
      minoType,
      minoAngleCW,
      xPos + this.xPos,
      yPos + this.yPos,
    );
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