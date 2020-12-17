import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mino_model.dart';
import 'mino_ring_buffer.dart';
import 'sound_controller.dart';

final random = math.Random();

class MinoController extends ChangeNotifier{
  /// 落下までの秒数（msec)
  int intervalMSecOfOneStepDown;
  MinoController(this.intervalMSecOfOneStepDown);

  /// ゲームの状態（プレイ中、一時停止中、ゲームオーバー）
  GameStatus gameStatus = GameStatus.ready;

  /// 落下中のミノが下端もしくは、フィックスミノに接地しているかを示す
  bool isGrounded = false;

  /// Hold機能に関する変数
  bool isHoldFunctionUsed = false;

  /// 設置中のユーザー操作に関する変数
  bool isUpdateMinoByGestureDuringGrounding = false; // 設置中に回転か移動を行うとtrueになる
  int isUpdateCountByGestureDuringGrounding = 0;     // 設置中に回転か移動を行った回数（1つのミノに対して）

  /// ミノに関する変数（落下中、Hold、フィックス済）
  MinoRingBuffer minoRingBuffer = MinoRingBuffer(); // 落下中のミノをリングバッファとして保持
  MinoModel holdMino;
  List<List<MinoType>> fixedMinoArrangement = List.generate(20, (index) => List.generate(10, (index) => MinoType.values[0])); // 落下して位置が決まったすべてのミノ（フィックスしたミノ）
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

  /// スタート or 一時停止
  void startOrPause() {
    switch (gameStatus) {
      // 初めてのタップでゲームスタート
      case GameStatus.ready:
        gameStatus = GameStatus.play;
        mainLoop(30);
        break;
      // プレイ中にタップで一時停止
      case GameStatus.play:
        gameStatus = GameStatus.pause;
        notifyListeners();
        break;
      // 一時停止中にタップでゲーム再開
      case GameStatus.pause:
        gameStatus = GameStatus.play;
        break;
    }
  }

  /// ゲームオーバー
  void gameOver() {
    debugPrint('ゲームオーバー');
  }

  /// =============
  /// メインのループ
  /// =============
  Future<void> mainLoop(int fps) async {

    /// ミノを生成する
    _generateFallingMino();

    /// 落下 or Fix までの待ちフレーム数 = fps * 秒数
    final _thresholdFrameForIsNotGrounded = fps * intervalMSecOfOneStepDown; // 落下
    final _thresholdFrameForIsGrounded    = fps * 0.5;                       // Fix

    /// 落下中・設置中に待ったフレーム数
    var frameDuringIsNotGrounded = 0;
    var frameDuringIsGrounded    = 0;

    /// ===============================
    /// ループ開始（ゲームオーバーになるまで）
    /// （一時停止中はスルー）
    /// ===============================
    while (gameStatus != GameStatus.gameOver) {

      // プレイ中のみ、画面更新などを行う
      if (gameStatus == GameStatus.play) {

        /// ミノが落下中で、指定した秒数たったら、1段落とす
        if (!isGrounded) {
          frameDuringIsGrounded = 0; // 設置中のフレームカウントをリセットしておく
          frameDuringIsNotGrounded++;
          if (frameDuringIsNotGrounded % _thresholdFrameForIsNotGrounded == 0) {
            oneStepDown();
          }
        }
        /// ミノが接地中だったら0.5秒後にフィックスさせる
        /// ただし、接地中にユーザーの操作があれば、さらに0.5秒待つ（15回まで可能）
        else if (isGrounded) {
          frameDuringIsNotGrounded = 0; // 落下中のフレームカウントをリセットしておく

          // 設置中に横移動か回転があった場合、新たに0.5秒の猶予を与える
          if (isUpdateMinoByGestureDuringGrounding && isUpdateCountByGestureDuringGrounding < 15) {
            frameDuringIsGrounded = 0;
            isUpdateMinoByGestureDuringGrounding = false;
          }
          // 何も操作なく0.5秒たったら、ミノをフィックスさせる
          else {
            frameDuringIsGrounded++;
            if (frameDuringIsGrounded % _thresholdFrameForIsGrounded == 0) {
              _fixMinoAndGenerateFallingMino();
            }
          }
        }

      }

      final waitTime = Duration(microseconds: 1000000 ~/ fps);
      await Future<void>.delayed(waitTime);
    }

    gameOver();
  }


  /// 落下中のミノを生成する
  void _generateFallingMino() {

    // 落下中のミノを生成する（ポインタを1つ進める）
    minoRingBuffer.goForwardPointer();

    // Hold機能使用済みフラグをリセットする
    isHoldFunctionUsed = false;

    // 設置フラグ更新
    updateIsGrounded();

    // 0.5秒の猶予の使用回数をリセット
    isUpdateCountByGestureDuringGrounding = 0;

    // 衝突判定
    if (minoRingBuffer.getFallingMinoModel().hasCollision(fixedMinoArrangement)) {
      gameStatus = GameStatus.gameOver;
    }

    notifyListeners();
  }

  /// ミノをフィックスして、新たなに落下中のミノを生成する
  void _fixMinoAndGenerateFallingMino() {
    final minoModel = minoRingBuffer.getFallingMinoModel();
    var yPos = minoModel.yPos;

    for (final side in minoModel.minoArrangement) {
      var xPos = minoModel.xPos;
      for (final minoType in side) {
        if (minoType != MinoType.none) {
          fixedMinoArrangement[yPos][xPos] = minoType;
        }
        xPos++;
      }
      yPos++;
    }

    // 消せる行があったら、消す
    _deleteLineIfPossible();

    // 落下中のミノを生成する
    _generateFallingMino();
  }

  /// 削除可能な行があれば削除する
  void _deleteLineIfPossible() {
    final deleteLineIndexes = <int>[];

    // 削除する行番号を取得
    for (var index = 0 ; index < 20 ; index++) {
      if (fixedMinoArrangement[index].every((minoType) => minoType != MinoType.none)) {
        deleteLineIndexes.add(index);
      }
    }

    // 消す行があるかないかで、効果音を切り分ける
    if (deleteLineIndexes.length > 0) {
      SoundsController.playSound(SoundType.deleteLine);
    }
    else {
      SoundsController.playSound(SoundType.fix);
    }

    // 削除実行
    for (final deleteLineIndex in deleteLineIndexes) {
      fixedMinoArrangement.removeAt(deleteLineIndex);
      fixedMinoArrangement.insert(0, List.generate(10, (index) => MinoType.values[0]));
    }
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

  /// 落下中のミノが設置しているか調べて、フラグ(isGrounded)を更新する
  void updateIsGrounded() {
    isGrounded = minoRingBuffer.getFallingMinoModel().checkIsGrounded(fixedMinoArrangement);
  }

  /// =========================
  /// ユーザー操作で呼ばれるメソッド
  /// =========================

  /// 回転
  bool rotate(MinoAngleCW minoAngleCW) {
    final result = minoRingBuffer.getFallingMinoModel().rotateMino(minoAngleCW, fixedMinoArrangement, minoRingBuffer);

    // 設置中に回転できた場合、isUpdateMinoByGestureDuringGroundingを更新する
    if (isGrounded && result) {
      isUpdateMinoByGestureDuringGrounding = true;
      isUpdateCountByGestureDuringGrounding++;
    }

    // 回転できた場合、音を鳴らす
    if (result) {
      SoundsController.playSound(SoundType.rotate);
    }

    // 設置フラグ更新
    updateIsGrounded();

    notifyListeners();
    return result;
  }

  /// 左右移動
  bool moveHorizontalBy({int x}) {
    final result = minoRingBuffer.getFallingMinoModel().moveBy(x, 0, fixedMinoArrangement, minoRingBuffer);

    // 設置中に移動できた場合、isUpdateMinoByGestureDuringGroundingを更新する
    if (isGrounded && result) {
      isUpdateMinoByGestureDuringGrounding = true;
      isUpdateCountByGestureDuringGrounding++;
    }

    // 設置フラグ更新
    updateIsGrounded();

    notifyListeners();
    return result;
  }

  /// ハードドロップ
  void doHardDrop() {
    final fallMinoModel = getFallMinoModel();
    minoRingBuffer.changeFallingMinoModel(fallMinoModel);
    _fixMinoAndGenerateFallingMino();
  }

  /// 1段落とす
  bool oneStepDown() {
    if (!minoRingBuffer.getFallingMinoModel().moveBy(0, 1, fixedMinoArrangement, minoRingBuffer)) {
      return false;
    }

    // 設置フラグ更新
    updateIsGrounded();

    notifyListeners();
    return true;
  }

  /// Hold機能
  bool changeHoldMinoAndFallingMino() {
    if (isHoldFunctionUsed || minoRingBuffer.pointer == -1)
      return false;

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
    return true;
  }
}

enum GameStatus {
  ready,
  play,
  pause,
  gameOver,
}