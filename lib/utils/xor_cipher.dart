class XorCipher {
  static const int _key = 0x4F;

  static String decode(List<int> encoded) {
    return String.fromCharCodes(
      encoded.map((b) => b ^ _key),
    );
  }

  // الـ URL مشفر — مش plain text في الكود
  // python3 -c "print([ord(c)^0x4F for c in 'YOUR_URL'])"
  static String get gistUrl => decode(_encodedUrl);

  static const List<int> _encodedUrl = [
    // هنحط القيم هنا بعد ما نعمل الـ Gist
    0x00
  ];
}
