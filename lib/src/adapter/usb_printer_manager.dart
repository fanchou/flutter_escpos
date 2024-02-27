import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter_escpos/src/enums/connection_response.dart';
import 'package:flutter_escpos/src/printer_manager.dart';
import 'package:quick_usb/quick_usb.dart';
import 'package:win32/win32.dart';
import '../findUsbPrinter.dart';
import '../model/pos_printer.dart';
import '../model/usb_printer.dart';

/// FileName: usb_printer_manager
/// Author: zhoufan
/// Date: 2022/3/13 15:42
/// Description:

class USBPrinterManager extends PrinterManager {
  static UsbEndpoint? _endpoint;
  POSPrinter? _printer;

  static USBPrinterManager get instance => _getInstance();
  static USBPrinterManager? _instance;

  USBPrinterManager._internal() {
    _init();
  }

  static USBPrinterManager _getInstance() {
    if (_instance == null) {
      _instance = USBPrinterManager._internal();
    }
    return _instance!;
  }

  factory USBPrinterManager() => _getInstance();

  /// init QuickUsb
  static void _init() async {
    bool init = await QuickUsb.init();
    print("QuickUSB init: $init");
  }

  // // win32
  // final phPrinter = calloc<HANDLE>();
  // final pDocName = 'My Document'.toNativeUtf16();
  // final pDataType = 'RAW'.toNativeUtf16();
  // final dwBytesWritten = calloc<DWORD>();
  // var docInfo;
  // var szPrinterName;
  // int hPrinter;
  // int dwCount;

  @override
  Future<ConnectionResponse> connect(POSPrinter printer,
      {Duration timeout = const Duration(seconds: 5)}) async {
    _printer = printer;
    if (Platform.isWindows) {
      // try {
      //   docInfo = calloc<DOC_INFO_1>()
      //     ..ref.pDocName = pDocName
      //     ..ref.pOutputFile = nullptr
      //     ..ref.pDatatype = pDataType;
      //   szPrinterName = printer.name.toNativeUtf16();
      //
      //   if (OpenPrinter(szPrinterName, phPrinter, nullptr) == FALSE) {
      //     this.isConnected = false;
      //     return Future<ConnectionResponse>.value(
      //         ConnectionResponse.printerNotConnected);
      //   } else {
      //     this.hPrinter = phPrinter.value;
      //     this.isConnected = true;
      //     return Future<ConnectionResponse>.value(ConnectionResponse.success);
      //   }
      // } catch(e) {
      //   this.isConnected = false;
      //   return Future<ConnectionResponse>.value(ConnectionResponse.timeout);
      // }
      return Future<ConnectionResponse>.value(ConnectionResponse.success);
    } else {
      bool openDevice = false;
      try {
        // reGetDevicesWithDescription
        List<UsbDeviceDescription> deviceList =
            await getDevicesWithDescription();
        UsbDevice device = deviceList
            .firstWhere((element) =>
                element.device.vendorId == printer.vendorId &&
                element.device.productId == printer.productId)
            .device;

        if (Platform.isAndroid) {
          bool hasPermission = await QuickUsb.hasPermission(device);
          if (!hasPermission) {
            await QuickUsb.requestPermission(device);
          }
        }

        openDevice = await QuickUsb.openDevice(device);
        if (!openDevice) {
          this.isConnected = false;
          // this.printer.connected = false;
          return Future<ConnectionResponse>.value(ConnectionResponse.timeout);
        }
        UsbConfiguration _configuration = await QuickUsb.getConfiguration(0);
        _endpoint = _configuration.interfaces[0].endpoints
            .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT);
        var claimInterface =
            await QuickUsb.claimInterface(_configuration.interfaces[0]);
        print('claimInterface $claimInterface');
        this.isConnected = true;
        // this.printer.connected = true;
        return Future<ConnectionResponse>.value(ConnectionResponse.success);
      } catch (e) {
        this.isConnected = false;
        // this.printer.connected = false;
        print("connect error $e");
        return Future<ConnectionResponse>.value(ConnectionResponse.timeout);
      }
    }
  }

  // 获取打印机
  @override
  Future<List<USBPrinter>> discover() async {
    List<USBPrinter> posPrinter = [];
    if (Platform.isWindows) {
      final winPrinter = FindUsbPrinter(PRINTER_ENUM_LOCAL);
      final printerNames = await winPrinter.getPrinterLists();
      printerNames.forEach((item) {
        posPrinter.add(USBPrinter(name: item));
      });
    } else {
      List<UsbDeviceDescription> usbPrinter =
          await QuickUsb.getDevicesWithDescription();
      usbPrinter.forEach((element) {
        posPrinter.add(USBPrinter(
            id: element.serialNumber,
            name: element.product,
            vendorId: element.device.vendorId,
            productId: element.device.productId));
      });
    }
    return posPrinter;
  }

  /// getDevicesWithDescription
  static Future<List<UsbDeviceDescription>> getDevicesWithDescription() async {
    List<UsbDeviceDescription>? _usbList;
    try {
      _usbList = await QuickUsb.getDevicesWithDescription();
    } catch (e) {
      print("getDevicesWithDescription error: + $e");
    }
    return _usbList!;
  }

  @override
  Future<ConnectionResponse> disconnect({Duration? timeout}) async {
    if (Platform.isWindows) {
      this.isConnected = false;
      if (timeout != null) {
        await Future.delayed(timeout, () => null);
      }
      return ConnectionResponse.success;
    } else {
      await QuickUsb.closeDevice();
      this.isConnected = false;
      // this.printer.connected = false;
      if (timeout != null) {
        await Future.delayed(timeout, () => null);
      }
      return ConnectionResponse.success;
    }
  }

  @override
  Future<ConnectionResponse> write(List<int> data,
      {bool isDisconnect = true}) async {
    if (Platform.isWindows) {
      int? hPrinter;
      int? dwCount;
      int? dwJob;
      final phPrinter = calloc<HANDLE>();
      final pDocName = 'My Document'.toNativeUtf16();
      final pDataType = 'RAW'.toNativeUtf16();
      final dwBytesWritten = calloc<DWORD>();
      final docInfo = calloc<DOC_INFO_1>()
        ..ref.pDocName = pDocName
        ..ref.pOutputFile = nullptr
        ..ref.pDatatype = pDataType;

      final szPrinterName = _printer!.name!.toNativeUtf16();
      final lpData = data.toUint8();

      try {
        if (!this.isConnected) {
          if (OpenPrinter(szPrinterName, phPrinter, nullptr) == FALSE) {
            this.isConnected = false;
            return ConnectionResponse.timeout;
          } else {
            hPrinter = phPrinter.value;
            this.isConnected = true;
          }
        }

        // Inform the spooler the document is beginning.
        dwJob = StartDocPrinter(hPrinter!, 1, docInfo);
        if (dwJob == 0) {
          ClosePrinter(hPrinter);
          return ConnectionResponse.printInProgress;
        }
        // Start a page.
        if (StartPagePrinter(hPrinter) == 0) {
          EndDocPrinter(hPrinter);
          ClosePrinter(hPrinter);
          return ConnectionResponse.printerNotSelected;
        }

        // Send the data to the printer.
        dwCount = data.length;
        if (WritePrinter(hPrinter, lpData, dwCount, dwBytesWritten) == 0) {
          EndPagePrinter(hPrinter);
          EndDocPrinter(hPrinter);
          ClosePrinter(hPrinter);
          return ConnectionResponse.printerNotWritable;
        }

        // End the page.
        if (EndPagePrinter(hPrinter) == 0) {
          EndDocPrinter(hPrinter);
          ClosePrinter(hPrinter);
        }

        ClosePrinter(hPrinter);

        // Inform the spooler that the document is ending.
        if (EndDocPrinter(hPrinter) == 0) {
          ClosePrinter(hPrinter);
        }

        // Check to see if correct number of bytes were written.
        if (dwBytesWritten.value != dwCount) {
          print("dwBytesWritten.value != dwCount");
        }

        return ConnectionResponse.success;
      } catch (e) {
        print("Windows打印机错误 $e");
      } finally {
        free(phPrinter);
        free(pDocName);
        free(pDataType);
        free(dwBytesWritten);
        free(docInfo);
        free(szPrinterName);
        free(lpData);
        return ConnectionResponse.success;
      }
    } else {
      if (!this.isConnected) {
        await connect(_printer!);
      }

      await QuickUsb.bulkTransferOut(_endpoint!, Uint8List.fromList(data),
          timeout: 6000);
      return ConnectionResponse.success;
    }
  }
}

extension IntParsing on List<int> {
  Pointer<BYTE> toUint8() {
    final result = calloc<Uint8>(this.length);
    final nativeString = result.asTypedList(this.length);
    nativeString.setAll(0, this);
    return result;
  }
}
