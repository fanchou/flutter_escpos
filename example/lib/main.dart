import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_escpos/src/printer_manager.dart';
import 'package:image/image.dart' as gImage;
import 'package:flutter_escpos/flutter_escpos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PrintScriptUtil? printScriptUtil;
  Printer? printer;
  USBPrinterManager? usbAdapter;
  NetworkPrinterManager? networkPrinterManager;
  // SerialPortAdapter serialPortAdapter;
  CapabilityProfile? capabilityProfile;
  POSPrinter? device;
  List<POSPrinter> usbList = [];
  List<String> serialPortList = [];
  String serialPort = '';
  Future<String>? deviceFuture;
  List<DropdownMenuItem<Object>> deviceWidget = [];

  @override
  void initState() {
    usbAdapter = USBPrinterManager.instance;
    // networkAdapter = NetworkAdapter.instance;
    networkPrinterManager = NetworkPrinterManager.instance;
    // serialPortAdapter = SerialPortAdapter.instance;
    super.initState();
    getCapabilityProfile();
    printScriptUtil = PrintScriptUtil(PaperSize.mm80, capabilityProfile!);
    deviceFuture = getDeviceList();
  }

  getCapabilityProfile() async {
    capabilityProfile = await CapabilityProfile.load();
  }

  Future<String> getDeviceList() async {
    print("这里是否执行了");
    printer = Printer(usbAdapter!);
    final usbList = await printer!.findPrinter();

    print("USB列表： " + usbList.toString());
    deviceWidget.clear();

    device = usbList[0];

    for (var item in usbList) {
      DropdownMenuItem<Object> usb =
          DropdownMenuItem(value: item, child: Text(item.name.toString()));
      deviceWidget.add(usb);
    }

    setState(() {
      device = device;
    });

    return "Loaded Successfully";
  }

  Future<List<int>> buildText() async {
    try {
      printScriptUtil
        ?..reset()
        ..text("中文测试",
            containsChinese: true,
            styles: const PosStyles(
                width: PosTextSize.size2,
                height: PosTextSize.size2,
                align: PosAlign.center))
        ..text("繁體字測試",
            containsChinese: true,
            styles: const PosStyles(
              width: PosTextSize.size2,
              height: PosTextSize.size2,
              align: PosAlign.center,
            ))
        ..text("にほんご",
            containsChinese: true,
            styles: const PosStyles(
                width: PosTextSize.size2,
                height: PosTextSize.size2,
                align: PosAlign.center))
        ..emptyLines(1)
        ..hr(ch: '=')
        ..emptyLines(1)
        ..text("望庐山瀑布",
            containsChinese: true,
            styles: const PosStyles(
              align: PosAlign.center,
              width: PosTextSize.size2,
              height: PosTextSize.size2,
            ))
        ..text("唐 李白",
            containsChinese: true,
            linesAfter: 1,
            styles: const PosStyles(
              align: PosAlign.center,
            ))
        ..text("日照香爐生紫煙",
            linesAfter: 1,
            containsChinese: true,
            styles: const PosStyles(
              width: PosTextSize.size2,
              height: PosTextSize.size2,
              align: PosAlign.center,
            ))
        ..text("遙看瀑布掛前川",
            linesAfter: 1,
            containsChinese: true,
            styles: const PosStyles(
                width: PosTextSize.size2,
                height: PosTextSize.size2,
                align: PosAlign.center))
        ..text("飛流直下三千尺",
            linesAfter: 1,
            containsChinese: true,
            styles: const PosStyles(
                width: PosTextSize.size2,
                height: PosTextSize.size2,
                align: PosAlign.center))
        ..text("疑是銀河落九天",
            linesAfter: 1,
            containsChinese: true,
            styles: const PosStyles(
                width: PosTextSize.size2,
                height: PosTextSize.size2,
                align: PosAlign.center))
        ..emptyLines(1)
        ..hr(ch: '=')
        ..text("English test", styles: const PosStyles(align: PosAlign.center))
        ..hr(ch: '=')
        ..text("What language is thine, O sea?")
        ..text("The language of eternal question.")
        ..text("What language is thy answer, O sky?")
        ..text("The language of eternal silence.")
        ..qrcode("escpos printer test", size: QRSize.Size6)
        ..cut();
      return printScriptUtil!.bytes;
    } catch (e) {
      rethrow;
    }
  }

  int _radioGroupA = 0;

  void _handleRadioValueChanged(int? value) {
    setState(() {
      _radioGroupA = value!;
    });
    if (_radioGroupA == 1) {
      // deviceFuture = getSerialPortList();
    } else if (_radioGroupA == 0) {
      getDeviceList();
    } else {
      deviceWidget.clear();
      printer = Printer(networkPrinterManager as PrinterManager);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<String>(
        future: deviceFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 180,
                      child: RadioListTile(
                        value: 0,
                        groupValue: _radioGroupA,
                        onChanged: _handleRadioValueChanged,
                        title: const Text('USB'),
                        selected: _radioGroupA == 0,
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    SizedBox(
                      width: 180,
                      child: RadioListTile(
                        value: 1,
                        groupValue: _radioGroupA,
                        onChanged: _handleRadioValueChanged,
                        title: const Text('serialPort'),
                        selected: _radioGroupA == 1,
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    SizedBox(
                      width: 180,
                      child: RadioListTile(
                        value: 2,
                        groupValue: _radioGroupA,
                        onChanged: _handleRadioValueChanged,
                        title: const Text('network'),
                        selected: _radioGroupA == 2,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("select printer: "),
                          Container(
                            width: 400,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black38, width: 1),
                                borderRadius: BorderRadius.circular(8.0)),
                            child: DropdownButton(
                              items: deviceWidget,
                              icon: const Icon(Icons.print),
                              hint: const Text("select printer"),
                              isExpanded: true,
                              value: _radioGroupA == 0 ? device : serialPort,
                              underline: Container(color: Colors.black),
                              onChanged: (newDevice) {
                                setState(() {
                                  if (_radioGroupA == 0) {
                                    device = newDevice as POSPrinter?;
                                  } else if (_radioGroupA == 1) {
                                    serialPort = newDevice as String;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                if (_radioGroupA == 0) {
                                  await printer!.connect(device!);
                                } else if (_radioGroupA == 1) {
                                  // await SerialPortAdapter.connect(serialPort, baudRate: "9600");
                                }
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12)),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(140, 45)),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                              ),
                              child: _radioGroupA == 0
                                  ? const Text("Open USB printer")
                                  : const Text("Open serial printer")),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_radioGroupA == 0) {
                                await printer!.disconnect();
                              } else if (_radioGroupA == 1) {
                                // await SerialPortAdapter.disconnect();
                              }
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 12)),
                              minimumSize: MaterialStateProperty.all(
                                  const Size(140, 45)),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.redAccent),
                            ),
                            child: _radioGroupA == 0
                                ? const Text("Close USB printer")
                                : const Text("Close serial printer"),
                          ),
                          const SizedBox(width: 20),
                          Visibility(
                            visible: _radioGroupA == 2,
                            child: ElevatedButton(
                                onPressed: () async {
                                  device = NetworkPrinter(
                                      address: "192.168.2.235", port: 9100);
                                  await printer?.connect(device!);
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 12)),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(140, 45)),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.amber),
                                ),
                                child: const Text("Open network printer")),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                try {
                                  await printer?.print(await buildText());
                                } catch (e) {
                                  print("打印报错");
                                } finally {
                                  printer?.disconnect();
                                }
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12)),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(140, 60)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.blueAccent),
                              ),
                              child: const Text("print ESC")),
                          const SizedBox(width: 20),
                          ElevatedButton(
                              onPressed: () async {
                                final ByteData qrData =
                                    await rootBundle.load('assets/qrcode.bmp');
                                final Uint8List qrBytes =
                                    qrData.buffer.asUint8List();
                                final gImage.Image? qrImage =
                                    gImage.decodeImage(qrBytes);

                                TscPrinter()
                                  // ..Download("qrcode.bmp", qrImage)
                                  ..setup(60, 120, 4, 12, 1, 2, 0)
                                  ..clearBuffer()
                                  ..box(5, 20, 460, 400, 2)
                                  ..box(5, 20, 200, 200, 2)
                                  // ..text(
                                  //     64, 40, "TSS24.BF2", 0, 4, 4, "固定资产标识卡")
                                  // ..bar(0, 146, 800, 4)
                                  // ..text(
                                  //     10, 166, "TSS24.BF2", 0, 2, 2, "资产名称：显示器")
                                  // ..text(10, 234, "TSS24.BF2", 0, 2, 2,
                                  //     "资产编号：WL456765456765456")
                                  // ..text(10, 302, "TSS24.BF2", 0, 2, 2,
                                  //     "使用部门：网络系统研发中心")
                                  // ..text(10, 370, "TSS24.BF2", 0, 2, 2,
                                  //     "产品规格：PHILIPS-227H")
                                  // ..text(10, 438, "TSS24.BF2", 0, 2, 2,
                                  //     "领用日期：2019-3-28")
                                  // ..barcode(10, 506, "128", 100, 1, 0, 3, 3,
                                  //     "WL5555123456789")
                                  // ..qrcode(525, 490, "H", 5, "A", 0, "M2", "S7",
                                  //     "http://www.freshfans.cn")
                                  ..printlabel(1, 1);
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12)),
                                minimumSize: MaterialStateProperty.all(
                                    const Size(140, 60)),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.pink),
                              ),
                              child: const Text("print TSC"))
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
