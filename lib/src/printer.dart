import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

import '../flutter_escpos.dart';
import 'model/pos_printer.dart';

/// FileName: printer
/// Author: zhoufan
/// Date: 2021/9/14 11:56
/// Description:

class Printer {
  final dynamic adapter;
  final PaperSize _paperSize;
  final CapabilityProfile _profile;
  Generator _generator;

  PaperSize get paperSize => _paperSize;
  CapabilityProfile get profile => _profile;

  Printer(this._paperSize, this._profile, this.adapter,
      {int spaceBetweenRows = 5}) {
    _generator = Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);
  }

  // 查找打印机
  Future<List<POSPrinter>> findPrinter() async {
    return await adapter.discover();
  }

  // 连接打印机
  Future<void> connect(POSPrinter printer) async {
    await adapter.connect(printer);
  }

  // 关闭打印机
  Future<void> disconnect() async {
    await adapter.disconnect();
  }


  Future<void> reset() async {
    await adapter.write(_generator.reset());
  }

  Future<void> text(String text,
      {PosStyles styles = const PosStyles(),
      int linesAfter = 0,
      bool containsChinese = false,
      int maxCharsPerLine}) async {
    await adapter.write(_generator.text(text,
        styles: styles,
        linesAfter: linesAfter,
        containsChinese: containsChinese,
        maxCharsPerLine: maxCharsPerLine));
  }

  Future<void> setGlobalCodeTable(String codeTable) async {
    await adapter.write(_generator.setGlobalCodeTable(codeTable));
  }

  Future<void> setGlobalFont(PosFontType font, {int maxCharsPerLine}) async {
    await adapter.write(
        _generator.setGlobalFont(font, maxCharsPerLine: maxCharsPerLine));
  }

  Future<void> setStyles(PosStyles styles, {bool isKanji = false}) async {
    await adapter.write(_generator.setStyles(styles, isKanji: isKanji));
  }

  Future<void> rawBytes(List<int> cmd, {bool isKanji = false}) async {
    await adapter.write(_generator.rawBytes(cmd, isKanji: isKanji));
  }

  Future<void> emptyLines(int n) async {
    await adapter.write(_generator.emptyLines(n));
  }

  Future<void> feed(int n) async {
    await adapter.write(_generator.feed(n));
  }

  Future<void> cut({PosCutMode mode = PosCutMode.full}) async {
    await adapter.write(_generator.cut(mode: mode));
  }

  Future<void> printCodeTable({String codeTable}) async {
    await adapter.write(_generator.printCodeTable(codeTable: codeTable));
  }

  Future<void> beep(
      {int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) async {
    await adapter.write(_generator.beep(n: n, duration: duration));
  }

  Future<void> reverseFeed(int n) async {
    await adapter.write(_generator.reverseFeed(n));
  }

  Future<void> row(List<PosColumn> cols) async {
    await adapter.write(_generator.row(cols));
  }

  Future<void> image(Image imgSrc, {PosAlign align = PosAlign.center}) async {
    await adapter.write(_generator.image(imgSrc, align: align));
  }

  Future<void> imageRaster(
    Image image, {
    PosAlign align = PosAlign.center,
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
    PosImageFn imageFn = PosImageFn.bitImageRaster,
  }) async {
    await adapter.write(_generator.imageRaster(
      image,
      align: align,
      highDensityHorizontal: highDensityHorizontal,
      highDensityVertical: highDensityVertical,
      imageFn: imageFn,
    ));
  }

  Future<void> barcode(
    Barcode barcode, {
    int width,
    int height,
    BarcodeFont font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) async {
    await adapter.write(_generator.barcode(
      barcode,
      width: width,
      height: height,
      font: font,
      textPos: textPos,
      align: align,
    ));
  }

  Future<void> qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) async {
    await adapter
        .write(_generator.qrcode(text, align: align, size: size, cor: cor));
  }

  Future<void> drawer({PosDrawer pin = PosDrawer.pin2}) async {
    await adapter.write(_generator.drawer(pin: pin));
  }

  Future<void> hr({String ch = '-', int len, int linesAfter = 0}) async {
    await adapter.write(_generator.hr(ch: ch, linesAfter: linesAfter));
  }

  Future<void> textEncoded(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int maxCharsPerLine,
  }) async {
    await adapter.write(_generator.textEncoded(
      textBytes,
      styles: styles,
      linesAfter: linesAfter,
      maxCharsPerLine: maxCharsPerLine,
    ));
  }
}
