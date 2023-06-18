import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../providers/AuthProvider/auth_provider.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/constants/urls.dart';

class LiveMap extends StatefulWidget {
  String chatType;
  String recId;
  LiveMap({Key? key, required this.chatType, required this.recId})
      : super(key: key);
  @override
  _LiveMapState createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  late GoogleMapController mapController;
  late Position currentPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission permanently denied. Please allow location access in app settings.',
          ),
        ),
      );
      return;
    }

    try {
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentPosition = position;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(currentPosition.latitude, currentPosition.longitude),
              zoom: 14,
            ),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
        ),
      );
    }
  }

  final IO.Socket _socket = IO.io(AppUrls.appSocketUrl,
      IO.OptionBuilder().setTransports(['websocket']).build());

  _connectSocket() {
    _socket.connect();
    _socket.onConnect((data) => print('Connection established'));
    _socket.onConnectError((data) => print('Connect Error $data'));
    _socket.onDisconnect((data) => print('Socket.IO disconneted'));
  }

  _destroySocket(){
    _socket.disconnect();
  }

  @override
  void initState() {
    _connectSocket();
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _destroySocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          Map(),
          LocationButton(),
          SendButton(auth),
        ],
      ),
    );
  }

  Positioned SendButton(AuthProvider auth) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          _shareLocation(auth.userId);
        },
        child: const Icon(Icons.send),
      ),
    );
  }

  Positioned LocationButton() {
    return Positioned(
      bottom: 10,
      right: 70,
      child: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _getUserLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  GoogleMap Map() {
    return GoogleMap(
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.hybrid,
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: LatLng(37.7749, -122.4194),
        zoom: 14,
      ),
      myLocationEnabled: true,
    );
  }

  void _shareLocation(String userId) async {
    print(currentPosition.latitude);
    var body;
    if (widget.chatType == 'single') {
      body = {
        'sid': userId,
        'rid': widget.recId,
        'message': '${currentPosition.latitude},${currentPosition.longitude}',
        'type': 'location',
      };
    }
    if (widget.chatType == 'group') {
      body = {
        'sid': userId,
        'room': widget.recId,
        'message': '${currentPosition.latitude},${currentPosition.longitude}',
        'type': 'location',
      };
    }
    _socket.emit('message', body);
    Navigator.pop(context);
  }
}
