import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';

class CategoryUseCases {
  final CategoryRepository _repository;

  CategoryUseCases(this._repository);

  Future<List<TaskCategory>> getCategories() {
    return _repository.getCategories();
  }

  Future<TaskCategory> createCategory(String name) {
    return _repository.createCategory(name);
  }
}