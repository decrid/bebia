import '../../features/profile/child_profile.dart';
import '../local/child_profile_store.dart';

class ChildProfileRepository {
  ChildProfileRepository(this._store);

  final ChildProfileStore _store;

  Future<ChildProfilesState> loadState() => _store.read();

  Future<void> saveState(ChildProfilesState state) => _store.write(state);

  Future<void> clear() => _store.clear();
}
