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
  static Color blueBgColor = hexToColor('DAE6FE');
  static Color grayBgColor = hexToColor('EDEDED');
  static Color blueTextColor = hexToColor('4481FC');
  static Color redTextColor = hexToColor('ED3737');
  static Color grayTextColor = hexToColor('8E8E8E');
  static Color blackTextColor = hexToColor('1E1E1E');
  static Color lightBlackTextColor = hexToColor('575757');
  static Color frameColor = hexToColor('C7C7C7');
  static Color dividerColor = hexToColor('F8F8F8');

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
