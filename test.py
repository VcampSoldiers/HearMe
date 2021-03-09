Future<dynamic> speechToText(File file) async {
  final bytes = file.readAsBytesSync();
  var uri = Uri.parse("https://westus.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US");
  var request = new http.Request("POST", uri)
    ..headers['Ocp-Apim-Subscription-Key'] = "d10dd8eff0e145eead43c5a63b808d1e"
    ..headers['Content-Type'] = "audio/wav"
    ..bodyBytes = bytes;

  var response = await request.send();
  print(request);
  print(response.statusCode);
  response.stream.transform(utf8.decoder).listen((value) {
    print(value);
  });
  return text;
}



Future<dynamic> addProfile(File file) async {
  
  var uri = Uri.parse("https://westus.api.cognitive.microsoft.com/sts/v1.0/issuetoken/speaker/identification/v2.0/text-independent/profiles");
  var request = new http.Request("POST", uri)
    ..headers['Ocp-Apim-Subscription-Key'] = "d10dd8eff0e145eead43c5a63b808d1e"
    ..headers['Content-Type'] = "application/json"
    ..bodyFields['locale'] = 'en-us';

  var response = await request.send();
  print(request);
  print(response.statusCode);
  response.stream.transform(utf8.decoder).listen((value) {
    print(value);
  });
  return profileid;
}

Future<dynamic> enrollProfile(File file, profileid) async {
  final bytes = file.readAsBytesSync();
  var uri = Uri.parse('https://westus.api.cognitive.microsoft.com/sts/v1.0/issuetoken/speaker/identification/v2.0/text-independent/profiles/{profileid}/enrollments');
  var request = new http.Request("POST", uri)
    ..headers['Ocp-Apim-Subscription-Key'] = "d10dd8eff0e145eead43c5a63b808d1e"
    ..headers['Content-Type'] = "audio/wav"
    ..bodyBytes = bytes;

  var response = await request.send();
  print(request);
  print(response.statusCode);
  response.stream.transform(utf8.decoder).listen((value) {
    print(value);
  });
}


Future<dynamic> identifyProfile(File file) async {
  final bytes = file.readAsBytesSync();
  var uri = Uri.parse('https://westus.api.cognitive.microsoft.com/sts/v1.0/issuetoken/speaker/identification/v2.0/text-independent/profiles/identifySingleSpeaker?profileIds={profileid}');
  var request = new http.Request("POST", uri)
    ..headers['Ocp-Apim-Subscription-Key'] = "d10dd8eff0e145eead43c5a63b808d1e"
    ..headers['Content-Type'] = "audio/wav"
    ..bodyBytes = bytes;

  var response = await request.send();
  print(request);
  print(response.statusCode);
  response.stream.transform(utf8.decoder).listen((value) {
    print(value);
  });
  return profileid, score;
}


Future<dynamic> delete Profile() async {
  final bytes = file.readAsBytesSync();
  var uri = Uri.parse('https://westus.api.cognitive.microsoft.com/sts/v1.0/issuetoken/speaker/identification/v2.0/text-independent/profiles/INSERT_PROFILE_ID_HERE');
  var request = new http.Request("POST", uri)
    ..headers['Ocp-Apim-Subscription-Key'] = "d10dd8eff0e145eead43c5a63b808d1e"

  var response = await request.send();
  print(request);
  print(response.statusCode);
  response.stream.transform(utf8.decoder).listen((value) {
    print(value);
  });
}