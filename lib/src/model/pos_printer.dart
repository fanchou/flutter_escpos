import '../enums/connection_type.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: pos_printer
/// Author: zhoufan
/// Date: 2022/3/13 15:39
/// Description:

class POSPrinter {
  String id;
  String name;
  String address;
  int deviceId;
  int vendorId;
  int productId;
  bool connected;
  int type;
  ConnectionType connectionType;

  factory POSPrinter.instance() => POSPrinter();

  POSPrinter({
    this.id,
    this.name,
    this.address,
    this.deviceId,
    this.vendorId,
    this.productId,
    this.connected: false,
    this.type: 0,
    this.connectionType,
  });
}
