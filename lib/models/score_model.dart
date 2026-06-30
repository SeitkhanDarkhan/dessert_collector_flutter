/// Бұл класс ойыншының нәтижесін (рекордын) сақтау үшін қолданылады
/// Мысалы: кім, қанша ұпай жинады, қашан ойнады деген мәліметтер
class ScoreModel {
  final String username;  // Ойыншының аты (кім ойнады?)
  final int score;        // Жинаған ұпай саны (қанша ұпай?)
  final DateTime date;    // Ойнаған күні мен уақыты (қашан ойнады?)

  ScoreModel({
    required this.username,
    required this.score,
    required this.date,
  });

  /// Бұл метод ScoreModel объектісін Map (сөздік) түріне түрлендіреді
  /// Бұл деректерді базаға сақтау немесе жіберу үшін керек
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'score': score,
      'date': date.toIso8601String(), // DateTime-ды жолға (String) түрлендіру
    };
  }

  /// Бұл фабрика (factory) конструкторы Map-тен ScoreModel құрады
  /// toMap() методімен кері байланыста жұмыс істейді
  /// Базадан немесе интернеттен алынған деректерді қайтадан ScoreModel-ге айналдырады
  factory ScoreModel.fromMap(Map<String, dynamic> map) {
    return ScoreModel(
      username: map['username'],           // Map-тен username-ді алу
      score: map['score'],                 // Map-тен score-ды алу
      date: DateTime.parse(map['date']),   // Жолды қайтадан DateTime-ға түрлендіру
    );
  }
}