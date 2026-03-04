import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();
  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}
class UserProfileLoading extends UserProfileState {}
class UserProfileLoaded extends UserProfileState {
  final UserModel user;
  const UserProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}
class UserProfileError extends UserProfileState {
  final String message;
  const UserProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserService _userService;
  StreamSubscription? _userSubscription;

  UserProfileCubit({required UserService userService})
      : _userService = userService,
        super(UserProfileInitial());

  void loadUserProfile(String uid) {
    emit(UserProfileLoading());
    _userSubscription?.cancel();
    _userSubscription = _userService.getUserProfileStream(uid).listen(
      (user) {
        if (user != null) {
          emit(UserProfileLoaded(user));
        } else {
          emit(const UserProfileError('User profile not found'));
        }
      },
      onError: (error) {
        emit(UserProfileError(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
