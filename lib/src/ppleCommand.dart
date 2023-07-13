import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:hex/hex.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: ppleCommand
/// Author: zhoufan
/// Date: 2023/7/6 15:51
/// Description:

class PPLEPrinter {
  List<int> _bytes = [];
  List<int> get bytes => _bytes;

  String _commandString = '';

  String _startTag = 'N\n';
  String _endTag = 'W1\n';

  // todo 如果记录一个高度值，是否更加方便计算？？？

  // 点密度
  int ratio;

  /**
   * 打印机初始化
   *
   * @param width           纸宽度 单位：mm
   * @param height          纸高度 单位：mm
   * @param origin          打印原点坐标 单位：dp
   * @param speed           打印速度  缺省值：0 -6 10 -80
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
    int gap = 3,
    Offset origin = const Offset(0, 0),
    int speed = 3,
  }) async {
    ratio = printerRatio; // 全部保存，计算是需要用到
    _commandString +=
        'q${width * ratio}<CR><LE>Q${height * ratio},${gap * ratio}<CR><LE>' +
            'S$speed<CR><LE>R${origin.dx * ratio},${origin.dy * ratio}<CR><LE>';
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

    // 旋转方向
    switch (style.turn) {
      case ZPLTurn.Inverted:
        turnChar = '3';
        break;
      case ZPLTurn.Roated:
        turnChar = '1';
        break;
      case ZPLTurn.Bottom:
        turnChar = '2';
        break;
      case ZPLTurn.Normal:
        turnChar = '0';
        break;
    }

    String textInfo =
        'T${x * ratio},${y * ratio},$turnChar,${style.fontFamily}' +
            '${style.scaleX},${style.scaleY},N,$text<CR><LE>';
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
    double width = 1,
    double height = 1,
    int thickness = 1,
    String color = 'B',
    int radius = 0,
  }) async {
    _commandString += '^FO${x * ratio},${y * ratio}' +
        '^GB${width * ratio},${height * ratio},${thickness},$color,$radius^FS\n';
    _bytes += _commandString.codeUnits;
  }

  /**
   * 打印二维码
   *
   * @param x          x坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param y          y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param content    二维码内容
   * @param turn       旋转方向
   * @param model      模式 默认值: 2(增强型)
      其他值: 1(原始型)
   * @param scale      放大因子
      默认值:2(200dpi 机器)/3(300dpi 机器)
      其他值:1 到 10
   * @param quality    纠错率
      默认值:Q(参数为空)/M(参数非法)
      其他值:H = 超高纠错等级
      Q = 高纠错等级
      M = 普通纠错等级
      L = 高密度等级
   * @param mask       掩码
      默认值: 7
      其他值: 0 到 7
   */

  Future<void> qrCode(
    int x,
    int y,
    String content, {
    String turn = 'N',
    int model = 2,
    int scale = 2,
    String quality = 'Q',
    int mask = 7,
  }) async {
    _commandString += '^FO${x * ratio},${y * ratio}' +
        '^BQ$turn,$model,$scale,$quality,$mask\n';
    String text = '^FDMM,A$content^FS\n';
    _commandString += text;
    _bytes += _commandString.codeUnits;
  }

  /**
   * 打印条码
   *
   * @param x          x坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param y          y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param type       条码的类型
   * @param content    条码内容
   * @param turn       旋转方向
   * @param check      校验位
      默认值：N(No) = 不打印校验位
      其他值: Y(Yes) = 打印校验位
   * @param height     条码高度
      默认值:由^BY 设置
      其他值:1 到 9999 点
   * @param isShowCode 是否打印识别码
      默认值: Y = 打印(Yes)
      其他值:N = 不打印(No)
   * @param isBelow    将识别码打印在条码上方
      默认值: N = 不打印在条码上方
      其他值: Y = 打印在条码上方
   */
  Future<void> barCode(int x, int y, BarcodeType type, String content,
      {String turn = 'N',
      String check = 'N',
      int height = 40,
      String isShowCode = 'Y',
      String isBelow = 'N'}) async {
    String _pre;
    switch (type) {
      case BarcodeType.CODE11:
        _pre = '^B1$turn,$check,$height,$isShowCode,$isBelow';
        break;
      case BarcodeType.CODE39:
        _pre = '^B3$turn,$check,$height,$isShowCode,$isBelow';
        break;
      case BarcodeType.CODE49:
        _pre = '^B4$turn,$height,$isShowCode,A';
        break;
      case BarcodeType.CODE93:
        _pre = '^BA$turn,$height,$isShowCode,$isBelow,$check';
        break;
      case BarcodeType.CODE128:
        _pre = '^BC$turn,$height,$isShowCode,$isBelow,$check,N';
        break;
      case BarcodeType.EAN8:
        _pre = '^B8$turn,$height,$isBelow';
        break;
      case BarcodeType.EAN13:
        _pre = '^BE$turn,$height,$isShowCode,$isBelow';
        break;
      case BarcodeType.UPCA:
        _pre = '^BU$turn,$height,$isShowCode,$isBelow,$check';
        break;
      case BarcodeType.UPCE:
        _pre = '^B9$turn,$height,$isShowCode,$isBelow,$check';
        break;
    }

    String command = '^FO${x * ratio},${y * ratio}$_pre\n^FDMM,A$content^FS\n';
    _commandString += command;
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
    this.turn = ZPLTurn.Normal,
  });

  // 字体类型
  // todo 文字打印跟字体类型有关
  final String fontFamily;

  // x 方向上的缩放大小
  final int scaleX;

  // x 方向上的缩放大小
  final int scaleY;

  // 旋转方向
  final ZPLTurn turn;
}

// 对齐方式
enum ZPLAlign { Left, Right, Auto }

// 旋转方向 正常、90、180、270
enum ZPLTurn { Normal, Roated, Inverted, Bottom }

// 条码类型
enum BarcodeType {
  CODE11,
  CODE39,
  CODE49,
  CODE93,
  CODE128,
  EAN8,
  EAN13,
  UPCA,
  UPCE
}
