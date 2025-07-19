import 'package:bloc/bloc.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _authService.login(email, password);
    if (result['success']) {
      emit(AuthAuthenticated(user: result['data']['user'], token: result['data']['token']));
    } else {
      emit(AuthError(message: result['message']));
    }
  }

  Future<void> signup(String username, String email, String password) async {
    emit(AuthLoading());
    final result = await _authService.signup(username, email, password);
    if (result['success']) {
      emit(AuthAuthenticated(user: result['data']['user'], token: result['data']['token']));
    } else {
      emit(AuthError(message: result['message']));
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> checkAuthentication() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final userData = await _authService.getUserData();
      final token = await _authService.getToken();
      if (userData != null && token != null) {
        emit(AuthAuthenticated(user: userData, token: token));
        return;
      }
    }
    emit(AuthUnauthenticated());
  }
}
