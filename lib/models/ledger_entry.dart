/// One record in the friend-money ledger ("Lend & Borrow" module).
///
/// [LedgerDirection.given] — I gave money to a friend (they owe me).
/// [LedgerDirection.taken] — I took/borrowed money from a friend (I owe them).
///
/// An entry starts unsettled. Settling it marks the debt as paid back
/// without deleting the record, so the full history stays visible.
enum LedgerDirection { given, taken }

class LedgerEntry {
  final String id;
  final String person;
  final double amount;
  final String note;
  final DateTime date;
  final LedgerDirection direction;
  final bool settled;
  final DateTime? settledDate;

  const LedgerEntry({
    required this.id,
    required this.person,
    required this.amount,
    required this.date,
    required this.direction,
    this.note = '',
    this.settled = false,
    this.settledDate,
  });

  LedgerEntry copyWith({
    String? id,
    String? person,
    double? amount,
    String? note,
    DateTime? date,
    LedgerDirection? direction,
    bool? settled,
    DateTime? settledDate,
  }) =>
      LedgerEntry(
        id: id ?? this.id,
        person: person ?? this.person,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        date: date ?? this.date,
        direction: direction ?? this.direction,
        settled: settled ?? this.settled,
        settledDate: settledDate ?? this.settledDate,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'person': person,
        'amount': amount,
        'note': note,
        'date': date.millisecondsSinceEpoch,
        'direction': direction.name,
        'settled': settled,
        'settledDate': settledDate?.millisecondsSinceEpoch,
      };

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: json['id'] as String,
        person: json['person'] as String,
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] as String? ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        direction: LedgerDirection.values.firstWhere(
          (d) => d.name == json['direction'],
          orElse: () => LedgerDirection.given,
        ),
        settled: json['settled'] as bool? ?? false,
        settledDate: json['settledDate'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['settledDate'] as int),
      );
}
