import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/board_provider.dart';
import 'screens/get_started_screen.dart';
import 'screens/privacy_acceptance_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  final isPrivacyAccepted = await storageService.isPrivacyAccepted();
  
  runApp(MyApp(isPrivacyAccepted: isPrivacyAccepted));
}

class MyApp extends StatelessWidget {
  final bool isPrivacyAccepted;

  const MyApp({super.key, required this.isPrivacyAccepted});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BoardProvider())],
      child: MaterialApp(
        title: 'Unimog V-7993',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: isPrivacyAccepted
            ? const GetStartedScreen()
            : const PrivacyAcceptanceScreen(),
      ),
    );
  }
}
