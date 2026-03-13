import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/scoliometer_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/image_capture_screen.dart';
import 'screens/analysis_results_screen.dart';
import 'screens/exercise_program_screen.dart';
import 'screens/progress_tracking_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/scoliometer_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/not_found_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScolioCareApp());
}

class ScolioCareApp extends StatelessWidget {
  const ScolioCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
        ChangeNotifierProvider(create: (_) => ScoliometerProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider()..loadSettings()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'ScolioCare',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const WelcomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/profile-setup': (_) => const ProfileSetupScreen(),
              '/dashboard': (_) => const DashboardScreen(),
              '/capture': (_) => const ImageCaptureScreen(),
              '/results': (_) => const AnalysisResultsScreen(),
              '/exercises': (_) => const ExerciseProgramScreen(),
              '/progress': (_) => const ProgressTrackingScreen(),
              '/scan-history': (_) => const ScanHistoryScreen(),
              '/scoliometer': (_) => const ScoliometerScreen(),
              '/chatbot': (_) => const ChatbotScreen(),
              '/reports': (_) => const ReportsScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
            onUnknownRoute: (_) =>
                MaterialPageRoute(builder: (_) => const NotFoundScreen()),
          );
        },
      ),
    );
  }
}
