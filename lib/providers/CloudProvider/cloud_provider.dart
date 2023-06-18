// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_station/utils/constants/urls.dart';
import 'package:smart_station/utils/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:smart_station/providers/AuthProvider/auth_provider.dart';

class CloudProvider extends ChangeNotifier {
  final baseUrl = AppUrls.appBaseUrl;

  //setter
  bool _isLoading = false;
  bool _completeStatus = false;
  String _resMessage = '';
  List<dynamic> _parentData = [];
  List<dynamic> _sendData = [];
  List<dynamic> _subData = [];
  List<dynamic> _receiveData = [];
  final List<dynamic> _data = [];
  BuildContext? ctx;
  List<dynamic> filteredSent = [];
  List<dynamic> filteredReceived = [];

  //getter
  bool get isLoading => _isLoading;
  bool get completeStatus => _completeStatus;
  String get resMessage => _resMessage;
  List get data => _data;
  List get parentData => _parentData;
  List get sendData => _sendData;
  List get receiveData => _receiveData;
  List get subData => _subData;

  void searchReceivedData(String searchText) {
    List searchList = [];
    if (searchText.isNotEmpty) {
      _receiveData.forEach((element) {
        if (element["name"]
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          searchList.add(element);
        }
      });
    } else {
      searchList.addAll(_receiveData);
    }
    filteredReceived = searchList;
    notifyListeners();
  }

  void searchSendData(String searchText) {
    List searchList = [];
    if (searchText.isNotEmpty) {
      _sendData.forEach((element) {
        if (element["name"]
            .toString()
            .toLowerCase()
            .contains(searchText.toString().toLowerCase())) {
          searchList.add(element);
        }
      });
    } else {
      searchList.addAll(_sendData);
    }
    filteredSent = searchList;
    notifyListeners();
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(leftGreen),
              ));
        });
  }

  void getParentData(data) {
    _parentData = data;
    notifyListeners();
  }

  void getSubData(data) {
    _subData = data;
    notifyListeners();
  }

  void getSubSendData(data) {
    print('ssss');
    _sendData = data;
    filteredSent = data;
    notifyListeners();
  }

  void getSubReceiveData(data) {
    _receiveData = data;
    filteredReceived = data;
    notifyListeners();
  }

  void createCloudParentFolder(
      String? receiverId,
      BuildContext? context,
      ) async {
    _isLoading = true;
    _completeStatus = false;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/create_cloud_parent_folder';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'receiver_id': receiverId,
    };

    print('BODY: ${jsonEncode(body)}');
    _isLoading ? buildShowDialog(ctx!) : Container();
    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        _completeStatus = true;
        notifyListeners();
        final res = jsonDecode(req.body);
        print(res);
        // getActualData(res['data']);
        _isLoading = false;
        _resMessage = req.body;
        //getParentData(context);
        getCloudParentList(context);
        notifyListeners();
        Navigator.pop(context!);
      } else {
        _completeStatus = true;
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
        Navigator.pop(context!);
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
      Navigator.pop(context!);
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();
      Navigator.pop(context!);
      print(':::::: $e');
    }
  }

  void getCloudParentList(
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_cloud_datas';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
    };
    print('fff');
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        getParentData(res['cloud_numbers']);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void createSubFolder(
      String? parentFolderId,
      String? folderName,
      String? accessPeriod,
      String? periodLimit,
      String? typeId,
      String? endDatetime,
      // String? parent_folder_id,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/create_cloud_sub_folder';

    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      typeId: parentFolderId,
      'folder_name': folderName,
      'access_period': accessPeriod,
      'period_limit': periodLimit,
      'end_datetime': endDatetime,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        // getActualData(res['data']);
        _isLoading = false;
        _resMessage = req.body;
        // getParentData(context);
        if (typeId == 'parent_folder_id') {
          getCloudSublist(parentFolderId, context);
        } else {
          getSubCloudSubList(parentFolderId, 'sent', context);
        }
        notifyListeners();
        Navigator.pop(context!);
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void getCloudSublist(
      String? parentFolderId,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_cloud_subfolders';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'parent_folder_id': parentFolderId,
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        getSubSendData(res['send_datas']);
        getSubReceiveData(res['received_datas']);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void getSubCloudSubList(
      String? subParentFolderId,
      String? type,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/get_subcloud_subfolders';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'sub_parent_folder_id': subParentFolderId,
    };
    print('ssss');
    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(type);
        type == 'sent'
            ? getSubSendData(res['datas'])
            : getSubReceiveData(res['datas']);
        _isLoading = false;
        _resMessage = req.body;
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void uploadFile(
      String? fileType,
      String? type,
      String? folderId,
      String? accessPeriod,
      String? periodLimit,
      String? endDatetime,
      File? ftr,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();

    String url = '$baseUrl/upload_cloud_files';
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    _isLoading ? buildShowDialog(ctx!) : Container();
// {"user_id":"54","accessToken":"54","parent_folder_id":"1","file":"http:/localhost/api/uploads/cloud/551/testing","access_period":"life_time","period_limit":"","file_type":"image"}
    try {
      var stream = http.ByteStream(ftr!.openRead());
      var length = await ftr.length();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      var multipartFile =
      http.MultipartFile('file', stream, length, filename: ftr.path);
      request.fields['user_id'] = auth.userId;
      request.fields['accessToken'] = auth.accessToken;
      request.fields['access_period'] = accessPeriod!;
      request.fields['period_limit'] = periodLimit!;
      request.fields[type!] = folderId!;
      request.fields['file_type'] = fileType!;
      request.fields['end_datetime'] = endDatetime!;
      request.files.add(multipartFile);

      print(request.fields);
      var resp = await request.send();
      resp.stream.transform(utf8.decoder).listen((event) {
        _isLoading = false;
        Navigator.pop(context!);
        var finalData = jsonDecode(event);
        // _profilePic = finalData['data']['profile_pic'];
        notifyListeners();
        if (finalData['statuscode'] == 200) {
          // Navigator.of(context!).pushReplacement(
          //     MaterialPageRoute(builder: (context) => FooterHome()));
          //getFooter(context);
          if (type == 'parent_folder_id') {
            getCloudSublist(folderId, context);
            notifyListeners();
          } else {
            getSubCloudSubList(folderId, 'sent', context);
          }
          notifyListeners();
          Navigator.pop(context);
        }
        print('::::::[RESPONSE]::::::');
        print(finalData);
        print('::::::[RESPONSE]::::::');
      });
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connectiongit add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void uploadImage(
      String? type,
      String? folderId,
      String? accessPeriod,
      String? periodLimit,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/upload_cloud_files';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      type: folderId,
      'access_period': accessPeriod,
      'period_limit': periodLimit,
      'file_type': 'image',
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
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void uploadFile2(
      String? type,
      String? folderId,
      String? accessPeriod,
      String? periodLimit,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/upload_cloud_files';
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      type: folderId,
      'access_period': accessPeriod,
      'period_limit': periodLimit,
      'file_type': 'pdf',
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
        notifyListeners();
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  /*{"accessToken":"c52c18ebaafc2bcb621f17e18203afeb","user_id":"6","id":"109"}*/
  void deleteCloudFile(
      String? parentFolderId,
      String? fileId,
      String? typeId,
      String? type,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/deletecloudFiles';
    print('gggg');
    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': fileId
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        // getActualData(res['data']);
        _isLoading = false;
        _resMessage = req.body;
        // getParentData(context);
        if (typeId == 'parent_folder_id') {
          getCloudSublist(parentFolderId, context);
          notifyListeners();
        } else {
          getSubCloudSubList(parentFolderId, type, context);
        }
        notifyListeners();
        Navigator.pop(context!);
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }

  void deleteSubfolder(
      String? parentFolderId,
      String? fileId,
      String? typeId,
      String? type,
      BuildContext? context,
      ) async {
    _isLoading = true;
    ctx = context;
    notifyListeners();
    var auth = Provider.of<AuthProvider>(ctx!, listen: false);
    String url = '$baseUrl/deletecloudsubfolder';

    final body = {
      'accessToken': auth.accessToken,
      'user_id': auth.userId,
      'id': fileId
    };

    print('BODY: ${jsonEncode(body)}');

    try {
      http.Response req =
      await http.post(Uri.parse(url), body: jsonEncode(body));

      if (req.statusCode == 200 || req.statusCode == 201) {
        final res = jsonDecode(req.body);
        print(res);
        // getActualData(res['data']);
        _isLoading = false;
        _resMessage = req.body;
        // getParentData(context);
        if (typeId == 'parent_folder_id') {
          getCloudSublist(parentFolderId, context);
          notifyListeners();
        } else {
          getSubCloudSubList(parentFolderId, type, context);
        }
        notifyListeners();
        Navigator.pop(context!);
      } else {
        final res = jsonDecode(req.body);
        print(':::::RRRRRR::::::$res');
        _isLoading = false;
        notifyListeners();
      }
    } on SocketException catch (_) {
      _isLoading = false;
      _resMessage = 'No Internet connection add available!';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _resMessage = 'Please try again!';
      notifyListeners();

      print(':::::: $e');
    }
  }
}
