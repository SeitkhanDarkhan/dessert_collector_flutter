import 'package:shared_preferences/shared_preferences.dart';  // Деректерді жадқа сақтау үшін
import '../models/score_model.dart';  // ScoreModel класын импорттау

/// Бұл класс ойын нәтижелерін (рекордтарды) құрылғының жадқа сақтау үшін қолданылады
/// SharedPreferences - қарапайым деректерді (сан, жол, тізім) сақтауға арналған
class StorageService {
  // Жадтағы кілт сөз (key) - нәтижелерді осы атпен сақтаймыз
  static const String _scoresKey = 'game_scores';

  /// Жаңа ойын нәтижесін жадқа сақтайды
  /// score - сақталатын нәтиже (кім, қанша ұпай, қашан)
  Future<void> saveScore(ScoreModel score) async {
    try {
      // SharedPreferences объектісін алу (жадқа қатынасу)
      final prefs = await SharedPreferences.getInstance();

      // Барлық бұрынғы нәтижелерді алу
      final scores = await getScores();

      // Жаңа нәтижені тізімге қосу
      scores.add(score);

      // Нәтижелерді жолдар тізіміне түрлендіру
      // Әр нәтижені "аты|ұпай|күні" форматында сақтаймыз
      final scoreStrings = scores.map((s) =>
      '${s.username}|${s.score}|${s.date.toIso8601String()}'
      ).toList();

      // Жолдар тізімін жадқа сақтау
      await prefs.setStringList(_scoresKey, scoreStrings);
    } catch (e) {
      // Қате болса, консольге шығару
      print('Error saving score: $e');
    }
  }

  /// Жадтан барлық ойын нәтижелерін оқиды
  /// Қайтарады: ScoreModel объектілерінің тізімі
  Future<List<ScoreModel>> getScores() async {
    try {
      // SharedPreferences объектісін алу
      final prefs = await SharedPreferences.getInstance();

      // Жадтан сақталған жолдар тізімін алу (егер жоқ болса, бос тізім)
      final scoreStrings = prefs.getStringList(_scoresKey) ?? [];

      // Әр жолды ScoreModel-ге түрлендіру
      final scores = scoreStrings.map((str) {
        // Жолды бөліктерге бөлу (аты, ұпай, күні)
        final parts = str.split('|');

        // Егер дұрыс форматта болса (3 бөліктен тұрса)
        if (parts.length == 3) {
          return ScoreModel(
            username: parts[0],  // Бірінші бөлік - ойыншы аты
            score: int.tryParse(parts[1]) ?? 0,  // Екінші бөлік - ұпай (санға түрлендіру)
            date: DateTime.tryParse(parts[2]) ?? DateTime.now(),  // Үшінші бөлік - күн
          );
        }

        // Егер формат дұрыс болмаса, бос нәтиже қайтару
        return ScoreModel(username: 'Player', score: 0, date: DateTime.now());
      }).toList();

      return scores;
    } catch (e) {
      // Қате болса, консольге шығарып, бос тізім қайтару
      print('Error getting scores: $e');
      return [];
    }
  }

  /// Барлық сақталған нәтижелерді жояды
  Future<void> clearScores() async {
    try {
      // SharedPreferences объектісін алу
      final prefs = await SharedPreferences.getInstance();

      // Нәтижелер сақталған кілтті жою (барлық нәтижелер өшеді)
      await prefs.remove(_scoresKey);
    } catch (e) {
      // Қате болса, консольге шығару
      print('Error clearing scores: $e');
    }
  }
}