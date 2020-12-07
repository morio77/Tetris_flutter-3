import 'package:flutter/material.dart';

import 'mino_model.dart';

const int verticalSeparationCount = 20; // 縦のマス数
const int horizontalSeparationCount = 10; // 横のマス数

/// フィックスしたミノを描画
class FixedMinoPainter extends CustomPainter {

  List<List<MinoType>> minoArrangement;
  FixedMinoPainter(this.minoArrangement);

  @override
  void paint(Canvas canvas, Size size) {
    final double heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final double widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横
    final paint = Paint();
    double yPos = 0;
    double xPos = 0;

    minoArrangement.forEach((lineList) { /// 1行分でループ
      xPos = 0;
      lineList.forEach((minoType) { /// 1マス分を描画
        paint.color = MinoColor.getMinoColor(minoType);
        if(minoType != MinoType.none){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint); /// 1マス分描画
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      });
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    });

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
    final double heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final double widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横
    final paint = Paint()
      ..color = MinoColor.getMinoColor(minoModel.minoType);
    double yPos = minoModel.yPos * heightOfCell;
    double xPos;

    minoModel.minoArrangement.forEach((step) { /// 1行分でループ
      xPos = minoModel.xPos * widthOfCell;
      step.forEach((minoType) { /// 1マス分を描画
        if(minoType != MinoType.none){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint); /// 1マス分描画
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      });
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    });

  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


/// NEXT,HOLDミノを描画
class NextOrHoldMinoPainter extends CustomPainter {

  MinoModel minoModel;
  NextOrHoldMinoPainter(this.minoModel);

  @override
  void paint(Canvas canvas, Size size) {
    final double heightOfCell = size.height / minoModel.minoArrangement.length; /// 1マスの縦
    final double widthOfCell = size.width / minoModel.minoArrangement.length;   /// 1マスの横
    final paint = Paint()
      ..color = MinoColor.getMinoColor(minoModel.minoType);
    double yPos = 0;
    double xPos;

    minoModel.minoArrangement.forEach((step) { /// 1行分でループ
      xPos = 0;
      step.forEach((minoType) { /// 1マス分を描画
        if(minoType != MinoType.none){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint); /// 1マス分描画
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      });
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    });

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
    final double heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final double widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横

    // 横線
    for(double y = 0; y < size.height ; y += heightOfCell){
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint());
    }

    // 縦線
    for(double x = 0; x < size.width ; x += widthOfCell){
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

  MinoModel minoModel;
  FallPositionPainter(this.minoModel);

  @override
  void paint(Canvas canvas, Size size) {
    final double heightOfCell = size.height / verticalSeparationCount; /// 1マスの縦
    final double widthOfCell = size.width / horizontalSeparationCount; /// 1マスの横
    final paint = Paint();
    paint.color = Colors.redAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;

    double yPos = minoModel.yPos * heightOfCell;
    double xPos;

    minoModel.minoArrangement.forEach((step) { /// 1行分でループ
      xPos = minoModel.xPos * widthOfCell;
      step.forEach((minoType) { /// 1マス分を描画
        if(minoType != MinoType.none){
          canvas.drawRect(Rect.fromLTWH(xPos, yPos , widthOfCell, heightOfCell), paint); /// 1マス分描画
        }
        xPos += widthOfCell; /// 描画位置を右に1マスずらす
      });
      yPos += heightOfCell; /// 描画位置を下に1マスずらす
    });

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

