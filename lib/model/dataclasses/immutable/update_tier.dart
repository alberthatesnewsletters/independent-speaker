import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class UpdateTier {
  const UpdateTier(
      {required this.tierOneLimit,
      required this.tierTwoLimit,
      required this.tierThreeLimit,
      required this.enableTierOne,
      required this.enableTierTwo,
      required this.enableTierThree});

  final int? tierOneLimit;
  final int? tierTwoLimit;
  final int? tierThreeLimit;
  final bool enableTierOne;
  final bool enableTierTwo;
  final bool enableTierThree;

  UpdateTier copyWith(int? tierOneLimit, int? tierTwoLimit, int? tierThreeLimit,
      bool? enableTierOne, bool? enableTierTwo, bool? enableTierThree) {
    return UpdateTier(
        tierOneLimit: tierOneLimit ?? this.tierOneLimit,
        tierTwoLimit: tierTwoLimit ?? this.tierTwoLimit,
        tierThreeLimit: tierThreeLimit ?? this.tierThreeLimit,
        enableTierOne: enableTierOne ?? this.enableTierOne,
        enableTierTwo: enableTierTwo ?? this.enableTierTwo,
        enableTierThree: enableTierThree ?? this.enableTierThree);
  }
}

class UpdateTierNotifier extends StateNotifier<UpdateTier> {
  UpdateTierNotifier([UpdateTier? initialTiers])
      : super(initialTiers ??
            const UpdateTier(
                tierOneLimit: 3,
                tierTwoLimit: 10,
                tierThreeLimit: null,
                enableTierOne: true,
                enableTierTwo: true,
                enableTierThree: true));

  void completeUpdate(int? tierOneLimit, int? tierTwoLimit, int? tierThreeLimit,
      bool enableTierOne, bool enableTierTwo, bool enableTierThree) {
    state = state.copyWith(tierOneLimit, tierTwoLimit, tierThreeLimit,
        enableTierOne, enableTierTwo, enableTierThree);
  }

  void changeTierOne(int? tierOneLimit) {
    state = state.copyWith(tierOneLimit, null, null, null, null, null);
  }

  void changeTierTwo(int? tierTwoLimit) {
    state = state.copyWith(null, tierTwoLimit, null, null, null, null);
  }

  void changeTierThree(int? tierThreeLimit) {
    state = state.copyWith(null, null, tierThreeLimit, null, null, null);
  }

  void ignoreTierOne() {
    state = state.copyWith(null, null, null, true, null, null);
  }

  void ignoreTierTwo() {
    state = state.copyWith(null, null, null, null, true, null);
  }

  void ignoreTierThree() {
    state = state.copyWith(null, null, null, null, null, true);
  }

  void unignoreTierOne() {
    state = state.copyWith(null, null, null, false, null, null);
  }

  void unignoreTierTwo() {
    state = state.copyWith(null, null, null, null, false, null);
  }

  void unignoreTierThree() {
    state = state.copyWith(null, null, null, null, null, false);
  }

  void toggleTierOne() {
    state = state.copyWith(null, null, null, !state.enableTierOne, null, null);
  }

  void toggleTierTwo() {
    state = state.copyWith(null, null, null, null, !state.enableTierTwo, null);
  }

  void toggleTierThree() {
    state =
        state.copyWith(null, null, null, null, null, !state.enableTierThree);
  }
}
