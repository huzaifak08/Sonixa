import 'package:coctio/views/coctio_home_view.dart';
import 'package:coctio/views/home_view.dart';
import 'package:flutter/material.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0; // Default index 0 displays Coctio Home View first

  // Array storing our premium child views matching navigation positions
  final List<Widget> _pages = const [CoctioHomeView(), HomeView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extend body behind the navigation bar to keep the background gradient uniform and seamless
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: const Color(0xff9333EA).withOpacity(0.15),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  );
                }
                return const TextStyle(color: Colors.white54, fontSize: 12);
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                    color: Color(0xff9333EA),
                    size: 26,
                  );
                }
                return const IconThemeData(color: Colors.white60, size: 24);
              }),
            ),
            child: NavigationBar(
              height: 70,
              backgroundColor: const Color(
                0xFF1E164C,
              ).withOpacity(0.92), // Matches your primary background swatch
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.timer_outlined),
                  selectedIcon: Icon(Icons.timer_rounded),
                  label: 'Coctio',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  selectedIcon: Icon(Icons.library_music_rounded),
                  label: 'Music',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
