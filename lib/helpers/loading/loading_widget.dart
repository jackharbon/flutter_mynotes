import 'package:flutter/material.dart';

class LoadingStandardProgressBar extends StatelessWidget {
  const LoadingStandardProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.blue[100],
      child: const CircularProgressIndicator(
        backgroundColor: Colors.white24,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }
}
