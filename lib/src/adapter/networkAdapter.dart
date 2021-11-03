import 'dart:io';

import 'dart:typed_data';

/// Copyright (C), 2019-2021, 深圳新语网络科技有限公司
/// FileName: networkAdapter
/// Author: zhoufan
/// Date: 2021/9/17 10:51
/// Description: Network adapter

class NetworkAdapter{

  factory NetworkAdapter() => _getInstance();
  static NetworkAdapter get instance => _getInstance();
  static NetworkAdapter _instance;

  static RawSocket device;

  NetworkAdapter._internal();

  static NetworkAdapter _getInstance() {
    if (_instance == null) {
      _instance = NetworkAdapter._internal();
    }
    return _instance;
  }


  static Future<void> connect(String address, {int port = 9100}) async{
    try{
      device = await RawSocket.connect(address, port, timeout: const Duration(seconds: 5));
      // device = await Socket.connect(address, port, timeout:  const Duration(seconds: 5));
    }catch(e){
      print("报错了" + e.toString());
    }
  }

  Future<void> write(List<int> data) async {

    Uint8List bytes = Uint8List.fromList(data);

    // await device.write(data);
    // 这里进行拆包发送

    final int sliceSize = 100;

    int bufferLength = bytes.length;

    print("打印内容的长度" + bufferLength.toString());

    if(bufferLength > sliceSize){
      int round = (bufferLength / sliceSize).ceil();
      for(int i = 0; i < round; i++){
        if(i*sliceSize < bufferLength) {
          device.write(bytes, i * sliceSize, sliceSize);
        }else{
          device.write(bytes, i * sliceSize, i*sliceSize - bufferLength);
        }
      }
    }else{
      device.write(bytes);
    }


  }

  Future<void> read(Function callback) async{
    device.listen((event) {
      callback(event);
    });
  }

  static Future<void> disconnect() async {
    device.close();
    // device.destroy();
  }

}

