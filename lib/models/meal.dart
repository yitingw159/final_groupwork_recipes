class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String image;
  final List<String> ingredients;
  final String instructions;
  final Nutrition nutrition;
  final int cookTime;

  Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.image,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    required this.cookTime,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      area: json['area'] ?? '',
      image: json['image'] ?? '',
      ingredients: (json['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [],
      instructions: json['instructions'] ?? '',
      nutrition: Nutrition.fromJson(json['nutrition'] ?? {}),
      cookTime: json['cookTime'] ?? 0,
    );
  }
}

class Nutrition {
  final int calories;
  final int protein;
  final int fat;
  final int carbs;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      fat: json['fat'] ?? 0,
      carbs: json['carbs'] ?? 0,
    );
  }
}