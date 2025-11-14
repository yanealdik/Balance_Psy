import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'core/api/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/registration_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/P_home_screen/P_home_screen.dart';
import 'theme/app_colors.dart';


void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Тест подключения
    try {
      final dio = Dio();
      final response = await dio.get('http://localhost:8080/api/auth/login');
      print('✅ Backend доступен: ${response.statusCode}');
    } catch (e) {
      print('❌ Backend недоступен: $e');
    }

    ApiClient.init();
    runApp(const BalancePsyApp());
  }


class BalancePsyApp extends StatelessWidget {
  const BalancePsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
      ],
      child: MaterialApp(
        title: 'BalancePsy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Manrope',
          useMaterial3: true,

          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.primary,
            background: AppColors.background,
            surface: AppColors.cardBackground,
            error: AppColors.error,
          ),

          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.backgroundLight,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),

        // Автоматически перенаправляем на веб-версию если открыто в браузере
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const PsychologistHomeScreen(),
        },
      ),
    );
  }
}
