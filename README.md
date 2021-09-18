# flutter_escpos

ESC/POS And TSC Printer driver for flutter.

## Dependencies

- [quick_usb](https://github.com/woodemi/quick_usb) for cross-platform USB plugin for Flutter.
- [esc_pos_utils](https://github.com/andrey-ushakov/esc_pos_utils) for base ESC/POS commands.

## Features

- Support USB and Network Adapter;
- Support ESC and TSC command;
- Support Pos printer and Label printer;
- Support multi platform(test on Windows,MacOs,Android);

## Tips

- On Windows, Use [Zadig](https://zadig.akeo.ie/) to install the WinUSB driver for your printer.
- On Mac, Need to set the USB permissions of the project.

## Example

- See ./examples for more examples.

![WechatIMG3702](https://user-images.githubusercontent.com/2160502/133883820-e6bd4310-422d-47c5-8921-ca1ef395d7bf.jpeg)


## TODO

- ~~Network Adapter~~
- Bluetooth Adapter
- SerialPort Adapter
