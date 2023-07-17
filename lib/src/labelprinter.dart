import 'label_interface.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: labelprinter
/// Author: zhoufan
/// Date: 2023/7/14 13:35
/// Description:

class LabelPrinter<T extends LabelInterFace> {
  T instance;
  LabelPrinter(this.instance);
}
