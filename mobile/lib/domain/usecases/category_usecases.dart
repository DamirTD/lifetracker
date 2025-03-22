import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';

class CategoryUseCases {
  final TaskCategoryRepository _repository;

  CategoryUseCases(this._repository);

  Future<List<TaskCategory>> getCategories() {
    return _repository.getCategories();
  }

  Future<TaskCategory> createCategory(String name) {
    return _repository.createCategory(name);
  }

  Future<TaskCategory> updateCategory(int categoryId, String name) {
    return _repository.updateCategory(categoryId, name);
  }

  Future<bool> deleteCategory(int categoryId) {
    return _repository.deleteCategory(categoryId);
  }
}