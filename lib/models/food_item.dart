import 'dart:ui'; // Flutter-дің графикалық компоненттері үшін керек (Offset, т.б.)

/// Бұл класс ойындағы әрбір тағам түрін сипаттайды
/// Мысалы: алма, торт, конфета, т.б.
class FoodItem {
  final String name;        // Тағамның аты (мысалы: "Алма", "Торт")
  final String imagePath;    // Суретінің орналасқан жолы (assets/images/apple.png)
  final int points;          // Бұл тағамды ұстағанда қанша ұпай беретіні
  final bool isDessert;      // Десерт пе, әлде пайдалы тағам ба? (true = десерт)
  final bool isTrash;        // Қоқыс па? (мысалы: қағаз, бөтелке)

  FoodItem({
    required this.name,       // Барлық параметрлер міндетті (required)
    required this.imagePath,
    required this.points,
    this.isDessert = true,    // Егер көрсетілмесе, десерт деп есептеледі
    this.isTrash = false,     // Әдепкі бойынша қоқыс емес
  });
}

/// Бұл класс ойыншы жинаған (ұстаған) тағамдарды сақтайды
class CollectedFood {
  final FoodItem food;     // Қандай тағам екені (жоғарыдағы FoodItem түрі)
  int count;               // Осы тағамнан қанша дана жиналғаны
  int totalScore;          // Осы тағамнан жиналған жалпы ұпай (count * food.points)

  CollectedFood({
    required this.food,
    this.count = 0,         // Бастапқыда 0
    this.totalScore = 0,    // Бастапқыда 0
  });
}

/// Бұл класс құлап жатқан әрбір затты сипаттайды
/// Ойын экранында жоғарыдан төмен қарай құлап жатқан тағамдарды басқару үшін
class FallingItem {
  final FoodItem food;      // Қандай тағам құлап жатыр
  Offset position;          // Қазіргі орны (x, y координаттары)
  double speed;             // Құлау жылдамдығы

  FallingItem({
    required this.food,
    required this.position,
    required this.speed,
  });
}