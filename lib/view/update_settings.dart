import '../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateSettings extends ConsumerStatefulWidget {
  const UpdateSettings({Key? key}) : super(key: key);

  static const routeName = "/update_settings";

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UpdateSettingsState();
}

class _UpdateSettingsState extends ConsumerState<UpdateSettings> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(updateTierNotifier);

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
                          enabled: settings.enableTierOne,
                          keyboardType: TextInputType.number,
                          initialValue: settings.tierOneLimit != null
                              ? settings.tierOneLimit.toString()
                              : "",
                          validator: (String? value) {},
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SwitchListTile(
                          value: settings.enableTierOne,
                          onChanged: (_) => ref
                              .read(updateTierNotifier.notifier)
                              .toggleTierOne(),
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
                          initialValue: settings.tierOneLimit != null
                              ? (settings.tierOneLimit! + 1).toString()
                              : "",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled:
                              settings.enableTierOne && settings.enableTierTwo,
                          keyboardType: TextInputType.number,
                          initialValue: settings.tierOneLimit != null &&
                                  settings.tierTwoLimit != null
                              ? settings.tierTwoLimit.toString()
                              : "",
                          validator: (String? value) {},
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SwitchListTile(
                          value:
                              settings.enableTierOne && settings.enableTierTwo,
                          onChanged: (_) => ref
                              .read(updateTierNotifier.notifier)
                              .toggleTierTwo(),
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
                          initialValue: settings.tierOneLimit != null &&
                                  settings.tierTwoLimit != null
                              ? (settings.tierTwoLimit! + 1).toString()
                              : "",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: settings.enableTierOne &&
                              settings.enableTierTwo &&
                              settings.enableTierThree,
                          keyboardType: TextInputType.number,
                          initialValue: settings.tierOneLimit != null &&
                                  settings.tierTwoLimit != null &&
                                  settings.tierThreeLimit != null
                              ? settings.tierThreeLimit.toString()
                              : "",
                          validator: (String? value) {},
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: SwitchListTile(
                          value: settings.enableTierOne &&
                              settings.enableTierTwo &&
                              settings.enableTierThree,
                          onChanged: (_) => ref
                              .read(updateTierNotifier.notifier)
                              .toggleTierThree(),
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