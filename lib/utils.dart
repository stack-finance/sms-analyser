abstract class Utils {
  static bool bankFilter(String source) {
    source = source.toLowerCase();
    return source.contains('hdfc') ||
        source.contains('axis') ||
        source.contains('amex') ||
        source.contains('icici') ||
        source.contains('sbi') ||
        source.contains('kotak') ||
        source.contains('axis') ||
        source.contains('iob') ||
        source.contains('idfc') ||
        source.contains('boi');
  }

}
