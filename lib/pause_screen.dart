import 'package:flutter/material.dart';

/// Бұл класс ОЙЫНДЫ КІДІРТУ (пауза) беті
/// StatelessWidget - себебі: бұл бетте өзгеретін деректер жоқ
/// Тек қана батырмалар мен мәтіндер бар
class PauseScreen extends StatelessWidget {

  // Келесі функцияларды (callback) ата-аналық беттен (GameScreen) қабылдайды
  final Function resumeGame;   // Ойынды жалғастыру функциясы
  final Function restartGame;  // Ойынды қайта бастау функциясы
  final Function quitGame;     // Ойыннан шығу функциясы

  // Конструктор - барлық функциялар міндетті (required)
  PauseScreen({
    required this.resumeGame,
    required this.restartGame,
    required this.quitGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Жартылай мөлдір қара фон (артқы фонды көруге болады)
      backgroundColor: Colors.black54,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Тігінен ортаға
          children: [
            // Бірінші элемент: "Game pause" мәтіні
            Text(
              'Game pause',  // "Ойын кідіртілді"
              style: TextStyle(
                fontSize: 32,        // Үлкен әріптер
                color: Colors.white, // Ақ түсті
              ),
            ),

            // Бос орын (мәтін мен батырмалар арасы)
            SizedBox(height: 30),

            // Бірінші батырма: CONTINUE (Жалғастыру)
            ElevatedButton(
              onPressed: () {
                // Екі әрекет:
                // 1. Ағымдағы PauseScreen бетін жабу (pop)
                Navigator.pop(context);

                // 2. resumeGame функциясын шақыру (ойынды жалғастыру)
                resumeGame();
              },
              child: Text('Continue'),  // "Жалғастыру"
            ),

            // Бос орын (батырмалар арасы)
            SizedBox(height: 15),

            // Екінші батырма: RESTART (Қайта бастау)
            ElevatedButton(
              onPressed: () {
                // Диалог терезесін көрсету (растау сұрау)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Restart Game'),        // Тақырыбы
                    content: Text('Do you want to reset game progress?'),  // Сұрақ
                    actions: [
                      // Бірінші әрекет: CANCEL (Бас тарту)
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Диалогты жабу
                        child: Text('Cancel'),
                      ),

                      // Екінші әрекет: RESTART (Қайта бастау)
                      TextButton(
                        onPressed: () {
                          // Екі әрекет:
                          // 1. Диалог терезесін жабу
                          Navigator.pop(context);

                          // 2. restartGame функциясын шақыру (ойынды қайта бастау)
                          restartGame();
                        },
                        child: Text('Restart'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Restart'),  // "Қайта бастау"
            ),

            // Бос орын (батырмалар арасы)
            SizedBox(height: 15),

            // Үшінші батырма: QUIT (Шығу)
            ElevatedButton(
              onPressed: () {
                // Диалог терезесін көрсету (растау сұрау)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Quit Game'),            // Тақырыбы
                    content: Text('Do you want to quit the game?'),  // Сұрақ
                    actions: [
                      // Бірінші әрекет: CANCEL (Бас тарту)
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Диалогты жабу
                        child: Text('Cancel'),
                      ),

                      // Екінші әрекет: QUIT (Шығу)
                      TextButton(
                        onPressed: () {
                          // Екі әрекет:
                          // 1. Диалог терезесін жабу
                          Navigator.pop(context);

                          // 2. quitGame функциясын шақыру (ойыннан шығу)
                          quitGame();
                        },
                        child: Text('Quit'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Quit'),  // "Шығу"
            ),
          ],
        ),
      ),
    );
  }
}