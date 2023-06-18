// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../utils/constants/urls.dart';
import '../AuthProvider/auth_provider.dart';

class InfoProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;
  bool _isLoading = false;
  String _resMessage = '';

  bool get isLoading => _isLoading;
  String get resMessage => _resMessage;


  void getIndividualProfile(
      String receiverId,
      BuildContext? ctx,
      ) async {
    _isLoading = true;
    notifyListeners();

    String url = '$baseUrl/get_individual_pofile_details';
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    final body = {
      'user_id':auth.userId,
      'accessToken':auth.accessToken,
      'receiver_id':receiverId
    };
    print('BODY: ${jsonEncode(body)}');
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        _isLoading = false;
        _resMessage = req.body;
        // _name = name;
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }
}