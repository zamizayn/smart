import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smart_station/providers/LetterProvider/letter_provider.dart';
import 'package:smart_station/screens/home_screen/letter/letter_List_Model.dart';
import 'package:smart_station/utils/constants/urls.dart';

import 'letter_draft_detail_view_model.dart';

class LetterApiService {
  final baseUrl = AppUrls.appBaseUrl;

  String _starStatus = '';
  String _importantStatus = '';
  String get starStatus => _starStatus;
  String get importantStatus => _importantStatus;
  Future<http.Response> deleteLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/delete_letter_mail';
    final body = {'accessToken': accessToken, 'user_id': userId, 'id': id};
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> approveLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/approve_letter';
    final body = {'accessToken': accessToken, 'user_id': userId, 'mailid': id};
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> rejectLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/rejected_letter';
    final body = {'accessToken': accessToken, 'user_id': userId, 'mailid': id};
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> viewLetterDetails(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/view_letter_list_details';
    final body = {'accessToken': accessToken, 'user_id': userId, 'id': id};
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (res.statusCode == 200 || res.statusCode == 201) {
      final resp = jsonDecode(res.body);
      final json = resp['data'];
      _starStatus = json['starred_status'].toString();
      _importantStatus = json['important_status'].toString();
      print('star ---$_starStatus');
      print(_starStatus.runtimeType);
    }
    return res;
  }

  Future<http.Response> starLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/letter_starred_status';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    print(res);
    // if (res.statusCode == 200 || res.statusCode == 201) {
    //   viewLetterDetails(id,accessToken, userId);
    // }
    return res;
  }

  Future<http.Response> unstarLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/letter_unstarred_status';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    print(res);
    return res;
  }

  Future<http.Response> markImportantLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/markas_important';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> markUnimportantLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/markas_unimportant';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> markAsUnreadLetter(
      String? id, String? accessToken, String? userId, context) async {
    String url = '$baseUrl/markas_unreadletter';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (res.statusCode == 200 || res.statusCode == 201) {
      var letter = Provider.of<LetterProvider>(context, listen: false);
      letter.getInboxList(context);
      Navigator.pop(context,'Refresh');
    }
    return res;
  }

  Future<http.Response> markAsReadLetter(
      String? id, String? accessToken, String? userId, context) async {
    String url = '$baseUrl/markas_readletter';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (res.statusCode == 200 || res.statusCode == 201) {
      var letter = Provider.of<LetterProvider>(context, listen: false);
      letter.getInboxList(context);
      Navigator.pop(context);
    }
    return res;
  }

  Future<http.Response> archieveLetter(
      String? id, String? accessToken, String? userId, context) async {
    String url = '$baseUrl/archive_letter';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (res.statusCode == 200 || res.statusCode == 201) {
      var letter = Provider.of<LetterProvider>(context, listen: false);
      letter.getInboxList(context);
      Navigator.pop(context,'Refresh');
    }
    return res;
  }

  Future<http.Response> unarchieveLetter(
      String? id, String? accessToken, String? userId, context) async {
    String url = '$baseUrl/unarchive_letter';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (res.statusCode == 200 || res.statusCode == 201) {
      var letter = Provider.of<LetterProvider>(context, listen: false);
      letter.getArchievedList(context);
      Navigator.pop(context,'Refresh');
    }
    return res;
  }

  Future<http.Response> deleteDraftLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/delete_letter_draft';
    final body = {'accessToken': accessToken, 'user_id': userId, 'id': id};
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<GetDraftLetterView> viewDraftLetterDetails(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/view_draft_letter_details';
    final body = {'accessToken': accessToken, 'user_id': userId, 'id': id};
    print('obj ========$body');
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (res.statusCode == 200 || res.statusCode == 201) {
      print('gtfdtgfrgtfgtf');
      print('ENTER');
      print(res.body);
      print('gtfdtgfrgtfgtf');
      final data = GetDraftLetterView.fromJson(json.decode(res.body));
      print('=================Response================');
      
      return data;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<http.Response> starDraftLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/starred_draftmessage';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> unstarDraftLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/unstarred_draftmessage';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> archieveDraftLetter(
      String? id, String? accessToken, String? userId, context) async {
    String url = '$baseUrl/archive_draft';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    // if (res.statusCode == 200 || res.statusCode == 201) {
    //   var letter = Provider.of<LetterProvider>(context,listen: false);
    //   letter.getInboxList(context);
    //   Navigator.pop(context);
    // }
    return res;
  }

  Future<http.Response> unarchieveDraftLetter(
      String? id, String? accessToken, String? userId, context) async {
    String url = '$baseUrl/unarchive_draft';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));
    // if (res.statusCode == 200 || res.statusCode == 201) {
    //   var letter = Provider.of<LetterProvider>(context,listen: false);
    //   letter.getInboxList(context);
    //   Navigator.pop(context);
    // }
    return res;
  }

  Future<http.Response> markImportantDraftLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/markas_importantdraft';
    final body = {'accessToken': accessToken, 'user_id': userId, 'id': id};
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<http.Response> markUnimportantDraftLetter(
      String? id, String? accessToken, String? userId) async {
    String url = '$baseUrl/markas_unimportantdraft';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'letter_id': id
    };
    print('obj ----$body');
    // "type":"send"
    // "type":"inbox"
    print('BODY: ${jsonEncode(body)}');
    var res = await http.post(Uri.parse(url), body: jsonEncode(body));

    return res;
  }

  Future<GetletterList> getletter_list(userId, accessToken, search) async {
    String url = '${AppUrls.appBaseUrl}/getletter_list';
    final body = {
      'accessToken': accessToken,
      'user_id': userId,
      'search': search,
    };
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = GetletterList.fromJson(json.decode(response.body));
      print(response.body);
      return data;
    } else {
      throw Exception('Failed to load users');
    }
  }
}
