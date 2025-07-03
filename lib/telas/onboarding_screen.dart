import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// Tela de Onboarding
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Bem-vindo ao Diário de Viagens',
      description:
          'Registre suas aventuras e mantenha suas memórias vivas para sempre',
      icon: Icons.flight_takeoff,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'Adicione Fotos',
      description: 'Capture e organize suas fotos favoritas de cada viagem',
      icon: Icons.photo_camera,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'Faça Anotações',
      description: 'Escreva sobre suas experiências e momentos especiais',
      icon: Icons.edit_note,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'Comece Agora',
      description: 'Sua próxima aventura está a um clique de distância!',
      icon: Icons.explore,
      color: Colors.purple,
    ),
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        page.color.withOpacity(0.8),
                        page.color.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(page.icon, size: 60, color: page.color),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        page.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        page.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Indicadores de página
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? _pages[_currentIndex].color
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botões de navegação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentIndex > 0)
                      TextButton(
                        onPressed: _previousPage,
                        child: const Text(
                          'Anterior',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      const SizedBox(width: 80),

                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentIndex].color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        _currentIndex == _pages.length - 1
                            ? 'Começar'
                            : 'Próximo',
                      ),
                    ),

                    if (_currentIndex < _pages.length - 1)
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: const Text(
                          'Pular',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      const SizedBox(width: 80),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
