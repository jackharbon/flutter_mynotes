import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../providers/app_notifier.dart';

class OnlineStatusIcon extends StatelessWidget {
  const OnlineStatusIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(builder: (context, appStateNotifier, child) {
      return IconButton(
        icon: (appStateNotifier.isOnline) ? const Icon(Icons.cloud_outlined) : const Icon(Icons.phone_iphone_sharp),
        color: (appStateNotifier.isOnline)
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.inversePrimary,
        onPressed: () {
          (appStateNotifier.isOnline)
              ? Get.rawSnackbar(
                  messageText: Text(
                    'You are in the online mode.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 18,
                    ),
                  ),
                  isDismissible: true,
                  duration: const Duration(seconds: 3),
                  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                  icon: Icon(
                    Icons.cloud_outlined,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    size: 30,
                  ),
                  margin: const EdgeInsets.all(0),
                  snackStyle: SnackStyle.GROUNDED,
                )
              : Get.rawSnackbar(
                  messageText: Text(
                    'You are in the offline mode.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 18,
                    ),
                  ),
                  isDismissible: true,
                  duration: const Duration(seconds: 3),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  icon: Icon(
                    Icons.phone_iphone_sharp,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 30,
                  ),
                  margin: const EdgeInsets.all(0),
                  snackStyle: SnackStyle.GROUNDED,
                );
        },
      );
    });
  }
}
