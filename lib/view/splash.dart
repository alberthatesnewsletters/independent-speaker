import 'package:attempt4/model/remotes/meos/connection.dart';
import 'package:attempt4/model/remotes/meos/reader.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../model/better_listener.dart';
import '../model/enums/connection_status.dart';
import 'settings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _ip;
  String? _port;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool _isValidIp(String address) {
      final sections = address.split(".");

      if (sections.length != 4) {
        return false;
      } else {
        for (final section in sections) {
          final asNumber = int.tryParse(section);
          if (asNumber == null || asNumber < 0 || asNumber > 255) {
            return false;
          }
        }
      }

      return true;
    }

    bool _isValidPort(String port) {
      return int.tryParse(port) != null;
    }

    void proceed(MeOSconnection conn) {
      Navigator.pushNamed(
        context,
        Settings.routeName,
        arguments: conn,
      );
    }

    Future<void> _errorDialog(String errorMsg) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('AlertDialog Title'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text('This is a demo alert dialog.'),
                  Text('Would you like to approve of this message?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                autofocus: true,
                onSaved: ((newValue) => _ip = newValue),
                decoration: const InputDecoration(
                  hintText: "Enter server IP",
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Enter an IP address";
                  } else if (!_isValidIp(value)) {
                    return "Enter a valid IP, like 192.168.13.15";
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                onSaved: ((newValue) => _port = newValue),
                decoration: const InputDecoration(
                  hintText: "Enter server port number",
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a port number";
                  } else if (!_isValidPort(value)) {
                    return "Enter a valid port, like 2009";
                  } else {
                    return null;
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final conn = MeOSconnection(ip: _ip!, port: _port!);
                            setState(() {
                              _isLoading = true;
                            });

                            final outcome = await conn.validate();
                            setState(() {
                              _isLoading = false;
                            });

                            switch (outcome) {
                              // TODO
                              case ConnectionStatus.Success:
                                proceed(conn);
                                break;
                              case ConnectionStatus.NoCompetition:
                                _errorDialog("No competition");
                                break;
                              case ConnectionStatus.NoConnection:
                                _errorDialog("No connection");
                                break;
                              case ConnectionStatus.WeirdMeOS:
                                print("Cannot understand MeOS data");
                                break;
                              case ConnectionStatus.Error:
                                print("MeOS couldn't understand us");
                                break;
                              case ConnectionStatus.Refused:
                                print("Server refused connection");
                                break;
                            }
                          }
                        },
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
