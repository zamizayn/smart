import '../../../../utils/constants/urls.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_list.dart';

// import '../../../../utils/constants/app_constants.dart';

Future<UserList> getUsersList(userId, accessToken) async {
  String url = '${AppUrls.appBaseUrl}get_all_user_details';
  var mediaInfo;
  var body = {
    'user_id': userId,
    'accessToken':accessToken,
    
  };

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200 || resp.statusCode == 201) {
    mediaInfo = UserList.fromJson(jsonDecode(resp.body));
  }

  return mediaInfo;
}