import '../../domain/entities/sleep_log.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../datasources/sleep_remote_datasource.dart';

class SleepRepositoryImpl implements SleepRepository {
  final SleepRemoteDatasource remoteDatasource;

  const SleepRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<SleepLog>> getSleepLogs() async {
    final dtos = await remoteDatasource.getSleepLogs();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<SleepLog> createSleepLog(DateTime start, DateTime end) async {
    final dto = await remoteDatasource.createSleepLog(start, end);
    return dto.toEntity();
  }

  @override
  Future<int> deleteSleepDay(DateTime date) async {
    return await remoteDatasource.deleteSleepDay(date);
  }
}
