import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/meal_provider.dart';
import '../models/meal.dart';
import '../pages/meal_detail_page.dart';

// 组员D — 完善搜索页功能

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<Meal> _searchResults = [];
  List<String> _history = [];
  bool _hasSearched = false;
  String _currentQuery = '';

    // 热门食材标签（食材反搜）— 与 data/meals.json 数据中的 ingredients 字段保持一致
  static const List<String> _hotIngredients = [
    '鸡肉', '豆腐', '番茄', '鸡蛋', '土豆',
    '牛肉', '排骨', '五花肉', '猪里脊', '鲈鱼',
  ];

  static const int _maxHistoryCount = 8;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _history = prefs.getStringList('search_history') ?? []);
  }

  Future<void> _saveHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history.remove(query);
      _history.insert(0, query);
      if (_history.length > _maxHistoryCount)
        _history = _history.sublist(0, _maxHistoryCount);
    });
    await prefs.setStringList('search_history', _history);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _history = []);
    await prefs.remove('search_history');
  }

  void _doSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() { _searchResults = []; _hasSearched = false; _currentQuery = ''; });
      return;
    }
    final provider = context.read<MealProvider>();
    setState(() {
      _hasSearched = true;
      _currentQuery = query.trim();
      _searchResults = provider.allMeals.where((m) =>
        m.name.toLowerCase().contains(_currentQuery.toLowerCase()) ||
        m.ingredients.any((ing) => ing.toLowerCase().contains(_currentQuery.toLowerCase()))
      ).toList();
    });
    _saveHistory(query.trim());
  }

  void _onTagTap(String ingredient) {
    _searchController.text = ingredient;
    _doSearch(ingredient);
  }

  void _onHistoryTap(String item) {
    _searchController.text = item;
    _doSearch(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索菜谱'), actions: [
        IconButton(icon: const Icon(Icons.clear_all), tooltip: '清空历史', onPressed: _clearHistory),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '输入菜名或食材...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _doSearch(''); })
                : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true, fillColor: Theme.of(context).cardColor,
            ),
             onSubmitted: (value) => _doSearch(value),
            textInputAction: TextInputAction.search,
          ),
        ),
        // 热门食材标签栏
                Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
          child: const Text('🔥 热门食材', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ),

        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _hotIngredients.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_hotIngredients[i]),
                selected: _currentQuery == _hotIngredients[i],
                onSelected: (_) => _onTagTap(_hotIngredients[i]),
                avatar: const Icon(Icons.restaurant_menu, size: 18),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ]),
    );
  }

  Widget _buildBody() {
    if (_searchResults.isNotEmpty) return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (ctx, i) => _buildMealCard(_searchResults[i], i),
    );

    if (_hasSearched && _searchResults.isEmpty) return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('没有找到相关菜谱 😔', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('试试换个关键词，或点击上方食材标签', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () { _searchController.clear(); _doSearch(''); },
            icon: const Icon(Icons.refresh), label: const Text('重新搜索'),
          ),
        ],
      )),
    );

    if (!_hasSearched || _currentQuery.isEmpty) {
      if (_history.isNotEmpty) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 16, 8), child: Row(children: [
          const Icon(Icons.history, size: 20, color: Colors.orange),
          const SizedBox(width: 8), const Text('最近搜索', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(onPressed: _clearHistory, child: const Text('清空', style: TextStyle(fontSize: 13))),
        ])),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _history.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.access_time, size: 20, color: Colors.grey),
            title: Text(_history[i], maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () => _onHistoryTap(_history[i]),
          ),
        )),
      ]);

      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, size: 72, color: Colors.blueGrey[200]),
          const SizedBox(height: 16),
          Text('搜索你想要的菜谱', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 8), Text('支持按菜名、食材搜索', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: _hotIngredients.take(6).map((tag) => ActionChip(label: Text(tag), onPressed: () => _onTagTap(tag))).toList(),
          ),
        ],
      )));
    }
    return const SizedBox.shrink();
  }

  // 卡片样式结果（纯文字）
  Widget _buildMealCard(Meal meal, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12), elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MealDetailPage(meal: meal))),
        child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.dinner_dining, size: 24, color: Colors.deepOrange[300]),
              const SizedBox(width: 10),
              Text(meal.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(meal.category, style: const TextStyle(fontSize: 11, color: Colors.deepOrange))),
              const SizedBox(width: 8),
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 2), Text(meal.area, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const Spacer(),
              Icon(Icons.timer_outlined, size: 13, color: Colors.blue[400]), const SizedBox(width: 3),
              Text('${meal.cookTime} 分钟', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.shopping_basket_outlined, size: 13, color: Colors.green[600]),
              const SizedBox(width: 4),
              Expanded(child: Text(meal.ingredients.take(5).join('、') + (meal.ingredients.length > 5 ? '...' : ''),
                style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
              Icon(Icons.navigate_next, size: 18, color: Colors.grey[400]),
            ]),
          ],
        )),
      ),
    );
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }
}
