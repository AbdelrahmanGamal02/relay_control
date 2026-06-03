import 'package:flutter/material.dart';

class DeviceIcon extends StatelessWidget {
  final String assetPath;
  final String? label;
  final double size;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;

  const DeviceIcon({
    super.key,
    required this.assetPath,
    this.label,
    this.size = 40.0,
    this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 3.0, // Thicker border for larger scale
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(2.0), // Minimal padding
            child: Image.asset(
              assetPath,
              color: color,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.device_unknown, size: size, color: Colors.grey);
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Predefined list of icons based on the user's request
final List<Map<String, String>> deviceIconsList = [
  {'path': 'assets/icons/starlink.png', 'label': 'icon_starlink'},
  {'path': 'assets/icons/Airco1.png', 'label': 'icon_ac1'},
  {'path': 'assets/icons/Airco2.png', 'label': 'icon_ac2'},
  {'path': 'assets/icons/Verwarming.png', 'label': 'icon_heater'},
  {'path': 'assets/icons/Koelkast1.png', 'label': 'icon_fridge1'},
  {'path': 'assets/icons/Koelkast2.png', 'label': 'icon_fridge2'},
  {'path': 'assets/icons/Satelliet telefoon.png', 'label': 'icon_sat_phone'},
  {'path': 'assets/icons/TV.png', 'label': 'icon_tv'},
  {'path': 'assets/icons/Wifi.png', 'label': 'icon_wifi'},
  {'path': 'assets/icons/Verlichting binnen.png', 'label': 'icon_light_indoor'},
  {'path': 'assets/icons/Verlichting buiten.png', 'label': 'icon_light_outdoor'},
  {'path': 'assets/icons/Oven.png', 'label': 'icon_oven'},
  {'path': 'assets/icons/Kookplaat.png', 'label': 'icon_cooktop'},
  {'path': 'assets/icons/Waterpomp.png', 'label': 'icon_pump'},
  {'path': 'assets/icons/WC.png', 'label': 'icon_wc'},
  {'path': 'assets/icons/Verlichting badkamer.png', 'label': 'icon_light_bathroom'},
  {'path': 'assets/icons/Wasmachine.png', 'label': 'icon_washer'},
];
