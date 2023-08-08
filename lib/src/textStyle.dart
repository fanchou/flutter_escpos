import 'enums/label_enums.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: textStyle.dart
/// Author: zhoufan
/// Date: 2023/7/13 19:37
/// Description:

// 统一字体
enum FontFamily {
  ZH16, // 中文16点阵，可能有些打印机是不支持的，将自动转化为支持的
  ZH24, // 中文24点阵
  VZH, // 中文矢量
  ENG12, // 英文12点阵
  ENG24, // 英文 24点阵
  ENG48, // 英文 48点阵
  VENG, // 英文矢量
}

class TextStyles {
  // 旋转方向
  // 对齐方式
  // 字体类型
  // 字体大小
  const TextStyles({
    this.fontFamily = '7', // todo 这个是不靠谱的，不同打印机可能是不同的
    this.scaleX = 24,
    this.scaleY = 24,
    this.turn = Turn.turn0,
    this.fontType,
    this.isBold = false,
    this.inverse = false,
  });

  // 字体类型
  // todo 文字打印跟字体类型有关
  final String fontFamily;

  // x 方向上的缩放大小
  final int scaleX;

  // x 方向上的缩放大小
  final int scaleY;

  // 旋转方向
  final Turn turn;

  // 是否加粗
  final bool isBold;

  // 是否反色
  final bool inverse;

  // 使用统一的字体
  final FontFamily fontType;
}

// 对齐方式
enum ZPLAlign { Left, Right, Auto }
