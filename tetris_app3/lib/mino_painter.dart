import 'package:flutter/material.dart';

import 'mino_model.dart';

const int verticalSeparationCount = 20; // 縦のマス数
const int horizontalSeparationCount = 10; // 横のマス数

/// フィックスしたミノを描画
class FixedMinoPainter extends CustomPainter {
  FixedMinoPainter(this.minoArrangement);
  List<List<MinoType>> minoArrangement;


  @override
  void paint(Canvas canvas, Size size) {
    final heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横
    var xPos = 0.0;
    var yPos = 0.0;

    for (final step in minoArrangement) { /// 1行分でループ
      xPos = 0.0;
      for (final minoType in step){
        if(minoType != MinoType.none){ /// 1マス分を描画
          final paint = Paint()..color = MinoColor.getMinoColor(minoType);
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint);
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      }
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    }

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 落下中のミノを描画
class FallingMinoPainter extends CustomPainter {

  MinoModel minoModel;
  FallingMinoPainter(this.minoModel);

  @override
  void paint(Canvas canvas, Size size) {
    final heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横
    final paint = Paint()
      ..color = MinoColor.getMinoColor(minoModel.minoType);
    var yPos = minoModel.yPos * heightOfCell;
    double xPos;

    for (final step in minoModel.minoArrangement) { /// 1行分でループ
      xPos = minoModel.xPos * widthOfCell;
      for (final minoType in step){
        if(minoType != MinoType.none){ /// 1マス分を描画
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint);
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      }
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    }

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


/// NEXT,HOLDミノを描画
class NextOrHoldMinoPainter extends CustomPainter {
  NextOrHoldMinoPainter(this.minoModel);
  MinoModel minoModel;


  @override
  void paint(Canvas canvas, Size size) {
    /// 1マスの縦
    final heightOfCell = size.height / minoModel.minoArrangement.length;
    /// 1マスの横
    final widthOfCell = size.width / minoModel.minoArrangement.length;

    final paint = Paint()
      ..color = MinoColor.getMinoColor(minoModel.minoType);
    var yPos = 0.0;
    double xPos;

    for (final step in minoModel.minoArrangement) { /// 1行分でループ
      xPos = 0;
      for (final minoType in step){
        if(minoType != MinoType.none){ /// 1マス分を描画
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint);
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      }
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    }

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}



/// 枠線を描画
class BoaderPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横

    // 横線
    for(var y = 0.0; y < size.height ; y += heightOfCell){
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint());
    }

    // 縦線
    for(var x = 0.0; x < size.width ; x += widthOfCell){
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint());
    }

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


/// 落下予測位置を描画
class FallPositionPainter extends CustomPainter {
  FallPositionPainter(this.minoModel);
  MinoModel minoModel;


  @override
  void paint(Canvas canvas, Size size) {
    final heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.redAccent
      ..strokeWidth = 5;

    var yPos = minoModel.yPos * heightOfCell;
    double xPos;

    for (final step in minoModel.minoArrangement) { /// 1行分でループ
      xPos = minoModel.xPos * widthOfCell;
      for (final minoType in step){
        if(minoType != MinoType.none){ /// 1マス分を描画
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint);
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      }
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    }

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MinoColor {
  static List<MaterialAccentColor> minoColorListBasedOnMinoType = [
    Colors.lightBlueAccent, // 使われない想定
    Colors.lightBlueAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
  ];

  static MaterialAccentColor getMinoColor(MinoType minoType) {
    return minoColorListBasedOnMinoType[minoType.index];
  }
}

