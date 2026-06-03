import 'dart:async';
import 'package:flutter/material.dart';
import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';

class SmartConfigScreen extends StatefulWidget {
  const SmartConfigScreen({super.key});

  @override
  State<SmartConfigScreen> createState() => _SmartConfigScreenState();
}

class _SmartConfigScreenState extends State<SmartConfigScreen> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConfiguring = false;
  String _status = 'Enter your WiFi details to configure the Board.';

  // ESPTouch response handling
  StreamSubscription<ESPTouchResult>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startConfig() async {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text.trim();
    const bssid =
        "00:00:00:00:00:00"; // Fake BSSID to prevent crash if not provided

    if (ssid.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('SSID is required.')));
      return;
    }

    setState(() {
      _isConfiguring = true;
      _status = 'Configuring Board... Please wait.';
    });

    // Capture messenger before async gap
    final messenger = ScaffoldMessenger.of(context);

    try {
      _subscription =
          EsptouchSmartconfig.run(
            ssid: ssid,
            bssid: bssid,
            password: password,
            // deviceCount: 1, // Optional: some versions use this
          )?.listen(
            (result) {
              setState(() {
                _status = 'Success! Board Connected at IP: ${result.ip}';
                _isConfiguring = false;
              });
              _subscription?.cancel();

              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Board Connected Successfully! IP: ${result.ip}',
                  ),
                ),
              );

              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) Navigator.pop(context);
              });
            },
            onError: (e) {
              setState(() {
                _status = 'Error during configuration: ${e.toString()}';
                _isConfiguring = false;
              });
            },
          );

      // Optional: Set a timeout
      Future.delayed(const Duration(minutes: 1), () {
        if (_isConfiguring) {
          setState(() {
            _status = 'Configuration timed out. Please try again.';
            _isConfiguring = false;
          });
          _subscription?.cancel();
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to start SmartConfig: ${e.toString()}';
        _isConfiguring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WiFi Configuration')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cell_tower_rounded,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                child: Text(
                  'Remote Configuration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
              if (!_isConfiguring) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: TextField(
                    controller: _ssidController,
                    decoration: InputDecoration(
                      labelText: 'WiFi SSID (Network Name)',
                      prefixIcon: const Icon(Icons.wifi),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'WiFi Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: ElevatedButton(
                    onPressed: _startConfig,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                    ),
                    child: Text('Start Configuration'),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 40),
                SpinKitPulse(color: Theme.of(context).primaryColor, size: 80.0),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    _subscription?.cancel();
                    setState(() {
                      _isConfiguring = false;
                      _status = 'Configuration cancelled.';
                    });
                  },
                  child: Text(
                    'Cancel Configuration',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
