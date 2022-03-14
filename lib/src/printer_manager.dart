import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'enums/connection_response.dart';
import 'model/pos_printer.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: printer_manager.dart
/// Author: zhoufan
/// Date: 2022/3/13 15:33
/// Description:

abstract class PrinterManager {
  PaperSize paperSize;
  CapabilityProfile profile;
  Generator generator;
  bool isConnected = false;
  String address;
  int vendorId;
  int productId;
  int deviceId;
  int port = 9100;
  int spaceBetweenRows = 5;
  POSPrinter printer;

  Future<ConnectionResponse> connect({Duration timeout});

  Future<ConnectionResponse> writeBytes(List<int> data, {bool isDisconnect: true});

  Future<ConnectionResponse> disconnect({Duration timeout});

}
