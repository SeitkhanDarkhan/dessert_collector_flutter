import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/score_model.dart';
import '../models/food_item.dart';
import 'rankings_screen.dart';

/// Бұл класс ОЙЫН АЯҚТАЛҒАННАН КЕЙІНГІ НӘТИЖЕЛЕР БЕТІ
/// StatelessWidget - себебі: нәтижелерді тек көрсетеді, өзгертпейді
class GameOverScreen extends StatelessWidget {
  // Барлық қажетті мәліметтерді конструктор арқылы қабылдайды
  final String username;                 // Ойыншы аты
  final int score;                       // Жалпы ұпай
  final int time;                        // Ойынға кеткен уақыт (секунд)
  final int livesLeft;                   // Қалған өмір саны
  final List<CollectedFood> collectedItems; // Жинаған заттар тізімі
  final int dessertsCollected;            // Жинаған десерттер саны
  final int trashCollected;               // Жинаған қоқыстар саны
  final int itemsMissed;                  // Жіберіп алған заттар саны
  final bool isWin;                       // Жеңіске жетті ме?

  GameOverScreen({
    required this.username,
    required this.score,
    required this.time,
    required this.livesLeft,
    required this.collectedItems,
    this.dessertsCollected = 0,
    this.trashCollected = 0,
    this.itemsMissed = 0,
    required this.isWin,
  });

  // StorageService - нәтижені сақтау үшін
  final StorageService storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    // БАРЛЫҚ МҮМКІН ЭЛЕМЕНТТЕРДІҢ ТІЗІМІН ЖАСАУ
    // Бұл барлық ойында бар тағам түрлері
    List<FoodItem> allFoodItems = [
      FoodItem(
          name: 'Baguette',
          imagePath: 'assets/images/baguette.png',
          points: 10,
          isDessert: true
      ),
      FoodItem(
          name: 'Macaron',
          imagePath: 'assets/images/macaron.png',
          points: 20,
          isDessert: true
      ),
      FoodItem(
          name: 'Puff',
          imagePath: 'assets/images/puff.png',
          points: 30,
          isDessert: true
      ),
      FoodItem(
          name: 'Bone',
          imagePath: 'assets/images/bone.png',
          points: -10,
          isDessert: false,
          isTrash: true
      ),
      FoodItem(
          name: 'Fishbone',
          imagePath: 'assets/images/fishbone.png',
          points: -20,
          isDessert: false,
          isTrash: true
      ),
    ];

    // БАРЛЫҚ ЭЛЕМЕНТТЕРДІ ЖИНАП, САНЫ 0 БОЛАТЫНДАРЫН ҚОСУ
    // Бұл әрбір тағам түрін (тіпті жиналмаса да) көрсету үшін
    Map<String, CollectedFood> collectedMap = {};

    // Алдымен жиналған элементтерді картаға салу (жылдам іздеу үшін)
    for (var item in collectedItems) {
      collectedMap[item.food.name] = item;
    }

    // Барлық элементтер үшін, егер жиналмаса 0 деп көрсету
    List<CollectedFood> allCollectedItems = [];

    for (var foodItem in allFoodItems) {
      if (collectedMap.containsKey(foodItem.name)) {
        // Егер жиналған болса, сол объектіні қосу
        allCollectedItems.add(collectedMap[foodItem.name]!);
      } else {
        // Егер жиналмаған болса, саны 0 болатын жаңа объект құру
        allCollectedItems.add(CollectedFood(
            food: foodItem,
            count: 0,
            totalScore: 0
        ));
      }
    }

    return Scaffold(
      body: Container(
        // Фон градиенті (әдемі түсті фон)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,      // Жоғарыдан
            end: Alignment.bottomCenter,     // Төменге қарай
            colors: [
              Color(0xFF2C3E50),  // Қою көк-сұр
              Color(0xFF1A1A2E),  // Қара-көк
            ],
          ),
        ),
        // SafeArea - экранның қауіпсіз аймағы (сенсорлар, камера т.б. болмайтын жер)
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. GAME OVER ЗАГОЛОВОГЫ
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),  // Жартылай мөлдір қызыл
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'GAME OVER',  // Ойын аяқталды
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,  // Әріп аралығы үлкен
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // 2. ПРЕДМЕТТЕР ТІЗІМІ (жиналған заттар)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),  // Жартылай мөлдір ақ
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      children: [
                        // Тақырыпша: "ITEMS COLLECTED" (Жинаған заттар)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                            ),
                          ),
                          child: Text(
                            'ITEMS COLLECTED',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Егер элемент жиналмаса (ешнәрсе жоқ болса)
                        if (collectedItems.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No items collected',  // "Ешқандай зат жиналмады"
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          )
                        else
                        // Предметтер тізімі (бар болса)
                          Expanded(
                            child: ListView.builder(
                              itemCount: allCollectedItems.length,
                              itemBuilder: (context, index) {
                                final item = allCollectedItems[index];
                                return _buildItemRow(item);  // Әр жолды құру
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // 3. УАҚЫТ ЖӘНЕ ҰПАЙ (төменгі қатар)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Уақыт блогы
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TIME',  // "УАҚЫТ"
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _formatTime(time),  // Уақытты форматтау (мм:сс)
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Жалпы ұпай блогы (ерекшеленген)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SCORE',  // "ҰПАЙ"
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // 4. NEXT КНОПКАСЫ (келесі бетке өту)
                ElevatedButton(
                  onPressed: () async {
                    // Алдымен нәтижені сақтау
                    await storageService.saveScore(
                      ScoreModel(
                        username: username,
                        score: score,
                        date: DateTime.now(),
                      ),
                    );

                    // Сосын RankingsScreen бетіне өту
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RankingsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blue.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, size: 24, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Әрбір жиналған заттың жолын құратын көмекші метод
  Widget _buildItemRow(CollectedFood item) {
    // Суреттерді таңдау - Box суреттерін қолданамыз (әдемі көріну үшін)
    String imagePath;
    switch (item.food.name) {
      case 'Baguette':
        imagePath = 'assets/images/baguette_box.png';
        break;
      case 'Macaron':
        imagePath = 'assets/images/macaron_box.png';
        break;
      case 'Puff':
      // Егер puff_box болмаса, әдеттегі puff суретін қолданамын
        imagePath = 'assets/images/puff.png';
        break;
      case 'Bone':
        imagePath = 'assets/images/bone_box.png';
        break;
      case 'Fishbone':
        imagePath = 'assets/images/fishbone_box.png';
        break;
      default:
        imagePath = item.food.imagePath;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          // 1. СУРЕТ (сол жақта)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.contain,  // Суреттің пропорциясын сақтау
              ),
            ),
          ),

          SizedBox(width: 15),

          // 2. АТАУЫ (ортада)
          Expanded(
            child: Text(
              item.food.name,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 3. САНЫ (x5, x2 т.б.)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'x${item.count}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(width: 15),

          // 4. ҰПАЙЫ (+10, -20 т.б.) - ең оң жақта
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: item.totalScore >= 0
                  ? Colors.green.withOpacity(0.2)   // Оң ұпай - жасыл фон
                  : Colors.red.withOpacity(0.2),     // Теріс ұпай - қызыл фон
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: item.totalScore >= 0 ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Text(
              '${item.totalScore >= 0 ? '+' : ''}${item.totalScore}', // Оң санға + қосу
              style: TextStyle(
                fontSize: 18,
                color: item.totalScore >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Уақытты секундтан "мм:сс" форматына түрлендіру
  /// Мысалы: 125 секунд -> "02:05"
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;        // Минуттар (бүтін бөлу)
    int remainingSeconds = seconds % 60; // Қалған секундтар
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}