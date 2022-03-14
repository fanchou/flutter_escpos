import 'dart:ffi';
import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_escpos/src/enums/connection_response.dart';
import 'package:flutter_escpos/src/printer_manager.dart';
import 'package:win32/win32.dart';
import 'findUsbPrinter.dart';
import 'model/pos_printer.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: usb_printer_manager
/// Author: zhoufan
/// Date: 2022/3/13 15:42
/// Description:


class USBPrinterManager extends PrinterManager {

  Generator generator;

  // win32
  Pointer<IntPtr> phPrinter = calloc<HANDLE>();
  Pointer<Utf16> pDocName = 'My Document'.toNativeUtf16();
  Pointer<Utf16> pDataType = 'RAW'.toNativeUtf16();
  Pointer<Uint32> dwBytesWritten = calloc<DWORD>();
  Pointer<DOC_INFO_1> docInfo;
  Pointer<Utf16> szPrinterName;
  int hPrinter;
  int dwCount;

  USBPrinterManager(
      POSPrinter printer,
      PaperSize paperSize,
      CapabilityProfile profile, {
        int spaceBetweenRows = 5,
        int port: 9100,
      }) {
    super.printer = printer;
    super.address = printer.address;
    super.productId = printer.productId;
    super.deviceId = printer.deviceId;
    super.vendorId = printer.vendorId;
    super.paperSize = paperSize;
    super.profile = profile;
    super.spaceBetweenRows = spaceBetweenRows;
    super.port = port;
    generator = Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);
  }


  @override
  Future<ConnectionResponse> connect({Duration timeout: const Duration(seconds: 5)}) async{
    if(Platform.isWindows){
      try {
        docInfo = calloc<DOC_INFO_1>()
          ..ref.pDocName = pDocName
          ..ref.pOutputFile = nullptr
          ..ref.pDatatype = pDataType;
        szPrinterName = printer.name.toNativeUtf16();
        final phPrinter = calloc<HANDLE>();

        if (OpenPrinter(szPrinterName, phPrinter, nullptr) == FALSE) {
          this.isConnected = false;
          this.printer.connected = false;
          return Future<ConnectionResponse>.value(
              ConnectionResponse.printerNotConnected);
        } else {
          this.hPrinter = phPrinter.value;
          this.isConnected = true;
          this.printer.connected = true;
          return Future<ConnectionResponse>.value(ConnectionResponse.success);
        }
      } catch(e) {
        this.isConnected = false;
        this.printer.connected = false;
        return Future<ConnectionResponse>.value(ConnectionResponse.timeout);
      }
    }else{

    }
  }

  // 获取打印机
  static Future<List<String>> discover() async {
    /// todo 不同系统获取的方式不同，需要重新处理
    var results = await FindUsbPrinter(PRINTER_ENUM_LOCAL).getPrinterLists();
    return results;
  }


  @override
  Future<ConnectionResponse> disconnect({Duration timeout}) async{
    if (Platform.isWindows) {
      ClosePrinter(hPrinter);
      free(phPrinter);
      free(pDocName);
      free(pDataType);
      free(dwBytesWritten);
      free(docInfo);
      free(szPrinterName);
      this.isConnected = false;
      this.printer.connected = false;
      if (timeout != null) {
        await Future.delayed(timeout, () => null);
      }
      return ConnectionResponse.success;
    }
  }

  @override
  Future<ConnectionResponse> writeBytes(List<int> data, {bool isDisconnect = true}) async{
    if (Platform.isWindows) {
      try {
        if (!this.isConnected) {
          await connect();
        }

        // Inform the spooler the document is beginning.
        final dwJob = StartDocPrinter(hPrinter, 1, docInfo);
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
        final lpData = data.toUint8();
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

        // Inform the spooler that the document is ending.
        if (EndDocPrinter(hPrinter) == 0) {
          ClosePrinter(hPrinter);
        }

        // Check to see if correct number of bytes were written.
        if (dwBytesWritten.value != dwCount) {
          print("dwBytesWritten.value != dwCount");
        }

        if (isDisconnect) {
          // Tidy up the printer handle.
          ClosePrinter(hPrinter);
        }
        return ConnectionResponse.success;
      } catch (e) {
        return ConnectionResponse.unknown;
      } finally {
        // 这里最好释放一下，不然可能释放不掉
        free(phPrinter);
        free(pDocName);
        free(pDataType);
        free(dwBytesWritten);
        free(docInfo);
        free(szPrinterName);
      }
    }
  }
}

extension IntParsing on List<int> {
  Pointer<Uint8> toUint8() {
    final result = calloc<Uint8>(this.length);
    final nativeString = result.asTypedList(this.length);
    nativeString.setAll(0, this);
    return result;
  }
}

