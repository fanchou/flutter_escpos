import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:quick_usb/quick_usb.dart';
// import 'package:usb_serial/usb_serial.dart';
import '../enums/connection_type.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: pos_printer
/// Author: zhoufan
/// Date: 2022/3/13 15:39
/// Description:

class POSPrinter {
  String? id;
  String? name;
  String? address;
  int? port;
  int? deviceId;
  int? vendorId;
  int? productId;
  int? baudRate;
  bool? connected;
  int? type;
  BluetoothDevice? bluetoothDevice;
  UsbDevice? usbDevice;
  ConnectionType? connectionType;

  factory POSPrinter.instance() => POSPrinter();

  factory POSPrinter.fromMap(Map<dynamic, dynamic> map) {
    return POSPrinter(
      name: map['name'],
      address: map['address'],
      baudRate: map['baudRate'],
      deviceId: map['deviceId'],
      vendorId: map['vendorId'],
      productId: map['productId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'deviceId': deviceId,
      'vendorId': vendorId,
      'productId': productId
    };
  }

  POSPrinter({
    this.id,
    this.name,
    this.address,
    this.baudRate,
    this.port,
    this.deviceId,
    this.vendorId,
    this.productId,
    this.connected = false,
    this.type = 0,
    this.connectionType,
  });
}
