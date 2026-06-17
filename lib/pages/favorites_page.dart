import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../pages/meal_detail_page.dart';

// TODO: 组员C — 完善收藏页功能
// 当前只有简单列表，需要完善：
// 1. 美化收藏列表项样式（和首页列表保持一致）
// 2. 实现SharedPreferences本地持久化（收藏数据重启不丢失）
// 3. 添加空收藏时的提示页面
// 4. 添加长按删除收藏的交互
// 5. 支持从收藏页进入详情页

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealProvider>();
    final favorites = provider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('暂无收藏，去首页添加吧！'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (ctx, i) {
                final meal = favorites[i];
                return ListTile(
                  title: Text(meal.name),
                  subtitle: Text('${meal.category} | ${meal.cookTime}分钟'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.removeFavorite(meal.id),
                  ),
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
    );
  }
}