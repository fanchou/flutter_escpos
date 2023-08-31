import '../../flutter_escpos.dart';
import 'package:usb_serial/usb_serial.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: usbToSeril_printer
/// Author: zhoufan
/// Date: 2023/8/31 11:11
/// Description:

class UsbToSerialPrinter extends POSPrinter {
  UsbToSerialPrinter({
    String id,
    String name,
    String address,
    int deviceId,
    int vendorId,
    int productId,
    bool connected = false,
    int type = 6,
    UsbDevice usbDevice,
    ConnectionType connectionType,
  }) {
    this.id = id;
    this.name = name;
    this.address = address;
    this.deviceId = deviceId;
    this.vendorId = vendorId;
    this.productId = productId;
    this.connected = connected;
    this.type = type;
    this.usbDevice = usbDevice;
    this.connectionType = ConnectionType.serial;
  }
}
