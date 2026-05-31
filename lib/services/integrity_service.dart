import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../utils/xor_cipher.dart';

class IntegrityService {
  static const _platform = MethodChannel('com.alaa.appguard/signature');

  // جيب الـ signature من الـ APK
  static Future<String?> getApkSignature() async {
    try {
      final String signature = await _platform.invokeMethod('getSignature');
      final bytes = utf8.encode(signature);
      return sha256.convert(bytes).toString();
    } catch (e) {
      return null;
    }
  }

  // جيب الـ hash المخزن على GitHub Gist
  static Future<String?> fetchRemoteHash() async {
    try {
      final url = XorCipher.gistUrl;
      if (url.isEmpty || url == '\x00') return null;

      final response = await http.get(
        Uri.parse(url),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // الـ Gist فيه file اسمه hash.txt
        return data['files']['hash.txt']['content']?.toString().trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // التحقق الرئيسي
  static Future<VerificationResult> verify() async {
    // فحص الـ debugger
    if (_isDebuggerAttached()) {
      return VerificationResult.tampered('Debugger detected');
    }

    final localHash = await getApkSignature();
    if (localHash == null) {
      return VerificationResult.tampered('Cannot read signature');
    }

    final remoteHash = await fetchRemoteHash();
    if (remoteHash == null) {
      return VerificationResult.networkError();
    }

    if (localHash == remoteHash) {
      return VerificationResult.valid();
    } else {
      return VerificationResult.tampered('Signature mismatch');
    }
  }

  static bool _isDebuggerAttached() {
    bool debuggerAttached = false;
    assert(() {
      // assert بيشتغل بس في debug mode
      debuggerAttached = true;
      return true;
    }());
    return debuggerAttached;
  }
}

class VerificationResult {
  final bool isValid;
  final bool isNetworkError;
  final String? reason;

  VerificationResult._({
    required this.isValid,
    required this.isNetworkError,
    this.reason,
  });

  factory VerificationResult.valid() =>
      VerificationResult._(isValid: true, isNetworkError: false);

  factory VerificationResult.tampered(String reason) =>
      VerificationResult._(isValid: false, isNetworkError: false, reason: reason);

  factory VerificationResult.networkError() =>
      VerificationResult._(isValid: false, isNetworkError: true);
}
