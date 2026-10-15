import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  UserModel? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  Stream<UserModel?> authStateChanges() => _authService.authStateChanges();

  Future<void> initializeAuth() => _authService.initializeAuth();

  Future<UserModel> login({required String email, required String password}) =>
      _authService.login(email: email, password: password);

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) =>
      _authService.register(name: name, email: email, phone: phone, password: password);

  Future<void> logout() => _authService.logout();

  Future<void> resetPassword(String email) => _authService.resetPassword(email);

  Future<void> switchDemoRole(UserRole role) => _authService.switchDemoRole(role);
}
