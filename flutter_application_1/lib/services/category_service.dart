import 'package:flutter_application_1/core/constants/api_constants.dart';
import 'package:flutter_application_1/models/category_model.dart';
import 'package:flutter_application_1/services/api_service.dart';

class CategoryService {
  CategoryService(this._api);

  final ApiService _api;

  Future<List<CategoryModel>> getAll() async {
    return _api.get(
      ApiConstants.categoriesPath,
      fromJson: (json) => _parseCategoryList(json),
    );
  }

  Future<CategoryModel> create(CategoryModel category) async {
    return _api.post(
      ApiConstants.categoriesPath,
      data: category.toApiJson(),
      fromJson: (json) => _parseCategory(json),
    );
  }

  Future<CategoryModel> update(CategoryModel category) async {
    return _api.put(
      '${ApiConstants.categoriesPath}/${category.id}',
      data: category.toApiJson(),
      fromJson: (json) => _parseCategory(json),
    );
  }

  Future<void> delete(String id) async {
    await _api.delete('${ApiConstants.categoriesPath}/$id');
  }

  static List<CategoryModel> _parseCategoryList(dynamic json) {
    if (json is List) {
      return json
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (json is Map<String, dynamic>) {
      final raw = json['categories'];
      if (raw is List) {
        return raw
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return <CategoryModel>[];
  }

  static CategoryModel _parseCategory(dynamic json) {
    if (json is Map<String, dynamic>) {
      final nested = json['category'];
      if (nested is Map<String, dynamic>) {
        return CategoryModel.fromJson(nested);
      }
      return CategoryModel.fromJson(json);
    }
    throw const FormatException('Respuesta de categoría inválida');
  }
}
