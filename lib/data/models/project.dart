import 'package:flutter/material.dart';

enum ProjectStatus { planned, inProgress, blocked, done }

class Project {
  final String id;
  final String name;
  final ProjectStatus status;
  final DateTime start;
  final DateTime end;
  final double progress; // 0..1
  final String owner;
  final List<String> team;
  final Color color;

  const Project({
    required this.id,
    required this.name,
    required this.status,
    required this.start,
    required this.end,
    required this.progress,
    required this.owner,
    required this.team,
    required this.color,
  });

  Duration get duration => end.difference(start);
}
