/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: label_enums
/// Author: zhoufan
/// Date: 2023/7/14 11:34
/// Description:

// 对齐方式
enum LabelAlign { Left, Right, Auto }

// 旋转方向 正常、90、180、270
enum Turn { turn0, turn90, turn180, turn270 }

enum CommandType { TSC, ZPL, PPLE, CPCL }

// 条码类型
enum BarcodeType {
  CODE11,
  CODE39,
  CODE49,
  CODE93,
  CODE128,
  EAN8,
  EAN13,
  UPCA,
  UPCE
}
