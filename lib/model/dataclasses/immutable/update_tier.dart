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

// TODO sending nulls here is confusing actually when nulls are actually used
  UpdateTier copyWith(int? tierOneLimit, int? tierTwoLimit, int? tierThreeLimit,
      bool? enableTierOne, bool? enableTierTwo, bool? enableTierThree) {
    return UpdateTier(
        tierOneLimit: tierOneLimit,
        tierTwoLimit: tierTwoLimit,
        tierThreeLimit: tierThreeLimit,
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

// TODO cancel the null festival

  void delimitTierOne(int tierOneLimit) {
    state = state.copyWith(tierOneLimit, null, null, null, null, null);
  }

  void delimitTierTwo(int tierTwoLimit) {
    state = state.copyWith(null, tierTwoLimit, null, null, null, null);
  }

  void delimitTierThree(int tierThreeLimit) {
    state = state.copyWith(null, null, tierThreeLimit, null, null, null);
  }

  void enableTierOne() {
    state = state.copyWith(null, null, null, true, null, null);
  }

  void disableTierOne() {
    state = state.copyWith(null, null, null, false, null, null);
  }

  void toggleTierOne() {
    state = state.copyWith(null, null, null, !state.enableTierOne, null, null);
  }

  void enableTierTwo() {
    state = state.copyWith(null, null, null, null, true, null);
  }

  void disableTierTwo() {
    state = state.copyWith(null, null, null, null, false, null);
  }

  void toggleTierTwo() {
    state = state.copyWith(null, null, null, null, !state.enableTierTwo, null);
  }

  void enableTierThree() {
    state = state.copyWith(null, null, null, null, null, true);
  }

  void disableTierThree() {
    state = state.copyWith(null, null, null, null, null, false);
  }

  void toggleTierThree() {
    state =
        state.copyWith(null, null, null, null, null, !state.enableTierThree);
  }
}
