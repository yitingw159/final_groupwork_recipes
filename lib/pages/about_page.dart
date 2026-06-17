import 'package:flutter/material.dart';

// TODO: 组员E — 完善关于/设置页
// 当前只有基础信息，需要完善：
// 1. 添加暗色模式切换开关（调用ThemeProvider切换主题）
// 2. 添加隐私政策/合规声明页面内容
// 3. 添加开源项目参考声明（注明参考了 gitee.com/coder-YsH/recipes，MIT License）
// 4. 添加小组7人分工信息展示
// 5. 添加数据来源说明（数据来自Gitee远程JSON加载）
// 6. 添加思政总结相关内容
// 7. 美化整体页面布局

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于与设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 应用信息 — TODO: 组员E美化样式
            const Text(
              '美食菜谱APP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('版本: 1.0.0'),
            const SizedBox(height: 8),
            const Text('一款基于Flutter开发的美食菜谱应用，提供菜谱浏览、分类筛选、收藏管理等功能。'),

            const SizedBox(height: 24),

            // 数据来源 — TODO: 组员E完善合规声明
            const Text(
              '数据来源',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('本应用菜谱数据通过远程加载方式从Gitee仓库获取，数据来源合法合规。'),

            const SizedBox(height: 24),

            // 开源声明 — TODO: 组员E完善MIT声明
            const Text(
              '开源声明',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('本项目自主开发，架构参考了开源项目 recipes (MIT License, gitee.com/coder-YsH/recipes)。'),

            const SizedBox(height: 24),

            // TODO: 组员E添加暗色模式切换
            // TODO: 组员E添加隐私政策页面
            // TODO: 组员E添加思政总结内容

            const Divider(),
            const Text('云南大学 信息学院 移动应用软件开发实训', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}