import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/urls.dart';

import '../models/contactModel/contact_list.dart';

Future<UserListModel> getContactList(userId, accessToken) async {
  var contactList;
  String url = '${AppUrls.appBaseUrl}get_all_user_details';
  var body = {
    'user_id' : userId,
    'accessToken' : accessToken
  };

  var resp = await http.post(Uri.parse(url), body: body);

  if (resp.statusCode == 200 || resp.statusCode == 201) {
    contactList = UserListModel.fromJson(jsonDecode(resp.body));
  }

  return contactList;
}