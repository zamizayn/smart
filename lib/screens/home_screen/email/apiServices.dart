import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_station/screens/home_screen/email/emailListViewModeal.dart';
import 'package:smart_station/utils/constants/urls.dart';
import 'emailViewModeal.dart';
import 'email_send_box_modeal.dart';
import 'getSendMailDetailsModeal.dart';

Future<http.Response> deleteEmail(userId, accessToken, id, type) async {
  String url = '${AppUrls.appBaseUrl}/deleteEmail';
  final body = {
    'accessToken': accessToken,
    'user_id': userId,
    'id': id,
    'type': type
  };
  var response = await http.post(Uri.parse(url), body: jsonEncode(body));
  return response;
}

Future<GetInboxMailDetails> get_inbox_mail_details(
    userId, accessToken, id) async {
  String url = '${AppUrls.appBaseUrl}/get_inbox_mail_details';
  final body = {
    'accessToken': accessToken,
    'user_id': userId,
    'id': id,
  };
  var response = await http.post(Uri.parse(url), body: jsonEncode(body));
  if (response.statusCode == 200) {
    final data = GetInboxMailDetails.fromJson(json.decode(response.body));
    print(response.body);
    return data;
  } else {
    throw Exception('Failed to load users');
  }
}

Future<http.Response> get_user_mailids(
  userId,
  accessToken,
) async {
  String url = '${AppUrls.appBaseUrl}/get_user_mailids';
  final body = {
    'accessToken': accessToken,
    'user_id': userId,
  };
  var response = await http.post(Uri.parse(url), body: jsonEncode(body));
  //print(response.body);
  return response;
}

Future<GetmailList> getmail_list(userId, accessToken, search) async {
  String url = '${AppUrls.appBaseUrl}/getmail_list';
  final body = {
    'accessToken': accessToken,
    'user_id': userId,
    'search': search,
  };
  var response = await http.post(Uri.parse(url), body: jsonEncode(body));
  print(response.body);
  if (response.statusCode == 200) {
    final data = GetmailList.fromJson(json.decode(response.body));
    print(response.body);
    return data;
  } else {
    throw Exception('Failed to load users');
  }
}

Future<get_Send_Box_ListM> get_Send_Box_List(
  userId,
  accessToken,
) async {
  String url = '${AppUrls.appBaseUrl}/send_mail_list';
  final body = {
    'accessToken': accessToken,
    'user_id': userId,
  };
  var response = await http.post(Uri.parse(url), body: jsonEncode(body));
  print(response.body);
  if (response.statusCode == 200) {
    final data = get_Send_Box_ListM.fromJson(json.decode(response.body));
    print(response.body);
    return data;
  } else {
    throw Exception('Failed to load users');
  }
}

Future<GetSentMailDetails> get_sent_mail_details(
  userId,
  accessToken,
  id,
) async {
  String url = '${AppUrls.appBaseUrl}/get_sent_mail_details';
  final body = {
    'accessToken': accessToken,
    'user_id': userId,
    'id': id,
  };
  var response = await http.post(Uri.parse(url), body: jsonEncode(body));
  print(response.body);
  if (response.statusCode == 200) {
    final data = GetSentMailDetails.fromJson(json.decode(response.body));
    print(response.body);
    return data;
  } else {
    throw Exception('Failed to load users');
  }
}
