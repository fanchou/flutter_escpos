import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:hex/hex.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: zplCommand
/// Author: zhoufan
/// Date: 2023/7/6 15:51
/// Description:

class ZPLPrinter {
  List<int> _bytes = [];
  List<int> get bytes => _bytes;

  String _commandString = '';

  String _startTag = '^XA\n';
  String _endTag = '^XZ\n';

  // todo 如果记录一个高度值，是否更加方便计算？？？

  // 点密度
  int ratio;

  /**
   * 打印机初始化
   *
   * @param width           纸宽度 单位：mm
   * @param height          纸高度 单位：mm
   * @param origin          打印原点坐标 单位：dp
   * @param speed           打印速度  缺省值：3
   *                        其他值：2 到 5，A 到 E
   *                        A 对应的速度为 2，B 对应为 3，C 对应为 4，D 和 E 均是对应 4。
   * @param ratio           打印机的点密度 即每毫米多少个点
   *                        6 dp/mm = 152dpi
   *                        8 dp/mm = 203dpi
   *                        12 dp/mm = 300dpi
   *                        24 dp/mm = 600dpi
   * @param density         打印相对浓度， 0 缺省值， -30-30
   *                        设置相对当前设置的绝对浓度增加或减少等级。计算公式是
   *                        绝对浓度+相对浓度=浓度。如果数字小于 0 或者大于 30，则浓度回绕，
   *                        从头或者从尾再计算。如当前 15，^MD-17，则浓度为 28
   */

  Future<void> setup(
    int width,
    int height,
    int printerRatio, {
    int density = 10,
    Offset origin = const Offset(0, 0),
    int speed = 3,
  }) async {
    ratio = printerRatio; // 全部保存，计算是需要用到
    _commandString += '^CI28\n^PW${width * ratio}\n^LL${height * ratio}\n' +
        '^PR$speed\n^MD$density\n^LH${origin.dx * ratio},${origin.dy * ratio}\n';
    _bytes += _commandString.codeUnits;
  }

  Future<void> builder() async {
    String fullCommand = _startTag + _commandString + _endTag;
    log('\n' + fullCommand, name: '完整指令集');
  }

  clearBuffer() {
    _commandString = '';
    _bytes = [];
  }

  /**
   * 打印文字
   *
   * @param x        x坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param y        y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param style    文字的样式，封装成一个类了
   */
  Future<void> text(
    int x,
    int y,
    String text, {
    TextStyles style,
  }) async {
    if (style == null) {
      style = TextStyles();
    }

    String turnChar;
    String alignChar;

    // 旋转方向
    switch (style.turn) {
      case ZPLTurn.Inverted:
        turnChar = 'I';
        break;
      case ZPLTurn.Roated:
        turnChar = 'R';
        break;
      case ZPLTurn.Bottom:
        turnChar = 'B';
        break;
    }

    // 对齐方式
    switch (style.align) {
      case ZPLAlign.Left:
        alignChar = '0';
        break;
      case ZPLAlign.Right:
        alignChar = '1';
        break;
      case ZPLAlign.Auto:
        alignChar = '2';
        break;
    }

    _commandString += '^FW$turnChar,$alignChar\n';
    _bytes += _commandString.codeUnits;
    String textInfo = '^FO${x * ratio},${y * ratio}' +
        '^A${style.fontFamily},${style.scaleX},${style.scaleY}^FD$text^FS\n';
    _commandString += textInfo;
    List<int> texHex = utf8.encode(textInfo);
    _bytes += texHex;
  }

  /**
   * 打印文字
   *
   * @param x          x坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param y          y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param width      框的宽度 单位：mm
   * @param height     框的高度 单位：mm
   * @param thickness  边框的粗细 单位：mm  1～9999
   * @param color      边框的颜色 单位：B = 黑色 W = 白色
   * @param radius     边框圆角值 0～8
   */
  Future<void> box(
    int x,
    int y, {
    int width = 1,
    int height = 1,
    int thickness = 1,
    String color = 'B',
    int radius = 0,
  }) async {
    _commandString += '^FO${x * ratio},${y * ratio}' +
        '^GB${width * ratio},${height * ratio},${thickness},$color,$radius^FS\n';
    _bytes += _commandString.codeUnits;
  }

  /**
   * 打印文字
   *
   * @param x          x坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param y          y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param width      框的宽度 单位：mm
   */
  Future<void> image(
    int x,
    int y,
    Uint8List imageBytes, {
    String compression = 'A',
  }) async {
    decodeImageFromList(imageBytes, (image) {
      final _widthBytes = image.width ~/ 8;
      final _total = _widthBytes * image.height;
      final _hexCode = HEX.encode(imageBytes);
      final _asciiCode = String.fromCharCodes(HEX.decode(_hexCode));
      _commandString += '^FO${x * ratio},${y * ratio}' +
          '^GF$compression,$_total,$_total,$_widthBytes,$_asciiCode^FS\n';
      _bytes += _commandString.codeUnits;
    });
  }
}

class TextStyles {
  // 旋转方向
  // 对齐方式
  // 字体类型
  // 字体大小
  const TextStyles({
    this.fontFamily = '7', // todo 这个是不靠谱的，不同打印机可能是不同的
    this.scaleX = 24,
    this.scaleY = 24,
    this.align = ZPLAlign.Auto,
    this.turn = ZPLTurn.Inverted,
  });

  // 字体类型
  // todo 文字打印跟字体类型有关
  final String fontFamily;

  // x 方向上的缩放大小
  final int scaleX;

  // x 方向上的缩放大小
  final int scaleY;

  // 对齐方式
  final ZPLAlign align;

  // 旋转方向
  final ZPLTurn turn;
}

// 对齐方式
enum ZPLAlign { Left, Right, Auto }

// 旋转方向 90、180、270
enum ZPLTurn { Roated, Inverted, Bottom }
