import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/meal.dart';

class DataService {
  static const String _remoteUrl =
      'https://gitee.com/Yiting_world/recipes_data/raw/master/data/meals.json';

  final Dio _dio = Dio();

  Future<List<Meal>> fetchMeals() async {
    try {
      final response = await _dio.get(_remoteUrl);
      final List<dynamic> mealsJson = response.data['meals'];
      print('远程数据加载成功，共 ${mealsJson.length} 条菜谱');
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } on DioException catch (e) {
      print('远程数据加载失败: ${e.message}，尝试使用本地数据');
      return _loadLocalData();
    } catch (e) {
      print('数据加载异常: $e');
      return _loadLocalData();
    }
  }

  Future<List<Meal>> _loadLocalData() async {
    try {
      final String jsonString = await rootBundle.loadString('data/meals.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> mealsJson = data['meals'];
      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } catch (e) {
      print('本地数据加载失败: $e');
      return [];
    }
  }
}
