import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_escpos/src/enums/label_enums.dart';
import 'package:flutter_escpos/src/textStyle.dart';
import 'package:fast_gbk/fast_gbk.dart';
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
  String endTag = 'PRINT ';

  @override
  int ratio;

  @override
  String startTag;

  @override
  CommandType type;

  int copyPage;

  @override
  Future<void> bLine(int startX, int startY, int endX, int endY,
      {int thickness = 1, String color = 'B'}) async {
    String message =
        'BAR ${startX * ratio},${startY * ratio},${endX * ratio},${endY * ratio}\r\n';
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
    String readable;
    String typeStr;
    String rotation;
    int narrow;
    int wide;
    switch (type) {
      case BarcodeType.CODE11:
        typeStr = '11';
        narrow = 2;
        wide = 4;
        break;
      case BarcodeType.CODE39:
        typeStr = '39';
        narrow = 2;
        wide = 4;
        break;
      case BarcodeType.CODE49:
        typeStr = 'CODE49';
        narrow = 2;
        wide = 2;
        break;
      case BarcodeType.CODE93:
        typeStr = 'CODE93';
        narrow = 2;
        wide = 6;
        break;
      case BarcodeType.CODE128:
        typeStr = '128';
        narrow = 2;
        wide = 2;
        break;
      case BarcodeType.EAN8:
        typeStr = 'EAN8';
        narrow = 2;
        wide = 2;
        break;
      case BarcodeType.EAN13:
        typeStr = 'EAN13';
        narrow = 2;
        wide = 2;
        break;
      case BarcodeType.UPCA:
        typeStr = 'UPCA';
        narrow = 2;
        wide = 2;
        break;
      case BarcodeType.UPCE:
        typeStr = 'UPCE';
        narrow = 2;
        wide = 2;
        break;
    }

    switch (turn) {
      case Turn.turn0:
        rotation = '0';
        break;
      case Turn.turn90:
        rotation = '90';
        break;
      case Turn.turn180:
        rotation = '180';
        break;
      case Turn.turn270:
        rotation = '270';
        break;
    }

    if (isShowCode) {
      readable = '2';
    } else {
      readable = '0';
    }

    String message =
        "BARCODE ${x * ratio},${y * ratio},$typeStr,$height,$readable $rotation,$narrow,$wide,0,$content\r\n";
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
    // BOX x,y,x_end,y_end,line thickness[,radius]
    String message = 'BOX ${x * ratio},${y * ratio},${(x + width) * ratio},' +
        '${(y + height) * ratio},$thickness,$radius\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> builder() async {
    String message = endTag + ',$copyPage\r\n';
    commandString += message;
    log('\n' + commandString, name: '完整指令集');
    bytes += message.codeUnits;
  }

  @override
  clearBuffer() {
    bytes = [];
    String message = "CLS\r\n";
    bytes += message.codeUnits;
  }

  @override
  Future<void> hLine(
    int x,
    int y, {
    double width = 1,
    int thickness = 1,
    String color = 'B',
  }) async {
    String message =
        'BAR ${x * ratio},${y * ratio},${width * ratio},$thickness\r\n';
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
      int scale = 4,
      String quality = 'Q',
      int mask = 7}) async {
    String rotation;
    switch (turn) {
      case Turn.turn0:
        rotation = '0';
        break;
      case Turn.turn90:
        rotation = '90';
        break;
      case Turn.turn180:
        rotation = '180';
        break;
      case Turn.turn270:
        rotation = '270';
        break;
    }
    String message =
        'QRCODE ${x * ratio},${y * ratio},$quality,$scale,A,$rotation,M1,S$mask,"$content"\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> setup(num width, num height, int pRatio,
      {int gap = 3,
      int density = 8,
      int speed,
      Offset origin,
      int copy = 1}) async {
    ratio = pRatio;
    String message;
    copyPage = copy;
    String labelSize = 'SIZE $width mm, $height mm';
    String speed_value = 'SPEED $speed';
    String density_value = 'DENSITY $density';
    String gapValue = 'GAP $gap mm, 0 mm'; // TODO 暂不实现黑标检测
    message = labelSize +
        "\n" +
        speed_value +
        "\n" +
        density_value +
        "\n" +
        gapValue +
        "\n";
    commandString += message;
    bytes += message.codeUnits;
  }

  @override
  Future<void> text(int x, int y, String text, {TextStyles style}) async {
    String turnStr;
    switch (style.turn) {
      case Turn.turn0:
        turnStr = '0';
        break;
      case Turn.turn90:
        turnStr = '90';
        break;
      case Turn.turn180:
        turnStr = '180';
        break;
      case Turn.turn270:
        turnStr = '270';
        break;
    }
    String message = 'TEXT ${x * ratio},${y * ratio},"${style.fontFamily}",' +
        '$turnStr,${style.scaleX},${style.scaleY},$text\r\n';
    commandString += message;
    bytes += gbk.encode(message);
  }

  @override
  Future<void> vLine(int x, int y,
      {double height = 1, int thickness = 1, String color = 'B'}) async {
    // BAR x,y,width,height
    String message =
        'BAR ${x * ratio},${y * ratio},$thickness,${height * ratio}\r\n';
    commandString += message;
    bytes += message.codeUnits;
  }
}
