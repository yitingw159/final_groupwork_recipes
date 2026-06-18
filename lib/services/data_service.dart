import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/meal.dart';

class DataService {
  // 真机：Gitee直连 | Web：GitHub raw（无CORS，国内可访问）
  static const String _giteeRawUrl =
      'https://gitee.com/Yiting_world/recipes_data/raw/master/data/meals.json';
  static const String _githubRawUrl =
      'https://raw.githubusercontent.com/yitingw159/final_groupwork_recipes/main/data/meals.json';

  late final Dio _dio;

  DataService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<List<Meal>> fetchMeals() async {
    // Web浏览器优先尝试本地数据（支持图片），真机直连远程
    if (kIsWeb) {
      // Web 模式：先尝试远程，如果远程数据的 image 字段为空则使用本地
      try {
        final response = await _dio.get(_githubRawUrl);
        final dynamic data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        final List<dynamic> mealsJson = data['meals'];
        // 检查第一条数据是否有 image 字段
        if (mealsJson.isNotEmpty && mealsJson[0]['image'] != null && mealsJson[0]['image'].toString().trim().isNotEmpty) {
          print('远程数据加载成功（含图片），共 ${mealsJson.length} 条菜谱');
          return mealsJson.map((json) => Meal.fromJson(json)).toList();
        } else {
          print('远程数据缺少 image 字段，使用本地数据');
          return _loadLocalData();
        }
      } catch (e) {
        print('远程数据加载失败: $e，使用本地数据');
        return _loadLocalData();
      }
    } else {
      // 真机模式：直连 Gitee，如果远程数据缺少 image 字段则回退本地
      final String url = _giteeRawUrl;
      try {
        final response = await _dio.get(url);
        final dynamic data = response.data is String
            ? jsonDecode(response.data as String)
            : response.data;
        final List<dynamic> mealsJson = data['meals'];
        // 检查第一条数据是否有 image 字段
        if (mealsJson.isNotEmpty && mealsJson[0]['image'] != null && mealsJson[0]['image'].toString().trim().isNotEmpty) {
          print('远程数据加载成功（含图片），共 ${mealsJson.length} 条菜谱');
          return mealsJson.map((json) => Meal.fromJson(json)).toList();
        } else {
          print('远程数据缺少 image 字段，使用本地数据');
          return _loadLocalData();
        }
      } on DioException catch (e) {
        print('远程数据加载失败: ${e.message}，尝试使用本地数据');
        return _loadLocalData();
      } catch (e) {
        print('数据加载异常: $e，尝试使用本地数据');
        return _loadLocalData();
      }
    }
  }

  Future<List<Meal>> _loadLocalData() async {
    final String jsonString = await rootBundle.loadString('data/meals.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> mealsJson = data['meals'];
    print('本地数据加载成功，共 ${mealsJson.length} 条菜谱');
    return mealsJson.map((json) => Meal.fromJson(json)).toList();
  }
}
