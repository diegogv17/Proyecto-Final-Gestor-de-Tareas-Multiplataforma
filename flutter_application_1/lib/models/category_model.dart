import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final Color color;
  final IconData icon;

  static const _defaultIcons = [
    Icons.code_rounded,
    Icons.palette_outlined,
    Icons.trending_up_rounded,
    Icons.person_outline_rounded,
    Icons.work_outline_rounded,
    Icons.school_outlined,
    Icons.fitness_center_outlined,
    Icons.shopping_bag_outlined,
    Icons.home_outlined,
    Icons.lightbulb_outline_rounded,
  ];

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final iconKey = json['icon'] as String?;
    return CategoryModel(
      id: (json['_id'] ?? json['id']).toString(),
      name: json['name'] as String,
      color: _colorFromHex(json['color'] as String? ?? '#6366F1'),
      icon: _iconFromKey(iconKey),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'color': _colorToHex(color),
      'icon': _iconToKey(icon),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  static Color _colorFromHex(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  static String _colorToHex(Color color) {
    final argb = color.toARGB32();
    final r = (argb >> 16) & 0xff;
    final g = (argb >> 8) & 0xff;
    final b = argb & 0xff;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  static IconData _iconFromKey(String? key) {
    if (key == null || key.isEmpty) return _defaultIcons.first;
    final index = int.tryParse(key);
    if (index != null && index >= 0 && index < _defaultIcons.length) {
      return _defaultIcons[index];
    }
    return _defaultIcons.first;
  }

  static String _iconToKey(IconData icon) {
    final index = _defaultIcons.indexOf(icon);
    return index >= 0 ? index.toString() : '0';
  }
}
