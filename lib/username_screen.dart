import 'package:flutter/material.dart';
import 'game_screen.dart';

/// Бұл класс ойыншының атын енгізуге арналған БЕТ
/// StatefulWidget - себебі: мәтін енгізу өрісінде (TextField) деректер өзгереді
class UsernameScreen extends StatefulWidget {

  @override
  _UsernameScreenState createState() => _UsernameScreenState();
}

/// Бұл класс - UsernameScreen-нің State (күй) бөлігі
/// Барлық өзгеретін деректер мен логика осында сақталады
class _UsernameScreenState extends State<UsernameScreen> {
  // TextEditingController - TextField-тен мәтінді оқуға және басқаруға арналған контроллер
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Центр - барлық элементтерді ортаға орналастыру
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Тігінен ортаға
          children: [
            // Бірінші элемент: Тақырып
            Text(
              'Player Name',  // "Ойыншының аты" деген мәтін
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            ),

            // Бос орын (тақырып пен мәтін өрісінің арасы)
            SizedBox(height: 20),

            // Мәтін енгізу өрісі (TextField)
            Padding(
              // Екі жағынан 40 пиксель қалдыру (мәтін өрісі тым кең болмас үшін)
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _usernameController,  // Мәтінді басқару үшін контроллер
                decoration: InputDecoration(
                  border: OutlineInputBorder(),   // Жиектеме (рамка)
                  hintText: 'Enter your name',    // Ішіндегі көмекші мәтін (сурау)
                ),
              ),
            ),

            // Бос орын (мәтін өрісі мен батырма арасы)
            SizedBox(height: 20),

            // "Start" батырмасы
            ElevatedButton(
              onPressed: () {
                // Батырма басылғанда: алдымен мәтін енгізілгенін тексеру
                if (_usernameController.text.isNotEmpty) {
                  // Егер мәтін енгізілсе, ойын бетіне өту
                  // Navigator.pushReplacement - ағымдағы бетті жауып, жаңа бетті ашады
                  // Яғни "Артқа" басқанда UsernameScreen-ге қайтпайды
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      // GameScreen-ге username параметрін жіберу
                      builder: (context) => GameScreen(
                        username: _usernameController.text,  // Енгізілген атын жіберу
                      ),
                    ),
                  );
                } else {
                  // Егер мәтін енгізілмесе, қате туралы хабарлама көрсету
                  // ScaffoldMessenger - уақытша хабарлама (snackbar) көрсету үшін
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter your name'),  // "Атыңызды енгізіңіз"
                    ),
                  );
                }
              },
              child: Text('Start'),  // Батырма мәтіні
            ),
          ],
        ),
      ),
    );
  }

  // StatefulWidget-де dispose() методін қосу пайдалы
  // Бет жабылғанда контроллерді тазалау (жадтан босату)
  @override
  void dispose() {
    _usernameController.dispose();  // Контроллерді жою (есте сақтау керек!)
    super.dispose();
  }
}