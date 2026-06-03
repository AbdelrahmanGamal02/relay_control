import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/board_provider.dart';
import '../widgets/device_icon.dart';
import 'relay_timing_screen.dart';

class RelayControlScreen extends StatelessWidget {
  final String serial;

  const RelayControlScreen({super.key, required this.serial});

  @override
  Widget build(BuildContext context) {
    return Consumer<BoardProvider>(
      builder: (context, provider, child) {
        final board = provider.boards.firstWhere((b) => b.serial == serial);

        return Scaffold(
          appBar: AppBar(
            title: Text('${'Relay Control'} - ${board.name}'),
            actions: [
              if (provider.isCheckingStatus(serial))
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          board.isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    board.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: board.isOnline ? Colors.green : Colors.red,
                  ),
                  onPressed: () => provider.checkBoardStatus(serial),
                  tooltip: 'Check board status (10s timeout)',
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: board.numRelays,
                  itemBuilder: (context, index) {
                    final isPending = provider.isRelayPending(serial, index);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 56, // Increased size
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white, // Uniform white background
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            board.relayIcons[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.power, color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          board.relayNames[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          board.relays[index] ? 'ON' : 'OFF',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPending)
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Switch(
                                value: board.relays[index],
                                onChanged: board.isOnline
                                    ? (val) => provider.toggleRelay(
                                          serial,
                                          index,
                                          val,
                                        )
                                    : null,
                                activeThumbColor: Colors.orange,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showRenameDialog(
                                context,
                                provider,
                                index,
                                board.relayNames[index],
                                board.relayIcons[index],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RelayTimingScreen(serial: serial),
                        ),
                      );
                    },
                    icon: const Icon(Icons.timer),
                    label: Text(
                      'Show Usage Timing',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(
    BuildContext context,
    BoardProvider provider,
    int index,
    String currentName,
    String currentIconPath,
  ) {
    final controller = TextEditingController(text: currentName);
    String selectedIconPath = currentIconPath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              'Rename Relay ${(index + 1).toString()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Relay Name',
                        prefixIcon: const Icon(Icons.edit_note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.05),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Choose Relay Icon',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF818CF8), // Lighter blue/indigo for dark theme
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16), // Increased padding
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Changed to 2 for much larger icons
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: deviceIconsList.length,
                        itemBuilder: (context, i) {
                          final iconData = deviceIconsList[i];
                          final isSelected = selectedIconPath == iconData['path'];

                          return DeviceIcon(
                            assetPath: iconData['path']!,
                            isSelected: isSelected,
                            size: 50,
                            onTap: () {
                              setState(() {
                                selectedIconPath = iconData['path']!;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      provider.updateRelaySettings(
                        serial,
                        index,
                        controller.text,
                        selectedIconPath,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Save',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
