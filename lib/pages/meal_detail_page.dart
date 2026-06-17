import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

// TODO: 组员B — 完善详情页UI设计
// 当前只显示基本信息，需要完善：
// 1. 添加菜谱图片展示区域（使用placeholder图标替代）
// 2. 美化食材列表展示（用标签/chips样式）
// 3. 添加烹饪步骤展示（带步骤编号的卡片）
// 4. 添加烹饪计时器功能（点击步骤开始倒计时）
// 5. 添加营养信息展示区域（卡路里/蛋白质等）
// 6. 美化收藏按钮位置和样式

class MealDetailPage extends StatelessWidget {
  final Meal meal;

  const MealDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealProvider>();
    final isFav = provider.isFavorite(meal.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            color: isFav ? Colors.red : null,
            onPressed: () {
              if (isFav) {
                provider.removeFavorite(meal.id);
              } else {
                provider.addFavorite(meal);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息 — TODO: 组员B美化成卡片样式
            Text(
              meal.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('分类: ${meal.category} | 地区: ${meal.area} | 用时: ${meal.cookTime}分钟'),

            const SizedBox(height: 16),

            // 食材列表 — TODO: 组员B美化成chips样式
            const Text('食材:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(meal.ingredients.join(', ')),

            const SizedBox(height: 16),

            // 烹饪步骤 — TODO: 组员B添加步骤编号+计时器
            const Text('做法:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(meal.instructions),

            const SizedBox(height: 16),

            // 营养信息 — TODO: 组员B美化成图表/数据卡片
            const Text('营养信息:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('卡路里: ${meal.nutrition.calories} | 蛋白质: ${meal.nutrition.protein}g | 脂肪: ${meal.nutrition.fat}g | 碳水: ${meal.nutrition.carbs}g'),
          ],
        ),
      ),
    );
  }
}