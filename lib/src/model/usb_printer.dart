import 'package:flutter_escpos/src/model/pos_printer.dart';

import '../enums/connection_type.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: usb_printer
/// Author: zhoufan
/// Date: 2022/3/13 15:40
/// Description:

class USBPrinter extends POSPrinter {
  USBPrinter({
    String? id,
    String? name,
    String? address,
    int? deviceId,
    int? vendorId,
    int? productId,
    bool connected = false,
    int type = 0,
    ConnectionType? connectionType,
  }) {
    this.id = id;
    this.name = name;
    this.address = address;
    this.deviceId = deviceId;
    this.vendorId = vendorId;
    this.productId = productId;
    this.connected = connected;
    this.type = type;
    this.connectionType = ConnectionType.usb;
  }
}
