import 'package:renty/utils/language_manager.dart';

dynamic translateDatabase(dynamic columnar, dynamic columnen) {
  if (LanguageManager.isArabic()) {
    return columnar;
  } else {
    return columnen;
  }
}
