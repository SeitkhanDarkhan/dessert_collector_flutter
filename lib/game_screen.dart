import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/food_item.dart';
import '../services/food_service.dart';
import 'pause_screen.dart';
import 'game_over_screen.dart';

/// Бұл класс НЕГІЗГІ ОЙЫН ЭКРАНЫ
/// StatefulWidget - себебі: ойын үнемі өзгеріп отырады (ұпай, позиция, уақыт т.б.)
class GameScreen extends StatefulWidget {
  final String username;  // Ойыншы аты (алдыңғы беттен келеді)

  GameScreen({required this.username});

  @override
  _GameScreenState createState() => _GameScreenState();
}

/// Ойынның негізгі күйі (state) мен логикасы
/// SingleTickerProviderStateMixin - анимация контроллері үшін керек
class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // ==================== НЕГІЗГІ АЙНЫМАЛЫЛАР ====================
  late AnimationController _animationController;  // Анимацияны басқару
  List<FallingItem> _fallingItems = [];            // Құлап жатқан заттар тізімі
  double _playerX = 0.5;                           // Ойыншының X позициясы (0-1 аралығында)
  double _playerY = 0.85;                           // Ойыншының Y позициясы (тұрақты)
  double _playerWidth = 80;                         // Ойыншы ені
  double _playerHeight = 100;                        // Ойыншы биіктігі
  int _score = 0;                                    // Жалпы ұпай
  int _lives = 3;                                    // Қалған жан саны
  int _timeLeft = 30;                                 // Қалған уақыт (секунд) - КРИТЕРИЙ 8
  bool _isPaused = false;                            // Пауза режимі
  bool _gameOver = false;                             // Ойын аяқталды ма?
  bool _isGameStarted = false;                         // Ойын басталды ма?
  double _baseSpeed = 2.0;                             // Базалық жылдамдық
  int _lastHpIncreaseScore = 0;                        // Соңғы HP өскен ұпай
  int _lastSpeedIncreaseScore = 0;                      // Соңғы жылдамдық өскен ұпай

  // Тильт режимі үшін
  bool _useTilt = false;                               // Тильт режимі қосылған ба?
  double _tiltValue = 0.0;                              // Тильт мәні
  Timer? _tiltTimer;                                    // Тильт таймеры

  // Жиналған элементтер (статистика үшін)
  Map<String, CollectedFood> _collectedItems = {};

  // Экран өлшемдері
  double _screenWidth = 360;
  double _screenHeight = 640;

  // Таймер
  Timer? _gameTimer;

  // ==================== INITSTATE - ОЙЫН БАСТАЛҒАНДА ====================
  @override
  void initState() {
    super.initState();

    print("GameScreen initState called");
    print("Initial time: $_timeLeft seconds");

    // Бастапқы жиналған элементтерді инициализациялау
    _collectedItems = FoodService.createInitialCollectedItems();

    // Анимация контроллеры - 16 миллисекунд сайын жаңарту (шамамен 60 FPS)
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 16),
    );

    // Әр кадр сайын ойынды жаңарту
    _animationController.addListener(() {
      if (!_isPaused && !_gameOver && _isGameStarted) {
        _updateGame();  // Ойын логикасын жаңарту
      }
    });

    // 1 секундтан кейін ойынды автоматты түрде бастау
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        _startGame();
      }
    });
  }

  /// Ойынды бастау
  void _startGame() {
    print("Starting game...");

    if (_screenWidth <= 0) {
      print("Screen width is 0, cannot start game");
      return;
    }

    setState(() {
      _isGameStarted = true;
      // Бастапқы түсетін элементтерді құру - КРИТЕРИЙ 1
      _fallingItems = FoodService.generateInitialFallingItems(_screenWidth);
    });

    // Анимацияны бастау
    _animationController.repeat();

    // Таймерды бастау - ойын басталғаннан кейін ғана
    _startTimer();

    print("Game started with ${_fallingItems.length} items");
    print("Time left: $_timeLeft seconds");
  }

  /// Уақыт таймерын бастау (секунд сайын азаяды)
  void _startTimer() {
    print("Starting timer with 30 seconds countdown...");

    // Бұрынғы таймерды тоқтату
    _gameTimer?.cancel();

    // Уақытты қайта орнату
    if (_timeLeft <= 0) {
      _timeLeft = 30;
    }

    // 1 секунд сайын азайтатын таймер
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        print("Timer tick: $_timeLeft seconds left");
      }

      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!_isPaused && !_gameOver && _isGameStarted) {
        setState(() {
          _timeLeft--;
          print("Time left: $_timeLeft seconds");
        });

        // Уақыт біткен кезде ойынды аяқтау
        if (_timeLeft <= 0) {
          print("Time's up! Game over!");
          _timeLeft = 0;
          _endGame();
          timer.cancel();
        }
      }
    });
  }

  // ==================== ОЙЫН ЛОГИКАСЫ (ӘР КАДР САЙЫН) ====================
  /// Ойынды жаңарту - әр кадр сайын шақырылады
  void _updateGame() {
    if (!mounted || _isPaused || _gameOver || !_isGameStarted) return;

    // КРИТЕРИЙ 5: Жылдамдықты тексеру (әрбір 100 ұпай сайын жылдамдық артады)
    if (_score - _lastSpeedIncreaseScore >= 100) {
      _lastSpeedIncreaseScore = _score;
      _baseSpeed += 0.5;
      print("Speed increased to: $_baseSpeed");

      // Барлық элементтердің жылдамдығын арттыру
      for (var item in _fallingItems) {
        item.speed += 0.2;
      }
    }

    // КРИТЕРИЙ 7: Денсаулықты тексеру (әрбір 50 ұпай сайын +1 жан)
    if (_score - _lastHpIncreaseScore >= 50 && _score > 0) {
      _lastHpIncreaseScore = _score;
      setState(() {
        _lives++;
      });
      print("HP increased to: $_lives");
    }

    // Тильт режимі актив болса, ойыншыны жылжыту
    if (_useTilt && _isGameStarted) {
      _updatePlayerPositionWithTilt();
    }

    List<FallingItem> itemsToRemove = [];

    // Барлық құлап жатқан заттарды жылжыту
    for (var item in _fallingItems) {
      item.position += Offset(0, item.speed);  // Төмен қарай жылжу

      // КРИТЕРИЙ 2: Ойыншымен соқтығысу тексеру
      if (_checkCollision(item)) {
        _handleItemCollected(item);  // Зат жиналды
        itemsToRemove.add(item);
        continue;
      }

      // Элемент еденге түсті (экраннан шығып кетті)
      if (item.position.dy > _screenHeight) {
        _handleItemMissed(item);  // Зат жіберіп алынды
        itemsToRemove.add(item);
      }
    }

    // Жиналған немесе жоғалған элементтерді жою
    for (var item in itemsToRemove) {
      _fallingItems.remove(item);
    }

    // КРИТЕРИЙ 1: Жаңа элементтерді қосу (егер аз болса)
    if (_fallingItems.length < 8 && Random().nextDouble() < 0.03) {
      final food = FoodService.getRandomFood();
      _fallingItems.add(FallingItem(
        food: food,
        position: Offset(
          Random().nextDouble() * (_screenWidth - 40),  // Кездейсоқ X позиция
          -50,  // Экраннан жоғары бастау
        ),
        speed: _baseSpeed + Random().nextDouble() * 0.5,
      ));
    }

    // setState арқылы интерфейсті жаңарту
    if (mounted && !_isPaused && !_gameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Тильт режимінде ойыншыны жылжыту
  void _updatePlayerPositionWithTilt() {
    // Қарапайым тильт симуляциясы - кездейсоқ жылжыту
    double randomMovement = (Random().nextDouble() * 0.02 - 0.01); // -0.01 to 0.01

    setState(() {
      _playerX += randomMovement;
      _playerX = _playerX.clamp(0.1, 0.9);  // Шектеу (шетінен шығып кетпеу үшін)
    });
  }

  /// Соқтығысуды тексеру (ойыншы мен құлап жатқан зат)
  bool _checkCollision(FallingItem item) {
    // Ойыншының тіктөртбұрышы
    double playerLeft = _playerX * (_screenWidth - _playerWidth);
    double playerRight = playerLeft + _playerWidth;
    double playerTop = _playerY * _screenHeight - _playerHeight / 2;
    double playerBottom = playerTop + _playerHeight;

    // Заттың тіктөртбұрышы
    double itemLeft = item.position.dx;
    double itemRight = itemLeft + 40;
    double itemTop = item.position.dy;
    double itemBottom = itemTop + 40;

    // Екі тіктөртбұрыш қиылыса ма?
    return itemRight > playerLeft &&
        itemLeft < playerRight &&
        itemBottom > playerTop &&
        itemTop < playerBottom;
  }

  /// Зат жиналған кездегі әрекет
  void _handleItemCollected(FallingItem item) {
    print("Collected: ${item.food.name}, Points: ${item.food.points}");

    // КРИТЕРИЙ 4: Ұпайды есептеу
    _score += item.food.points;

    // КРИТЕРИЙ 4c: Пирожок (Puff) уақыт қосады
    if (item.food.name == 'Puff') {
      setState(() {
        _timeLeft += 30;
      });
      print("Time increased by 30 seconds. New time: $_timeLeft");
    }

    // КРИТЕРИЙ 4d: Рыбья кость (Fishbone) жан азайтады
    if (item.food.name == 'Fishbone') {
      if (_lives > 0) {
        setState(() {
          _lives--;
        });
        print("HP decreased to: $_lives");
      }
    }

    // Ұпай теріс болмауы керек
    if (_score < 0) _score = 0;

    // Жиналған элементтерді жаңарту (статистика)
    if (_collectedItems.containsKey(item.food.name)) {
      var collected = _collectedItems[item.food.name]!;
      collected.count++;
      collected.totalScore += item.food.points;
    }

    // Жандар тексеруі (өліп қалмады ма?)
    _checkGameOver();
  }

  /// Зат жіберіп алынған кездегі әрекет
  void _handleItemMissed(FallingItem item) {
    print("Missed: ${item.food.name}");

      // КРИТЕРИЙ 6: Егер десерт еденге түссе, жан азаяды
    if (item.food.isDessert && !item.food.isTrash) {
      if (_lives > 0) {
        setState(() {
          _lives--;
        });
        print("HP decreased to: $_lives (dessert missed)");
      }
    }

    // Жандар тексеруі
    _checkGameOver();
  }

  /// Ойын аяқталды ма? Тексеру
  void _checkGameOver() {
    if (_lives <= 0 || _timeLeft <= 0) {
      _endGame();  // Ойынды аяқтау
    }
  }

  /// Ойынды аяқтау
  void _endGame() {
    if (_gameOver) return;

    print("Ending game...");
    print("Final score: $_score");
    print("Final lives: $_lives");
    print("Final time: $_timeLeft");

    _gameOver = true;
    _isPaused = true;

    // Барлық анимациялар мен таймерларды тоқтату
    _animationController.stop();
    _gameTimer?.cancel();
    _tiltTimer?.cancel();

    // КРИТЕРИЙ 9: Game Over экранына өту
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameOverScreen(
              username: widget.username,
              score: _score,
              time: 30 - _timeLeft, // Шынымен өткен уақыт
              livesLeft: _lives,
              collectedItems: _collectedItems.values
                  .where((item) => item.count > 0)
                  .toList(),
              isWin: _lives > 0 && _timeLeft > 0,
            ),
          ),
        );
      }
    });
  }

  // ==================== ПАУЗА ЖӘНЕ БАСҚАРУ ФУНКЦИЯЛАРЫ ====================
  /// Ойынды кідірту - КРИТЕРИЙ 3
  void _pauseGame() {
    print("Pausing game... Time left: $_timeLeft");
    setState(() {
      _isPaused = true;
    });
    _animationController.stop();
    _gameTimer?.cancel();
  }

  /// Ойынды жалғастыру
  void _resumeGame() {
    print("Resuming game... Time left: $_timeLeft");
    setState(() {
      _isPaused = false;
    });
    _animationController.repeat();
    _startTimer(); // Таймерды қайта бастау
  }

  /// Ойынды қайта бастау
  void _restartGame() {
    print("Restarting game...");

    // Барлық таймерларды тоқтату
    _gameTimer?.cancel();
    _tiltTimer?.cancel();
    _animationController.stop();

    // Контекст қолжетімді болса, жаңа ойын бастау
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(username: widget.username),
        ),
      );
    }
  }

  /// Тильт режимін ауыстыру
  void _toggleTiltMode() {
    setState(() {
      _useTilt = !_useTilt;

      if (_useTilt) {
        // Тильт таймерын бастау (әр 100 мс сайын жаңарту)
        _tiltTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
          if (!_isPaused && !_gameOver && _isGameStarted && mounted) {
            _updatePlayerPositionWithTilt();
          }
        });
      } else {
        _tiltTimer?.cancel();  // Тильт таймерын тоқтату
      }
    });
  }

  // ==================== DISPOSE - ЖАДТЫ БОСАТУ ====================
  @override
  void dispose() {
    print("GameScreen dispose called");
    _animationController.dispose();
    _gameTimer?.cancel();
    _tiltTimer?.cancel();
    super.dispose();
  }

  // ==================== BUILD - ИНТЕРФЕЙСТІ ҚҰРУ ====================
  @override
  Widget build(BuildContext context) {
    // Экран өлшемдерін алу
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;

    return Scaffold(
          body: GestureDetector(
        // КРИТЕРИЙ 2: Drag арқылы басқару
        onPanUpdate: (details) {
          // Drag режимі актив болса
          if (!_isPaused && !_gameOver && _isGameStarted && !_useTilt) {
            setState(() {
              // details.delta.dx - саусақтың қозғалыс мөлшері
              _playerX += details.delta.dx / _screenWidth;  // Пропорцияға түрлендіру
              _playerX = _playerX.clamp(0.1, 0.9);  // Шектеу
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4A90E2),  // Көгілдір
                Color(0xFF63B8FF),  // Ашық көк
              ],
            ),
          ),
          //
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. ТҮСЕТІН ЭЛЕМЕНТТЕР
              ..._buildFallingItems(),

              // 2. ОЙЫНШЫ (ҚЫЗ)
              Positioned(
                left: _playerX * (_screenWidth - _playerWidth),
                top: _playerY * _screenHeight - _playerHeight / 2,
                child: Container(
                  width: _playerWidth,
                  height: _playerHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/player.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // 3. ҰПАЙ КӨРСЕТКІШІ
              Positioned(
                top: 40,
                left: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$_score',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 4. ЖАНДАР (LIVES) - КРИТЕРИЙ 6
              Positioned(
                top: 40,
                left: _screenWidth / 2 - 40,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 24),
                      SizedBox(width: 5),
                      Text(
                        'x$_lives',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. УАҚЫТ - КРИТЕРИЙ 8
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 10
                        ? Colors.red.withOpacity(0.7)  // 10 секундтан аз болса қызыл
                        : Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _timeLeft <= 10 ? Colors.red : Colors.green,
                        width: 2
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_timeLeft.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'seconds',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. ТИЛЬТ/DRAG РЕЖИМІН АУЫСТЫРУ ТҮЙМЕСІ
              Positioned(
                bottom: 120,
                left: 20,
                child: GestureDetector(
                  onTap: _toggleTiltMode,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: _useTilt ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _useTilt ? Icons.phone_android : Icons.touch_app,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          _useTilt ? 'Tilt ON' : 'Drag',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 7. ПАУЗА КНОПКАСЫ - КРИТЕРИЙ 3
              Positioned(
                bottom: 40,
                left: _screenWidth / 2 - 30,
                child: GestureDetector(
                  onTap: () {
                    _pauseGame();  // Ойынды кідірту

                    // Пауза экранын ашу
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PauseScreen(
                          resumeGame: _resumeGame,    // Жалғастыру
                          restartGame: _restartGame,   // Қайта бастау
                          quitGame: () {
                            // Барлық беттерді жауып, басты бетке қайту
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.pause,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // 8. СТАРТ ХАБАРЛАМАСЫ (ойын басталмаған кезде)
              if (!_isGameStarted && !_gameOver)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.yellow, width: 3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TIME STARTED!',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Time is counting down: $_timeLeft',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Get ready in 1 second...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 9. ЖЕҢІЛГЕН КЕЗДЕГІ ХАБАРЛАМА
              if (_lives <= 0 && !_gameOver)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red, width: 3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sentiment_very_dissatisfied,
                            size: 60,
                            color: Colors.red,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'GAME OVER',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No more lives!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 10. УАҚЫТ АЯҚТАЛҒАНДА
              if (_timeLeft <= 0 && !_gameOver)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.yellow, width: 3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_off,
                            size: 60,
                            color: Colors.yellow,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'TIME\'S UP!',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '30 seconds finished!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 11. ПАУЗА МӘТІНІ
              if (_isPaused && !_gameOver)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pause_circle_filled,
                            size: 60,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'PAUSED',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Time: $_timeLeft seconds left',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Құлап жатқан заттардың Widget-терін құру
  List<Widget> _buildFallingItems() {
    return _fallingItems.map((item) {
      return Positioned(
        left: item.position.dx,
        top: item.position.dy,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(item.food.imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }).toList();
  }
}