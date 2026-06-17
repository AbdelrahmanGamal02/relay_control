import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import 'get_started_screen.dart';

class PrivacyAcceptanceScreen extends StatefulWidget {
  const PrivacyAcceptanceScreen({super.key});

  @override
  State<PrivacyAcceptanceScreen> createState() => _PrivacyAcceptanceScreenState();
}

class _PrivacyAcceptanceScreenState extends State<PrivacyAcceptanceScreen> {
  final StorageService _storageService = StorageService();
  bool _isAccepted = false;

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Ignore errors silently
    }
  }

  void _onAccept() async {
    if (_isAccepted) {
      await _storageService.setPrivacyAccepted(true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 60,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.security_rounded,
                              size: 80,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: const Text(
                            'Privacy & Terms',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInDown(
                          duration: const Duration(milliseconds: 400),
                          child: const Text(
                            'Please review how Unimog V-7993 protects your privacy and handles operations before continuing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHighlightRow(
                                  context,
                                  icon: Icons.storage_rounded,
                                  title: 'Local Storage Only',
                                  description:
                                      'All board names, configuration data, and settings are stored locally on your device.',
                                ),
                                const SizedBox(height: 16),
                                _buildHighlightRow(
                                  context,
                                  icon: Icons.router_rounded,
                                  title: 'MQTT Connection',
                                  description:
                                      'Device control signals are sent directly to your designated MQTT broker. We do not monitor your traffic.',
                                ),
                                const SizedBox(height: 16),
                                _buildHighlightRow(
                                  context,
                                  icon: Icons.qr_code_scanner_rounded,
                                  title: 'On-Device Camera',
                                  description:
                                      'Camera permission is solely used to scan QR codes for easy onboarding. No images are uploaded.',
                                ),
                                const SizedBox(height: 16),
                                _buildHighlightRow(
                                  context,
                                  icon: Icons.warning_amber_rounded,
                                  title: 'Safety Responsibility',
                                  description:
                                      'You assume all risks of controlling physical electrical hardware and connected devices.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Spacer(),
                        FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          child: Column(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () => _launchURL(
                                      'https://abdelrahmangamal02.github.io/iot-app-policy/privacy-policy.html',
                                    ),
                                    child: const Text('Privacy Policy'),
                                  ),
                                  const Text('•', style: TextStyle(color: Colors.grey)),
                                  TextButton(
                                    onPressed: () => _launchURL(
                                      'https://abdelrahmangamal02.github.io/iot-app-policy/terms.html',
                                    ),
                                    child: const Text('Terms of Service'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _isAccepted,
                                      activeColor: primaryColor,
                                      onChanged: (val) {
                                        setState(() {
                                          _isAccepted = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isAccepted = !_isAccepted;
                                        });
                                      },
                                      child: const Text(
                                        'I have read and agree to the Privacy Policy and Terms & Conditions',
                                        style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isAccepted ? _onAccept : null,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 56),
                                    backgroundColor: _isAccepted ? primaryColor : Colors.grey.shade800,
                                    foregroundColor: _isAccepted ? Colors.white : Colors.grey.shade500,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Accept & Continue'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
