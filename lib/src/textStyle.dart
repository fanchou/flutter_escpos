import 'enums/label_enums.dart';

/// Copyright (C), 2019-2023, 深圳新语网络科技有限公司
/// FileName: textStyle.dart
/// Author: zhoufan
/// Date: 2023/7/13 19:37
/// Description:

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
}

// 对齐方式
enum ZPLAlign { Left, Right, Auto }
