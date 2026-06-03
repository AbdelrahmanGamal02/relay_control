import 'dart:convert';

class Board {
  final String serial;
  String name;
  int numRelays;
  List<bool> relays;
  List<String> relayNames;
  List<String> relayIcons; // Added to store icon asset paths
  bool isOnline;

  Board({
    required this.serial,
    required this.name,
    this.numRelays = 8,
    List<bool>? relays,
    List<String>? relayNames,
    List<String>? relayIcons,
    this.isOnline = false,
  })  : relays = relays ?? List.filled(numRelays, false),
        relayNames =
            relayNames ?? List.generate(numRelays, (i) => 'Relay ${i + 1}'),
        relayIcons = relayIcons ??
            List.generate(numRelays, (i) => 'assets/icons/Wifi.png');

  Map<String, dynamic> toMap() {
    return {
      'serial': serial,
      'name': name,
      'numRelays': numRelays,
      'relays': relays,
      'relayNames': relayNames,
      'relayIcons': relayIcons,
    };
  }

  factory Board.fromMap(Map<String, dynamic> map) {
    final numRelays = map['numRelays'] ?? 8;
    
    // Safely handle relayIcons migration from int to String
    List<String> icons;
    if (map['relayIcons'] != null) {
      icons = (map['relayIcons'] as List).map((item) {
        if (item is String) return item;
        return 'assets/icons/Wifi.png'; // Fallback for old int codePoints
      }).toList();
    } else {
      icons = List.generate(numRelays, (i) => 'assets/icons/Wifi.png');
    }

    return Board(
      serial: map['serial'] ?? '',
      name: map['name'] ?? 'Unknown Board',
      numRelays: numRelays,
      relays:
          map['relays'] != null
              ? List<bool>.from(map['relays'])
              : List.filled(numRelays, false),
      relayNames:
          map['relayNames'] != null
              ? List<String>.from(map['relayNames'])
              : List.generate(numRelays, (i) => 'Relay ${i + 1}'),
      relayIcons: icons,
      isOnline: false, // Always start as offline until state is confirmed
    );
  }

  String toJson() => json.encode(toMap());

  factory Board.fromJson(String source) => Board.fromMap(json.decode(source));

  Board copyWith({
    String? serial,
    String? name,
    int? numRelays,
    List<bool>? relays,
    List<String>? relayNames,
    List<String>? relayIcons,
    bool? isOnline,
  }) {
    return Board(
      serial: serial ?? this.serial,
      name: name ?? this.name,
      numRelays: numRelays ?? this.numRelays,
      relays: relays ?? List.from(this.relays),
      relayNames: relayNames ?? List.from(this.relayNames),
      relayIcons: relayIcons ?? List.from(this.relayIcons),
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
