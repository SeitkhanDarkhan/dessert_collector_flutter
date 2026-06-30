import 'dart:math';      // Кездейсоқ сандар генераторы үшін (Random классы)
import 'dart:ui';        // Offset (координат) класы үшін
import '../models/food_item.dart';  // FoodItem моделін импорттау

/// Бұл класс ойынның негізгі сервисі
/// Барлық тағамдарды басқарады, кездейсоқ тағамдарды таңдайды
class FoodService {
  // Десерттер тізімі - ойындағы пайдалы/тәтті тағамдар
  static List<FoodItem> desserts = [
    FoodItem(name: 'Baguette', imagePath: 'assets/images/Baguette.png', points: 10, isDessert: true),
    FoodItem(name: 'Macaron', imagePath: 'assets/images/macaron.png', points: 20, isDessert: true),
    FoodItem(name: 'Puff', imagePath: 'assets/images/puff.png', points: 30, isDessert: true),
  ];

  // Мусор (қоқыс) тізімі - теріс ұпай беретін заттар
  static List<FoodItem> trashItems = [
    FoodItem(name: 'Bone', imagePath: 'assets/images/bone.png', points: -10, isDessert: false, isTrash: true),
    FoodItem(name: 'Fishbone', imagePath: 'assets/images/fishbone.png', points: -20, isDessert: false, isTrash: true),
  ];

  /// Кездейсоқ тағам қайтарады
  /// 30% ықтималдықпен қоқыс, 70% ықтималдықпен десерт қайтарады
  static FoodItem getRandomFood() {
    Random random = Random();  // Кездейсоқ сандар генераторы
    bool isTrash = random.nextDouble() < 0.3;  // 0.0-1.0 аралығындағы кездейсоқ сан. Егер 0.3-тен кіші болса - қоқыс

    if (isTrash) {
      // Қоқыстар тізімінен кездейсоқ біреуін таңдау
      return trashItems[random.nextInt(trashItems.length)];
    } else {
      // Десерттер тізімінен кездейсоқ біреуін таңдау
      return desserts[random.nextInt(desserts.length)];
    }
  }

  /// Ойын басында құлап жатқан заттардың бастапқы тізімін жасайды
  /// screenWidth - экран ені (заттарды экранның ішінде орналастыру үшін)
  static List<FallingItem> generateInitialFallingItems(double screenWidth) {
    // Егер экран ені дұрыс емес болса, бос тізім қайтару
    if (screenWidth <= 0) return [];

    Random random = Random();
    List<FallingItem> items = [];

    // 5 құлап жатқан зат жасау
    for (int i = 0; i < 5; i++) {
      FoodItem food = getRandomFood();  // Кездейсоқ тағам алу

      items.add(FallingItem(
        food: food,
        position: Offset(
          // Кездейсоқ x координаты (экранның сол жақ шетінен оң жақ шетіне дейін)
          // 40 пиксельді шегеру - заттың өз енін ескеру үшін
          random.nextDouble() * (screenWidth - 40),
          // Кездейсоқ y координаты (экраннан жоғары, теріс мәндер)
          // -50 ден -250 ге дейін (экраннан жоғарыда басталады)
          -random.nextDouble() * 200 - 50,
        ),
        speed: 2.0 + random.nextDouble() * 0.5,  // Жылдамдық: 2.0 - 2.5 аралығында
      ));
    }

    return items;
  }

  /// Ойын басында жиналған заттардың бастапқы тізімін жасайды
  /// Әрбір тағам түрі үшін CollectedFood объектісін құрады
  static Map<String, CollectedFood> createInitialCollectedItems() {
    Map<String, CollectedFood> items = {};

    // Барлық десерттер үшін CollectedFood жасау
    for (var dessert in desserts) {
      items[dessert.name] = CollectedFood(food: dessert);
    }

    // Барлық қоқыстар үшін CollectedFood жасау
    for (var trash in trashItems) {
      items[trash.name] = CollectedFood(food: trash);
    }

    return items;
  }
}