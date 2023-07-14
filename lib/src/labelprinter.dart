import 'enums/label_enums.dart';
import 'laberInterface.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: labelprinter
/// Author: zhoufan
/// Date: 2023/7/14 13:35
/// Description:

class LabelPrinter<T extends LabelInterFace> {
  T _label;
  LabelPrinter(this._label);

  // 指令集类型
  String getType() {
    String _type;
    switch (_label.type) {
      case CommandType.PPLE:
        _type = 'PPLE';
        break;
      case CommandType.TSC:
        _type = 'TSC';
        break;
      case CommandType.ZPL:
        _type = 'ZPL';
        break;
    }
    return _type;
  }
}
