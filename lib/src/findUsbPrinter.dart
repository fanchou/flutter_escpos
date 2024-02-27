import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Copyright (C), 2019-2022, 深圳新语网络科技有限公司
/// FileName: findUsbPrinter
/// Author: zhoufan
/// Date: 2022/3/12 21:18
/// Description:

class FindUsbPrinter {
  final int _flags;

  FindUsbPrinter(this._flags);

  Iterable<String> getPrinterLists() sync* {
    try {
      _getBufferSize();

      try {
        _readRawBuff();
        yield* parse();
      } finally {
        free(_rawBuffer);
      }
    } finally {
      free(_pBuffSize);
      free(_bPrinterLen);
    }
  }

  late Pointer<DWORD> _pBuffSize;
  late Pointer<DWORD> _bPrinterLen;

  void _getBufferSize() {
    _pBuffSize = calloc<DWORD>();
    _bPrinterLen = calloc<DWORD>();

    EnumPrinters(_flags, nullptr, 2, nullptr, 0, _pBuffSize, _bPrinterLen);

    if (_pBuffSize.value == 0) {
      throw 'Read printer buffer size fail';
    }
  }

  late Pointer<BYTE> _rawBuffer;

  void _readRawBuff() {
    _rawBuffer = malloc.allocate<BYTE>(_pBuffSize.value);

    final isRawBuffFail = EnumPrinters(_flags, nullptr, 2, _rawBuffer,
            _pBuffSize.value, _pBuffSize, _bPrinterLen) ==
        0;

    if (isRawBuffFail) {
      throw 'Read printer raw buffer fail';
    }
  }

  Iterable<String> parse() sync* {
    for (var i = 0; i < _bPrinterLen.value; i++) {
      final printer = _rawBuffer.cast<PRINTER_INFO_2>().elementAt(i);
      yield printer.ref.pPrinterName.toDartString();
    }
  }
}
