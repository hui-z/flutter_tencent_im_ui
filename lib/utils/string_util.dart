import 'package:flutter_tencent_im_ui/common/constants.dart';

class StringUtil {
  static String appendConversionType(String id, int type) {
    return '${type == ConversationType.c2c ? 'c2c' : 'group'}_$id';
  }
}