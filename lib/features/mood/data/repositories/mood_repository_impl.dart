import '../../domain/entities/mood_log.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_remote_datasource.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodRemoteDatasource remoteDatasource;

  const MoodRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<MoodLog>> getMoodLogs() async {
    final dtos = await remoteDatasource.getMoodLogs();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<MoodLog> createOrUpdateMoodLog({
    required DateTime date,
    required int mood,
    String? note,
  }) async {
    final dto = await remoteDatasource.createOrUpdateMoodLog(
      date: date,
      mood: mood,
      note: note,
    );
    return dto.toEntity();
  }

  @override
  Future<int> deleteMoodDay(DateTime date) async {
    return await remoteDatasource.deleteMoodDay(date);
  }
}
