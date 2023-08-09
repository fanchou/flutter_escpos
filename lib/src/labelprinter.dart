import 'dart:typed_data';
import 'dart:ui';

import '../flutter_escpos.dart';
import 'enums/label_enums.dart';
import 'label_interface.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: labelprinter
/// Author: zhoufan
/// Date: 2023/7/14 13:35
/// Description:

class LabelPrinter<T extends LabelInterFace> {
  T instance;
  LabelPrinter(this.instance);

  // 十进制指令
  List<int> get bytes => instance.bytes;

  // 字符串指令
  String get commandString => instance.commandString;

  // 开始标识
  String get startTag => instance.startTag;

  // 结束标识
  String get endTag => instance.endTag;

  // 打印机分辨率
  int get ratio => instance.ratio;

  // 指令集类型
  CommandType get type => instance.type;

  /** 初始化打印机
   * @param width     纸张宽度、单位mm
   * @param height    纸张高度、单位mm
   * @param height    纸张高度、单位mm
   * @param gap       标签间的间距、单位dot
   * @param density   打印浓度
   * @param speed     打印速度
   * @param origin    原点坐标
   * @param origin    打印份数
   */

  Future<void> setup(
    num width,
    num height,
    int pRatio, {
    int gap = 3,
    int density = 8,
    int speed = 4,
    Offset origin = const Offset(0, 0),
    int copy = 1,
  }) async {
    instance.setup(width, height, pRatio,
        gap: gap, density: density, speed: speed, origin: origin, copy: copy);
  }

  /**
   * 打印文字
   * @param x         x坐标、单位mm
   * @param y         y坐标、单位mm
   * @param text      打印的内容
   * @param style     文字的样式
   */

  Future<void> text(
    int x,
    int y,
    String text, {
    TextStyles style,
  }) async {
    instance.text(x, y, text, style: style);
  }

  /**
   * 打印方形
   *
   * @param x          x坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param y          y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param width      框的宽度 单位：mm
   * @param height     框的高度 单位：mm
   * @param thickness  边框的粗细 单位：dot
   * @param color      边框的颜色 单位：B = 黑色 W = 白色
   * @param radius     边框圆角值 0～8 不一定都支持
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
    instance.box(x, y,
        width: width,
        height: height,
        thickness: thickness,
        color: color,
        radius: radius);
  }

  /**
   * 横线
   *
   * @param x          起始x坐标 单位：mm
   * @param y          起始y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param width      框的宽度 单位：mm
   * @param thickness  边框的粗细 单位：dot
   * @param color      边框的颜色 单位：B = 黑色 W = 白色
   */

  Future<void> hLine(
    int x,
    int y, {
    double width = 1,
    int thickness = 1,
    String color = 'B',
  }) async {
    instance.hLine(x, y, width: width, thickness: thickness, color: color);
  }

  /**
   * 竖线
   *
   * @param x          起始x坐标 单位：mm
   * @param y          起始y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param height     线的高度 单位：mm
   * @param thickness  边框的粗细 单位：dot
   * @param color      边框的颜色 单位：B = 黑色 W = 白色
   */

  Future<void> vLine(
    int x,
    int y, {
    double height = 1,
    int thickness = 1,
    String color = 'B',
  }) async {
    instance.vLine(x, y, height: height, thickness: thickness, color: color);
  }

  /**
   * 斜线
   *
   * @param x          起始x坐标 单位：mm
   * @param y          起始y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param height     线的高度 单位：mm
   * @param thickness  边框的粗细 单位：dot
   * @param color      边框的颜色 单位：B = 黑色 W = 白色
   */

  Future<void> bLine(
    int startX,
    int startY,
    int endX,
    int endY, {
    int thickness = 1,
    String color = 'B',
  }) async {
    instance.bLine(startX, startY, endX, endY,
        thickness: thickness, color: color);
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
    Turn turn = Turn.turn0,
    int model = 2,
    int scale = 2,
    String quality = 'Q', // TODO 需要统一为可选值
    int mask = 7,
  }) async {
    instance.qrCode(x, y, content,
        turn: turn, model: model, scale: scale, quality: quality, mask: mask);
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
  Future<void> barCode(
    int x,
    int y,
    BarcodeType type,
    String content, {
    Turn turn = Turn.turn0,
    bool check = false,
    int height = 40,
    bool isShowCode = true,
    bool isBelow = false,
  }) async {
    instance.barCode(x, y, type, content,
        turn: turn,
        check: check,
        height: height,
        isShowCode: isShowCode,
        isBelow: isBelow);
  }

  /**
   * 打印图片
   *
   * @param x                x坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param y                y坐标 单位：mm，注意这里是mm,会自动根据分辨率转化的
   * @param compression      编码方式
   */
  Future<void> image(
    int x,
    int y,
    Uint8List imageBytes, {
    String compression = 'A',
  }) async {
    instance.image(x, y, imageBytes, compression: compression);
  }

  // 构建指令
  Future<void> builder() async {
    instance.builder();
  }

  // 清除
  clearBuffer() {
    instance.clearBuffer();
  }
}
