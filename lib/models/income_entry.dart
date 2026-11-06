/// A single income record. Two kinds of income are tracked:
/// [IncomeType.job]  — the fixed monthly job salary (a single value, not a list).
/// [IncomeType.other] — one-off / random earnings: freelance work, gifts,
/// cashback, part-time gigs, etc. Each one is stored as an entry.
enum IncomeType { job, other }

class IncomeEntry {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final IncomeType type;

  const IncomeEntry({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.type = IncomeType.other,
  });

  IncomeEntry copyWith({
    String? id,
    String? source,
    double? amount,
    DateTime? date,
    IncomeType? type,
  }) =>
      IncomeEntry(
        id: id ?? this.id,
        source: source ?? this.source,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        type: type ?? this.type,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'amount': amount,
        'date': date.millisecondsSinceEpoch,
        'type': type.name,
      };

  factory IncomeEntry.fromJson(Map<String, dynamic> json) => IncomeEntry(
        id: json['id'] as String,
        source: json['source'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        type: IncomeType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => IncomeType.other,
        ),
      );
}
