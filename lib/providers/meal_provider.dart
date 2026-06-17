import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/data_service.dart';

class MealProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<Meal> _meals = [];
  List<Meal> _filteredMeals = [];
  List<Meal> _favorites = [];
  String _selectedCategory = '全部';
  bool _isLoading = false;
  String? _errorMessage;

  List<Meal> get meals => _filteredMeals;
  List<Meal> get allMeals => _meals;
  List<Meal> get favorites => _favorites;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get categories {
    final cats = _meals.map((m) => m.category).toSet().toList();
    cats.sort();
    return ['全部', ...cats];
  }

  // 从Gitee远程加载菜谱数据
  Future<void> loadMeals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meals = await _dataService.fetchMeals();
      if (_meals.isEmpty) {
        _errorMessage = '远程数据加载失败，请检查网络连接';
      }
      _filteredMeals = _meals;
    } catch (e) {
      _errorMessage = '加载出错: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 按分类筛选
  void filterByCategory(String category) {
    _selectedCategory = category;
    if (category == '全部') {
      _filteredMeals = _meals;
    } else {
      _filteredMeals = _meals.where((m) => m.category == category).toList();
    }
    notifyListeners();
  }

  // 添加收藏
  void addFavorite(Meal meal) {
    if (!_favorites.any((m) => m.id == meal.id)) {
      _favorites.add(meal);
      notifyListeners();
    }
  }

  // 取消收藏
  void removeFavorite(String mealId) {
    _favorites.removeWhere((m) => m.id == mealId);
    notifyListeners();
  }

  // 是否已收藏
  bool isFavorite(String mealId) {
    return _favorites.any((m) => m.id == mealId);
  }
}