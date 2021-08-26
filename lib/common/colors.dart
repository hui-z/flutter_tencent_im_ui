import 'dart:ui';

class CommonColors {
  static const String TextBasicColorHexString = '111111';
  static const String TextWeakColorHexString = '999999';
  static const String BorderColorHexString = 'ededed';
  static const String GapColorHexString = 'ededed';
  static const String ThemeColorHexString = '006fff';
  static const String WightColorHexString = 'ffffff';
  static const String RedColor = 'FA5151';
  static const String GreenColor = '06ad56';

  static getTextBasicColor() {
    return hexToColor(TextBasicColorHexString);
  }

  static getTextWeakColor() {
    return hexToColor(TextWeakColorHexString);
  }

  static getBorderColor() {
    return hexToColor(BorderColorHexString);
  }

  static getGapColor() {
    return hexToColor(GapColorHexString);
  }

  static getThemeColor() {
    return hexToColor(ThemeColorHexString);
  }

  static getWitheColor() {
    return hexToColor(WightColorHexString);
  }

  static getReadColor() {
    return hexToColor(RedColor);
  }

  static getGreenColor() {
    return hexToColor(GreenColor);
  }
}

Color hexToColor(String hexString) {
  return Color(int.parse(hexString, radix: 16)).withAlpha(255);
}
