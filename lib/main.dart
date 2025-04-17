import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'screens/sell_screen.dart';
import 'screens/purchase_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/monthly_summary_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/constants.dart';
import 'localization/app_localizations.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SharedPreferences
  await SharedPreferences.getInstance();

  // Initialiser les formats de date
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);

  // Obtenir la locale sauvegardée
  final locale = await AppLocalizations.getLocale();

  // Obtenir le thème sauvegardé
  final themeMode = await ThemeService.getThemeMode();

  // Définir l'orientation de l'application (portrait uniquement)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Définir la couleur de la barre d'état
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
  ));

  runApp(MainApp(locale: locale, themeMode: themeMode));
}

class MainApp extends StatefulWidget {
  final Locale locale;
  final ThemeMode themeMode;

  const MainApp({super.key, required this.locale, required this.themeMode});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Locale _locale;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
    _themeMode = widget.themeMode;
  }

  // Méthode pour mettre à jour la langue
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // Méthode pour mettre à jour le thème
  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appName,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      supportedLocales: AppLocalizations.supportedLocales(),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Thème clair - forêt ensoleillée
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.lightPrimary,
          primary: AppColors.lightPrimary,
          secondary: AppColors.lightSecondary,
          surface: AppColors.lightSurface,
          // background est déprécié, utiliser surface à la place
          // background: AppColors.lightBackground,
          error: AppColors.lightError,
          onPrimary: Colors.white,
          onSecondary: AppColors.lightTextPrimary,
          onSurface: AppColors.lightTextPrimary,
          // onBackground est déprécié, utiliser onSurface à la place
          // onBackground: AppColors.lightTextPrimary,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        // fontFamily: 'Poppins', // Commenté temporairement

        // AppBar plus douce
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: const TextStyle(
            // fontFamily: 'Poppins', // Commenté temporairement
            fontWeight: FontWeight.w500, // Moins gras
            fontSize: 20,
          ),
        ),

        // Cartes plus douces
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            side: BorderSide(color: Colors.grey.shade200), // Bordure légère
          ),
          elevation: 0.5, // Élévation réduite
          color: Colors.white,
          shadowColor: Colors.black.withAlpha(25), // Ombre plus douce
          margin: const EdgeInsets.symmetric(vertical: AppSizes.xs),
        ),

        // Champs de saisie plus doux
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.m,
            vertical: AppSizes.m,
          ),
          floatingLabelStyle: TextStyle(color: AppColors.primary),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: AppColors.lightError.withAlpha(204), width: 1),
          ),
        ),

        // Boutons plus doux
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.lightPrimary,
            elevation: 1, // Élévation réduite
            shadowColor: Colors.black.withAlpha(25), // Ombre plus douce
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.m,
              horizontal: AppSizes.l,
            ),
            textStyle: const TextStyle(
              // fontFamily: 'Poppins', // Commenté temporairement
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),

        // Boutons texte plus doux
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.lightPrimary,
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.s,
              horizontal: AppSizes.m,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),

        // Thème de texte amélioré
        textTheme: TextTheme(
          displayLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
          bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
        ),

        // Divider plus doux
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200,
          thickness: 1,
          space: AppSizes.s,
        ),

        // Checkbox plus doux
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade300;
              }
              return AppColors.lightPrimary;
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.xs),
          ),
        ),

        // Radio plus doux
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade300;
              }
              return AppColors.lightPrimary;
            },
          ),
        ),

        // Switch plus doux
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade300;
              }
              if (states.contains(WidgetState.selected)) {
                return AppColors.lightPrimary;
              }
              return Colors.grey.shade400;
            },
          ),
          trackColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade200;
              }
              if (states.contains(WidgetState.selected)) {
                return AppColors.lightPrimary.withAlpha(76);
              }
              return Colors.grey.shade300;
            },
          ),
        ),

        dialogTheme: DialogTheme(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
          contentTextStyle: TextStyle(
            fontSize: 16,
            color: AppColors.lightTextPrimary,
          ),
        ),
        useMaterial3: true,
      ),
      // Thème sombre - forêt sombre
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.darkSecondary,
          surface: AppColors.darkSurface,
          // background est déprécié, utiliser surface à la place
          // background: AppColors.darkBackground,
          error: AppColors.darkError,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
          // onBackground est déprécié, utiliser onSurface à la place
          // onBackground: AppColors.darkTextPrimary,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            side: BorderSide(color: Colors.grey.shade700),
          ),
          elevation: 0.5,
          color: AppColors.darkSurface,
          shadowColor: Colors.black.withAlpha(50),
          margin: const EdgeInsets.symmetric(vertical: AppSizes.xs),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.m,
            vertical: AppSizes.m,
          ),
          floatingLabelStyle: TextStyle(color: AppColors.darkPrimary),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: AppColors.darkError.withAlpha(204), width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.darkPrimary,
            elevation: 1,
            shadowColor: Colors.black.withAlpha(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.m,
              horizontal: AppSizes.l,
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade700,
          thickness: 1,
          space: AppSizes.s,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade700;
              }
              return AppColors.darkPrimary;
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.xs),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade700;
              }
              return AppColors.darkPrimary;
            },
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade700;
              }
              if (states.contains(WidgetState.selected)) {
                return AppColors.darkPrimary;
              }
              return Colors.grey.shade400;
            },
          ),
          trackColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade700;
              }
              if (states.contains(WidgetState.selected)) {
                return AppColors.darkPrimary.withAlpha(76);
              }
              return Colors.grey.shade700;
            },
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            side: BorderSide(color: Colors.grey.shade700),
          ),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkTextPrimary,
          ),
          contentTextStyle: TextStyle(
            fontSize: 16,
            color: AppColors.darkTextPrimary,
          ),
        ),
        useMaterial3: true,
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(nextScreen: MainScreen()),
        '/settings': (context) => SettingsScreen(
          onLanguageChanged: (locale) => setLocale(locale),
          onThemeChanged: (themeMode) => setThemeMode(themeMode),
        ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    SellScreen(),
    PurchaseScreen(),
    WalletScreen(),
    InventoryScreen(),
    MonthlySummaryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: AppLocalizations.of(context).translate(AppTexts.homeTitle),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.sell_outlined),
              activeIcon: const Icon(Icons.sell),
              label: AppLocalizations.of(context).translate(AppTexts.sellTitle),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              activeIcon: const Icon(Icons.shopping_cart),
              label: AppLocalizations.of(context).translate(AppTexts.purchaseTitle),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: AppLocalizations.of(context).translate(AppTexts.walletTitle),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: AppLocalizations.of(context).translate(AppTexts.inventoryTitle),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month),
              label: AppLocalizations.of(context).translate(AppTexts.monthlyTitle),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.lightPrimary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
