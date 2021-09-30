import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

/// FileName: serialportAdapter
/// Author: zhoufan
/// Date: 2021/9/18 19:00
/// Description: serialport adapter

class SerialPortAdapter {

  factory SerialPortAdapter() => _getInstance();
  static SerialPortAdapter get instance => _getInstance();
  static SerialPortAdapter _instance;

  SerialPortAdapter._internal();

  static SerialPort port;
  static bool isOpen = false;
  final reader = SerialPortReader(port);

  static Future<bool> connect(String comName, {String baudRate = '9600'}) async{
    port = SerialPort(comName);
    // try{
      isOpen = await port.open(mode: SerialPortMode.readWrite);
      print("是否打开了" + isOpen.toString());
      if(isOpen){
        SerialPortConfig portConfig = SerialPortConfig();
        portConfig.baudRate = int.parse(baudRate);
        port.config = portConfig;
      }
    // }catch(e){
    //   print("open serialPort error $e");
    // }
    return isOpen;
  }

  static SerialPortAdapter _getInstance() {
    if (_instance == null) {
      _instance = SerialPortAdapter._internal();
    }
    return _instance;
  }


  static Future<List> getSerialPortList() async {
    List _serialList;
    try {
      _serialList = await SerialPort.availablePorts;
    } catch (e) {
      print("getAvailablePorts error: + $e");
    }
    print("可用串口列表: " + _serialList.toString());
    return _serialList;
  }

  Future<void> write(List<int> data) async {
    await port.write(Uint8List.fromList(data));
  }

  Future<void> read(Function callback) async{
    reader.stream.listen((event) {
      callback(event);
    });
  }

  static Future<void> disconnect() async {
    await port.close();
  }

}
