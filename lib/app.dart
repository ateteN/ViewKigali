import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/listing_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/user_profile/user_profile_cubit.dart';
import 'blocs/listing/listing_bloc.dart';
import 'blocs/my_listings/my_listings_bloc.dart';
import 'blocs/notification/notification_cubit.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/main_screen.dart';

class ViewKigaliApp extends StatelessWidget {
  const ViewKigaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => UserService()),
        RepositoryProvider(create: (_) => ListingService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
              userService: context.read<UserService>(),
            ),
          ),
          BlocProvider(
            create: (context) => UserProfileCubit(
              userService: context.read<UserService>(),
            ),
          ),
          BlocProvider(
            create: (context) => ListingBloc(
              listingService: context.read<ListingService>(),
            ),
          ),
          BlocProvider(
            create: (context) => MyListingsBloc(
              listingService: context.read<ListingService>(),
            ),
          ),
          BlocProvider(
            create: (context) => NotificationCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'ViewKigali',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF010A26),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF7C35F),
              primary: const Color(0xFFF7C35F),
              secondary: const Color(0xFFF7C35F),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 0,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            textTheme: const TextTheme(
              headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          context.read<UserProfileCubit>().loadUserProfile(state.user!.uid);
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AuthStatus.authenticated) {
          return const MainScreen();
        }

        if (state.status == AuthStatus.needsVerification) {
          return const EmailVerificationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
