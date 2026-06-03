import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/board.dart';
import '../services/mqtt_service.dart';
import '../services/storage_service.dart';

const Duration _kRetryInterval = Duration(seconds: 5);
const Duration _kStatusCheckTimeout = Duration(seconds: 10);

class BoardProvider with ChangeNotifier {
  final MqttService _mqttService = MqttService();
  final StorageService _storageService = StorageService();

  List<Board> _boards = [];
  bool _isConnected = false;
  bool _isRetrying = false;
  Timer? _retryTimer;
  final Set<String> _pendingRelays = {};
  final Set<String> _checkingBoardStatus =
      {}; // Track boards being status checked

  // Timing state: serial -> List of times
  final Map<String, List<int>> _relayTimes = {};

  List<Board> get boards => _boards;
  bool get isConnected => _isConnected;

  bool isCheckingStatus(String serial) => _checkingBoardStatus.contains(serial);

  List<int>? getRelayTimes(String serial) => _relayTimes[serial];

  BoardProvider() {
    _init();
  }

  Future<void> _init() async {
    _boards = await _storageService.loadBoards();
    // Ensure all loaded boards start as offline
    for (var board in _boards) {
      board.isOnline = false;
    }
    notifyListeners();
    _mqttService.onDisconnectedCallback = _onMqttDisconnected;
    _mqttService.updates.listen(_handleMqttUpdate);
    _startRetryLoop();
  }

  // ── Auto-reconnect loop ───────────────────────────────────────────────────

  void _startRetryLoop() {
    if (_isRetrying) return;
    _isRetrying = true;
    _retryOnce();
  }

  Future<void> _retryOnce() async {
    if (_isConnected) {
      _isRetrying = false;
      return;
    }
    if (kDebugMode) print('[Server] Attempting connection...');
    final ok = await _mqttService.connect();
    if (ok) {
      _isConnected = true;
      _isRetrying = false;
      _retryTimer?.cancel();
      _retryTimer = null;
      _onMqttConnected();
    } else {
      if (kDebugMode) {
        print('[Server] Failed — retrying in ${_kRetryInterval.inSeconds}s');
      }
      _retryTimer?.cancel();
      _retryTimer = Timer(_kRetryInterval, _retryOnce);
    }
    notifyListeners();
  }

  void _onMqttConnected() {
    for (var board in _boards) {
      board.isOnline = false; // reset to offline until response is received
      _mqttService.subscribe('smart_relay/${board.serial}/state');
      _mqttService.subscribe('smart_relay/${board.serial}/timing_state');
      requestBoardState(board.serial);
    }
    notifyListeners();
    _mqttService.subscribe('smart_relay/handshake/response');
    if (kDebugMode) print('[Server] Connected — subscriptions restored');
  }

  void _onMqttDisconnected() {
    if (kDebugMode) print('[Server] Disconnected — marking boards offline');
    _isConnected = false;
    for (var board in _boards) {
      board.isOnline = false;
    }
    _pendingRelays.clear();
    notifyListeners();
    _startRetryLoop();
  }

  /// Legacy helper kept for external callers (e.g. "Add Board" screen).
  Future<void> connectMqtt() async => _retryOnce();

  void requestBoardState(String serial) {
    _mqttService.publish('smart_relay/$serial/status_request', {
      'serial': serial,
    });
  }

  Future<void> checkBoardStatus(String serial) async {
    final boardIndex = _boards.indexWhere((b) => b.serial == serial);
    if (boardIndex == -1) return;

    _checkingBoardStatus.add(serial);
    notifyListeners();

    if (kDebugMode) print('[STATUS CHECK] Starting 10s check for $serial');

    // Send status request
    requestBoardState(serial);

    // Wait for state response with 10 second timeout
    try {
      await _mqttService.updates
          .firstWhere((update) {
            final String topic = update['topic'];
            return topic == 'smart_relay/$serial/state';
          })
          .timeout(_kStatusCheckTimeout);

      // Response received - board is online
      if (kDebugMode) {
        print('[STATUS CHECK] Response received - board is online');
      }
      _boards[boardIndex].isOnline = true;
    } catch (e) {
      // Timeout - no response from Board
      if (kDebugMode) {
        print(
          '[STATUS CHECK] Timeout - no response from Board, marking offline',
        );
      }
      _boards[boardIndex].isOnline = false;
    }

    _checkingBoardStatus.remove(serial);
    notifyListeners();
  }

  void startTimingUpdates(String serial) {
    _mqttService.publish('smart_relay/$serial/timing_request', {
      'serial': serial,
      'command': 'start',
    });
  }

  void stopTimingUpdates(String serial) {
    _mqttService.publish('smart_relay/$serial/timing_request', {
      'serial': serial,
      'command': 'stop',
    });
    _relayTimes.remove(serial);
    notifyListeners();
  }

  void resetTiming(String serial) {
    _mqttService.publish('smart_relay/$serial/timing_request', {
      'serial': serial,
      'command': 'reset',
    });
    if (kDebugMode) print('[RESET] Sent reset command for serial $serial');
  }

  bool isRelayPending(String serial, int relayIndex) {
    return _pendingRelays.contains('$serial-$relayIndex');
  }

  void _handleMqttUpdate(Map<String, dynamic> update) {
    final String topic = update['topic'];
    final dynamic payload = update['payload'];

    if (topic.endsWith('/state')) {
      final serial = topic.split('/')[1];
      final index = _boards.indexWhere((b) => b.serial == serial);
      if (index != -1) {
        if (payload['relays'] != null) {
          final List<dynamic> relayStates = payload['relays'];
          for (
            int i = 0;
            i < relayStates.length && i < _boards[index].numRelays;
            i++
          ) {
            _boards[index].relays[i] = relayStates[i];
            _pendingRelays.remove('$serial-$i');
          }
        }
        _boards[index].isOnline = true;
        notifyListeners();
      }
    } else if (topic.endsWith('/timing_state')) {
      final serial = topic.split('/')[1];
      if (payload['times'] != null) {
        _relayTimes[serial] = List<int>.from(payload['times']);
        notifyListeners();
      }
    } else if (topic == 'smart_relay/handshake/response') {
      final serial = payload['serial'];
      final success = payload['success'];
      if (success == true) {
        final index = _boards.indexWhere((b) => b.serial == serial);
        if (index != -1) {
          // Mark online only when state is received, not on handshake
          // The state should be requested after successful handshake
          notifyListeners();
        }
      }
    }
  }

  Future<bool> addBoard(String serial, String name) async {
    if (_boards.any((b) => b.serial == serial)) return false;

    // Handshake no longer requires code
    _mqttService.publish('smart_relay/handshake/request', {'serial': serial});

    try {
      final responseMap = await _mqttService.updates
          .firstWhere((update) {
            final String topic = update['topic'];
            final dynamic payload = update['payload'];
            return topic == 'smart_relay/handshake/response' &&
                payload['serial'] == serial;
          })
          .timeout(const Duration(seconds: 10));

      final payload = responseMap['payload'];
      if (payload['success'] == true) {
        final numRelays = payload['relays'] ?? 8; // Get relay count from Board
        final newBoard = Board(
          serial: serial,
          name: name,
          numRelays: numRelays,
        );
        newBoard.isOnline = false; // Wait for state message from Board
        _boards.add(newBoard);
        await _storageService.saveBoards(_boards);
        _mqttService.subscribe('smart_relay/$serial/state');
        _mqttService.subscribe('smart_relay/$serial/timing_state');
        _mqttService.subscribe('smart_relay/handshake/response');
        requestBoardState(serial);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void toggleRelay(String serial, int relayIndex, bool value) {
    final index = _boards.indexWhere((b) => b.serial == serial);
    if (index != -1) {
      _pendingRelays.add('$serial-$relayIndex');
      notifyListeners();

      final List<bool> newStates = List.from(_boards[index].relays);
      newStates[relayIndex] = value;

      _mqttService.publish('smart_relay/$serial/command', {
        'serial': serial,
        'relays': newStates,
      });
    }
  }

  Future<void> updateRelaySettings(
    String serial,
    int relayIndex,
    String newName,
    String iconPath,
  ) async {
    final index = _boards.indexWhere((b) => b.serial == serial);
    if (index != -1) {
      _boards[index].relayNames[relayIndex] = newName;
      _boards[index].relayIcons[relayIndex] = iconPath;
      await _storageService.saveBoards(_boards);
      notifyListeners();
    }
  }

  Future<void> removeBoard(String serial) async {
    _boards.removeWhere((b) => b.serial == serial);
    await _storageService.saveBoards(_boards);
    notifyListeners();
  }
}
