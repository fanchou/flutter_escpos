import 'dart:typed_data';
import 'package:image/image.dart';
// import 'package:gbk_codec/gbk_codec.dart';
import 'package:fast_gbk/fast_gbk.dart';

/// Copyright (C), 2019-2021, 深圳新语网络科技有限公司
/// FileName: tscCommand
/// Author: zhoufan
/// Date: 2021/9/17 13:10
/// Description: tsc commands

class TscPrinter{

  final dynamic adapter;

  TscPrinter(this.adapter);

  /**
   * 打印机初始化
   *
   * @param width           纸宽度
   * @param height          纸高度
   * @param speed           打印速度
   * @param density         打印浓度， 0 使用最淡的打印浓度， 15 使用最深的打印浓度
   * @param sensor          1. GAP
   *                        该指令定义两张卷标纸间的垂直间距距离
   *                        m 两标签纸中间的垂直距离
   *                        0≤m≤1（inch），0≤m≤25.4（mm）
   *                        n 垂直间距的偏移
   *                        n ≤ 标签纸张长度 (inch或mm)
   *                        2.不知道。。。
   * @param sensor_distance 传感器距离
   * @param sensor_offset   传感器偏移
   */
  Future<void> setup(int width, int height, int speed, int density, int sensor, int sensor_distance, int sensor_offset) async{
    String message;
    String size = "SIZE " + width.toString() + " mm" + ", " + height.toString() + " mm";
    String speed_value = "SPEED " + speed.toString();
    String density_value = "DENSITY " + density.toString();
    String sensor_value = "";
    if (sensor == 0) {
      sensor_value = "GAP " + sensor_distance.toString() + " mm" + ", " + sensor_offset.toString() + " mm";
    } else if (sensor == 1) {
      sensor_value = "BLINE " + sensor_distance.toString() + " mm" + ", " + sensor_offset.toString() + " mm";
    }
    message = size + "\n" + speed_value + "\n" + density_value + "\n" + sensor_value + "\n";

    await sendCommand(message);
  }

  /**
   * 打印文字
   *
   * @param x                文字 X 方向启始点坐标
   * @param y                文字 Y 方向启始点坐标
   * @param font             字体名称
   *                         1 8 x 12 dot 英数字体
   *                         2 12 x 20 dot英数字体
   *                         3 16 x 24 dot英数字体
   *                         4 24 x 32 dot英数字体
   *                         5 32 x 48 dot英数字体
   *                         6 14 x 19 dot英数字体 OCR-B
   *                         7 21 x 27 dot 英数字体OCR-B
   *                         8 14 x25 dot英数字体OCR-A
   *                         TST24.BF2 繁体中文 24 x 24 font (大五码)
   *                         TSS24.BF2 简体中文 24 x 24 font (GB 码)
   *                         K 韩文 24 x 24 font (KS 码)
   *                         注: 五号字英文字母仅可打印大写字母
   *                         若要打印双引号时(“)在程序中请使用\[“]来打印双引号
   *                         若要打印 0D(hex)字符时，请在程序中使用\[R]来打印 CR
   *                         若要打印 0A(hex)字符时，请在程序中使用\[A]来打印 LF
   * @param rotation         文字旋转角度(顺时钟方向)
   *                         0 0 度
   *                         90 90 度
   *                         180 180
   *                         270 270
   * @param x_multiplication X 方向放大倍率 1~10
   * @param y_multiplication Y 方向放大倍率 1~10
   * @param text             你要打印的文字
   * @return 范例 TEXT 100,100,”4”,0,1,1,”DEMO FOR TEXT
   */
  Future<void> text(int x, int y, String font, int rotation, int x_multiplication, int y_multiplication, String text) async {
    String message;
    String s = "TEXT ";
    String position = "$x,$y";
    String size_value = "\"" + font + "\"";
    String rota = "" + rotation.toString();
    String x_value = "" + x_multiplication.toString();
    String y_value = "" + y_multiplication.toString();
    String string_value = "\"" + text + "\"";
    message = s + position + "," + size_value + "," + rota + "," + x_value + "," + y_value + "," + string_value + "\r\n";
    await sendCommand(message);
  }

  Future<void> printlabel(int quantity, int copy) async {
    String message = "";
    message = "PRINT " + quantity.toString() + ", " + copy.toString() + "\r\n";
    await sendCommand(message);
  }

  /// barCode
  Future<void> barcode(int x, int y, String type, int height, int human_readable, int rotation, int narrow, int wide, String string) async {
    String message = "";
    String barcode = "BARCODE ";
    String position = x.toString() + "," + y.toString();
    String mode = "\"" + type + "\"";
    String height_value = "" + height.toString();
    String human_value = "" + human_readable.toString();
    String rota = "" + rotation.toString();
    String narrow_value = "" + narrow.toString();
    String wide_value = "" + wide.toString();
    String string_value = "\"" + string + "\"";
    message = barcode + position + " ," + mode + " ," + height_value + " ," + human_value + " ," + rota + " ," + narrow_value + " ," + wide_value + " ," + string_value + "\r\n";
    await sendCommand(message);
  }


  /**
   * qrcode
   *
   * @param x                The upper left corner x-coordinate of the QR code
   * @param y                The upper left corner y-coordinate of the QR code
   * @param eccLevel         Error correction recovery level
   *                         L 7%
   *                         M 15%
   *                         Q 25%
   *                         H 30%
   * @param cellWidth        1~10
   * @param mode             Auto / manual encode
   *                         A Auto
   *                         M Manual
   * @param rotation         0  0 degree
   *                         90 90 degree
   *                         180 180 degree
   *                         270 270 degree
   * @param model            M1: (default), original version
   *                         M2:  enhanced version (Almost smart phone is supported by this version.)
   * @param mask             S0~S8, default is S7
   * @param content          content
   * @return "QRCODE 50,50,H,4,A,0,M2,S7,\"123TSCtest\"\n"
   */
  Future<void> qrcode(int x, int y, String eccLevel, int cellWidth, String mode, int rotation, String version, String mask, String content) async {
    String message;
    String qrcode = "QRCODE ";
    String position = "$x,$y";
    String ecc = "$eccLevel";
    String size = "$cellWidth";
    String encodeMode = "$mode";
    String rota = "$rotation";
    String qrVersion = "$version";
    String qrMask = "$mask";
    String string_value = "\"" + content + "\"";
    message = qrcode + position + "," + ecc + "," + size + "," + encodeMode + "," + rota + "," + qrVersion + "," + qrMask + "," + string_value + "\r\n";
    print("二维码指令集合: " + message);
    await sendCommand(message);
  }

  /// This command draws a bar on the label format.
  Future<void> bar(int x, int y, int width, int height) async{
    String message;
    String bar = "BAR ";
    String position = "$x,$y";
    String barWidth = "$width";
    String barHeight = "$height";
    message = bar + position + "," + barWidth + "," + barHeight + "\r\n";
    await sendCommand(message);
  }

  /// PUTBMP
  Future<void> bmp(int x, int y, String name) async {
    String message;
    String bar = "PUTBMP ";
    String position = "$x,$y";
    String content = "\"" + name + "\"";
    message = bar + position +  ',' + content + "\r\n";
    await sendCommand(message);
  }

  /// Download
  Future<void> Download(String fileName,Image imgSrc) async {
    List<int> bytes = [];
    final Image image = Image.from(imgSrc);
    Uint8List imgData = image.getBytes();
    int size = imgData.elementSizeInBytes;
    String message;
    String downLoad = "DOWNLOAD ";
    String content = "\"" + fileName + "\"";
    message = downLoad + content + "," + size.toString();
    List<int> header = message.codeUnits;
    bytes += header;
    bytes += imgData.toList();
    try {
      await adapter.write(bytes);
    } catch (e) {
      print(e);
    }
  }

  /// todo bitmap
  /// todo box
  /// todo CIRCLE
  /// todo ELLIPSE
  /// todo ERASE
  ///

  /// clear buffer
  Future<void> clearBuffer() async {
    String message = "CLS\r\n";
    await sendCommand(message);
  }

  /// send Command
  Future sendCommand(String command) async {
    // Uint8List com = utf8.encode(command);
    List<int> data = gbk.encode(command);
    try {
      await adapter.write(data);
    } catch (e) {
      print(e);
    }
  }
}

