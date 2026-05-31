import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/integrity_service.dart';

class GuardScreen extends StatefulWidget {
  final Widget child;
  const GuardScreen({super.key, required this.child});

  @override
  State<GuardScreen> createState() => _GuardScreenState();
}

class _GuardScreenState extends State<GuardScreen> {
  _Status _status = _Status.checking;
  String _message = 'Verifying integrity...';

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final result = await IntegrityService.verify();

    if (!mounted) return;

    if (result.isValid) {
      setState(() => _status = _Status.valid);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.child),
        );
      }
    } else if (result.isNetworkError) {
      setState(() {
        _status = _Status.error;
        _message = 'Network error.\nCannot verify app integrity.';
      });
    } else {
      setState(() {
        _status = _Status.tampered;
        _message = 'App integrity violation detected.\nThis app has been modified.';
      });
      // اقفل بعد 3 ثواني
      await Future.delayed(const Duration(seconds: 3));
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 32),
            Text(
              _message,
              style: GoogleFonts.sourceCodePro(
                color: _statusColor(),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (_status) {
      case _Status.checking:
        return const CircularProgressIndicator(color: Color(0xFF00FF88))
            .animate()
            .fadeIn();
      case _Status.valid:
        return const Icon(Icons.verified_rounded, color: Color(0xFF00FF88), size: 64)
            .animate()
            .scale()
            .fadeIn();
      case _Status.tampered:
        return const Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 64)
            .animate()
            .shake();
      case _Status.error:
        return const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 64)
            .animate()
            .fadeIn();
    }
  }

  Color _statusColor() {
    switch (_status) {
      case _Status.checking: return Colors.white54;
      case _Status.valid: return const Color(0xFF00FF88);
      case _Status.tampered: return Colors.red;
      case _Status.error: return Colors.orange;
    }
  }
}

enum _Status { checking, valid, tampered, error }
