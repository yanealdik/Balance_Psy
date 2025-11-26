import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/api/api_client.dart';
import 'providers/appointment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/registration_provider.dart';
import 'providers/psychologist_registration_provider.dart';
import 'providers/report_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/splash/splash_screen.dart'; // ✅ Добавлено
import 'services/chat_service.dart';
import 'services/report_service.dart';
import 'services/schedule_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Тест подключения к бэку
  try {
    final dio = Dio();
    final response = await dio.get('http://localhost:8080/api/auth/login');
    print('✅ Backend доступен: ${response.statusCode}');
  } catch (e) {
    print('❌ Backend недоступен: $e');
  }

  // Инициализация клиента API
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
        ChangeNotifierProvider(
          create: (_) => PsychologistRegistrationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppointmentProvider(),
        ), // ✅ Добавлено
        ChangeNotifierProvider(
          create: (_) => ChatProvider(ChatService())),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(
          create: (_) => ReportProvider()),
      ], 
      child: MaterialApp(
        title: 'BalancePsy',
        debugShowCheckedModeBanner: false,

        // ✅ ДОБАВЛЕНО: Начальный экран
        home: const SplashScreen(),

        // Локализация (даты, диалоги и т.п.)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
        locale: const Locale('ru', 'RU'),

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

          // ✅ ДОБАВЛЕНО: Тема для DatePicker (календарь)
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.background,
            headerBackgroundColor: AppColors.primary,
            headerForegroundColor: Colors.white,
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return AppColors.textPrimary;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
            todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return AppColors.textPrimary;
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
          ),
        ),
      ),
    );
  }
}
