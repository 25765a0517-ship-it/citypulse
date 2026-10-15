import '../models/department_model.dart';
import '../services/firestore_service.dart';

class DepartmentRepository {
  final FirestoreService _firestoreService;

  DepartmentRepository(this._firestoreService);

  Future<List<DepartmentModel>> getDepartments() => _firestoreService.getDepartments();
}
