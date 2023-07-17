import 'dart:developer';
import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter_escpos/src/enums/label_enums.dart';

import 'package:flutter_escpos/src/textStyle.dart';

import '../label_interface.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: cpcl_adapter
/// Author: zhoufan
/// Date: 2023/7/14 16:31
/// Description:

class CPCLAdapter implements LabelInterFace {
  @override
  List<int> bytes = [];

  @override
  String commandString = '';

  @override
  String endTag = 'PRINT\r\n';

  @override
  int ratio;

  @override
  String startTag = '';

  @override
  CommandType type;

  @override
  Future<void> bLine(int startX, int startY, int endX, int endY,
      {int thickness = 1, String color = 'B'}) async {
    if (color == 'B') {
      commandString +=
          'LINE ${startX * ratio} ${startY * ratio} ${endX * ratio} ${endY * ratio} $thickness\r\n';
    } else {
      commandString +=
          'INVERSE-LINE ${startX * ratio} ${startY * ratio} ${endX * ratio} ${endY * ratio} $thickness\r\n';
    }
  }

  @override
  Future<void> barCode(int x, int y, BarcodeType type, String content,
      {Turn turn = Turn.turn0,
      bool check = false,
      int height = 40,
      bool isShowCode = true,
      bool isBelow = false}) async {
    // 类型
    String _type;

    // 水平还是竖直
    String _turnString;

    if (true == Turn.turn90) {
      _turnString = 'VB';
    } else {
      _turnString = 'B';
    }

    switch (type) {
      case BarcodeType.CODE11:
        _type = '';
        break;
      case BarcodeType.CODE39:
        _type = '39';
        break;
      case BarcodeType.CODE49:
        _type = '';
        break;
      case BarcodeType.CODE93:
        _type = '93';
        break;
      case BarcodeType.CODE128:
        _type = '128';
        break;
      case BarcodeType.EAN8:
        _type = 'EAN8';
        break;
      case BarcodeType.EAN13:
        _type = 'EAN13';
        break;
      case BarcodeType.UPCA:
        _type = 'UPCA';
        break;
      case BarcodeType.UPCE:
        _type = 'UPCE';
        break;
    }

    String command =
        '$_turnString $_type 2 2 $height ${x * ratio} ${y * ratio} $content\r\n';
    commandString += command;
    bytes += commandString.codeUnits;
  }

  @override
  Future<void> box(int x, int y,
      {double width = 1,
      double height = 1,
      int thickness = 1,
      String color = 'B',
      int radius = 0}) async {
    commandString +=
        'BOX ${x * ratio} ${y * ratio} ${(x + width) * ratio} ${(y + height) * ratio} $thickness\r\n';
    bytes += commandString.codeUnits;
  }

  @override
  Future<void> builder() async {
    commandString += endTag;
    bytes += endTag.codeUnits;
    // TODO 最好debug模式下才开启
    log('\n' + commandString, name: '完整指令集');
  }

  @override
  clearBuffer() {
    // TODO: implement clearBuffer
    throw UnimplementedError();
  }

  @override
  Future<void> hLine(int x, int y,
      {double width = 1, int thickness = 1, String color = 'B'}) async {
    if (color == 'B') {
      commandString +=
          'LINE ${x * ratio} ${y * ratio} ${(x + width) * ratio} $y $thickness\r\n';
    } else {
      commandString +=
          'INVERSE-LINE ${x * ratio} ${y * ratio} ${(x + width) * ratio} $y $thickness\r\n';
    }
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
      int scale = 6,
      String quality = 'Q',
      int mask = 7}) async {
    commandString += 'B QR ${x * ratio} ${y * ratio} M $model U $scale\r\n' +
        '$quality $mask MA,$content\r\nENDQR\r\n';
    bytes += commandString.codeUnits;
  }

  @override
  Future<void> setup(num width, num height, int pRatio,
      {int gap, int density = 0, int speed = 3, Offset origin}) async {
    ratio = pRatio; // 全部保存，计算是需要用到
    commandString += '!0 ${width * ratio} ${height * ratio} 1\r\n' +
        'SPEED $speed\r\n' +
        'CONTRAST $density\r\n';
    bytes += commandString.codeUnits;
  }

  @override
  Future<void> text(int x, int y, String text, {TextStyles style}) async {
    String turnChar;
    // 旋转方向
    switch (style.turn) {
      case Turn.turn270:
        if (!style.inverse) {
          turnChar = 'TEXT270';
        } else {
          turnChar = 'TEXT270';
        }
        break;
      case Turn.turn90:
        if (!style.inverse) {
          turnChar = 'TEXT90';
        } else {
          turnChar = 'TR90';
        }
        break;
      case Turn.turn180:
        if (!style.inverse) {
          turnChar = 'TEXT180';
        } else {
          turnChar = 'TR180';
        }
        break;
      case Turn.turn0:
        if (!style.inverse) {
          turnChar = 'TEXT';
        } else {
          turnChar = 'TR';
        }
        break;
    }

    if (!style.isBold) {
      commandString += 'SETBOLD 0\r\n' +
          'SETMAG ${style.scaleX} ${style.scaleY}\r\n' +
          '$turnChar ${style.fontFamily} 0 ${x * ratio} ${y * ratio} $text\r\n';
    } else {
      commandString += 'SETBOLD 2\r\n' +
          'SETMAG ${style.scaleX} ${style.scaleY}\r\n' +
          '$turnChar ${style.fontFamily} 0 ${x * ratio} ${y * ratio} $text\r\n';
    }
  }

  @override
  Future<void> vLine(int x, int y,
      {double height = 1, int thickness = 1, String color = 'B'}) async {
    if (color == 'B') {
      commandString +=
          'LINE ${x * ratio} ${y * ratio} ${x * ratio} ${(y + height) * ratio} $thickness\r\n';
    } else {
      commandString +=
          'INVERSE-LINE ${x * ratio} ${y * ratio} ${x * ratio} ${(y + height) * ratio} $thickness\r\n';
    }
  }
}