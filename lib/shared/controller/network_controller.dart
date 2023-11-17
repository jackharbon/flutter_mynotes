// import 'dart:developer' as devtools show log;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
        messageText: const Text(
          'No Internet! You are in the offline mode.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        isDismissible: true,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red[400]!,
        icon: const Icon(
          Icons.cloud_off_outlined,
          color: Colors.white,
          size: 30,
        ),
        margin: const EdgeInsets.all(0),
        snackStyle: SnackStyle.GROUNDED,
      );
    } else {
      Get.rawSnackbar(
        messageText: const Text(
          'Internet is on!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        isDismissible: true,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green[400]!,
        icon: const Icon(
          Icons.cloud_done_outlined,
          color: Colors.white,
          size: 30,
        ),
        margin: const EdgeInsets.all(0),
        snackStyle: SnackStyle.GROUNDED,
      );
    }
  }
}
