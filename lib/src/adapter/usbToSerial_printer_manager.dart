import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_escpos/src/enums/connection_response.dart';
import 'package:flutter_escpos/src/model/pos_printer.dart';
import '../printer_manager.dart';
import 'package:usb_serial/usb_serial.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: usbToSerial_printer_manager.dart
/// Author: zhoufan
/// Date: 2023/8/28 16:44
/// Description: USB转串口，只适用于Android、Windows

class UsbToSerialPrinterManager extends PrinterManager {
  static UsbPort _port;
  static UsbDevice _device;
  static POSPrinter _printer;

  static UsbToSerialPrinterManager get instance => _getInstance();
  static UsbToSerialPrinterManager _instance;

  UsbToSerialPrinterManager._internal();

  static UsbToSerialPrinterManager _getInstance() {
    if (_instance == null) {
      _instance = UsbToSerialPrinterManager._internal();
    }
    return _instance;
  }

  factory UsbToSerialPrinterManager() => _getInstance();

  @override
  Future<ConnectionResponse> connect(POSPrinter printer,
      {Duration timeout}) async {
    _printer = printer;
    _device = printer.usbDevice;
    _port = await _device.create();
    if (_port == null) {
      log('创建设备失败~');
      return ConnectionResponse.unknown;
    }

    bool openResult = await _port.open();
    if (!openResult) {
      log('打开设备失败~');
      return ConnectionResponse.unknown;
    }
    // 设置创客参数
    await setPortParameters(9200);
    isConnected = true;
    return ConnectionResponse.success;
  }

  // 设置串口参数
  Future<void> setPortParameters(int baudRate) async {
    await _port.setDTR(true);
    await _port.setRTS(true);
    await _port.setPortParameters(
        baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
  }

  @override
  Future<ConnectionResponse> disconnect({Duration timeout}) async {
    await _port.close();
    isConnected = false;
    return ConnectionResponse.success;
  }

  @override
  Future<List<UsbDevice>> discover() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    return devices;
  }

  @override
  Future<ConnectionResponse> write(List<int> data,
      {bool isDisconnect = true}) async {
    if (!this.isConnected) {
      await connect(_printer);
    }
    Uint8List bytes = Uint8List.fromList(data);
    _port.write(bytes);
    return ConnectionResponse.success;
  }
}
