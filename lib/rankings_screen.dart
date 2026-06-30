import 'package:flutter/material.dart';
import '../services/storage_service.dart';  // Деректерді сақтау сервисі
import '../models/score_model.dart';        // Нәтиже моделі
import 'username_screen.dart';               // Қайта ойнау үшін атын енгізу беті

/// Бұл класс ОЙЫН НӘТИЖЕЛЕРІН (рейтингтерді) көрсететін бет
/// StatefulWidget - себебі: нәтижелер тізімі жүктелгеннен кейін өзгереді
class RankingsScreen extends StatefulWidget {
  @override
  _RankingsScreenState createState() => _RankingsScreenState();
}

/// RankingsScreen-нің State (күй) бөлігі
class _RankingsScreenState extends State<RankingsScreen> {
  // StorageService объектісі - нәтижелерді оқу үшін
  final StorageService storageService = StorageService();

  // Нәтижелер тізімі (бос тізімнен басталады)
  List<ScoreModel> scores = [];

  /// Бет инициализацияланғанда бір рет орындалады
  @override
  void initState() {
    super.initState();
    loadScores();  // Нәтижелерді жүктеу
  }

  /// Сақталған нәтижелерді жүктейтін әдіс
  void loadScores() async {
    // StorageService-тен нәтижелерді алу (асинхронды)
    final loadedScores = await storageService.getScores();

    // setState - бетті қайта салу (тізімді жаңарту)
    setState(() {
      // Нәтижелерді ұпай саны бойынша КЕМІМЕН сұрыптау (ең жоғарыдан төменге)
      // .. - каскадты оператор (бірнеше операцияны тізбектеп орындау)
      // sort - сұрыптау (b.score.compareTo(a.score) - кемімелі ретпен)
      scores = loadedScores..sort((a, b) => b.score.compareTo(a.score));
    });
  }

  /// Бет интерфейсін құру
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Жоғарғы панель (AppBar)
      appBar: AppBar(
        title: Text('Rankings'),
        automaticallyImplyLeading: false,// Тақырыбы: "Рейтингтер"
      ),

      // Негізгі бет бөлігі
      body: scores.isEmpty
      // Егер нәтижелер тізімі БОС болса:
          ? Center(
        child: Text('No scores yet'),  // "Әзірге нәтижелер жоқ"
      )
      // Егер нәтижелер бар болса:
          : ListView.builder(
        // Тізім элементтерінің саны
        itemCount: scores.length,

        // Әрбір элементті құру
        itemBuilder: (context, index) {
          final score = scores[index];  // Ағымдағы нәтиже

          return ListTile(
            // Сол жақтағы номер (1, 2, 3...)
            leading: Text('${index + 1}'),

            // Ойыншы аты (негізгі мәтін)
            title: Text(score.username),

            // Күні (қосымша мәтін)
            subtitle: Text('Date: ${score.date.toLocal()}'),

            // Оң жақтағы ұпай саны
            trailing: Text('Score: ${score.score}'),
          );
        },
      ),

      // Қалқымалы әрекет батырмасы (FAB)
      floatingActionButton: FloatingActionButton(
        // Батырма басылғанда
        onPressed: () {
          // Navigator.pushReplacement - ағымдағы бетті жауып, жаңа бет ашу
          // Яғни "Артқа" басқанда RankingsScreen-ге қайтпайды
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UsernameScreen(),  // Атын енгізу бетіне өту
            ),
          );
        },
        child: Icon(Icons.refresh),  // Батырма ішіндегі иконка (жаңарту)
        tooltip: 'Tap To Retry',     // Ұстап тұрғанда шығатын көмекші мәтін
      ),
    );
  }
}