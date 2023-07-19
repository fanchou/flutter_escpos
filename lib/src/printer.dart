import 'package:flutter_escpos/src/printer_manager.dart';

import '../flutter_escpos.dart';
import 'model/pos_printer.dart';

/// FileName: printer
/// Author: zhoufan
/// Date: 2021/9/14 11:56
/// Description:

class Printer<T extends PrinterManager> {
  T adapter;
  Printer(this.adapter);

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

  // 打印方法
  Future<void> print(List<int> data) async {
    await adapter.write(data);
  }
}
