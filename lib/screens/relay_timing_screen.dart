import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/board_provider.dart';

class RelayTimingScreen extends StatefulWidget {
  final String serial;

  const RelayTimingScreen({super.key, required this.serial});

  @override
  State<RelayTimingScreen> createState() => _RelayTimingScreenState();
}

class _RelayTimingScreenState extends State<RelayTimingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BoardProvider>(
        context,
        listen: false,
      ).startTimingUpdates(widget.serial);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    Provider.of<BoardProvider>(
      context,
      listen: false,
    ).stopTimingUpdates(widget.serial);
    super.deactivate();
  }

  String _formatTime(int? seconds) {
    if (seconds == null) return 'Unknown';
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String res = "";
    if (hours > 0) res += "${hours}h ";
    if (minutes > 0 || hours > 0) res += "${minutes}m ";
    res += "${remainingSeconds}s";
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relay Usage Times')),
      body: Consumer<BoardProvider>(
        builder: (context, provider, child) {
          final board = provider.boards.firstWhere(
            (b) => b.serial == widget.serial,
          );
          final times = provider.getRelayTimes(widget.serial);

          if (times == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: board.numRelays,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                const Icon(Icons.power, color: Colors.blueAccent),
                          ),
                        ),
                        title: Text(
                          board.relayNames[index],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Elapsed Time (Daily)'),
                        trailing: Text(
                          _formatTime(times[index]),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
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
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Reset Timing Data?'),
                          content: Text('Are you sure you want to reset all timing data for this board?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                provider.resetTiming(widget.serial);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reset command sent to Board'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: Text(
                      'Reset Timing Data',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
