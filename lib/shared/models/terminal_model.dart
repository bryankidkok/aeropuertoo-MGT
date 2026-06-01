import 'package:equatable/equatable.dart';

class TerminalModel extends Equatable {
  final String id;
  final String name;
  final String code;
  final int gatesCount;

  const TerminalModel({
    required this.id,
    required this.name,
    required this.code,
    this.gatesCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'code': code,
        'gatesCount': gatesCount,
      };

  factory TerminalModel.fromMap(String id, Map<String, dynamic> map) {
    return TerminalModel(
      id: id,
      name: map['name'] as String? ?? '',
      code: map['code'] as String? ?? '',
      gatesCount: (map['gatesCount'] as num?)?.toInt() ?? 0,
    );
  }

  TerminalModel copyWith({
    String? id,
    String? name,
    String? code,
    int? gatesCount,
  }) {
    return TerminalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      gatesCount: gatesCount ?? this.gatesCount,
    );
  }

  @override
  List<Object?> get props => [id, name, code, gatesCount];
}
