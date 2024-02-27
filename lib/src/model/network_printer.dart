import '../../flutter_escpos.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: network_printer
/// Author: zhoufan
/// Date: 2022/4/20 11:25
/// Description:

class NetworkPrinter extends POSPrinter {
  NetworkPrinter({
    String? name,
    required String address,
    int? port,
    bool connected = false,
    int type = 1,
    ConnectionType? connectionType,
  }) {
    this.name = name;
    this.address = address;
    this.connected = connected;
    this.type = type;
    this.connectionType = ConnectionType.network;
  }
}
