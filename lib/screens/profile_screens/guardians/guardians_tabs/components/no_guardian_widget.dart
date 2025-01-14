import 'package:flutter/material.dart';
import 'package:seeds/design/app_theme.dart';

class NoGuardiansWidget extends StatelessWidget {
  final String message;

  const NoGuardiansWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Text(
        message,
        style: Theme.of(context).textTheme.subtitle2LowEmphasis,
      ),
    ));
  }
}
