import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:quick_usb/quick_usb.dart';
import 'package:flutter_escpos/flutter_escpos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UsbAdapter usbAdapter;
  CapabilityProfile capabilityProfile;
  UsbDevice device;
  UsbDeviceDescription usbDeviceDescription;
  List<UsbDeviceDescription> usbList = [];
  Future<String> deviceFuture;

  @override
  void initState() {
    usbAdapter = UsbAdapter.instance;
    getCapabilityProfile();
    deviceFuture = getDeviceList();
    super.initState();
  }

  getCapabilityProfile() async {
    capabilityProfile = await CapabilityProfile.load();
  }

  Future<String> getDeviceList() async {
    List<UsbDeviceDescription> returnedUsbList;

    returnedUsbList = await UsbAdapter.getDevicesWithDescription();

    setState(() {
      usbList = returnedUsbList;
      usbDeviceDescription = usbList[0];
      device = usbDeviceDescription.device;
    });

    return "Loaded Successfully";
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
            appBar: AppBar(
              title: const Text('USB ESC/POS test'),
            ),
            body: Center(
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
                            border: Border.all(color: Colors.black38, width: 1),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: DropdownButton(
                          items: usbList
                              .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item.product.toString())))
                              .toList(),
                          icon: const Icon(Icons.print),
                          hint: const Text("select printer"),
                          isExpanded: true,
                          value: usbDeviceDescription,
                          underline: Container(color: Colors.black),
                          onChanged: (newDevice) {
                            setState(() {
                              usbDeviceDescription =
                                  newDevice as UsbDeviceDescription;
                              device = usbDeviceDescription.device;
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
                            await UsbAdapter.connect(device);
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12)),
                            minimumSize:
                                MaterialStateProperty.all(const Size(140, 45)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green),
                          ),
                          child: const Text("Open printer")),
                      const SizedBox(width: 20),
                      ElevatedButton(
                          onPressed: () async {
                            await UsbAdapter.disconnect();
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12)),
                            minimumSize:
                                MaterialStateProperty.all(const Size(140, 45)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.redAccent),
                          ),
                          child: const Text("Close printer")),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                      onPressed: () async {
                        Printer(PaperSize.mm80, capabilityProfile, usbAdapter)
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
                          ..text("English test",
                              styles: const PosStyles(align: PosAlign.center))
                          ..hr(ch: '=')
                          ..text("What language is thine, O sea?")
                          ..text("The language of eternal question.")
                          ..text("What language is thy answer, O sky?")
                          ..text("The language of eternal silence.")
                          ..qrcode("escpos printer test", size: QRSize.Size6)
                          ..cut();
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12)),
                        minimumSize:
                            MaterialStateProperty.all(const Size(140, 60)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueAccent),
                      ),
                      child: const Text("print"))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
