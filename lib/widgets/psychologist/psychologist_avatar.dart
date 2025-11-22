import 'package:flutter/material.dart';

/// Универсальный виджет аватара психолога: показывает NetworkImage или инициалы.
Widget buildPsychologistAvatar(
  String? avatarUrl,
  String fullName, {
  double radius = 28,
}) {
  final bool hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

  if (!hasAvatar) {
    final initials = fullName.isNotEmpty
        ? fullName.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: Text(
        initials,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  return CircleAvatar(
    radius: radius,
    backgroundImage: NetworkImage(avatarUrl!),
    backgroundColor: Colors.grey[200],
  );
}
