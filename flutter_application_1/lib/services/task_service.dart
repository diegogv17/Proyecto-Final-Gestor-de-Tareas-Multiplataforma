import 'package:flutter_application_1/core/constants/api_constants.dart';
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/services/api_service.dart';

class TaskService {
  TaskService(this._api);

  final ApiService _api;

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

  Future<TaskModel> getById(String id) async {
    return _api.get(
      '${ApiConstants.tasksPath}/$id',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        return TaskModel.fromJson(map['task'] as Map<String, dynamic>);
      },
    );
  }

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

  Future<void> delete(String id) async {
    await _api.delete('${ApiConstants.tasksPath}/$id');
  }
}
