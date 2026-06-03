
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board.dart';

class StorageService {
  static const String _keyBoards = 'boards';

  Future<void> saveBoards(List<Board> boards) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> boardsJson = boards.map((b) => b.toJson()).toList();
    await prefs.setStringList(_keyBoards, boardsJson);
  }

  Future<List<Board>> loadBoards() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? boardsJson = prefs.getStringList(_keyBoards);
    if (boardsJson == null) return [];
    return boardsJson.map((s) => Board.fromJson(s)).toList();
  }
}
