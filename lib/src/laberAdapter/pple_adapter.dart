import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_escpos/src/textStyle.dart';
import 'package:fast_gbk/fast_gbk.dart';
import '../enums/label_enums.dart';
import '../label_interface.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: pple_adapter
/// Author: zhoufan
/// Date: 2023/7/14 11:16
/// Description:

class PPLEAdapter implements LabelInterFace {
  @override
  List<int> bytes = [];

  @override
  String commandString = '';

  @override
  String endTag = 'W1';

  @override
  int ratio;

  @override
  String startTag = 'N\r\n';

  @override
  CommandType type = CommandType.PPLE;

  int copyPage;

  @override
  Future<void> bLine(int startX, int startY, int endX, int endY,
      {int thickness = 1, String color = 'B'}) async {
    String message =
        'LS${startX * ratio},${startY * ratio},$thickness,${endX * ratio},${endY * ratio}\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> barCode(int x, int y, BarcodeType type, String content,
      {Turn turn = Turn.turn0,
      bool check = false,
      int height = 40,
      bool isShowCode = true,
      bool isBelow = false}) async {
    String _pre;
    switch (type) {
      case BarcodeType.CODE11:
        _pre = '';
        break;
      case BarcodeType.CODE39:
        _pre = '3';
        break;
      case BarcodeType.CODE49:
        _pre = '';
        break;
      case BarcodeType.CODE93:
        _pre = '9';
        break;
      case BarcodeType.CODE128:
        _pre = '1';
        break;
      case BarcodeType.EAN8:
        _pre = 'E80';
        break;
      case BarcodeType.EAN13:
        _pre = 'E30';
        break;
      case BarcodeType.UPCA:
        _pre = 'UA0';
        break;
      case BarcodeType.UPCE:
        _pre = 'UE0';
        break;
    }

    String turnStr;
    switch (turn) {
      case Turn.turn270:
        turnStr = '3';
        break;
      case Turn.turn90:
        turnStr = '1';
        break;
      case Turn.turn180:
        turnStr = '2';
        break;
      case Turn.turn0:
        turnStr = '0';
        break;
    }

    String isShow;
    if (isShowCode) {
      isShow = 'B';
    } else {
      isShow = 'N';
    }

    String message =
        'B${x * ratio},${y * ratio},$turnStr,$_pre,3,5,$height,$isShow,"$content"\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> box(int x, int y,
      {double width = 1,
      double height = 1,
      int thickness = 1,
      String color = 'B',
      int radius = 0}) async {
    String message =
        'X${x * ratio},${y * ratio},$thickness,${((x + width) * ratio).toInt()},${((y + height) * ratio).toInt()}\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> hLine(int x, int y,
      {double width = 1, int thickness = 1, String color = 'B'}) async {
    String message;
    if (color == 'B') {
      message = 'LO${x * ratio},${y * ratio},${width * ratio},$thickness\r\n';
    } else {
      message = 'LW${x * ratio},${y * ratio},${width * ratio},$thickness\r\n';
    }

    commandString += message;
    bytes += message.codeUnits;
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
      int mask = 7}) async {
    String turnStr;
    switch (turn) {
      case Turn.turn270:
        turnStr = '3';
        break;
      case Turn.turn90:
        turnStr = '1';
        break;
      case Turn.turn180:
        turnStr = '2';
        break;
      case Turn.turn0:
        turnStr = '0';
        break;
    }

    String message =
        'b${x * ratio},${y * ratio},QR,0,0,o$turnStr,r$scale,m$model,g$quality,s$mask,"$content"\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> setup(num width, num height, int pRatio,
      {int gap = 3,
      int density,
      int speed,
      Offset origin = const Offset(0, 0),
      int copy = 1}) async {
    ratio = pRatio; // 全部保存，计算是需要用到
    copyPage = copy;
    commandString += startTag;
    bytes += startTag.codeUnits;
    String message =
        'q${width * ratio}\r\nQ${height * ratio},${gap * ratio}\r\n' +
            'S$speed\r\nR${origin.dx * ratio},${origin.dy * ratio}\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> text(int x, int y, String text, {TextStyles style}) async {
    String turnChar;

    // 旋转方向
    switch (style.turn) {
      case Turn.turn270:
        turnChar = '3';
        break;
      case Turn.turn90:
        turnChar = '1';
        break;
      case Turn.turn180:
        turnChar = '2';
        break;
      case Turn.turn0:
        turnChar = '0';
        break;
    }

    String fontFamily;
    int scaleX = style.scaleX;
    int scaleY = style.scaleY;

    switch (style.fontType) {
      case FontFamily.ZH16:
        fontFamily = '7';
        scaleX = scaleX ~/ 16;
        scaleY = scaleY ~/ 16;
        break;
      case FontFamily.ZH24:
        fontFamily = '7';
        scaleX = scaleX ~/ 24;
        scaleY = scaleX ~/ 24;
        break;
      case FontFamily.VZH:
        fontFamily = '7';
        break;
      case FontFamily.ENG12:
        fontFamily = '1';
        break;
      case FontFamily.ENG24:
        fontFamily = '4';
        break;
      case FontFamily.ENG48:
        fontFamily = '5';
        break;
      case FontFamily.VENG:
        fontFamily = '8';
        scaleX = scaleX ~/ 8;
        scaleY = scaleY ~/ 12;
        break;
    }

    String textInfo = 'T${x * ratio},${y * ratio},$turnChar,$fontFamily,' +
        '$scaleX,$scaleY,N,"$text"\r\n';
    commandString += textInfo;
    List<int> texHex = gbk.encode(textInfo);
    bytes += texHex;
  }

  @override
  Future<void> vLine(int x, int y,
      {double height = 1, int thickness = 1, String color = 'B'}) async {
    String message;
    if (color == 'B') {
      message = 'LO${x * ratio},${y * ratio},$thickness,${height * ratio}\r\n';
    } else {
      message = 'LW${x * ratio},${y * ratio},$thickness,${height * ratio}\r\n';
    }
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> builder() async {
    String message = endTag + ',$copyPage\r\n';
    commandString += message;
    bytes += message.codeUnits;
    log('\n' + commandString, name: '完整指令集');
  }

  @override
  clearBuffer() {
    commandString = '';
    bytes = [];
  }
}
