import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

final isOnlineProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return service.isConnected();
});

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _connectivityController!.stream;
  }
  
  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = _isConnectedFromResults(results);
      _connectivityController?.add(isConnected);
    });
    
    // Emit initial state
    isConnected().then((connected) {
      _connectivityController?.add(connected);
    });
  }
  
  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
  
  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }
  
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnectedFromResults(results);
  }
  
  Future<ConnectivityResult> getConnectionType() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return ConnectivityResult.none;
    
    // Return the first valid connection type
    for (final result in results) {
      if (result != ConnectivityResult.none) {
        return result;
      }
    }
    return ConnectivityResult.none;
  }
  
  void dispose() {
    _stopListening();
    _connectivityController?.close();
    _connectivityController = null;
  }
}
