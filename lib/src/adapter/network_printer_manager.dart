import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_escpos/src/enums/connection_response.dart';

import 'package:flutter_escpos/src/model/pos_printer.dart';

import '../printer_manager.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: network_printer_manager.dart
/// Author: zhoufan
/// Date: 2022/4/20 10:41
/// Description:

class NetworkPrinterManager extends PrinterManager {
  static NetworkPrinterManager get instance => _getInstance();
  static NetworkPrinterManager _instance;

  static RawSocket _device;
  static POSPrinter _printer;

  NetworkPrinterManager._internal();

  static NetworkPrinterManager _getInstance() {
    if (_instance == null) {
      _instance = NetworkPrinterManager._internal();
    }
    return _instance;
  }

  factory NetworkPrinterManager() => _getInstance();

  @override
  Future<ConnectionResponse> connect(POSPrinter printer,
      {Duration timeout}) async {
    try {
      _device = await RawSocket.connect(printer.address, 9100,
          timeout: const Duration(seconds: 5));
      this.isConnected = true;
      return Future<ConnectionResponse>.value(ConnectionResponse.success);
    } catch (e) {
      print("报错了" + e.toString());
      this.isConnected = false;
      return Future<ConnectionResponse>.value(ConnectionResponse.timeout);
    }
  }

  @override
  Future<ConnectionResponse> disconnect({Duration timeout}) async {
    await _device.close();
    return ConnectionResponse.success;
  }

  @override
  Future<ConnectionResponse> write(List<int> data,
      {bool isDisconnect = true}) async {
    if (!this.isConnected) {
      await connect(_printer);
    }
    try {
      Uint8List bytes = Uint8List.fromList(data);
      final int sliceSize = 1024;
      int bufferLength = bytes.length;

      print("打印内容的长度" + bufferLength.toString());

      if (bufferLength > sliceSize) {
        int round = (bufferLength / sliceSize).ceil();
        for (int i = 0; i < round; i++) {
          int fromIndex = i * sliceSize;
          if ((i + 1) * sliceSize <= bufferLength) {
            _device.write(bytes, fromIndex, sliceSize);
          } else {
            _device.write(bytes, fromIndex);
          }
        }
      } else {
        _device.write(bytes);
      }

      return ConnectionResponse.success;
    } catch (e) {
      print("打印机错误 $e");
      rethrow;
    }
  }

  @override
  Future<List> discover() {
    // TODO: implement discover
    throw UnimplementedError();
  }
}
