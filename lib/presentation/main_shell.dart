import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int activeIndex = 0;
    if (location.startsWith('/search')) activeIndex = 1;
    else if (location.startsWith('/ai-chat')) activeIndex = 2;
    else if (location.startsWith('/profile')) activeIndex = 3;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: TimboColors.borderLight, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: activeIndex,
          onTap: (i) {
            switch (i) {
              case 0: context.go('/home');
              case 1: context.go('/search');
              case 2: context.go('/ai-chat');
              case 3: context.go('/profile');
            }
          },
          backgroundColor: TimboColors.surface,
          selectedItemColor: TimboColors.ink,
          unselectedItemColor: TimboColors.inkFaint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
