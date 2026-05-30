// ============================================================
// TaskService: Servicio de tareas (CRUD contra el backend)
// ============================================================
// Cada método realiza una petición HTTP y transforma la respuesta
// JSON en objetos TaskModel de Dart.
// ============================================================
import 'package:flutter_application_1/core/constants/api_constants.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/services/api_service.dart';

class TaskService {
  TaskService(this._api);

  final ApiService _api; // Cliente HTTP inyectado

  // Obtener todas las tareas: GET /api/tasks
  Future<List<TaskModel>> getAll({
    String? status,
    String? priority,
    String? categoryId,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (priority != null) query['priority'] = priority;
    if (categoryId != null) query['categoryId'] = categoryId;

    return _api.get(
      ApiConstants.tasksPath,
      queryParameters: query.isEmpty ? null : query,
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['tasks'] as List<dynamic>? ?? [];
        return list
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // Obtener tarea por ID: GET /api/tasks/:id
  Future<TaskModel> getById(String id) async {
    return _api.get(
      '${ApiConstants.tasksPath}/$id',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return TaskModel.fromJson(map['task'] as Map<String, dynamic>);
      },
    );
  }

  // Crear tarea: POST /api/tasks
  Future<TaskModel> create(TaskModel task) async {
    return _api.post(
      ApiConstants.tasksPath,
      data: task.toApiJson(),
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return TaskModel.fromJson(map['task'] as Map<String, dynamic>);
      },
    );
  }

  // Actualizar tarea: PUT /api/tasks/:id
  Future<TaskModel> update(TaskModel task) async {
    return _api.put(
      '${ApiConstants.tasksPath}/${task.id}',
      data: task.toApiJson(),
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return TaskModel.fromJson(map['task'] as Map<String, dynamic>);
      },
    );
  }

  // Eliminar tarea: DELETE /api/tasks/:id
  Future<void> delete(String id) async {
    await _api.delete('${ApiConstants.tasksPath}/$id');
  }
}
