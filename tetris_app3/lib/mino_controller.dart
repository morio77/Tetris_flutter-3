import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mino_model.dart';
import 'mino_ring_buffer.dart';

const int lowerLimitOfFallSpeed = 100; // 落下速度の下限
final random = math.Random();

class MinoController extends ChangeNotifier{
  MinoController(this.IntervalMSecOfOneStepDown);
  int IntervalMSecOfOneStepDown;

  // タップ中における左右累積移動距離（ミノの左右moveが発生・指が離れたら0にリセット）
  double cumulativeLeftDrag = 0;
  double cumulativeRightDrag = 0;

  bool isFixed = true; // 落下中のミノがフィックスしたか
  bool isGameOver = false; // ゲームオーバーになったかどうか。
  // 7種1巡の法則が適用された、出現するミノをリングバッファとして保持
  MinoRingBuffer minoRingBuffer = MinoRingBuffer();
  MinoModel holdMino;
  bool isHoldFunctionUsed = false; // Hold機能は1つのミノに対して一回まで
  bool isPossibleHardDrop = true; // ハードドロップを1度使用したら、指が離れるまではfalseにしておく
  int millSecondIn1Loop = 0;
  bool doneHardDropIn1Loop = false;
  int memoryCurrentFallSpeed;

  /// 落下して位置が決まったすべてのミノ（フィックスしたミノ）
  List<List<MinoType>> fixedMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => MinoType.values[0]));
  // ↓こんな感じなのができる
  // [
  //   [0,0,0,0,0,0,0,0,0,0,], // 0 ではなく、本当はenumで表している
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  //   [0,0,0,0,0,0,0,0,0,0,],
  // ];

  /// ゲームスタート
  void startGame() {
    // メインループへ
    mainLoop(30);
  }

  /// ゲームオーバー
  void gameOver() {
    debugPrint('ゲームオーバー');
  }

  /// =============
  /// メインのループ
  /// =============
  /// ①ミノを生成する
  /// ②1マス落下処理
  Future<void> mainLoop(int fps) async {

    /// 画面更新するまでの待ちフレーム数  =  fps  *  落下までの秒数
    final _thresholdFrame = fps * IntervalMSecOfOneStepDown;

    var frame = 0;

    // ゲームオーバーになるまで、ループを続ける
    while (!isGameOver) {
      frame++;
      if (frame % _thresholdFrame == 0) {

        // フィックスしていれば、落下中のミノを生み出す
        if (isFixed) {
          _generateFallingMino();
        }
        // フィックスしていなければ1段落とす
        else {
          _subRoutine();
        }
      }
      final waitTime = Duration(microseconds: 1000000 ~/ fps);
      await Future<void>.delayed(waitTime);
    }

    gameOver();
  }



  /// 前処理
  void _generateFallingMino() {

    // 落下中のミノがなければ、落下中のミノを生成する（ポインタを1つ進める）
    minoRingBuffer.goForwardPointer();

    // Hold機能使用済みフラグをリセットする
    isHoldFunctionUsed = false;

    // 衝突判定
    if (minoRingBuffer.getFallingMinoModel().hasCollision(fixedMinoArrangement)) {
      debugPrint('衝突');
      isGameOver = true;
    }

    // フィックスフラグを解除
    isFixed = false;

    notifyListeners();
  }

  /// 1段落とす
  void _subRoutine() {
    int deferralCount = 0; // 0.5秒の猶予を使える回数

    // 1段落下させられるなら、1段落下させて、
    // 落下できなかったら、フィックス判定（ToDo:0.5秒の猶予処理に移る）
    if (!minoRingBuffer.moveIfCan(0, 1, fixedMinoArrangement)) {
      isFixed = true;
    }

    // // 0.5秒の猶予（15回まで使える）
    // if (isFixed && deferralCount < 15) {
    //
    //   // ToDo:ここでタイマーの時間を0.5に変えてなんとかできないか
    //
    //   if (!_isCollideBottom()) {
    //     isFixed = false;
    //     deferralCount++;
    //   }
    // }

    notifyListeners();

    if (isFixed) {
      _postProcessing();
    }

  }

  /// 後処理
  void _postProcessing() {
    // カレントミノをフィックスさせる
    MinoModel minoModel = minoRingBuffer.getFallingMinoModel();
    int y = minoModel.yPos;
    minoModel.minoArrangement.forEach((side) {
      int x = minoModel.xPos;
      side.forEach((minoType) {
        if (minoType != MinoType.none) fixedMinoArrangement[y][x] = minoType;
        x++;
      });
      y++;
    });

    isFixed = true;
    isPossibleHardDrop = false;

    // 消せる行があったら、消す
    _deleteLineIfCan();

    notifyListeners();

    // // 落下速度を速める
    // _changeFallSpeed();
  }

  void _changeFallSpeed() {
    if (IntervalMSecOfOneStepDown > lowerLimitOfFallSpeed){
      IntervalMSecOfOneStepDown--;
    }

    if (memoryCurrentFallSpeed > lowerLimitOfFallSpeed) {
      memoryCurrentFallSpeed--;
    }
  }

  void _deleteLineIfCan() {
    var deleteLineIndexs = List<int>();

    // 削除する行番号を取得
    for (int index = 0 ; index < 20 ; index++) {
      if (fixedMinoArrangement[index].every((minoType) => minoType != MinoType.none)) {
        deleteLineIndexs.add(index);
      }
    }

    // 削除実行
    deleteLineIndexs.forEach((index) {
      fixedMinoArrangement.removeAt(index);
      fixedMinoArrangement.insert(0, List.generate(10, (index) => MinoType.values[0]));
    });

  }

  /// 回転
  void rotate(MinoAngleCW minoAngleCW) {
    minoRingBuffer.rotateIfCan(minoAngleCW, fixedMinoArrangement);
    notifyListeners();
  }

  /// 左右移動
  void moveHorizontal(int moveXPos) {
    minoRingBuffer.moveIfCan(moveXPos, 0, fixedMinoArrangement);
    notifyListeners();
  }

  /// 落下予測位置を取得する
  MinoModel getFallMinoModel() {
    var _fallMinoModel = minoRingBuffer.getFallingMinoModel().copyWith();
    var _oneStepDownMinoModel = _fallMinoModel.copyWith(yPos: _fallMinoModel.yPos + 1);

    while (!_oneStepDownMinoModel.hasCollision(fixedMinoArrangement)) {
      _fallMinoModel = _oneStepDownMinoModel.copyWith();
      _oneStepDownMinoModel = _oneStepDownMinoModel.copyWith(yPos: _oneStepDownMinoModel.yPos + 1);
    }

    return _fallMinoModel;
  }

  /// ハードドロップ
  void doHardDrop() {
    var fallMinoModel = getFallMinoModel();
    minoRingBuffer.changeFallingMinoModel(fallMinoModel);
    _postProcessing();

    // 時間を待たずに、ループの先頭に戻る
    doneHardDropIn1Loop = true;

    notifyListeners();
  }

  /// ソフトドロップON
  void OnSoftDropMode() {
    memoryCurrentFallSpeed = IntervalMSecOfOneStepDown;
    IntervalMSecOfOneStepDown = 100;
  }

  /// ソフトドロップOFF
  void OffSoftDropMode() {
    IntervalMSecOfOneStepDown = memoryCurrentFallSpeed;
  }

  /// Hold機能
  void changeHoldMinoAndFallingMino() {
    if (isHoldFunctionUsed || minoRingBuffer.pointer == -1) return;

    if (holdMino == null) {
      holdMino = minoRingBuffer.getFallingMinoModel();
      minoRingBuffer.goForwardPointer();
    }
    else {
      final _willFallingMinoModel = MinoModel(holdMino.minoType, holdMino.minoAngleCW, 4, 0);
      holdMino = minoRingBuffer.getFallingMinoModel();
      minoRingBuffer.changeFallingMinoModel(_willFallingMinoModel);
    }
    isHoldFunctionUsed = true;
    notifyListeners();
  }
}