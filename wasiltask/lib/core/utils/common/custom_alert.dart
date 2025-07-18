import 'package:flutter/material.dart';
import 'package:wasiltask/core/constants/strings.dart';

Future<void> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  required VoidCallback onConfirm,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(Strings.cancel),
        ),
        TextButton(onPressed: () => {onConfirm()}, child: Text(confirmText)),
      ],
    ),
  );
}
