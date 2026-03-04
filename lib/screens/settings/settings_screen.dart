import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/user_profile/user_profile_cubit.dart';
import '../../blocs/notification/notification_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              if (state is UserProfileLoaded) {
                return UserAccountsDrawerHeader(
                  accountName: Text(state.user.displayName),
                  accountEmail: Text(state.user.email),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  decoration: const BoxDecoration(color: Colors.blue),
                );
              }
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Loading profile...'),
              );
            },
          ),
          BlocBuilder<NotificationCubit, bool>(
            builder: (context, enabled) {
              return SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive alerts for nearby services'),
                value: enabled,
                onChanged: (value) {
                  context.read<NotificationCubit>().toggleNotifications(value);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.green),
            title: const Text('Seed Sample Data'),
            subtitle: const Text('Populate Firestore with initial listings'),
            onTap: () async {
              final user = context.read<AuthBloc>().state.user;
              if (user != null) {
                try {
                  await context.read<ListingService>().seedListings(user.uid);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sample data added successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to seed data: $e')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
    );
  }
}
