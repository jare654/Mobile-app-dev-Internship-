import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_app/services/auth_service.dart';
import 'package:news_app/screens/main_navigation_container.dart';
import 'package:news_app/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => authService.isAuthenticated 
            ? const MainNavigationContainer() 
            : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
