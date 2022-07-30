// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';

class UpdateSettings extends ConsumerStatefulWidget {
  const UpdateSettings({Key? key}) : super(key: key);

  static const routeName = "/update_settings";

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UpdateSettingsState();
}

class _UpdateSettingsState extends ConsumerState<UpdateSettings> {
  final _formKey = GlobalKey<FormState>();
  final _tierOneUpperController = TextEditingController();
  final _tierTwoLowerController = TextEditingController();
  final _tierTwoUpperController = TextEditingController();
  final _tierThreeLowerController = TextEditingController();
  final _tierThreeUpperController = TextEditingController();

  late bool _tierOneSwitch;
  late bool _tierTwoSwitch;
  late bool _tierThreeSwitch;

  @override
  void initState() {
    super.initState();

    _tierOneSwitch = ref.read(updateTierNotifier).enableTierOne;
    _tierTwoSwitch = ref.read(updateTierNotifier).enableTierTwo;
    _tierThreeSwitch = ref.read(updateTierNotifier).enableTierThree;

    _tierOneUpperController.value = _tierOneUpperController.value.copyWith(
        text: ref.read(updateTierNotifier).tierOneLimit == null
            ? ""
            : ref.read(updateTierNotifier).tierOneLimit.toString());

    _tierTwoLowerController.value = _tierTwoLowerController.value.copyWith(
        text: ref.read(updateTierNotifier).tierOneLimit == null
            ? ""
            : (ref.read(updateTierNotifier).tierOneLimit! + 1).toString());

    _tierTwoUpperController.value = _tierTwoUpperController.value.copyWith(
        text: ref.read(updateTierNotifier).tierTwoLimit == null
            ? ""
            : ref.read(updateTierNotifier).tierTwoLimit.toString());

    _tierThreeLowerController.value = _tierThreeLowerController.value.copyWith(
        text: ref.read(updateTierNotifier).tierTwoLimit == null
            ? ""
            : (ref.read(updateTierNotifier).tierTwoLimit! + 1).toString());

    _tierThreeUpperController.value = _tierThreeUpperController.value.copyWith(
        text: ref.read(updateTierNotifier).tierThreeLimit == null
            ? ""
            : ref.read(updateTierNotifier).tierThreeLimit.toString());

    _tierOneUpperController.addListener(() {
      final input = _tierOneUpperController.text;
      if (input.isNotEmpty) {
        ref.read(updateTierNotifier.notifier).enableTierTwo();
        if (int.parse(input) < 1) {
          _tierOneUpperController.value =
              _tierOneUpperController.value.copyWith(text: "1");
        } else {
          _tierTwoLowerController.value = _tierTwoLowerController.value
              .copyWith(text: "${(int.parse(input) + 1)}");
        }
      } else {
        ref.read(updateTierNotifier.notifier).disableTierTwo();
      }
    });

    _tierTwoUpperController.addListener(() {
      final input = _tierTwoUpperController.text;
      if (input.isNotEmpty) {
        if (int.parse(input) < int.parse(_tierTwoLowerController.value.text)) {
          _tierTwoUpperController.value = _tierTwoUpperController.value
              .copyWith(text: _tierTwoLowerController.value.text);
        } else {
          _tierThreeLowerController.value = _tierThreeLowerController.value
              .copyWith(text: "${(int.parse(input) + 1)}");
        }
      }
    });

    _tierThreeUpperController.addListener(() {
      final input = _tierThreeUpperController.text;
      if (input.isNotEmpty &&
          int.parse(input) < int.parse(_tierThreeLowerController.value.text)) {
        _tierThreeUpperController.value = _tierThreeUpperController.value
            .copyWith(text: _tierTwoLowerController.value.text);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tierOneUpperController.dispose();
    _tierTwoLowerController.dispose();
    _tierTwoUpperController.dispose();
    _tierThreeLowerController.dispose();
    _tierThreeUpperController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: false,
                          initialValue: "1",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: _tierOneSwitch,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _tierOneUpperController,
                          // onChanged: (value) {
                          //   final number = int.tryParse(value);
                          //   if (number != null && number >= 1) {
                          //     ref
                          //         .read(updateTierNotifier.notifier)
                          //         .delimitTierOne(number);
                          //   }
                          // },
                          // initialValue: settings.tierOneLimit != null
                          //     ? settings.tierOneLimit.toString()
                          //     : "",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SwitchListTile(
                          value: _tierOneSwitch,
                          onChanged: (_) {
                            setState(() {
                              _tierOneSwitch = !_tierOneSwitch;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: false,
                          controller: _tierTwoLowerController,
                          // initialValue: settings.tierOneLimit != null
                          //     ? (settings.tierOneLimit! + 1).toString()
                          //     : "",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: _tierOneSwitch && _tierTwoSwitch,
                          keyboardType: TextInputType.number,
                          controller: _tierTwoUpperController,
                          // initialValue: settings.tierOneLimit != null &&
                          //         settings.tierTwoLimit != null
                          //     ? settings.tierTwoLimit.toString()
                          //     : "",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SwitchListTile(
                          value: _tierOneSwitch && _tierTwoSwitch,
                          onChanged: (_) {
                            if (_tierOneUpperController.value.text.isNotEmpty) {
                              setState(() {
                                _tierTwoSwitch = !_tierTwoSwitch;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: false,
                          controller: _tierThreeLowerController,
                          // initialValue: settings.tierOneLimit != null &&
                          //         settings.tierTwoLimit != null
                          //     ? (settings.tierTwoLimit! + 1).toString()
                          //     : "",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: _tierOneSwitch &&
                              _tierTwoSwitch &&
                              _tierThreeSwitch,
                          keyboardType: TextInputType.number,
                          controller: _tierThreeUpperController,
                          // initialValue: settings.tierOneLimit != null &&
                          //         settings.tierTwoLimit != null &&
                          //         settings.tierThreeLimit != null
                          //     ? settings.tierThreeLimit.toString()
                          //     : "",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SwitchListTile(
                          value: _tierOneSwitch &&
                              _tierTwoSwitch &&
                              _tierThreeSwitch,
                          onChanged: (_) {
                            if (_tierOneUpperController.value.text.isNotEmpty &&
                                _tierTwoUpperController.value.text.isNotEmpty) {
                              setState(() {
                                _tierThreeSwitch = !_tierThreeSwitch;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Submit"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


// return Scaffold(
//       body: Center(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       hintText: "Yolo",
//                     ),
//                     validator: (String? value) {},
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       hintText: "Yolo2",
//                     ),
//                     validator: (String? value) {},
//                   ),
//                 ],
//               ),
//               TextFormField(
//                 decoration: const InputDecoration(
//                   hintText: "Enter server port number",
//                 ),
//                 validator: (String? value) {},
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   child: const Text("Submit"),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
