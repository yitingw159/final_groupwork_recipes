import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../models/meal.dart';
import '../pages/meal_detail_page.dart';

// TODO: 组员D — 完善搜索页功能
// 当前只有基本搜索框，需要完善：
// 1. 实现按菜名搜索功能
// 2. 实现按食材搜索功能（食材反搜：输入食材→推荐可用菜谱）
// 3. 添加搜索历史记录（SharedPreferences保存）
// 4. 美化搜索结果列表样式
// 5. 添加空结果时的提示

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<Meal> _searchResults = [];

  void _doSearch(String query) {
    final provider = context.read<MealProvider>();
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = provider.allMeals.where((m) =>
        m.name.toLowerCase().contains(query.toLowerCase()) ||
        m.ingredients.any((ing) => ing.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索菜谱'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '输入菜名或食材...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _doSearch,
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? const Center(child: Text('输入关键词搜索菜谱'))
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (ctx, i) {
                      final meal = _searchResults[i];
                      return ListTile(
                        title: Text(meal.name),
                        subtitle: Text(meal.ingredients.join(', ')),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealDetailPage(meal: meal),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}