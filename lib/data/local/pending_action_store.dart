import '../../core/entities.dart';
import 'local_store.dart';

abstract class PendingActionStore {
  Future<void> writeAll(List<PendingAction> actions);
  Future<List<PendingAction>> readAll();
  Future<void> clear();
}

class HivePendingActionStore implements PendingActionStore {
  HivePendingActionStore(this.localStore);

  final LocalStore localStore;

  @override
  Future<void> writeAll(List<PendingAction> actions) {
    return localStore.writePendingActions(actions);
  }

  @override
  Future<List<PendingAction>> readAll() async {
    return localStore.readPendingActions();
  }

  @override
  Future<void> clear() {
    return localStore.writePendingActions(const []);
  }
}

class InMemoryPendingActionStore implements PendingActionStore {
  List<PendingAction> _actions = const [];

  @override
  Future<void> writeAll(List<PendingAction> actions) async {
    _actions = List<PendingAction>.from(actions);
  }

  @override
  Future<List<PendingAction>> readAll() async {
    return List<PendingAction>.from(_actions);
  }

  @override
  Future<void> clear() async {
    _actions = const [];
  }
}
