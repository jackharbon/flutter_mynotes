import 'package:flutter/material.dart';

class LoadingStandardProgressBar extends StatelessWidget {
  const LoadingStandardProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
