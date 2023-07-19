import 'dart:async';
import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_escpos/src/enums/connection_response.dart';

import 'package:flutter_escpos/src/model/pos_printer.dart';

import '../printer_manager.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: bluetooth_printer_manager
/// Author: zhoufan
/// Date: 2023/7/18 09:33
/// Description:

class BluetoothPrinterManager extends PrinterManager {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance; //蓝牙API
  BluetoothCharacteristic _writeCharacteristic = null;
  static const int SCAN_TIMEOUT = 10000;
  static BluetoothDevice _device;
  static POSPrinter _printer;
  var _isScanning = false;
  Timer _timer = null;
  bool isConnecting = false;

  StreamController<ScanResult> scanStream = StreamController.broadcast();

  // 蓝牙单例
  BluetoothPrinterManager._internal();
  static BluetoothPrinterManager _instance;
  static BluetoothPrinterManager get instance => _getInstance();
  static BluetoothPrinterManager _getInstance() {
    if (_instance == null) {
      _instance = BluetoothPrinterManager._internal();
    }
    return _instance;
  }

  factory BluetoothPrinterManager() => _getInstance();

  // 蓝牙特征值及相关参数
  final List<int> ENABLE_NOTIFICATION_VALUE = [0x01, 0x00]; //启用Notification模式
  final List<int> DISABLE_NOTIFICATION_VALUE = [0x00, 0x00]; //停用Notification模式
  final List<int> ENABLE_INDICATION_VALUE = [0x02, 0x00]; //启用Indication模式
  Guid SET_MODE_SERVICE_UUID; //设置模式-服务UUID
  Guid SET_MODE_CHARACTERISTIC_UUID; //设置模式-特征值UUID
  Guid SET_MODE_DESCRIPTOR_UUID; //设置模式-特征值描述UUID(固定不变)
  Guid WRITE_DATA_SERVICE_UUID; //写数据-服务UUID
  Guid WRITE_DATA_CHARACTERISTIC_UUID; //写数据-特征值UUID

  // 扫描设备
  @override
  Future discover({int timeout = SCAN_TIMEOUT}) async {
    log("开始扫描设备 >>>>>>");
    if (_isScanning) return;
    _isScanning = true;
    _flutterBlue.scanResults.listen((results) {
      for (ScanResult item in results) {
        if (_device != null && item.device.id == _device.id) {
          // 自动连接
          stopScan();
          connect(_printer);
        }
        if (item.device.name != null && item.device.name != '') {
          scanStream.add(item);
        }
      }
    });
    _flutterBlue?.startScan(timeout: Duration(seconds: timeout));
    startTimer();
  }

  //N秒后停止扫描, 并回调通知外部
  void startTimer() {
    cancelTimer();
    _timer = Timer(Duration(milliseconds: SCAN_TIMEOUT), () {
      stopScan(); //停止扫描
      // _callback.onStop(); //回调通知外部
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  //是否扫描中
  bool isScan() {
    return _isScanning;
  }

  //停止扫描
  void stopScan() {
    log("停止扫描设备 >>>>>>");
    cancelTimer();
    if (!_isScanning) return;
    _isScanning = false;
    _flutterBlue.stopScan();
  }

  @override
  Future<ConnectionResponse> connect(POSPrinter printer,
      {Duration timeout}) async {
    _printer = printer;
    _device = printer.bluetoothDevice;
    isConnecting = true;
    log("开始连接 >>>>>>name: ${_device.name}");
    await _device.connect(
      timeout: Duration(milliseconds: SCAN_TIMEOUT),
      autoConnect: false,
    );
    log("连接成功 >>>>>>name: ${_device.name}");
    _printer.connected = true;
    _discoverServices(_device);
    // todo 最好可以全局保存
    this.isConnected = true;
    return Future<ConnectionResponse>.value(ConnectionResponse.success);
  }

  //3.发现服务
  Future<void> _discoverServices(BluetoothDevice device) async {
    log("开始发现服务 >>>>>>name: ${device.name}");
    List<BluetoothService> services = await device.discoverServices();
    log("发现服务成功 >>>>>>name: ${device.name}");
    _handlerServices(device, services); //遍历服务列表，找出指定服务
    isConnecting = false;
  }

  //3.1遍历服务列表，找出指定服务
  void _handlerServices(
      BluetoothDevice device, List<BluetoothService> services) {
    // 遍历服务
    services.forEach((sItem) {
      log(sItem.toString(), name: '遍历服务类型');
      var characteristics = sItem.characteristics;
      // 遍历特征值
      for (BluetoothCharacteristic cItem in characteristics) {
        // 写的特征值
        if (cItem.properties.write && cItem.properties.read) {
          log("5.0.找到写数据的特征值 >>>>>>name: ${device.name}  cItem: ${cItem.toString()}");
          WRITE_DATA_SERVICE_UUID = sItem.uuid;
          WRITE_DATA_CHARACTERISTIC_UUID = cItem.uuid;
          _writeCharacteristic = cItem;
        } else if (cItem.properties.write &&
            !cItem.properties.read &&
            cItem.descriptors.isNotEmpty) {
          log("5.0.找到设置模式的特征值 >>>>>>name: ${device.name}  characteristicUUID: ${SET_MODE_CHARACTERISTIC_UUID.toString()}");
          SET_MODE_DESCRIPTOR_UUID = cItem.descriptors[0].uuid;
          _requestMtu(device); //设置MTU
          _setNotificationMode(device, cItem); //设置为Notification模式(设备主动给手机发数据)
        } else if (!cItem.properties.write && cItem.properties.read) {
          // 读模式
          log("4.找到读模式的特征值 >>>>>>name: ${device.name}  serviceGuid: ${SET_MODE_SERVICE_UUID.toString()}");
          SET_MODE_SERVICE_UUID = sItem.uuid;
          SET_MODE_CHARACTERISTIC_UUID = cItem.uuid;
        }
      }
    });
  }

  //4.读取特征值(读出设置模式与写数据的特征值)
  Future<void> _readCharacteristics(
      BluetoothDevice device, BluetoothService service) async {
    log(service.characteristics.toString(), name: '读取服务特征值');
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic cItem in characteristics) {
      String cUuid = cItem.uuid.toString();
      if (cUuid == SET_MODE_CHARACTERISTIC_UUID.toString()) {
        //找到设置模式的特征值
        log("5.0.找到设置模式的特征值 >>>>>>name: ${device.name}  characteristicUUID: ${SET_MODE_CHARACTERISTIC_UUID.toString()}");
        _requestMtu(device); //设置MTU
        _setNotificationMode(device, cItem); //设置为Notification模式(设备主动给手机发数据)
      } else if (cUuid == WRITE_DATA_CHARACTERISTIC_UUID.toString()) {
        //找到写数据的特征值
        log("5.0.找到写数据的特征值 >>>>>>name: ${device.name}  characteristicUUID: ${WRITE_DATA_CHARACTERISTIC_UUID.toString()}");
        _writeCharacteristic = cItem; //保存写数据的征值
      }
    }
  }

  //4.1.设置MTU
  Future<void> _requestMtu(BluetoothDevice device) async {
    final mtu = await device.mtu.first;
    log("4.1.当前mtu: $mtu 请求设置mtu为512 >>>>>>name: ${device.name}");
    await device.requestMtu(512);
  }

  //4.2.设置为Notification模式(设备主动给手机发数据)，Indication模式需要手机读设备的数据
  Future<void> _setNotificationMode(
      BluetoothDevice device, BluetoothCharacteristic cItem) async {
    log("4.2.设置为通知模式 >>>>>>name: ${device.name}");
    await cItem.setNotifyValue(true); //为指定特征的值设置通知
    cItem.value.listen((value) {
      if (value == null || value.isEmpty) return;
      log("接收数据 >>>>>>name: ${device.name}  value: $value");
    });
    var descriptors = cItem.descriptors;
    for (BluetoothDescriptor dItem in descriptors) {
      if (dItem.uuid.toString() == SET_MODE_DESCRIPTOR_UUID.toString()) {
        //找到设置模式的descriptor
        log("发送Notification模式给设备 >>>>>>name: ${device.name}");
        dItem.write(ENABLE_NOTIFICATION_VALUE); //发送Notification模式给设备
        return;
      }
    }
  }

  @override
  Future<ConnectionResponse> disconnect({Duration timeout}) async {
    log("断开连接 >>>>>>name: ${_device.name}");
    _device.disconnect(); //关闭连接
    return ConnectionResponse.success;
  }

  @override
  Future<ConnectionResponse> write(List<int> data,
      {bool isDisconnect = true}) async {
    log("发送指令给设备 >>>>>> ${_writeCharacteristic.uuid} data: $data");
    if (!this.isConnected) {
      await connect(_printer);
    }
    // 可能需要切片
    await _writeCharacteristic?.write(data);
    return ConnectionResponse.success;
  }
}
