import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_app/firebase_util.dart';
import 'package:http/http.dart' as http;

class AzureManager {
  static Future<String> addProfile() async {
    var headers = {
      'Ocp-Apim-Subscription-Key': "a0aa18bbe74f47ad930ed83346ef2e61",
      'Content-Type': "application/json"
    };
    var body = jsonEncode(<String, String>{'locale': 'en-us'});

    var response;
    Map<dynamic, dynamic> responseBody;
    print("pre send");
    response = await http.post(
      Uri.parse(
          "https://westus.api.cognitive.microsoft.com/speaker/identification/v2.0/text-independent/profiles"),
      body: body,
      headers: headers,
    );
    if (response != null) {
      print("got response");
    }
    responseBody = jsonDecode(response.body);
    var id = responseBody['profileId'];
    print(responseBody);
    return id;
  }

  static Future<bool> enrollProfile(Uint8List file, String id) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': "a0aa18bbe74f47ad930ed83346ef2e61",
      'Content-Type': "audio/wav"
    };

    var response;
    Map<String, dynamic> responseBody;
    print("pre send");
    response = await http.post(
      Uri.parse(
          'https://westus.api.cognitive.microsoft.com/speaker/identification/v2.0/text-independent/profiles/' +
              id +
              '/enrollments'),
      body: file,
      headers: headers,
    );
    if (response != null) {
      print("got response");
    }
    responseBody = jsonDecode(response.body);
    print(responseBody);
    var enrollmentStatus = responseBody['enrollmentStatus'];
    var res = enrollmentStatus == "Enrolled";
    if (!res) {
      res = await enrollProfile(file, id);
      // print(responseBody);
    }
    return res;
  }

  static Future<String> identifyProfile(Uint8List file, String email) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': "a0aa18bbe74f47ad930ed83346ef2e61",
      'Content-Type': "audio/wav"
    };

    var response;
    Map<String, dynamic> responseBody;
    print("pre send");
    var base_uri =
        'https://westus.api.cognitive.microsoft.com/speaker/identification/v2.0/text-independent/profiles/identifySingleSpeaker?profileIds=';
    var friends_map = await FirestoreManager.getPersonFriendsIDList(email);
    friends_map.forEach((key, value) {
      base_uri += key + ",";
    });
    response = await http.post(
      Uri.parse(base_uri),
      body: file,
      headers: headers,
    );
    if (response != null) {
      print("got response");
    }
    responseBody = jsonDecode(response.body);
    print("Identify profile");
    print(responseBody);
    var identifiedProfile = responseBody['profilesRanking'][0];
    var caller_name = null;
    if (identifiedProfile['score'] > 0.38) {
      caller_name = friends_map[identifiedProfile["profileId"]];
    }
    return caller_name;
  }

  static Future<void> deleteProfile(String id) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': "d10dd8eff0e145eead43c5a63b808d1e",
    };

    var response;
    Map<String, dynamic> responseBody;
    var text;
    print("pre send");
    response = await http.post(
      Uri.parse(
          'https://westus.api.cognitive.microsoft.com/sts/v1.0/issuetoken/speaker/identification/v2.0/text-independent/profiles/' +
              id),
      headers: headers,
    );
  }

  static Future<String> speechToText(Uint8List file) async {
    var headers = {
      'Ocp-Apim-Subscription-Key': "ee672aa1674048da9b3af5b787dfafd4",
      'Content-Type': "audio/wav"
    };
    var response;
    Map<String, dynamic> responseBody;
    var text;
    print("pre send");
    response = await http.post(
      Uri.parse(
          "https://koreacentral.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US"),
      body: file,
      headers: headers,
    );
    responseBody = jsonDecode(response.body);
    text = responseBody['DisplayText'];
    String detectedWord;
    if (text == null) {
      detectedWord = "No words detected";
    } else {
      detectedWord = text;
    }
    print("Detected word: " + detectedWord);
    return detectedWord;
  }
}
