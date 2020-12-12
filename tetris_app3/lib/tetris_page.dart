import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'mino_controller.dart';
import 'mino_model.dart';
import 'mino_painter.dart';

class TetrisPlayPage extends StatelessWidget {
  final int fallSpeed;
  final String gameLevel;
  TetrisPlayPage(this.fallSpeed, this.gameLevel);

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MinoController>(
      create: (_) => MinoController(fallSpeed),
      child: TetrisPlayPageRender(gameLevel),
    );
  }
}


class TetrisPlayPageRender extends StatelessWidget {
  final String gameLevel;
  TetrisPlayPageRender(this.gameLevel);

  @override
  Widget build(BuildContext context) {
    ///描画に使うための変数
    final displaySize = MediaQuery.of(context).size;
    final playWindowHeight = displaySize.height * 0.6;
    final playWindowWidth = playWindowHeight * 0.5;
    const opacity = 0.1;
    final nextHoldWindowHeight = displaySize.height * 0.1;
    final nextHoldWindowWidth = nextHoldWindowHeight;

    /// ジェスチャー操作の各閾値
    const flickThreshold = 30;
    const dragThreshold = 15;

    /// 以下のいずれかのアクションが起こった場合、指を離すまでドラッグ系の操作を無効にする
    /// ①Hold機能でミノが入れ替わる ②ハードドロップ ③ソフトドロップによってフィックスする
    var _isFunctionEnabledByGesture = true;

    /// 左右移動・ソフトドロップ時のドラッグ累積距離を保持（指が離れたらリセット）
    var cumulativeDeltaXOfLeftDrag = 0.0;
    var cumulativeDeltaXOfRightDrag = 0.0;
    var cumulativeDeltaYOfDownDrag = 0.0;

    return Consumer<MinoController>(
      builder: (context, minoController, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute<void>(builder: (context) => TetrisHomePage())),
            ),
            title: Text(gameLevel),
            actions: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => minoController.startGame(),
              ),
              IconButton(
                icon: const Icon(Icons.rotate_right),
                onPressed: () => minoController.rotate(MinoAngleCW.arg90),
              )
            ],
          ),
          body: Stack(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// 枠線を描画
                        painter: BoaderPainter(),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// フィックスしたミノを描画
                        painter: FixedMinoPainter(minoController.fixedMinoArrangement),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// 落下中のミノを描画
                        painter: minoController.minoRingBuffer.pointer == -1 ? null : FallingMinoPainter(minoController.minoRingBuffer.getFallingMinoModel()),
                      ),
                    ),
                    Container(
                      color: Colors.grey.withOpacity(opacity),
                      height: playWindowHeight,
                      width: playWindowWidth,
                      child: CustomPaint( /// 落下予測位置を描画
                        painter: minoController.minoRingBuffer.pointer == -1 ? null : FallPositionPainter(minoController.getFallMinoModel()),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: displaySize.height,
                width: displaySize.width,
                child: GestureDetector(
                  /// タップアップで回転させる
                  onTapUp: (details) {
                    if (details.globalPosition.dx < displaySize.width * 0.5) {
                      minoController.rotate(MinoAngleCW.arg270);
                    }
                    else {
                      minoController.rotate(MinoAngleCW.arg90);
                    }
                  },

                  /// ドラッグ系（左右移動・Hold機能・ハードドロップ・ソフトドロップ）
                  /// <remark>
                  /// Hold機能・ハードドロップを使用、またはソフトドロップでフィックスした場合
                  /// 一度指を離すまで、ドラッグ系操作を無効にする
                  /// </remark>
                  onPanUpdate: (details) {
                    if (!_isFunctionEnabledByGesture)
                      return;

                    final dx = details.delta.dx;
                    final dy = details.delta.dy;

                    // Hold機能
                    if (dy < -flickThreshold) {
                      if (minoController.changeHoldMinoAndFallingMino()) {
                        _isFunctionEnabledByGesture = false;
                      }
                    }

                    // ハードドロップ
                    if (dy > flickThreshold) {
                      _isFunctionEnabledByGesture = false;
                      minoController.doHardDrop();
                    }
                    
                    // 左右移動
                    if (dx > 0) {
                      cumulativeDeltaXOfRightDrag += dx;
                      if (cumulativeDeltaXOfRightDrag > dragThreshold) {
                        minoController.moveHorizontalBy(x: 1);
                        cumulativeDeltaXOfRightDrag = 0.0;
                      }
                    }
                    else {
                      cumulativeDeltaXOfLeftDrag += dx;
                      if (cumulativeDeltaXOfLeftDrag < -dragThreshold) {
                        minoController.moveHorizontalBy(x: -1);
                        cumulativeDeltaXOfLeftDrag = 0.0;
                      }
                    }

                    // ソフトドロップ
                    if (dy > 0) {
                      cumulativeDeltaYOfDownDrag += dy;
                      if (cumulativeDeltaYOfDownDrag > dragThreshold) {
                        if (!minoController.oneStepDown()) {
                          _isFunctionEnabledByGesture = false;
                        }
                        cumulativeDeltaYOfDownDrag = 0;
                      }
                    }
                  },

                  /// 指が離れたときに、各値を初期化する
                  onPanEnd: (details) {
                    _isFunctionEnabledByGesture = true;
                    cumulativeDeltaXOfLeftDrag = 0.0;
                    cumulativeDeltaXOfRightDrag = 0.0;
                    cumulativeDeltaYOfDownDrag = 0.0;
                  },

                ),
              ),
              Stack( /// NEXT,HOLD枠
                children: [
                  Positioned(
                    left: 10.0,
                    top: 20.0,
                    child: GestureDetector(
                      onTap: () => minoController.changeHoldMinoAndFallingMino(),
                      child: Container(
                        height: nextHoldWindowHeight,
                        width: nextHoldWindowWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: CustomPaint( /// Holdミノを描画
                            painter: minoController.holdMino != null ? NextOrHoldMinoPainter(minoController.holdMino) : null
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.0,
                    top: 20.0,
                    child: Container(
                      height: nextHoldWindowHeight,
                      width: nextHoldWindowWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next1ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModelAt(1)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10.0,
                    top: 20 + nextHoldWindowHeight + 20,
                    child: Container(
                      height: nextHoldWindowHeight,
                      width: nextHoldWindowWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next2ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModelAt(2)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 20.0 +nextHoldWindowHeight + 20 + nextHoldWindowHeight + 20,
                    child: Container(
                      height: nextHoldWindowHeight,
                      width: nextHoldWindowWidth,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next3ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModelAt(3)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}