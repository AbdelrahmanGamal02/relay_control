import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/board.dart';
import '../providers/board_provider.dart';
import '../screens/relay_control_screen.dart';

class BoardCard extends StatelessWidget {
  final Board board;

  const BoardCard({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardProvider>(context, listen: false);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RelayControlScreen(serial: board.serial),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: board.isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                board.isOnline ? Icons.router : Icons.router_outlined,
                color: board.isOnline ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    board.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 4),
                  Text(
                    '${board.numRelays} ${'Relays Control System'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: board.isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        board.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: board.isOnline ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, provider),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  void _confirmDelete(BuildContext context, BoardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Board?'),
        content: Text('Are you sure you want to remove "${board.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.removeBoard(board.serial);
              Navigator.pop(context);
            },
            child: Text('Remove', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Extension to make life easier with animate_do if needed or just use widgets as usual.
// Actually I'll use the widgets as usual in HomeScreen.
