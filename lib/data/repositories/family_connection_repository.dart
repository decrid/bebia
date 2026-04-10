import '../../features/family/family_connection.dart';
import '../local/family_connection_store.dart';

class FamilyConnectionRepository {
  FamilyConnectionRepository(this._store);

  final FamilyConnectionStore _store;

  Future<FamilyConnectionState> loadState() => _store.read();

  Future<void> saveState(FamilyConnectionState state) => _store.write(state);

  Future<void> clear() => _store.clear();
}
