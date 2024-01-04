import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_escpos/src/enums/label_enums.dart';
import 'package:flutter_escpos/src/textStyle.dart';
import '../label_interface.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: zpl_adapter
/// Author: zhoufan
/// Date: 2023/7/15 00:34
/// Description:

class ZPLAdapter implements LabelInterFace {
  @override
  List<int> bytes = [];

  @override
  String commandString = '';

  @override
  String endTag = '^XZ\n';

  @override
  int ratio;

  @override
  String startTag =
      '^XA\n^SEE:GB.DAT^FS\n^CW7,MHeiGB18030C-Medium.TTF^FS\n^CI28\n';

  @override
  CommandType type;

  @override
  Future<void> bLine(int startX, int startY, int endX, int endY,
      {int thickness = 1, String color = 'B'}) async {
    String message = '^FO${startX * ratio},${startX * ratio}\n' +
        '^GD${(endX - startX) * ratio},${(endY - startY) * ratio},${thickness},$color,R^FS\n';
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

    String turnStr;

    switch (turn) {
      case Turn.turn0:
        turnStr = 'N';
        break;
      case Turn.turn90:
        turnStr = 'R';
        break;
      case Turn.turn180:
        turnStr = 'I';
        break;
      case Turn.turn270:
        turnStr = 'B';
        break;
    }

    switch (type) {
      case BarcodeType.CODE11:
        _pre = '^B1$turnStr,$check,$height,$isShowCode,$isBelow';
        break;
      case BarcodeType.CODE39:
        _pre = '^B3$turnStr,$check,$height,$isShowCode,$isBelow';
        break;
      case BarcodeType.CODE49:
        _pre = '^B4$turnStr,$height,$isShowCode,A';
        break;
      case BarcodeType.CODE93:
        _pre = '^BA$turnStr,$height,$isShowCode,$isBelow,$check';
        break;
      case BarcodeType.CODE128:
        _pre = '^BC$turnStr,$height,$isShowCode,$isBelow,$check,N';
        break;
      case BarcodeType.EAN8:
        _pre = '^B8$turnStr,$height,$isBelow';
        break;
      case BarcodeType.EAN13:
        _pre = '^BE$turnStr,$height,$isShowCode,$isBelow';
        break;
      case BarcodeType.UPCA:
        _pre = '^BU$turnStr,$height,$isShowCode,$isBelow,$check';
        break;
      case BarcodeType.UPCE:
        _pre = '^B9$turnStr,$height,$isShowCode,$isBelow,$check';
        break;
    }

    String command = '^FO${x * ratio},${y * ratio}$_pre\n^FDMM,A$content^FS\n';
    commandString += command;
    bytes += command.codeUnits;
  }

  @override
  Future<void> box(int x, int y,
      {double width = 1,
      double height = 1,
      int thickness = 1,
      String color = 'B',
      int radius = 0}) async {
    String message = '^FO${x * ratio},${y * ratio}' +
        '^GB${width * ratio},${height * ratio},${thickness},$color,$radius^FS\n';
    commandString += message;
    bytes += message.codeUnits;
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
    commandString = '';
    bytes = [];
  }

  @override
  Future<void> hLine(int x, int y,
      {double width = 1, int thickness = 1, String color = 'B'}) async {
    String message = '^FO${x * ratio},${y * ratio}' +
        '^GB${width * ratio},0,${thickness},$color,0^FS\n';
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
      case Turn.turn0:
        turnStr = 'N';
        break;
      case Turn.turn90:
        turnStr = 'R';
        break;
      case Turn.turn180:
        turnStr = 'I';
        break;
      case Turn.turn270:
        turnStr = 'B';
        break;
    }
    String message;
    message = '^FO${x * ratio},${y * ratio}' +
        '^BQ$turnStr,$model,$scale,$quality,$mask\n';
    String text = '^FDMM,A$content^FS\n';
    message += text;
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> setup(num width, num height, int pRatio,
      {int gap, int density, int speed, Offset origin, int copy = 1}) async {
    ratio = pRatio;
    String message = '';
    message += startTag;
    message += '^CI28\n^PW${width * ratio}\n^LL${height * ratio}\n' +
        '^PR$speed\n^MD$density\n^LH${origin.dx * ratio},${origin.dy * ratio}\n' +
        '^PQ1,0,$copy,N\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> text(int x, int y, String text, {TextStyles style}) async {
    if (style == null) {
      style = TextStyles();
    }

    String turnChar;

    // 旋转方向
    switch (style.turn) {
      case Turn.turn270:
        turnChar = 'I';
        break;
      case Turn.turn90:
        turnChar = 'R';
        break;
      case Turn.turn180:
        turnChar = 'B';
        break;
      case Turn.turn0:
        turnChar = 'N';
        break;
    }

    String textInfo = '^FO${x * ratio},${y * ratio}' +
        '^A${style.fontFamily},$turnChar,${style.scaleY},${style.scaleX}^FD$text^FS\n';
    commandString += textInfo;
    List<int> texHex = utf8.encode(textInfo);
    bytes += texHex;
  }

  @override
  Future<void> vLine(int x, int y,
      {double height = 1, int thickness = 1, String color = 'B'}) async {
    String message = '^FO${x * ratio},${y * ratio}' +
        '^GB0,${height * ratio},${thickness},$color,0^FS\n';
    commandString += message;
    bytes += message.codeUnits;
  }
}
