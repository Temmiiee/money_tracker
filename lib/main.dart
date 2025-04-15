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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SharedPreferences
  await SharedPreferences.getInstance();

  // Initialiser les formats de date
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);

  // Obtenir la locale sauvegardée
  final locale = await AppLocalizations.getLocale();

  // Définir l'orientation de l'application (portrait uniquement)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Définir la couleur de la barre d'état
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(MainApp(locale: locale));
}

class MainApp extends StatefulWidget {
  final Locale locale;

  const MainApp({super.key, required this.locale});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  // Méthode pour mettre à jour la langue
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appName,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales(),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          // background est déprécié, utiliser surface à la place
          // background: AppColors.background,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
          // onBackground est déprécié, utiliser onSurface à la place
          // onBackground: AppColors.textPrimary,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        // fontFamily: 'Poppins', // Commenté temporairement

        // AppBar plus douce
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
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
          floatingLabelStyle: const TextStyle(color: AppColors.primary),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s),
            borderSide: BorderSide(color: AppColors.error.withAlpha(204), width: 1),
          ),
        ),

        // Boutons plus doux
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
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
            foregroundColor: AppColors.primary,
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
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
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
              return AppColors.primary;
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
              return AppColors.primary;
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
                return AppColors.primary;
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
                return AppColors.primary.withAlpha(76);
              }
              return Colors.grey.shade300;
            },
          ),
        ),

        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(nextScreen: MainScreen()),
        '/settings': (context) => SettingsScreen(onLanguageChanged: (locale) => setLocale(locale)),
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
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppTexts.homeTitle,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sell_outlined),
              activeIcon: Icon(Icons.sell),
              label: 'Je vends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'J\'achète',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Portefeuille',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Stock',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Mon mois',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
