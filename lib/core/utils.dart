import 'package:flutter/material.dart';

String timeAgo(DateTime dateTime) {
  final now = DateTime.now().toUtc();
  final post = dateTime.toUtc();
  final diff = now.difference(post);
  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));
}
