import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_model.dart';
import '../models/user_model.dart';
import 'app_providers.dart';

final departmentsFutureProvider = FutureProvider<List<DepartmentModel>>((ref) async {
  final repo = ref.watch(departmentRepositoryProvider);
  return repo.getDepartments();
});

final officersByDepartmentProvider = FutureProvider.family<List<UserModel>, String>((ref, departmentId) async {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getOfficersByDepartment(departmentId);
});

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getAllUsers();
});
