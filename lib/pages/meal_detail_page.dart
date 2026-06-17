import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

// 组员B — 高级感菜谱详情页 + 烹饪计时器功能
// 设计风格：温暖轻食风 + 简约高级感
// 关键词：高级感、简洁、干净、留白、柔和配色、大圆角、轻阴影、统一视觉层级

class MealDetailPage extends StatefulWidget {
  final Meal meal;

  const MealDetailPage({super.key, required this.meal});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  // 步骤数组（按换行符拆分后，去掉开头重复的编号如 "1."）
  late List<String> _steps;

  // 已完成步骤集合（存储步骤编号，0-based）
  final Set<int> _completedSteps = {};

  // 获取第一个未完成的步骤下标（0-based），全部完成返回 -1
  int _getNextUnfinishedStepIndex() {
    for (int i = 0; i < _steps.length; i++) {
      if (!_completedSteps.contains(i)) {
        return i;
      }
    }
    return -1;
  }

  @override
  void initState() {
    super.initState();
    _steps = _parseInstructions(widget.meal.instructions);
  }

  // 拆分步骤并去掉开头的 "1." "2." 等编号
  List<String> _parseInstructions(String instructions) {
    if (instructions.isEmpty) return [];
    List<String> rawSteps = instructions
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return rawSteps.map((s) => s.replaceFirst(RegExp(r'^\d+\.\s*'), '')).toList();
  }

  // 从步骤文字中提取分钟数（如 "8分钟"、"40分钟"）
  int _extractMinutes(String step) {
    final regex = RegExp(r'(\d+)\s*分钟');
    final match = regex.firstMatch(step);
    return match != null ? (int.tryParse(match.group(1) ?? '0') ?? 0) : 0;
  }

  // 计算每个步骤的默认计时时长（总时间 / 步骤数量，至少 1 分钟）
  int _getDefaultMinutes() {
    final defaultMins = widget.meal.cookTime / _steps.length;
    return defaultMins.ceil().clamp(1, 60);
  }

  // 启动计时器弹窗
  void _showTimerDialog(BuildContext context, String step, int stepIndex) {
    int mins = _extractMinutes(step);
    if (mins == 0) mins = _getDefaultMinutes();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _TimerDialog(
        step: step,
        stepIndex: stepIndex,
        initialSeconds: mins * 60,
        onComplete: () {
          setState(() => _completedSteps.add(stepIndex));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('步骤 ${stepIndex + 1} 已完成！'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFav = context.watch<MealProvider>().isFavorite(widget.meal.id);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ---------- 顶部 Hero 头图区域 ----------
          _buildHeroHeader(context, isFav),
          // ---------- 页面主体内容（限制最大宽度，居中显示）----------
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 基础信息卡片
                      _buildInfoCard(context),
                      const SizedBox(height: 24),
                      // 食材区域
                      _buildIngredientsSection(context),
                      const SizedBox(height: 24),
                      // 营养信息区域
                      _buildNutritionSection(context),
                      const SizedBox(height: 24),
                      // 烹饪步骤区域
                      _buildTimelineSteps(context),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // ---------- 底部固定主按钮 ----------
      bottomNavigationBar: _buildBottomCookingButton(context),
    );
  }

  // ============================================================
  // 1. 顶部 Hero 头图区域
  // ============================================================
  Widget _buildHeroHeader(BuildContext context, bool isFav) {
    final colorScheme = Theme.of(context).colorScheme;
    // 临时调试：检查 image 数据是否正确传递
    debugPrint('当前菜品: ${widget.meal.name}, image路径: ${widget.meal.image}');

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // 收藏按钮：右上角浮动圆形按钮
        Padding(
          padding: const EdgeInsets.all(8),
          child: FloatingActionButton(
            onPressed: () {
              final provider = context.read<MealProvider>();
              if (isFav) {
                provider.removeFavorite(widget.meal.id);
              } else {
                provider.addFavorite(widget.meal);
              }
            },
            backgroundColor: Colors.white.withOpacity(0.25),
            foregroundColor: isFav ? Colors.redAccent : Colors.white,
            mini: true,
            child: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 默认渐变背景（当图片加载失败时显示）
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF8B500).withOpacity(0.9),
                    const Color(0xFFE67E22).withOpacity(0.85),
                    const Color(0xFFD35400).withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // 本地图片：优先使用 meal.image 字段，如果为空则直接显示渐变背景
            if (widget.meal.image.trim().isNotEmpty)
              Image.asset(
                widget.meal.image.trim(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('图片加载失败: ${widget.meal.image}');
                  return const SizedBox.shrink();
                },
              ),
            // 叠加渐变蒙层：保证文字清晰可见
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            // 内容区域：图标 + 菜名 + 简介
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 餐厅图标占位
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.local_dining,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 菜名
                  Text(
                    widget.meal.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // 副标题：分类 + 地区
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.meal.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.meal.area,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 2. 基础信息卡片
  // ============================================================
  Widget _buildInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoItem(context, Icons.category, '分类', widget.meal.category),
            Container(width: 1, height: 40, color: colorScheme.outlineVariant),
            _buildInfoItem(context, Icons.public, '地区', widget.meal.area),
            Container(width: 1, height: 40, color: colorScheme.outlineVariant),
            _buildInfoItem(context, Icons.timer, '用时', '${widget.meal.cookTime} 分钟'),
          ],
        ),
      ),
    );
  }

  // 单个信息项：图标 + 标题 + 内容
  Widget _buildInfoItem(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  // 3. 食材区域
  // ============================================================
  Widget _buildIngredientsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行：图标 + 标题
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.restaurant_menu, color: colorScheme.onPrimaryContainer, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              '食材',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 食材卡片
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          shadowColor: Colors.black.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.meal.ingredients.map((ingredient) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ingredient,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 4. 营养信息区域（响应式布局：宽屏4列，窄屏2列）
  // ============================================================
  Widget _buildNutritionSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bar_chart, color: colorScheme.onPrimaryContainer, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              '营养信息',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 使用 LayoutBuilder 实现响应式布局
        LayoutBuilder(
          builder: (context, constraints) {
            // 宽度大于 700 时每行 4 个，否则每行 2 个
            final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
            // 卡片固定高度 130（足够放下所有内容）
            const cardHeight = 130.0;
            // 间距
            const spacing = 12.0;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount,
                  height: cardHeight,
                  child: _buildNutritionCard(
                    context,
                    Icons.local_fire_department,
                    '卡路里',
                    widget.meal.nutrition.calories.toString(),
                    'kcal',
                    const Color(0xFFFF6B6B),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount,
                  height: cardHeight,
                  child: _buildNutritionCard(
                    context,
                    Icons.fitness_center,
                    '蛋白质',
                    widget.meal.nutrition.protein.toString(),
                    'g',
                    const Color(0xFF4ECDC4),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount,
                  height: cardHeight,
                  child: _buildNutritionCard(
                    context,
                    Icons.water_drop,
                    '脂肪',
                    widget.meal.nutrition.fat.toString(),
                    'g',
                    const Color(0xFF45B7D1),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount,
                  height: cardHeight,
                  child: _buildNutritionCard(
                    context,
                    Icons.rice_bowl,
                    '碳水',
                    widget.meal.nutrition.carbs.toString(),
                    'g',
                    const Color(0xFFF9CA24),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // 单个营养信息卡片（紧凑布局，防止溢出）
  Widget _buildNutritionCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    String unit,
    Color iconColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 小圆形图标背景（38x38）
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.65),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            // 名称
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            // 数值 + 单位（使用 FittedBox 防止溢出）
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 5. 烹饪步骤区域（时间轴式流程布局）
  // ============================================================
  Widget _buildTimelineSteps(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行 + 进度显示
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.list_alt, color: colorScheme.onPrimaryContainer, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              '烹饪步骤',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            // 完成进度
            if (_steps.isNotEmpty)
              Row(
                children: [
                  Text(
                    '已完成 ${_completedSteps.length} / ${_steps.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        // 进度条
        if (_steps.isNotEmpty)
          LinearProgressIndicator(
            value: _completedSteps.length / _steps.length,
            backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
            minHeight: 6,
          ),
        const SizedBox(height: 16),
        // 步骤列表
        if (_steps.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('暂无烹饪步骤')),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: List.generate(_steps.length, (index) {
                return _buildTimelineStep(context, _steps[index], index);
              }),
            ),
          ),
      ],
    );
  }

  // 单个时间轴步骤
  Widget _buildTimelineStep(BuildContext context, String step, int stepIndex) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = _completedSteps.contains(stepIndex);
    int estimatedMinutes = _extractMinutes(step);
    if (estimatedMinutes == 0) estimatedMinutes = _getDefaultMinutes();
    final isLast = stepIndex == _steps.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧时间轴：圆形编号 + 连接线
        Column(
          children: [
            // 圆形步骤编号
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF2ECC71)
                    : colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isCompleted
                        ? const Color(0xFF2ECC71).withOpacity(0.3)
                        : colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            // 竖向连接线（最后一个步骤不显示）
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF2ECC71).withOpacity(0.4)
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // 右侧步骤内容卡片
        Expanded(
          child: Card(
            elevation: isCompleted ? 1 : 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isCompleted ? colorScheme.secondaryContainer.withOpacity(0.4) : null,
            shadowColor: isCompleted
                ? Colors.black.withOpacity(0.03)
                : Colors.black.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 步骤标题 + 预计时间标签
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '步骤 ${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF2ECC71).withOpacity(0.15)
                              : colorScheme.primaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 10,
                              color: isCompleted ? const Color(0xFF2ECC71) : colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '预计 $estimatedMinutes 分钟',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isCompleted ? const Color(0xFF2ECC71) : colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 步骤内容
                  Text(
                    step,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isCompleted
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 计时按钮：放在右下角，使用轻量样式
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isCompleted
                          ? // 已完成：显示绿色图标 + 文字
                          Row(
                              children: [
                                Icon(Icons.check_circle, color: const Color(0xFF2ECC71), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '已完成',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF2ECC71),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : // 未完成：轻量按钮
                          OutlinedButton.icon(
                              onPressed: () => _showTimerDialog(context, step, stepIndex),
                              icon: const Icon(Icons.timer, size: 16),
                              label: Text(
                                estimatedMinutes > 0
                                    ? '计时 $estimatedMinutes 分'
                                    : '开始计时',
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(color: colorScheme.primary, width: 1.5),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 6. 底部固定主按钮
  // ============================================================
  Widget _buildBottomCookingButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final nextIndex = _getNextUnfinishedStepIndex();
    final allCompleted = nextIndex == -1;
    final hasCompleted = _completedSteps.isNotEmpty;

    String buttonText;
    if (allCompleted) {
      buttonText = '全部完成';
    } else if (hasCompleted) {
      buttonText = '继续烹饪：步骤 ${nextIndex + 1}';
    } else {
      buttonText = '开始烹饪';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _steps.isEmpty
                ? null
                : () {
                    if (allCompleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('所有步骤都完成啦！'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      _showTimerDialog(context, _steps[nextIndex], nextIndex);
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: allCompleted
                  ? const Color(0xFF2ECC71)
                  : colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: colorScheme.primary.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  allCompleted ? Icons.check_circle : Icons.play_circle,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(buttonText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 计时器弹窗组件（精致烹饪计时面板）
// ============================================================
class _TimerDialog extends StatefulWidget {
  final String step;
  final int stepIndex;
  final int initialSeconds;
  final VoidCallback? onComplete;

  const _TimerDialog({
    required this.step,
    required this.stepIndex,
    required this.initialSeconds,
    this.onComplete,
  });

  @override
  State<_TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<_TimerDialog> {
  late int _remainingSeconds;
  late int _totalSeconds;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _totalSeconds = widget.initialSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return _remainingSeconds / _totalSeconds;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
            _isRunning = false;
            widget.onComplete?.call();
          }
        });
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _closeTimer() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFinished = _remainingSeconds == 0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题区
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.timer, color: colorScheme.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  '步骤 ${widget.stepIndex + 1} 计时器',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 步骤说明区
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.step,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            // 倒计时圆环
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 背景圆环
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ),
                  // 进度圆环
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFinished
                            ? const Color(0xFF2ECC71)
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  // 中间文字
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: isFinished
                              ? const Color(0xFF2ECC71)
                              : colorScheme.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isFinished ? '已完成！' : '剩余',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // 按钮区
            Row(
              children: [
                // 关闭按钮（弱操作）
                Expanded(
                  child: TextButton(
                    onPressed: _closeTimer,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                    child: const Text('关闭'),
                  ),
                ),
                const SizedBox(width: 12),
                // 重置按钮（次按钮）
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetTimer,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('重置'),
                  ),
                ),
                const SizedBox(width: 12),
                // 开始/暂停按钮（主按钮）
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: isFinished
                          ? const Color(0xFF2ECC71)
                          : colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      isFinished ? '完成' : (_isRunning ? '暂停' : '开始'),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}