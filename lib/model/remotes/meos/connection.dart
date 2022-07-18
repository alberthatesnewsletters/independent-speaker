import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../../../utils.dart';

// thanks to https://superpenguin.app/
extension XmlDocumentExt on XmlDocument {
  XmlElement forceGetElement(String name, {String? namespace}) {
    final result = getElement(name, namespace: namespace);
    if (result != null) return result;
    throw Exception('Element not found, tag: <$name>');
  }
}

extension XmlElementExt on XmlElement {
  XmlElement forceGetElement(String name, {String? namespace}) {
    final result = getElement(name, namespace: namespace);
    if (result != null) return result;
    throw Exception('Element not found, tag: <$name>');
  }

  String forceGetAttribute(String name, {String? namespace}) {
    final result = getAttribute(name, namespace: namespace);
    if (result != null) return result;
    throw Exception(
      'Attribute not found, tag: <${this.name.local}> with attr: $name',
    );
  }
}

class MeOSconnection {
  String _currentDifference = "zero";
  String _nextDifference = "zero";

  Future<XmlDocument> getDifference(
      {bool previousSuccessful = true, bool reset = false}) async {
    if (reset) {
      _currentDifference = "zero";
      _nextDifference = "zero";
    }
    if (previousSuccessful) {
      _currentDifference = _nextDifference;
    }

    // error sources:
    // wrong ip
    // wrong port
    // server offline
    // invalid request
    // not connected to the same network
    try {
      final response = await http.get(Uri.parse(
          "http://${Utils.serverIP}:${Utils.serverPort}/meos?difference=$_currentDifference"));

      if (response.statusCode != 200) {
        throw Exception("Server refused to grant data");
      }

      final String body = utf8.decode(response.bodyBytes);

      if (body.startsWith("Error")) {
        log(body);
        if (!reset) {
          // we try this once
          // spamming it is the highway to stack overflow
          return (getDifference(previousSuccessful: false, reset: true));
        } else {
          // TODO
          print("THINGS HAVE GONE HORRIBLY WRONG BETWEEN US AND THE SERVER");
        }
      }

      // if (_currentDifference != "zero") {
      //   print(body);
      // }

      // print(body);

      final toReturn = XmlDocument.parse(
          body); // TODO: xml expects utf-16 but I receive utf-8. problim?
      _nextDifference = toReturn.firstElementChild!
          .forceGetAttribute("nextdifference"); // TODO: error handling
      return toReturn;
    } on Exception catch (e) {
      log(e.toString(), time: DateTime.now());
      rethrow;
    }
  }
}
