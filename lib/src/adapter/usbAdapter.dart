import 'dart:async';
import 'dart:typed_data';
import 'package:quick_usb/quick_usb.dart';

/// FileName: usbAdapter
/// Author: zhoufan
/// Date: 2021/9/14 11:57
/// Description: usbAdapter

class UsbAdapter {
  static UsbConfiguration _configuration;
  static UsbEndpoint _endpoint;

  factory UsbAdapter() => _getInstance();
  static UsbAdapter get instance => _getInstance();
  static UsbAdapter _instance;

  UsbAdapter._internal() {
    _init();
  }

  static UsbAdapter _getInstance() {
    if (_instance == null) {
      _instance = UsbAdapter._internal();
    }
    return _instance;
  }

  /// init QuickUsb
  static void _init() async {
    bool init = await QuickUsb.init();
    print("QuickUSB init: $init");
  }

  static Future<bool> connect(UsbDevice device) async {
    bool openDevice = false;
    try {
      // reGetDevicesWithDescription
      List<UsbDeviceDescription> deviceList = await getDevicesWithDescription();
      device = deviceList
          .firstWhere((element) =>
              element.device.vendorId == device.vendorId &&
              element.device.productId == device.productId)
          .device;
      openDevice = await QuickUsb.openDevice(device);
      if (!openDevice) {
        return false;
      }
      _configuration = await QuickUsb.getConfiguration(0);
      _endpoint = _configuration.interfaces[0].endpoints
          .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT);
      var claimInterface =
          await QuickUsb.claimInterface(_configuration.interfaces[0]);
      print('claimInterface $claimInterface');
    } catch (e) {
      print("connect error $e");
    }
    return openDevice;
  }

  /// getDevicesWithDescription
  static Future<List<UsbDeviceDescription>> getDevicesWithDescription() async {
    List<UsbDeviceDescription> _usbList;
    try {
      _usbList = await QuickUsb.getDevicesWithDescription();
    } catch (e) {
      print("getDevicesWithDescription error: + $e");
    }
    return _usbList;
  }

  Future<void> write(List<int> data) async {
    await QuickUsb.bulkTransferOut(_endpoint, Uint8List.fromList(data));
  }

  Future<void> read(Function callback) async {
    var bulkTransferIn = await QuickUsb.bulkTransferIn(_endpoint, 1024);
    callback(bulkTransferIn);
  }

  static Future<void> disconnect() async {
    await QuickUsb.closeDevice();
  }
}
