import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter_escpos/src/enums/label_enums.dart';

import 'package:flutter_escpos/src/textStyle.dart';

import '../label_interface.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: tsc_adapter
/// Author: zhoufan
/// Date: 2023/7/15 01:09
/// Description:

class TSCAdapter implements LabelInterFace {
  @override
  List<int> bytes;

  @override
  String commandString;

  @override
  String endTag;

  @override
  int ratio;

  @override
  String startTag;

  @override
  CommandType type;

  @override
  Future<void> bLine(int startX, int startY, int endX, int endY,
      {int thickness = 1, String color = 'B'}) {
    // TODO: implement bLine
    throw UnimplementedError();
  }

  @override
  Future<void> barCode(int x, int y, BarcodeType type, String content,
      {Turn turn = Turn.turn0,
      bool check = false,
      int height = 40,
      bool isShowCode = true,
      bool isBelow = false}) {
    // TODO: implement barCode
    throw UnimplementedError();
  }

  @override
  Future<void> box(int x, int y,
      {double width = 1,
      double height = 1,
      int thickness = 1,
      String color = 'B',
      int radius = 0}) {
    // TODO: implement box
    throw UnimplementedError();
  }

  @override
  Future<void> builder() {
    // TODO: implement builder
    throw UnimplementedError();
  }

  @override
  clearBuffer() {
    // TODO: implement clearBuffer
    throw UnimplementedError();
  }

  @override
  Future<void> hLine(int x, int y,
      {double width = 1, int thickness = 1, String color = 'B'}) {
    // TODO: implement hLine
    throw UnimplementedError();
  }

  @override
  Future<void> image(int x, int y, Uint8List imageBytes,
      {String compression = 'A'}) {
    // TODO: implement image
    throw UnimplementedError();
  }

  @override
  Future<void> qrCode(int x, int y, String content,
      {Turn turn = Turn.turn0,
      int model = 2,
      int scale = 2,
      String quality = 'Q',
      int mask = 7}) {
    // TODO: implement qrCode
    throw UnimplementedError();
  }

  @override
  Future<void> setup(num width, num height, int pRatio,
      {int gap, int density, int speed, Offset origin, int copy}) {
    // TODO: implement setup
    throw UnimplementedError();
  }

  @override
  Future<void> text(int x, int y, String text, {TextStyles style}) {
    // TODO: implement text
    throw UnimplementedError();
  }

  @override
  Future<void> vLine(int x, int y,
      {double height = 1, int thickness = 1, String color = 'B'}) {
    // TODO: implement vLine
    throw UnimplementedError();
  }
}
