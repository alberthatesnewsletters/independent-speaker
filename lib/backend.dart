import 'package:attempt4/model/better_listener.dart';
import 'package:attempt4/model/remotes/meos/connection.dart';
import 'package:attempt4/model/remotes/meos/reader.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Backend {
  const Backend(
      {required this.connection, required this.reader, required this.listener});

  final MeOSconnection connection;
  final MeOSreader reader;
  final BetterListener listener;
}

class BackendInfo extends StateNotifier<Backend> {
  BackendInfo(super.state);

  void overwrite(Backend newBackend) {
    state = newBackend;
  }
}
