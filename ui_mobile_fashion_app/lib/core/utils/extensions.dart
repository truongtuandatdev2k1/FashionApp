// lib/core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtension on BuildContext {
  void go(String location, {Object? extra}) => GoRouter.of(this).go(location, extra: extra);
  void push(String location, {Object? extra}) => GoRouter.of(this).push(location, extra: extra);
  void pop() => GoRouter.of(this).pop();
}