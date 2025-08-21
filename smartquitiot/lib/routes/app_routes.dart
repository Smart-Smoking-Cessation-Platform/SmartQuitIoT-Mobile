import 'package:flutter/widgets.dart';
import '../features/products/presentation/screens/product_details_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/quit_smoking/presentation/screens/welcome_screen.dart';
import '../features/quit_smoking/presentation/screens/who_validation_screen.dart';
import '../features/quit_smoking/presentation/screens/account_creation_screen.dart';
import '../features/quit_smoking/presentation/screens/dashboard_screen.dart';

class AppRoutes {
  static const String productList = '/';
  static const String productDetails = '/products/details';
  static const String quitSmokingWelcome = '/quit-smoking/welcome';
  static const String quitSmokingWho = '/quit-smoking/who';
  static const String quitSmokingAccount = '/quit-smoking/account';
  static const String quitSmokingDashboard = '/quit-smoking/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    productList: (_) => const ProductListScreen(),
    productDetails: (_) => const ProductDetailsScreen(),
    quitSmokingWelcome: (_) => const WelcomeScreen(),
    quitSmokingWho: (_) => const WhoValidationScreen(),
    quitSmokingAccount: (_) => const AccountCreationScreen(),
    quitSmokingDashboard: (_) => const DashboardScreen(),
  };
}
