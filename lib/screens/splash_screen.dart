import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';

class MountMapSplashScreen extends StatefulWidget {
  const MountMapSplashScreen({super.key});

  @override
  State<MountMapSplashScreen> createState() => _MountMapSplashScreenState();
}

class _MountMapSplashScreenState extends State<MountMapSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fade;

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String? _authMessage;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _mainController.forward().then((_) => _authenticateUser());
  }

  Future<void> _authenticateUser() async {
    if (_isAuthenticating) return;

    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        _navigateToDashboard();
        return;
      }

      if (mounted) {
        setState(() {
          _isAuthenticating = true;
          _authMessage = 'Tempelkan sidik jari untuk masuk';
        });
      }

      bool authenticated = await _auth.authenticate(
        localizedReason: 'Verify to access MountMap',
        options:
            const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );

      if (!mounted) return;

      if (authenticated) {
        _navigateToDashboard();
      } else {
        setState(() {
          _isAuthenticating = false;
          _authMessage =
              'Autentikasi dibatalkan / gagal. Tekan Coba Lagi untuk mengulangi.';
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      final code = e.code.toLowerCase();
      if (code.contains('notavailable') ||
          code.contains('passcodenotset') ||
          code.contains('nobiometric') ||
          code.contains('biometricnotavailable')) {
        _navigateToDashboard();
        return;
      }

      setState(() {
        _isAuthenticating = false;
        _authMessage =
            'Sidik jari gagal (${e.code}). Tekan Coba Lagi untuk mengulangi.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _authMessage = 'Terjadi kendala. Silakan tekan Coba Lagi.';
      });
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MountMapDashboard(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double logoSize = size.width * 0.22;
    final double titleSize = size.width * 0.06;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A166A),
                  Color(0xFF090C1A),
                  Color(0xFF08152D),
                  Color(0xFF00BFA6),
                ],
                stops: [0.0, 0.35, 0.72, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -40,
            child: _buildGlowOrb(const Color(0xFF7C4DFF), 220),
          ),
          Positioned(
            bottom: -70,
            left: -50,
            child: _buildGlowOrb(const Color(0xFF00E5C4), 210),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.white.withValues(alpha: 0.01)),
            ),
          ),
          FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          constraints:
                              const BoxConstraints(maxWidth: 100, maxHeight: 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: MountMapColors.violet.withValues(alpha: 0.25),
                                blurRadius: 45,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Icon(Icons.terrain_rounded,
                                size: logoSize * 0.5, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'MOUNTMAP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleSize > 24 ? 24 : titleSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_authMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _authMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        _isAuthenticating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.7,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white70),
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.fingerprint,
                                      color: Colors.white.withValues(alpha: 0.45),
                                      size: titleSize),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: _authenticateUser,
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('Coba Lagi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          MountMapColors.teal.withValues(alpha: 0.85),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.35),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
