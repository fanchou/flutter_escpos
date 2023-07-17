import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:hex/hex.dart';
import 'enums/label_enums.dart';
import 'textStyle.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: laberPrinter
/// Author: zhoufan
/// Date: 2023/7/14 09:59
/// Description: 条码打印接口

abstract class LabelInterFace {
  // 十进制指令
  List<int> bytes = [];

  // 字符串指令
  String commandString = '';

  // 开始标识
  String startTag;

  // 结束标识
  String endTag;

  // 打印机分辨率
  int ratio;

  // 指令集类型
  CommandType type;

  /** 初始化打印机
   * @param width     纸张宽度、单位mm
   * @param height    纸张高度、单位mm
   * @param height    纸张高度、单位mm
   * @param gap       标签间的间距、单位dot
   * @param density   打印浓度
   * @param speed     打印速度
   * @param origin    原点坐标
  */

  Future<void> setup(
    num width,
    num height,
    int pRatio, {
    int gap,
    int density,
    int speed,
    Offset origin,
  });

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
  });

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
  });

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
  });

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
  });

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
  });

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
  });

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
  });

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
    // todo 如何实现这个还需要考虑
    // TODO 最好直接指定图片就可以实现打印，具体可参考小票打印
    decodeImageFromList(imageBytes, (image) {
      final _widthBytes = image.width ~/ 8;
      final _total = _widthBytes * image.height;
      final _hexCode = HEX.encode(imageBytes);
      final _asciiCode = String.fromCharCodes(HEX.decode(_hexCode));
    });
  }

  // 构建指令
  Future<void> builder();

  // 清除
  clearBuffer();
}
