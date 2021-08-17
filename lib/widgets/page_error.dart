import 'package:flutter/material.dart';

class PageError extends StatelessWidget {
  const PageError({required this.onReload, Key? key}) : super(key: key);

  final Function() onReload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(image: AssetImage('assets/mana_orz.png')),
          TextButton(onPressed: onReload, child: const Text('重新加载')),
        ],
      ),
    );
  }
}
