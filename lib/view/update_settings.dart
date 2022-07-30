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
  bool _isValidData = true;

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
      final input = _tierOneUpperController
          .text; // TODO make sure this really REALLY can't be null
      if (input.isNotEmpty) {
        _tierTwoSwitch = true;
        if (int.parse(input) < 1) {
          _tierOneUpperController.value =
              _tierOneUpperController.value.copyWith(text: "1");
        } else {
          _tierTwoLowerController.value = _tierTwoLowerController.value
              .copyWith(text: "${(int.parse(input) + 1)}");
        }
      } else {
        _tierTwoSwitch = false;
      }
      _validateForm();
    });

    _tierTwoUpperController.addListener(() {
      final input = _tierTwoUpperController.text;
      if (input.isNotEmpty) {
        if (int.parse(input) < int.parse(_tierTwoLowerController.value.text)) {
          _tierThreeSwitch = false;
        } else {
          _tierThreeLowerController.value = _tierThreeLowerController.value
              .copyWith(text: "${(int.parse(input) + 1)}");
          _tierThreeSwitch = true;
        }
      } else {
        _tierThreeSwitch = false;
      }
      _validateForm();
    });

    _tierThreeUpperController.addListener(() {
      _validateForm();
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

  void _validateForm() {
    if (!_tierOneSwitch || _tierOneUpperController.value.text.isEmpty) {
      setState(() {
        _isValidData = true;
      });
    } else if (_tierTwoSwitch &&
        _tierTwoUpperController.value.text.isNotEmpty &&
        int.parse(_tierTwoLowerController.value.text) >
            int.parse(_tierTwoUpperController.value.text)) {
      setState(() {
        _isValidData = false;
      });
    } else if (_tierThreeSwitch &&
        _tierThreeUpperController.value.text.isNotEmpty &&
        int.parse(_tierThreeLowerController.value.text) >
            int.parse(_tierThreeUpperController.value.text)) {
      setState(() {
        _isValidData = false;
      });
    } else {
      setState(() {
        _isValidData = true;
      });
    }
  }

  List<Text> _currentStatus() {
    if (!_tierOneSwitch) {
      return [const Text("No punches will trigger any alerts!")];
    } else if (_tierOneUpperController.value.text.isEmpty) {
      return [const Text("All punches will trigger a Tier 1 alert.")];
    } else {
      final List<Text> info = [];

      info.add(Text(
          "Runners punching in places 1 through ${_tierOneUpperController.value.text} will trigger a Tier 1 alert."));

      if (!_tierTwoSwitch) {
        info.add(const Text("Other punches will trigger no alerts."));
      } else {
        if (_tierTwoUpperController.value.text.isEmpty) {
          info.add(const Text("Other punches will trigger a Tier 2 alert."));
        } else if (int.parse(_tierTwoLowerController.value.text) >
            int.parse(_tierTwoUpperController.value.text)) {
          return ([
            Text(
              "Tier 2 upper limit must be greater than its lower limit (${_tierTwoLowerController.value.text}).",
              style: const TextStyle(color: Colors.red),
            )
          ]);
        } else {
          info.add(Text(
              "Runners punching in places ${_tierTwoLowerController.value.text} through ${_tierTwoUpperController.value.text} will trigger a Tier 2 alert."));

          if (!_tierThreeSwitch) {
            info.add(const Text("Other punches will trigger no alerts."));
          } else if (_tierThreeUpperController.value.text.isEmpty) {
            info.add(const Text("Other punches will trigger a Tier 3 alert."));
          } else if (int.parse(_tierThreeLowerController.value.text) >
              int.parse(_tierThreeUpperController.value.text)) {
            return ([
              Text(
                "Tier 3 upper limit must be greater than its lower limit (${_tierThreeLowerController.value.text}).",
                style: const TextStyle(color: Colors.red),
              )
            ]);
          } else {
            info.add(Text(
                "Runners punching in places ${_tierThreeLowerController.value.text} through ${_tierThreeUpperController.value.text} will trigger a Tier 3 alert."));
            info.add(const Text("Other punches will trigger no alerts."));
          }
        }
      }
      return info;
    }
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
              Expanded(
                child: Center(
                  child: ListView(
                    children: _currentStatus(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO consider using validator for the fields and the form key
                        // this is a bit of added rebuilding
                        setState(() {
                          _validateForm();
                        });
                        if (_isValidData) {
                          ref.read(updateTierNotifier.notifier).completeUpdate(
                              _tierOneUpperController.value.text.isEmpty
                                  ? null
                                  : int.parse(
                                      _tierOneUpperController.value.text),
                              _tierTwoUpperController.value.text.isEmpty
                                  ? null
                                  : int.parse(
                                      _tierTwoUpperController.value.text),
                              _tierThreeUpperController.value.text.isEmpty
                                  ? null
                                  : int.parse(
                                      _tierThreeUpperController.value.text),
                              _tierOneSwitch,
                              _tierTwoSwitch,
                              _tierThreeSwitch);
                          Navigator.pop(context);
                        } else {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  const Text("Invalid data nay!"));
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _tierOneUpperController.value =
                              _tierOneUpperController.value.copyWith(text: "3");
                          _tierTwoUpperController.value =
                              _tierTwoUpperController.value
                                  .copyWith(text: "10");
                          _tierThreeUpperController.value =
                              _tierThreeUpperController.value
                                  .copyWith(text: "");
                          _tierOneSwitch = true;
                          _tierTwoSwitch = true;
                          _tierThreeSwitch = true;
                        });
                      },
                      child: const Text("Restore defaults"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
