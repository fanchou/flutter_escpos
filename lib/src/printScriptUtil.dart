import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

/// FileName: printScriptUtil
/// Author: zhoufan
/// Date: 2022/4/18 21:35
/// Description: print until

class PrintScriptUtil {

  final PaperSize paperSize;
  final CapabilityProfile profile;

  List<int> _bytes;
  Generator _generator;

  PrintScriptUtil(this.paperSize, this.profile, {int spaceBetweenRows = 5}) {
    _bytes = [];
    _generator =
        Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);
  }

  List<int> get bytes => _bytes;

  PrintScriptUtil reset() {
    _bytes = []; // reset data;
    _bytes += _generator.reset();
    return this;
  }

  PrintScriptUtil text(String text,
      {PosStyles styles = const PosStyles(),
      int linesAfter = 0,
      bool containsChinese = false,
      int maxCharsPerLine}) {
    _bytes += _generator.text(text,
        styles: styles,
        linesAfter: linesAfter,
        containsChinese: containsChinese,
        maxCharsPerLine: maxCharsPerLine);
    return this;
  }

  PrintScriptUtil setGlobalCodeTable(String codeTable) {
    _bytes += _generator.setGlobalCodeTable(codeTable);
    return this;
  }

  PrintScriptUtil setGlobalFont(PosFontType font, {int maxCharsPerLine}) {
    _bytes += _generator.setGlobalFont(font, maxCharsPerLine: maxCharsPerLine);
    return this;
  }

  PrintScriptUtil setStyles(PosStyles styles, {bool isKanji = false}) {
    _bytes += _generator.setStyles(styles, isKanji: isKanji);
    return this;
  }

  PrintScriptUtil rawBytes(List<int> cmd, {bool isKanji = false}) {
    _bytes += _generator.rawBytes(cmd, isKanji: isKanji);
    return this;
  }

  PrintScriptUtil emptyLines(int n) {
    _bytes += _generator.emptyLines(n);
    return this;
  }

  PrintScriptUtil feed(int n) {
    _bytes += _generator.feed(n);
    return this;
  }

  PrintScriptUtil cut({PosCutMode mode = PosCutMode.full}) {
    _bytes += _generator.cut(mode: mode);
    return this;
  }

  PrintScriptUtil printCodeTable({String codeTable}) {
    _bytes += _generator.printCodeTable(codeTable: codeTable);
    return this;
  }

  PrintScriptUtil beep(
      {int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
    _bytes += _generator.beep(n: n, duration: duration);
    return this;
  }

  PrintScriptUtil reverseFeed(int n) {
    _bytes += _generator.reverseFeed(n);
    return this;
  }

  PrintScriptUtil row(List<PosColumn> cols) {
    _bytes += _generator.row(cols);
    return this;
  }

  PrintScriptUtil image(Image imgSrc, {PosAlign align = PosAlign.center}) {
    _bytes += _generator.image(imgSrc, align: align);
    return this;
  }

  PrintScriptUtil imageRaster(
    Image image, {
    PosAlign align = PosAlign.center,
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
    PosImageFn imageFn = PosImageFn.bitImageRaster,
  }) {
    _bytes += _generator.imageRaster(
      image,
      align: align,
      highDensityHorizontal: highDensityHorizontal,
      highDensityVertical: highDensityVertical,
      imageFn: imageFn,
    );
    return this;
  }

  PrintScriptUtil barcode(
    Barcode barcode, {
    int width,
    int height,
    BarcodeFont font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) {
    _bytes += _generator.barcode(
      barcode,
      width: width,
      height: height,
      font: font,
      textPos: textPos,
      align: align,
    );
    return this;
  }

  PrintScriptUtil qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) {
    _bytes += _generator.qrcode(text, align: align, size: size, cor: cor);
    return this;
  }

  PrintScriptUtil drawer({PosDrawer pin = PosDrawer.pin2}) {
    _bytes += _generator.drawer(pin: pin);
    return this;
  }

  PrintScriptUtil hr({String ch = '-', int len, int linesAfter = 0}) {
    _bytes += _generator.hr(ch: ch, linesAfter: linesAfter);
    return this;
  }

  PrintScriptUtil textEncoded(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int maxCharsPerLine,
  }) {
    _bytes += _generator.textEncoded(
      textBytes,
      styles: styles,
      linesAfter: linesAfter,
      maxCharsPerLine: maxCharsPerLine,
    );
    return this;
  }
}
