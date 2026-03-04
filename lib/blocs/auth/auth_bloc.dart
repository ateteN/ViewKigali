import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserService _userService;
  StreamSubscription? _userSubscription;

  AuthBloc({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService,
        super(AuthState.initial()) {
    
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ReloadUserRequested>(_onReloadUserRequested);

    _userSubscription = _authService.user.listen((user) {
      add(AuthStatusChanged(user));
    });
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    if (user == null) {
      emit(AuthState.unauthenticated());
    } else {
      if (user.emailVerified) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.needsVerification(user));
      }
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());
    try {
      final credential = await _authService.signUp(event.email, event.password);
      final user = credential.user;
      if (user != null) {
        // Create user profile in Firestore
        await _userService.saveUserProfile(UserModel(
          uid: user.uid,
          email: event.email,
          displayName: event.displayName,
          createdAt: DateTime.now(),
        ));
        await _authService.sendEmailVerification();
        emit(AuthState.needsVerification(user));
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());
    try {
      final credential = await _authService.signIn(event.email, event.password);
      final user = credential.user;
      if (user != null) {
        if (user.emailVerified) {
          emit(AuthState.authenticated(user));
        } else {
          emit(AuthState.needsVerification(user));
        }
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
  }

  Future<void> _onReloadUserRequested(
    ReloadUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.reloadUser();
    final user = _authService.currentUser;
    add(AuthStatusChanged(user));
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
