import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/board_provider.dart';
import '../widgets/board_card.dart';
import 'smart_config_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Boards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAppInfoDialog(context),
            tooltip: 'App Info & Legal',
          ),
          Consumer<BoardProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: provider.isConnected
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: provider.isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BoardProvider>(
        builder: (context, provider, child) {
          if (provider.boards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No boards found',
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.boards.length,
            itemBuilder: (context, index) {
              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: BoardCard(board: provider.boards[index]),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionCard(
              context,
              icon: Icons.wifi_rounded,
              label: 'WiFi Config',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmartConfigScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              context,
              icon: Icons.add_rounded,
              label: 'Add Board',
              color: Theme.of(context).primaryColor,
              onTap: () => _showAddBoardDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBoardDialog(BuildContext context) {
    final nameController = TextEditingController();
    final serialController = TextEditingController();
    final provider = Provider.of<BoardProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Board'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the name and serial number of your Board board to connect.'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Board Name',
                      hintText: 'e.g. Living Room',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: serialController,
                    decoration: InputDecoration(
                      labelText: 'Serial Number',
                      hintText: 'e.g. SN12345',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final serial = await _scanQRCode(context);
                          if (serial != null && serial.isNotEmpty) {
                            serialController.text = serial;
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a board name')),
                    );
                    return;
                  }
                  if (serialController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a serial number')),
                    );
                    return;
                  }
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await provider.addBoard(
                    serialController.text,
                    nameController.text,
                  );
                  if (success) {
                    nav.pop();
                  } else {
                    messenger.showSnackBar(
                       SnackBar(
                        content: Text('Board already exists or invalid Serial.'),
                      ),
                    );
                  }
                },
                child: Text('Connect'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String?> _scanQRCode(BuildContext context) async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (context) => const _QRScannerScreen()),
    );
    return result;
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Unimog V-7993'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unimog V-7993 is a mobile application designed to remotely configure and control hardware boards and relay modules.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 20),
            const Text(
              'Version: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Support: bebo2002elkhateeb@gmail.com',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    _launchURL('https://abdelrahmangamal02.github.io/iot-app-policy/terms.html');
                  },
                  child: const Text('Terms of Service'),
                ),
                TextButton(
                  onPressed: () {
                    _launchURL('https://abdelrahmangamal02.github.io/iot-app-policy/privacy-policy.html');
                  },
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Ignore errors silently or log them
    }
  }
}

class _QRScannerScreen extends StatefulWidget {
  const _QRScannerScreen();

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  late MobileScannerController controller;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isDetecting) return; // Prevent multiple detections

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
                  _isDetecting = true;

                  // Show visual feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('QR Code detected: ${barcode.rawValue!}'),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );

                  final navigator = Navigator.of(context);
                  // Return the scanned value
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      navigator.pop(barcode.rawValue);
                    }
                  });
                  return;
                }
              }
            },
          ),
          // Scanning overlay with guide
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Align QR code within the frame',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
