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
    state = UpdateTier(
        tierOneLimit: tierOneLimit,
        tierTwoLimit: tierTwoLimit,
        tierThreeLimit: tierThreeLimit,
        enableTierOne: enableTierOne,
        enableTierTwo: enableTierTwo,
        enableTierThree: enableTierThree);
  }
}
