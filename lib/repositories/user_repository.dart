import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository(this._firestoreService);

  Future<UserModel?> getUser(String uid) => _firestoreService.getUser(uid);

  Future<void> saveUser(UserModel user) => _firestoreService.saveUser(user);

  Future<List<UserModel>> getAllUsers() => _firestoreService.getAllUsers();

  Future<List<UserModel>> getOfficersByDepartment(String departmentId) =>
      _firestoreService.getOfficersByDepartment(departmentId);
}
