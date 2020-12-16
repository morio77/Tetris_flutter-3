import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'mino_controller.dart';
import 'mino_model.dart';
import 'mino_painter.dart';

@immutable
class TetrisPlayPage extends StatelessWidget {
  final int fallSpeed;
  final String gameLevel;
  const TetrisPlayPage(this.fallSpeed, this.gameLevel);

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MinoController>(
      create: (_) => MinoController(fallSpeed),
      child: TetrisPlayPageRender(gameLevel),
    );
  }
}

@immutable
class TetrisPlayPageRender extends StatelessWidget {
  final String gameLevel;
  const TetrisPlayPageRender(this.gameLevel);

  @override
  Widget build(BuildContext context) {
    /// プレイ・NEXT・HOLDの枠のサイズに関する変数
    final displaySize = MediaQuery.of(context).size;
    final playWindowHeight = displaySize.height * 0.6;
    final playWindowWidth = playWindowHeight * 0.5;

    double nextHoldWindowWidthAndHeight;
    // 縦向きだったら
    if (displaySize.height > displaySize.width) {
      nextHoldWindowWidthAndHeight = (displaySize.width - playWindowWidth) * 0.45;
    }
    // 横向きだったら
    else {
      nextHoldWindowWidthAndHeight = displaySize.height * 0.1;
    }

    const opacity = 0.1;

    /// ジェスチャー操作の閾値
    const flickThreshold = 30;
    const dragThreshold  = 15;

    /// 以下のいずれかのアクションが起こった場合、指を離すまでドラッグ系の操作を無効にする
    /// ①Hold機能でミノが入れ替わる ②ハードドロップ ③ソフトドロップによってフィックス
    var _isFunctionEnabledByGesture = true;

    /// 左右移動・ソフトドロップ時のドラッグ累積距離を保持（指が離れたらリセット）
    var cumulativeDeltaXOfLeftDrag  = 0.0;
    var cumulativeDeltaXOfRightDrag = 0.0;
    var cumulativeDeltaYOfDownDrag  = 0.0;

    return Consumer<MinoController>(
      builder: (context, minoController, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute<void>(builder: (context) => TetrisHomePage()));
              }
            ),
            title: Text(gameLevel),
            actions: [
              IconButton(
                icon: _getStartOrPauseButtonIcon(minoController.gameStatus),
                onPressed: () => minoController.startOrPause(),
              ),
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
              SizedBox(
                height: displaySize.height,
                width: displaySize.width,
                child: minoController.gameStatus != GameStatus.play ? null : GestureDetector(
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
                    left: 5,
                    top: 20,
                    child: GestureDetector(
                      onTap: () => minoController.changeHoldMinoAndFallingMino(),
                      child: Container(
                        height: nextHoldWindowWidthAndHeight,
                        width: nextHoldWindowWidthAndHeight,
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
                    right: 5,
                    top: 20,
                    child: Container(
                      height: nextHoldWindowWidthAndHeight,
                      width: nextHoldWindowWidthAndHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next1ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModelAt(1)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 20 + nextHoldWindowWidthAndHeight + 20,
                    child: Container(
                      height: nextHoldWindowWidthAndHeight,
                      width: nextHoldWindowWidthAndHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: CustomPaint( /// Next2ミノを描画
                        painter: NextOrHoldMinoPainter(minoController.minoRingBuffer.getMinoModelAt(2)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 20 + nextHoldWindowWidthAndHeight + 20 + nextHoldWindowWidthAndHeight + 20,
                    child: Container(
                      height: nextHoldWindowWidthAndHeight,
                      width: nextHoldWindowWidthAndHeight,
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

  Icon _getStartOrPauseButtonIcon(GameStatus gameStatus) {
    switch (gameStatus) {
    // プレイ前・一時停止中
      case GameStatus.ready:
      case GameStatus.pause:
        return const Icon(Icons.play_arrow);
    // プレイ中
      case GameStatus.play:
        return const Icon(Icons.pause);
    // ゲームオーバーしてたら
      case GameStatus.gameOver:
        return const Icon(Icons.do_not_disturb_alt);
    }
  }
}