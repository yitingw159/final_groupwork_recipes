import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../pages/meal_detail_page.dart';

// TODO: 组员A — 完善首页UI设计
// 当前只显示菜谱名称列表，需要完善：
// 1. 添加顶部分类筛选标签栏（横向滑动的category chips）
// 2. 优化列表项样式（添加图标、美化卡片外观）
// 3. 添加下拉刷新功能
// 4. 添加搜索功能（按菜名搜索）
// 5. 优化加载状态的显示（添加loading动画）

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 启动时加载远程数据
    Future.microtask(() =>
      context.read<MealProvider>().loadMeals()
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('美食菜谱'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(MealProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadMeals(),
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (provider.meals.isEmpty) {
      return const Center(child: Text('暂无菜谱数据'));
    }

    return Column(
      children: [
        // 分类筛选栏 — TODO: 组员A美化成横向滑动标签
        Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            itemBuilder: (ctx, i) {
              final cat = provider.categories[i];
              final selected = cat == provider.selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => provider.filterByCategory(cat),
                ),
              );
            },
          ),
        ),
        // 菜谱列表 — TODO: 组员A美化成卡片式列表
        Expanded(
          child: ListView.builder(
            itemCount: provider.meals.length,
            itemBuilder: (ctx, i) {
              final meal = provider.meals[i];
              return ListTile(
                title: Text(meal.name),
                subtitle: Text('${meal.category} | ${meal.area} | ${meal.cookTime}分钟'),
                trailing: Icon(
                  provider.isFavorite(meal.id) ? Icons.favorite : Icons.favorite_border,
                  color: provider.isFavorite(meal.id) ? Colors.red : null,
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
        ),
      ],
    );
  }
}