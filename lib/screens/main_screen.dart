import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/listing/listing_bloc.dart';
import '../blocs/listing/listing_event.dart';
import '../blocs/search_filter/search_filter_cubit.dart';
import 'directory/directory_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'map_view/map_view_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DirectoryScreen(),
    const MyListingsScreen(),
    const MapViewScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load all listings when app starts
    context.read<ListingBloc>().add(LoadListingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchFilterCubit(),
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Directory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_circle),
              label: 'My Listings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map View',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary placeholders until screens are implemented in next steps
class MyListingsScreenPlaceholder extends StatelessWidget {
  const MyListingsScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('My Listings Coming Soon')));
}

class MapViewScreenPlaceholder extends StatelessWidget {
  const MapViewScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Map View Coming Soon')));
}

class SettingsScreenPlaceholder extends StatelessWidget {
  const SettingsScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings Coming Soon')));
}
