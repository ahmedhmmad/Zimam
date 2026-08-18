// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 120),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    name,
    institution,
    currencyCode,
    type,
    colorArgb,
    notes,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String name;

  /// Bank or provider. Free text — the long tail of small institutions is
  /// exactly the audience here, so there is no closed list to pick from.
  final String? institution;

  /// ISO 4217. The account's native currency, which never changes: if money
  /// moves to a different currency it is a different account.
  final String currencyCode;

  /// Serialised [AccountType].
  final String type;

  /// ARGB, for the user's own colour tag. Note this is *not* the categorical
  /// ramp — that is assigned by share at render time.
  final int? colorArgb;
  final String? notes;

  /// Archived accounts stay in history and drop out of net worth. Distinct
  /// from [deletedAt]: archiving is a normal act, deleting is a correction.
  final bool isArchived;
  const AccountRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.name,
    this.institution,
    required this.currencyCode,
    required this.type,
    this.colorArgb,
    this.notes,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || colorArgb != null) {
      map['color_argb'] = Variable<int>(colorArgb);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      name: Value(name),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      currencyCode: Value(currencyCode),
      type: Value(type),
      colorArgb: colorArgb == null && nullToAbsent
          ? const Value.absent()
          : Value(colorArgb),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isArchived: Value(isArchived),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      institution: serializer.fromJson<String?>(json['institution']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      type: serializer.fromJson<String>(json['type']),
      colorArgb: serializer.fromJson<int?>(json['colorArgb']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'institution': serializer.toJson<String?>(institution),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'type': serializer.toJson<String>(type),
      'colorArgb': serializer.toJson<int?>(colorArgb),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  AccountRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? name,
    Value<String?> institution = const Value.absent(),
    String? currencyCode,
    String? type,
    Value<int?> colorArgb = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isArchived,
  }) => AccountRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    institution: institution.present ? institution.value : this.institution,
    currencyCode: currencyCode ?? this.currencyCode,
    type: type ?? this.type,
    colorArgb: colorArgb.present ? colorArgb.value : this.colorArgb,
    notes: notes.present ? notes.value : this.notes,
    isArchived: isArchived ?? this.isArchived,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      type: data.type.present ? data.type.value : this.type,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institution: $institution, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('type: $type, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    name,
    institution,
    currencyCode,
    type,
    colorArgb,
    notes,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.institution == this.institution &&
          other.currencyCode == this.currencyCode &&
          other.type == this.type &&
          other.colorArgb == this.colorArgb &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> institution;
  final Value<String> currencyCode;
  final Value<String> type;
  final Value<int?> colorArgb;
  final Value<String?> notes;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const AccountsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.institution = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.type = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String name,
    this.institution = const Value.absent(),
    required String currencyCode,
    required String type,
    this.colorArgb = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       currencyCode = Value(currencyCode),
       type = Value(type);
  static Insertable<AccountRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? institution,
    Expression<String>? currencyCode,
    Expression<String>? type,
    Expression<int>? colorArgb,
    Expression<String>? notes,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (institution != null) 'institution': institution,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (type != null) 'type': type,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? name,
    Value<String?>? institution,
    Value<String>? currencyCode,
    Value<String>? type,
    Value<int?>? colorArgb,
    Value<String?>? notes,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      institution: institution ?? this.institution,
      currencyCode: currencyCode ?? this.currencyCode,
      type: type ?? this.type,
      colorArgb: colorArgb ?? this.colorArgb,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('institution: $institution, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('type: $type, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BalanceSnapshotsTable extends BalanceSnapshots
    with TableInfo<$BalanceSnapshotsTable, BalanceSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BalanceSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedAtMeta = const VerificationMeta(
    'observedAt',
  );
  @override
  late final GeneratedColumn<DateTime> observedAt = GeneratedColumn<DateTime>(
    'observed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    accountId,
    amountMinor,
    currencyCode,
    observedAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'balance_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<BalanceSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('observed_at')) {
      context.handle(
        _observedAtMeta,
        observedAt.isAcceptableOrUnknown(data['observed_at']!, _observedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_observedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BalanceSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BalanceSnapshotRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      observedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}observed_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $BalanceSnapshotsTable createAlias(String alias) {
    return $BalanceSnapshotsTable(attachedDatabase, alias);
  }
}

class BalanceSnapshotRow extends DataClass
    implements Insertable<BalanceSnapshotRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String accountId;

  /// Minor units, scaled by [currencyCode]'s ISO 4217 exponent. Never a real
  /// number — see `lib/core/money/money.dart`.
  final int amountMinor;

  /// Denormalised from the account on purpose: an account's currency must
  /// never silently reinterpret past snapshots, so each row records the
  /// currency its own integer was scaled by.
  final String currencyCode;
  final DateTime observedAt;

  /// Serialised [SnapshotSource] — whether the user typed this or a
  /// notification suggested it. Phase 5 needs to tell them apart.
  final String source;
  const BalanceSnapshotRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.accountId,
    required this.amountMinor,
    required this.currencyCode,
    required this.observedAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['observed_at'] = Variable<DateTime>(observedAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  BalanceSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return BalanceSnapshotsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      accountId: Value(accountId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      observedAt: Value(observedAt),
      source: Value(source),
    );
  }

  factory BalanceSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BalanceSnapshotRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      observedAt: serializer.fromJson<DateTime>(json['observedAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'observedAt': serializer.toJson<DateTime>(observedAt),
      'source': serializer.toJson<String>(source),
    };
  }

  BalanceSnapshotRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? accountId,
    int? amountMinor,
    String? currencyCode,
    DateTime? observedAt,
    String? source,
  }) => BalanceSnapshotRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    observedAt: observedAt ?? this.observedAt,
    source: source ?? this.source,
  );
  BalanceSnapshotRow copyWithCompanion(BalanceSnapshotsCompanion data) {
    return BalanceSnapshotRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      observedAt: data.observedAt.present
          ? data.observedAt.value
          : this.observedAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('observedAt: $observedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    accountId,
    amountMinor,
    currencyCode,
    observedAt,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BalanceSnapshotRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.observedAt == this.observedAt &&
          other.source == this.source);
}

class BalanceSnapshotsCompanion extends UpdateCompanion<BalanceSnapshotRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> accountId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<DateTime> observedAt;
  final Value<String> source;
  final Value<int> rowid;
  const BalanceSnapshotsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.observedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BalanceSnapshotsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String accountId,
    required int amountMinor,
    required String currencyCode,
    required DateTime observedAt,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       observedAt = Value(observedAt),
       source = Value(source);
  static Insertable<BalanceSnapshotRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<DateTime>? observedAt,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (observedAt != null) 'observed_at': observedAt,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BalanceSnapshotsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? accountId,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<DateTime>? observedAt,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return BalanceSnapshotsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      observedAt: observedAt ?? this.observedAt,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (observedAt.present) {
      map['observed_at'] = Variable<DateTime>(observedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BalanceSnapshotsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('observedAt: $observedAt, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtsTable extends Debts with TableInfo<$DebtsTable, DebtRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterpartyMeta = const VerificationMeta(
    'counterparty',
  );
  @override
  late final GeneratedColumn<String> counterparty = GeneratedColumn<String>(
    'counterparty',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalMinorMeta = const VerificationMeta(
    'principalMinor',
  );
  @override
  late final GeneratedColumn<int> principalMinor = GeneratedColumn<int>(
    'principal_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _homeCurrencyCodeMeta = const VerificationMeta(
    'homeCurrencyCode',
  );
  @override
  late final GeneratedColumn<String> homeCurrencyCode = GeneratedColumn<String>(
    'home_currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateAtCreationScaledMeta =
      const VerificationMeta('rateAtCreationScaled');
  @override
  late final GeneratedColumn<int> rateAtCreationScaled = GeneratedColumn<int>(
    'rate_at_creation_scaled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdOnMeta = const VerificationMeta(
    'createdOn',
  );
  @override
  late final GeneratedColumn<DateTime> createdOn = GeneratedColumn<DateTime>(
    'created_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueOnMeta = const VerificationMeta('dueOn');
  @override
  late final GeneratedColumn<DateTime> dueOn = GeneratedColumn<DateTime>(
    'due_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    counterparty,
    direction,
    principalMinor,
    currencyCode,
    homeCurrencyCode,
    rateAtCreationScaled,
    createdOn,
    dueOn,
    settledAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('counterparty')) {
      context.handle(
        _counterpartyMeta,
        counterparty.isAcceptableOrUnknown(
          data['counterparty']!,
          _counterpartyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_counterpartyMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('principal_minor')) {
      context.handle(
        _principalMinorMeta,
        principalMinor.isAcceptableOrUnknown(
          data['principal_minor']!,
          _principalMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_principalMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('home_currency_code')) {
      context.handle(
        _homeCurrencyCodeMeta,
        homeCurrencyCode.isAcceptableOrUnknown(
          data['home_currency_code']!,
          _homeCurrencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_homeCurrencyCodeMeta);
    }
    if (data.containsKey('rate_at_creation_scaled')) {
      context.handle(
        _rateAtCreationScaledMeta,
        rateAtCreationScaled.isAcceptableOrUnknown(
          data['rate_at_creation_scaled']!,
          _rateAtCreationScaledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rateAtCreationScaledMeta);
    }
    if (data.containsKey('created_on')) {
      context.handle(
        _createdOnMeta,
        createdOn.isAcceptableOrUnknown(data['created_on']!, _createdOnMeta),
      );
    } else if (isInserting) {
      context.missing(_createdOnMeta);
    }
    if (data.containsKey('due_on')) {
      context.handle(
        _dueOnMeta,
        dueOn.isAcceptableOrUnknown(data['due_on']!, _dueOnMeta),
      );
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      counterparty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      principalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}principal_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      homeCurrencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_currency_code'],
      )!,
      rateAtCreationScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_at_creation_scaled'],
      )!,
      createdOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_on'],
      )!,
      dueOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_on'],
      ),
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DebtsTable createAlias(String alias) {
    return $DebtsTable(attachedDatabase, alias);
  }
}

class DebtRow extends DataClass implements Insertable<DebtRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String counterparty;

  /// Serialised [DebtDirection].
  final String direction;
  final int principalMinor;
  final String currencyCode;

  /// The home currency *at the time the debt was created*, not today's. If the
  /// user later changes their home currency, this debt's original cost must
  /// still mean what it meant when it was recorded.
  final String homeCurrencyCode;

  /// The rate from [currencyCode] to [homeCurrencyCode] on [createdOn],
  /// scaled by `FxRate.scaleFactor`.
  ///
  /// Written once and never updated. This single column is the whole
  /// repayment-drift feature: without a frozen historical rate there is
  /// nothing to compare today's cost against.
  final int rateAtCreationScaled;
  final DateTime createdOn;
  final DateTime? dueOn;
  final DateTime? settledAt;
  final String? notes;
  const DebtRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.counterparty,
    required this.direction,
    required this.principalMinor,
    required this.currencyCode,
    required this.homeCurrencyCode,
    required this.rateAtCreationScaled,
    required this.createdOn,
    this.dueOn,
    this.settledAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['counterparty'] = Variable<String>(counterparty);
    map['direction'] = Variable<String>(direction);
    map['principal_minor'] = Variable<int>(principalMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['home_currency_code'] = Variable<String>(homeCurrencyCode);
    map['rate_at_creation_scaled'] = Variable<int>(rateAtCreationScaled);
    map['created_on'] = Variable<DateTime>(createdOn);
    if (!nullToAbsent || dueOn != null) {
      map['due_on'] = Variable<DateTime>(dueOn);
    }
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DebtsCompanion toCompanion(bool nullToAbsent) {
    return DebtsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      counterparty: Value(counterparty),
      direction: Value(direction),
      principalMinor: Value(principalMinor),
      currencyCode: Value(currencyCode),
      homeCurrencyCode: Value(homeCurrencyCode),
      rateAtCreationScaled: Value(rateAtCreationScaled),
      createdOn: Value(createdOn),
      dueOn: dueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOn),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DebtRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      counterparty: serializer.fromJson<String>(json['counterparty']),
      direction: serializer.fromJson<String>(json['direction']),
      principalMinor: serializer.fromJson<int>(json['principalMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      homeCurrencyCode: serializer.fromJson<String>(json['homeCurrencyCode']),
      rateAtCreationScaled: serializer.fromJson<int>(
        json['rateAtCreationScaled'],
      ),
      createdOn: serializer.fromJson<DateTime>(json['createdOn']),
      dueOn: serializer.fromJson<DateTime?>(json['dueOn']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'counterparty': serializer.toJson<String>(counterparty),
      'direction': serializer.toJson<String>(direction),
      'principalMinor': serializer.toJson<int>(principalMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'homeCurrencyCode': serializer.toJson<String>(homeCurrencyCode),
      'rateAtCreationScaled': serializer.toJson<int>(rateAtCreationScaled),
      'createdOn': serializer.toJson<DateTime>(createdOn),
      'dueOn': serializer.toJson<DateTime?>(dueOn),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DebtRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? counterparty,
    String? direction,
    int? principalMinor,
    String? currencyCode,
    String? homeCurrencyCode,
    int? rateAtCreationScaled,
    DateTime? createdOn,
    Value<DateTime?> dueOn = const Value.absent(),
    Value<DateTime?> settledAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => DebtRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    counterparty: counterparty ?? this.counterparty,
    direction: direction ?? this.direction,
    principalMinor: principalMinor ?? this.principalMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    homeCurrencyCode: homeCurrencyCode ?? this.homeCurrencyCode,
    rateAtCreationScaled: rateAtCreationScaled ?? this.rateAtCreationScaled,
    createdOn: createdOn ?? this.createdOn,
    dueOn: dueOn.present ? dueOn.value : this.dueOn,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    notes: notes.present ? notes.value : this.notes,
  );
  DebtRow copyWithCompanion(DebtsCompanion data) {
    return DebtRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      counterparty: data.counterparty.present
          ? data.counterparty.value
          : this.counterparty,
      direction: data.direction.present ? data.direction.value : this.direction,
      principalMinor: data.principalMinor.present
          ? data.principalMinor.value
          : this.principalMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      homeCurrencyCode: data.homeCurrencyCode.present
          ? data.homeCurrencyCode.value
          : this.homeCurrencyCode,
      rateAtCreationScaled: data.rateAtCreationScaled.present
          ? data.rateAtCreationScaled.value
          : this.rateAtCreationScaled,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('counterparty: $counterparty, ')
          ..write('direction: $direction, ')
          ..write('principalMinor: $principalMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('homeCurrencyCode: $homeCurrencyCode, ')
          ..write('rateAtCreationScaled: $rateAtCreationScaled, ')
          ..write('createdOn: $createdOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('settledAt: $settledAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    counterparty,
    direction,
    principalMinor,
    currencyCode,
    homeCurrencyCode,
    rateAtCreationScaled,
    createdOn,
    dueOn,
    settledAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.counterparty == this.counterparty &&
          other.direction == this.direction &&
          other.principalMinor == this.principalMinor &&
          other.currencyCode == this.currencyCode &&
          other.homeCurrencyCode == this.homeCurrencyCode &&
          other.rateAtCreationScaled == this.rateAtCreationScaled &&
          other.createdOn == this.createdOn &&
          other.dueOn == this.dueOn &&
          other.settledAt == this.settledAt &&
          other.notes == this.notes);
}

class DebtsCompanion extends UpdateCompanion<DebtRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> counterparty;
  final Value<String> direction;
  final Value<int> principalMinor;
  final Value<String> currencyCode;
  final Value<String> homeCurrencyCode;
  final Value<int> rateAtCreationScaled;
  final Value<DateTime> createdOn;
  final Value<DateTime?> dueOn;
  final Value<DateTime?> settledAt;
  final Value<String?> notes;
  final Value<int> rowid;
  const DebtsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.counterparty = const Value.absent(),
    this.direction = const Value.absent(),
    this.principalMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.homeCurrencyCode = const Value.absent(),
    this.rateAtCreationScaled = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String counterparty,
    required String direction,
    required int principalMinor,
    required String currencyCode,
    required String homeCurrencyCode,
    required int rateAtCreationScaled,
    required DateTime createdOn,
    this.dueOn = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       counterparty = Value(counterparty),
       direction = Value(direction),
       principalMinor = Value(principalMinor),
       currencyCode = Value(currencyCode),
       homeCurrencyCode = Value(homeCurrencyCode),
       rateAtCreationScaled = Value(rateAtCreationScaled),
       createdOn = Value(createdOn);
  static Insertable<DebtRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? counterparty,
    Expression<String>? direction,
    Expression<int>? principalMinor,
    Expression<String>? currencyCode,
    Expression<String>? homeCurrencyCode,
    Expression<int>? rateAtCreationScaled,
    Expression<DateTime>? createdOn,
    Expression<DateTime>? dueOn,
    Expression<DateTime>? settledAt,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (counterparty != null) 'counterparty': counterparty,
      if (direction != null) 'direction': direction,
      if (principalMinor != null) 'principal_minor': principalMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (homeCurrencyCode != null) 'home_currency_code': homeCurrencyCode,
      if (rateAtCreationScaled != null)
        'rate_at_creation_scaled': rateAtCreationScaled,
      if (createdOn != null) 'created_on': createdOn,
      if (dueOn != null) 'due_on': dueOn,
      if (settledAt != null) 'settled_at': settledAt,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? counterparty,
    Value<String>? direction,
    Value<int>? principalMinor,
    Value<String>? currencyCode,
    Value<String>? homeCurrencyCode,
    Value<int>? rateAtCreationScaled,
    Value<DateTime>? createdOn,
    Value<DateTime?>? dueOn,
    Value<DateTime?>? settledAt,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return DebtsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      counterparty: counterparty ?? this.counterparty,
      direction: direction ?? this.direction,
      principalMinor: principalMinor ?? this.principalMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      homeCurrencyCode: homeCurrencyCode ?? this.homeCurrencyCode,
      rateAtCreationScaled: rateAtCreationScaled ?? this.rateAtCreationScaled,
      createdOn: createdOn ?? this.createdOn,
      dueOn: dueOn ?? this.dueOn,
      settledAt: settledAt ?? this.settledAt,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (counterparty.present) {
      map['counterparty'] = Variable<String>(counterparty.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (principalMinor.present) {
      map['principal_minor'] = Variable<int>(principalMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (homeCurrencyCode.present) {
      map['home_currency_code'] = Variable<String>(homeCurrencyCode.value);
    }
    if (rateAtCreationScaled.present) {
      map['rate_at_creation_scaled'] = Variable<int>(
        rateAtCreationScaled.value,
      );
    }
    if (createdOn.present) {
      map['created_on'] = Variable<DateTime>(createdOn.value);
    }
    if (dueOn.present) {
      map['due_on'] = Variable<DateTime>(dueOn.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('counterparty: $counterparty, ')
          ..write('direction: $direction, ')
          ..write('principalMinor: $principalMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('homeCurrencyCode: $homeCurrencyCode, ')
          ..write('rateAtCreationScaled: $rateAtCreationScaled, ')
          ..write('createdOn: $createdOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('settledAt: $settledAt, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebtPaymentsTable extends DebtPayments
    with TableInfo<$DebtPaymentsTable, DebtPaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebtPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _debtIdMeta = const VerificationMeta('debtId');
  @override
  late final GeneratedColumn<String> debtId = GeneratedColumn<String>(
    'debt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES debts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidOnMeta = const VerificationMeta('paidOn');
  @override
  late final GeneratedColumn<DateTime> paidOn = GeneratedColumn<DateTime>(
    'paid_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateAtPaymentScaledMeta =
      const VerificationMeta('rateAtPaymentScaled');
  @override
  late final GeneratedColumn<int> rateAtPaymentScaled = GeneratedColumn<int>(
    'rate_at_payment_scaled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    debtId,
    amountMinor,
    currencyCode,
    paidOn,
    rateAtPaymentScaled,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debt_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebtPaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debt_id')) {
      context.handle(
        _debtIdMeta,
        debtId.isAcceptableOrUnknown(data['debt_id']!, _debtIdMeta),
      );
    } else if (isInserting) {
      context.missing(_debtIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('paid_on')) {
      context.handle(
        _paidOnMeta,
        paidOn.isAcceptableOrUnknown(data['paid_on']!, _paidOnMeta),
      );
    } else if (isInserting) {
      context.missing(_paidOnMeta);
    }
    if (data.containsKey('rate_at_payment_scaled')) {
      context.handle(
        _rateAtPaymentScaledMeta,
        rateAtPaymentScaled.isAcceptableOrUnknown(
          data['rate_at_payment_scaled']!,
          _rateAtPaymentScaledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rateAtPaymentScaledMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DebtPaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebtPaymentRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      debtId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debt_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      paidOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_on'],
      )!,
      rateAtPaymentScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_at_payment_scaled'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DebtPaymentsTable createAlias(String alias) {
    return $DebtPaymentsTable(attachedDatabase, alias);
  }
}

class DebtPaymentRow extends DataClass implements Insertable<DebtPaymentRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String debtId;
  final int amountMinor;
  final String currencyCode;
  final DateTime paidOn;

  /// Rate to the debt's home currency on [paidOn], scaled. Frozen like the
  /// debt's own rate.
  final int rateAtPaymentScaled;
  final String? notes;
  const DebtPaymentRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.debtId,
    required this.amountMinor,
    required this.currencyCode,
    required this.paidOn,
    required this.rateAtPaymentScaled,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['debt_id'] = Variable<String>(debtId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['paid_on'] = Variable<DateTime>(paidOn);
    map['rate_at_payment_scaled'] = Variable<int>(rateAtPaymentScaled);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DebtPaymentsCompanion toCompanion(bool nullToAbsent) {
    return DebtPaymentsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      debtId: Value(debtId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      paidOn: Value(paidOn),
      rateAtPaymentScaled: Value(rateAtPaymentScaled),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DebtPaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebtPaymentRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      debtId: serializer.fromJson<String>(json['debtId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      paidOn: serializer.fromJson<DateTime>(json['paidOn']),
      rateAtPaymentScaled: serializer.fromJson<int>(
        json['rateAtPaymentScaled'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'debtId': serializer.toJson<String>(debtId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'paidOn': serializer.toJson<DateTime>(paidOn),
      'rateAtPaymentScaled': serializer.toJson<int>(rateAtPaymentScaled),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DebtPaymentRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? debtId,
    int? amountMinor,
    String? currencyCode,
    DateTime? paidOn,
    int? rateAtPaymentScaled,
    Value<String?> notes = const Value.absent(),
  }) => DebtPaymentRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    debtId: debtId ?? this.debtId,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    paidOn: paidOn ?? this.paidOn,
    rateAtPaymentScaled: rateAtPaymentScaled ?? this.rateAtPaymentScaled,
    notes: notes.present ? notes.value : this.notes,
  );
  DebtPaymentRow copyWithCompanion(DebtPaymentsCompanion data) {
    return DebtPaymentRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      debtId: data.debtId.present ? data.debtId.value : this.debtId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      paidOn: data.paidOn.present ? data.paidOn.value : this.paidOn,
      rateAtPaymentScaled: data.rateAtPaymentScaled.present
          ? data.rateAtPaymentScaled.value
          : this.rateAtPaymentScaled,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebtPaymentRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('paidOn: $paidOn, ')
          ..write('rateAtPaymentScaled: $rateAtPaymentScaled, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    debtId,
    amountMinor,
    currencyCode,
    paidOn,
    rateAtPaymentScaled,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebtPaymentRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.debtId == this.debtId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.paidOn == this.paidOn &&
          other.rateAtPaymentScaled == this.rateAtPaymentScaled &&
          other.notes == this.notes);
}

class DebtPaymentsCompanion extends UpdateCompanion<DebtPaymentRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> debtId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<DateTime> paidOn;
  final Value<int> rateAtPaymentScaled;
  final Value<String?> notes;
  final Value<int> rowid;
  const DebtPaymentsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.debtId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.paidOn = const Value.absent(),
    this.rateAtPaymentScaled = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebtPaymentsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String debtId,
    required int amountMinor,
    required String currencyCode,
    required DateTime paidOn,
    required int rateAtPaymentScaled,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       debtId = Value(debtId),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       paidOn = Value(paidOn),
       rateAtPaymentScaled = Value(rateAtPaymentScaled);
  static Insertable<DebtPaymentRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? debtId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<DateTime>? paidOn,
    Expression<int>? rateAtPaymentScaled,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (debtId != null) 'debt_id': debtId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (paidOn != null) 'paid_on': paidOn,
      if (rateAtPaymentScaled != null)
        'rate_at_payment_scaled': rateAtPaymentScaled,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebtPaymentsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? debtId,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<DateTime>? paidOn,
    Value<int>? rateAtPaymentScaled,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return DebtPaymentsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      paidOn: paidOn ?? this.paidOn,
      rateAtPaymentScaled: rateAtPaymentScaled ?? this.rateAtPaymentScaled,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (debtId.present) {
      map['debt_id'] = Variable<String>(debtId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (paidOn.present) {
      map['paid_on'] = Variable<DateTime>(paidOn.value);
    }
    if (rateAtPaymentScaled.present) {
      map['rate_at_payment_scaled'] = Variable<int>(rateAtPaymentScaled.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebtPaymentsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('debtId: $debtId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('paidOn: $paidOn, ')
          ..write('rateAtPaymentScaled: $rateAtPaymentScaled, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FxRatesTable extends FxRates
    with TableInfo<$FxRatesTable, CachedFxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseCodeMeta = const VerificationMeta(
    'baseCode',
  );
  @override
  late final GeneratedColumn<String> baseCode = GeneratedColumn<String>(
    'base_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteCodeMeta = const VerificationMeta(
    'quoteCode',
  );
  @override
  late final GeneratedColumn<String> quoteCode = GeneratedColumn<String>(
    'quote_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateScaledMeta = const VerificationMeta(
    'rateScaled',
  );
  @override
  late final GeneratedColumn<int> rateScaled = GeneratedColumn<int>(
    'rate_scaled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateDateMeta = const VerificationMeta(
    'rateDate',
  );
  @override
  late final GeneratedColumn<DateTime> rateDate = GeneratedColumn<DateTime>(
    'rate_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    baseCode,
    quoteCode,
    rateScaled,
    rateDate,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('base_code')) {
      context.handle(
        _baseCodeMeta,
        baseCode.isAcceptableOrUnknown(data['base_code']!, _baseCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_baseCodeMeta);
    }
    if (data.containsKey('quote_code')) {
      context.handle(
        _quoteCodeMeta,
        quoteCode.isAcceptableOrUnknown(data['quote_code']!, _quoteCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteCodeMeta);
    }
    if (data.containsKey('rate_scaled')) {
      context.handle(
        _rateScaledMeta,
        rateScaled.isAcceptableOrUnknown(data['rate_scaled']!, _rateScaledMeta),
      );
    } else if (isInserting) {
      context.missing(_rateScaledMeta);
    }
    if (data.containsKey('rate_date')) {
      context.handle(
        _rateDateMeta,
        rateDate.isAcceptableOrUnknown(data['rate_date']!, _rateDateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateDateMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {baseCode, quoteCode, rateDate};
  @override
  CachedFxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFxRate(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      baseCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_code'],
      )!,
      quoteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_code'],
      )!,
      rateScaled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_scaled'],
      )!,
      rateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_date'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $FxRatesTable createAlias(String alias) {
    return $FxRatesTable(attachedDatabase, alias);
  }
}

class CachedFxRate extends DataClass implements Insertable<CachedFxRate> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String baseCode;
  final String quoteCode;

  /// Rate × 10^8, as an integer. A rate is a ratio, and storing it as a double
  /// would reintroduce exactly the drift that integer money is there to avoid.
  final int rateScaled;

  /// The day the rate is *for*, at UTC midnight.
  final DateTime rateDate;

  /// When it was retrieved. Distinct from [rateDate]: a rate for the 3rd
  /// fetched on the 5th is two days stale, and the UI says so.
  final DateTime fetchedAt;
  const CachedFxRate({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.baseCode,
    required this.quoteCode,
    required this.rateScaled,
    required this.rateDate,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['base_code'] = Variable<String>(baseCode);
    map['quote_code'] = Variable<String>(quoteCode);
    map['rate_scaled'] = Variable<int>(rateScaled);
    map['rate_date'] = Variable<DateTime>(rateDate);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  FxRatesCompanion toCompanion(bool nullToAbsent) {
    return FxRatesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      baseCode: Value(baseCode),
      quoteCode: Value(quoteCode),
      rateScaled: Value(rateScaled),
      rateDate: Value(rateDate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedFxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFxRate(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      baseCode: serializer.fromJson<String>(json['baseCode']),
      quoteCode: serializer.fromJson<String>(json['quoteCode']),
      rateScaled: serializer.fromJson<int>(json['rateScaled']),
      rateDate: serializer.fromJson<DateTime>(json['rateDate']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'baseCode': serializer.toJson<String>(baseCode),
      'quoteCode': serializer.toJson<String>(quoteCode),
      'rateScaled': serializer.toJson<int>(rateScaled),
      'rateDate': serializer.toJson<DateTime>(rateDate),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedFxRate copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? baseCode,
    String? quoteCode,
    int? rateScaled,
    DateTime? rateDate,
    DateTime? fetchedAt,
  }) => CachedFxRate(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    baseCode: baseCode ?? this.baseCode,
    quoteCode: quoteCode ?? this.quoteCode,
    rateScaled: rateScaled ?? this.rateScaled,
    rateDate: rateDate ?? this.rateDate,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedFxRate copyWithCompanion(FxRatesCompanion data) {
    return CachedFxRate(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      baseCode: data.baseCode.present ? data.baseCode.value : this.baseCode,
      quoteCode: data.quoteCode.present ? data.quoteCode.value : this.quoteCode,
      rateScaled: data.rateScaled.present
          ? data.rateScaled.value
          : this.rateScaled,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFxRate(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('baseCode: $baseCode, ')
          ..write('quoteCode: $quoteCode, ')
          ..write('rateScaled: $rateScaled, ')
          ..write('rateDate: $rateDate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    baseCode,
    quoteCode,
    rateScaled,
    rateDate,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFxRate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.baseCode == this.baseCode &&
          other.quoteCode == this.quoteCode &&
          other.rateScaled == this.rateScaled &&
          other.rateDate == this.rateDate &&
          other.fetchedAt == this.fetchedAt);
}

class FxRatesCompanion extends UpdateCompanion<CachedFxRate> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> baseCode;
  final Value<String> quoteCode;
  final Value<int> rateScaled;
  final Value<DateTime> rateDate;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const FxRatesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.baseCode = const Value.absent(),
    this.quoteCode = const Value.absent(),
    this.rateScaled = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FxRatesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String baseCode,
    required String quoteCode,
    required int rateScaled,
    required DateTime rateDate,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : baseCode = Value(baseCode),
       quoteCode = Value(quoteCode),
       rateScaled = Value(rateScaled),
       rateDate = Value(rateDate),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedFxRate> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? baseCode,
    Expression<String>? quoteCode,
    Expression<int>? rateScaled,
    Expression<DateTime>? rateDate,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (baseCode != null) 'base_code': baseCode,
      if (quoteCode != null) 'quote_code': quoteCode,
      if (rateScaled != null) 'rate_scaled': rateScaled,
      if (rateDate != null) 'rate_date': rateDate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FxRatesCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? baseCode,
    Value<String>? quoteCode,
    Value<int>? rateScaled,
    Value<DateTime>? rateDate,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return FxRatesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      baseCode: baseCode ?? this.baseCode,
      quoteCode: quoteCode ?? this.quoteCode,
      rateScaled: rateScaled ?? this.rateScaled,
      rateDate: rateDate ?? this.rateDate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (baseCode.present) {
      map['base_code'] = Variable<String>(baseCode.value);
    }
    if (quoteCode.present) {
      map['quote_code'] = Variable<String>(quoteCode.value);
    }
    if (rateScaled.present) {
      map['rate_scaled'] = Variable<int>(rateScaled.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<DateTime>(rateDate.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FxRatesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('baseCode: $baseCode, ')
          ..write('quoteCode: $quoteCode, ')
          ..write('rateScaled: $rateScaled, ')
          ..write('rateDate: $rateDate, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    key,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String key;
  final String value;
  const Setting({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? key,
    String? value,
  }) => Setting(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    key: key ?? this.key,
    value: value ?? this.value,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, deletedAt, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSuggestionsTable extends PendingSuggestions
    with TableInfo<$PendingSuggestionsTable, PendingSuggestionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMinorMeta = const VerificationMeta(
    'balanceMinor',
  );
  @override
  late final GeneratedColumn<int> balanceMinor = GeneratedColumn<int>(
    'balance_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postedAtMeta = const VerificationMeta(
    'postedAt',
  );
  @override
  late final GeneratedColumn<DateTime> postedAt = GeneratedColumn<DateTime>(
    'posted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTitleMeta = const VerificationMeta(
    'rawTitle',
  );
  @override
  late final GeneratedColumn<String> rawTitle = GeneratedColumn<String>(
    'raw_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rawBodyMeta = const VerificationMeta(
    'rawBody',
  );
  @override
  late final GeneratedColumn<String> rawBody = GeneratedColumn<String>(
    'raw_body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    ruleId,
    packageName,
    amountMinor,
    currencyCode,
    direction,
    balanceMinor,
    merchant,
    postedAt,
    rawTitle,
    rawBody,
    accountId,
    resolvedAt,
    resolution,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSuggestionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('balance_minor')) {
      context.handle(
        _balanceMinorMeta,
        balanceMinor.isAcceptableOrUnknown(
          data['balance_minor']!,
          _balanceMinorMeta,
        ),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('posted_at')) {
      context.handle(
        _postedAtMeta,
        postedAt.isAcceptableOrUnknown(data['posted_at']!, _postedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_postedAtMeta);
    }
    if (data.containsKey('raw_title')) {
      context.handle(
        _rawTitleMeta,
        rawTitle.isAcceptableOrUnknown(data['raw_title']!, _rawTitleMeta),
      );
    }
    if (data.containsKey('raw_body')) {
      context.handle(
        _rawBodyMeta,
        rawBody.isAcceptableOrUnknown(data['raw_body']!, _rawBodyMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSuggestionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSuggestionRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      balanceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_minor'],
      ),
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      postedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}posted_at'],
      )!,
      rawTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_title'],
      )!,
      rawBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_body'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
    );
  }

  @override
  $PendingSuggestionsTable createAlias(String alias) {
    return $PendingSuggestionsTable(attachedDatabase, alias);
  }
}

class PendingSuggestionRow extends DataClass
    implements Insertable<PendingSuggestionRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;

  /// Which rule produced this, so a bad figure can be traced to its pattern.
  final String ruleId;
  final String packageName;
  final int amountMinor;
  final String currencyCode;

  /// Serialised `TransactionDirection`.
  final String direction;

  /// The balance the message reported, when it stated one. More valuable than
  /// the amount: it is an observation of the true balance rather than
  /// something inferred by arithmetic.
  final int? balanceMinor;
  final String? merchant;
  final DateTime postedAt;

  /// The notification as it arrived, for review.
  final String rawTitle;
  final String rawBody;

  /// The account the user matched it to. Null until they choose.
  final String? accountId;

  /// Set once the user has confirmed or rejected. Kept rather than deleted so
  /// the same notification is not suggested twice.
  final DateTime? resolvedAt;

  /// `confirmed` | `rejected`, null while pending.
  final String? resolution;
  const PendingSuggestionRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.ruleId,
    required this.packageName,
    required this.amountMinor,
    required this.currencyCode,
    required this.direction,
    this.balanceMinor,
    this.merchant,
    required this.postedAt,
    required this.rawTitle,
    required this.rawBody,
    this.accountId,
    this.resolvedAt,
    this.resolution,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['rule_id'] = Variable<String>(ruleId);
    map['package_name'] = Variable<String>(packageName);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    map['direction'] = Variable<String>(direction);
    if (!nullToAbsent || balanceMinor != null) {
      map['balance_minor'] = Variable<int>(balanceMinor);
    }
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    map['posted_at'] = Variable<DateTime>(postedAt);
    map['raw_title'] = Variable<String>(rawTitle);
    map['raw_body'] = Variable<String>(rawBody);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    return map;
  }

  PendingSuggestionsCompanion toCompanion(bool nullToAbsent) {
    return PendingSuggestionsCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      ruleId: Value(ruleId),
      packageName: Value(packageName),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      direction: Value(direction),
      balanceMinor: balanceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(balanceMinor),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      postedAt: Value(postedAt),
      rawTitle: Value(rawTitle),
      rawBody: Value(rawBody),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
    );
  }

  factory PendingSuggestionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSuggestionRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      packageName: serializer.fromJson<String>(json['packageName']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      direction: serializer.fromJson<String>(json['direction']),
      balanceMinor: serializer.fromJson<int?>(json['balanceMinor']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      postedAt: serializer.fromJson<DateTime>(json['postedAt']),
      rawTitle: serializer.fromJson<String>(json['rawTitle']),
      rawBody: serializer.fromJson<String>(json['rawBody']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      resolution: serializer.fromJson<String?>(json['resolution']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'ruleId': serializer.toJson<String>(ruleId),
      'packageName': serializer.toJson<String>(packageName),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'direction': serializer.toJson<String>(direction),
      'balanceMinor': serializer.toJson<int?>(balanceMinor),
      'merchant': serializer.toJson<String?>(merchant),
      'postedAt': serializer.toJson<DateTime>(postedAt),
      'rawTitle': serializer.toJson<String>(rawTitle),
      'rawBody': serializer.toJson<String>(rawBody),
      'accountId': serializer.toJson<String?>(accountId),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'resolution': serializer.toJson<String?>(resolution),
    };
  }

  PendingSuggestionRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? ruleId,
    String? packageName,
    int? amountMinor,
    String? currencyCode,
    String? direction,
    Value<int?> balanceMinor = const Value.absent(),
    Value<String?> merchant = const Value.absent(),
    DateTime? postedAt,
    String? rawTitle,
    String? rawBody,
    Value<String?> accountId = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<String?> resolution = const Value.absent(),
  }) => PendingSuggestionRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    packageName: packageName ?? this.packageName,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    direction: direction ?? this.direction,
    balanceMinor: balanceMinor.present ? balanceMinor.value : this.balanceMinor,
    merchant: merchant.present ? merchant.value : this.merchant,
    postedAt: postedAt ?? this.postedAt,
    rawTitle: rawTitle ?? this.rawTitle,
    rawBody: rawBody ?? this.rawBody,
    accountId: accountId.present ? accountId.value : this.accountId,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    resolution: resolution.present ? resolution.value : this.resolution,
  );
  PendingSuggestionRow copyWithCompanion(PendingSuggestionsCompanion data) {
    return PendingSuggestionRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      direction: data.direction.present ? data.direction.value : this.direction,
      balanceMinor: data.balanceMinor.present
          ? data.balanceMinor.value
          : this.balanceMinor,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      postedAt: data.postedAt.present ? data.postedAt.value : this.postedAt,
      rawTitle: data.rawTitle.present ? data.rawTitle.value : this.rawTitle,
      rawBody: data.rawBody.present ? data.rawBody.value : this.rawBody,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSuggestionRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('packageName: $packageName, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('direction: $direction, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('merchant: $merchant, ')
          ..write('postedAt: $postedAt, ')
          ..write('rawTitle: $rawTitle, ')
          ..write('rawBody: $rawBody, ')
          ..write('accountId: $accountId, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    ruleId,
    packageName,
    amountMinor,
    currencyCode,
    direction,
    balanceMinor,
    merchant,
    postedAt,
    rawTitle,
    rawBody,
    accountId,
    resolvedAt,
    resolution,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSuggestionRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.packageName == this.packageName &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.direction == this.direction &&
          other.balanceMinor == this.balanceMinor &&
          other.merchant == this.merchant &&
          other.postedAt == this.postedAt &&
          other.rawTitle == this.rawTitle &&
          other.rawBody == this.rawBody &&
          other.accountId == this.accountId &&
          other.resolvedAt == this.resolvedAt &&
          other.resolution == this.resolution);
}

class PendingSuggestionsCompanion
    extends UpdateCompanion<PendingSuggestionRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> ruleId;
  final Value<String> packageName;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<String> direction;
  final Value<int?> balanceMinor;
  final Value<String?> merchant;
  final Value<DateTime> postedAt;
  final Value<String> rawTitle;
  final Value<String> rawBody;
  final Value<String?> accountId;
  final Value<DateTime?> resolvedAt;
  final Value<String?> resolution;
  final Value<int> rowid;
  const PendingSuggestionsCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.packageName = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.direction = const Value.absent(),
    this.balanceMinor = const Value.absent(),
    this.merchant = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.rawTitle = const Value.absent(),
    this.rawBody = const Value.absent(),
    this.accountId = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingSuggestionsCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String ruleId,
    required String packageName,
    required int amountMinor,
    required String currencyCode,
    required String direction,
    this.balanceMinor = const Value.absent(),
    this.merchant = const Value.absent(),
    required DateTime postedAt,
    this.rawTitle = const Value.absent(),
    this.rawBody = const Value.absent(),
    this.accountId = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.resolution = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ruleId = Value(ruleId),
       packageName = Value(packageName),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       direction = Value(direction),
       postedAt = Value(postedAt);
  static Insertable<PendingSuggestionRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? ruleId,
    Expression<String>? packageName,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? direction,
    Expression<int>? balanceMinor,
    Expression<String>? merchant,
    Expression<DateTime>? postedAt,
    Expression<String>? rawTitle,
    Expression<String>? rawBody,
    Expression<String>? accountId,
    Expression<DateTime>? resolvedAt,
    Expression<String>? resolution,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (packageName != null) 'package_name': packageName,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (direction != null) 'direction': direction,
      if (balanceMinor != null) 'balance_minor': balanceMinor,
      if (merchant != null) 'merchant': merchant,
      if (postedAt != null) 'posted_at': postedAt,
      if (rawTitle != null) 'raw_title': rawTitle,
      if (rawBody != null) 'raw_body': rawBody,
      if (accountId != null) 'account_id': accountId,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (resolution != null) 'resolution': resolution,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingSuggestionsCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? ruleId,
    Value<String>? packageName,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<String>? direction,
    Value<int?>? balanceMinor,
    Value<String?>? merchant,
    Value<DateTime>? postedAt,
    Value<String>? rawTitle,
    Value<String>? rawBody,
    Value<String?>? accountId,
    Value<DateTime?>? resolvedAt,
    Value<String?>? resolution,
    Value<int>? rowid,
  }) {
    return PendingSuggestionsCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      packageName: packageName ?? this.packageName,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      direction: direction ?? this.direction,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      merchant: merchant ?? this.merchant,
      postedAt: postedAt ?? this.postedAt,
      rawTitle: rawTitle ?? this.rawTitle,
      rawBody: rawBody ?? this.rawBody,
      accountId: accountId ?? this.accountId,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (balanceMinor.present) {
      map['balance_minor'] = Variable<int>(balanceMinor.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (postedAt.present) {
      map['posted_at'] = Variable<DateTime>(postedAt.value);
    }
    if (rawTitle.present) {
      map['raw_title'] = Variable<String>(rawTitle.value);
    }
    if (rawBody.present) {
      map['raw_body'] = Variable<String>(rawBody.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSuggestionsCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('packageName: $packageName, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('direction: $direction, ')
          ..write('balanceMinor: $balanceMinor, ')
          ..write('merchant: $merchant, ')
          ..write('postedAt: $postedAt, ')
          ..write('rawTitle: $rawTitle, ')
          ..write('rawBody: $rawBody, ')
          ..write('accountId: $accountId, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('resolution: $resolution, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnparsedSamplesTable extends UnparsedSamples
    with TableInfo<$UnparsedSamplesTable, UnparsedSampleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnparsedSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _postedAtMeta = const VerificationMeta(
    'postedAt',
  );
  @override
  late final GeneratedColumn<DateTime> postedAt = GeneratedColumn<DateTime>(
    'posted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sharedAtMeta = const VerificationMeta(
    'sharedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sharedAt = GeneratedColumn<DateTime>(
    'shared_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    createdAt,
    updatedAt,
    deletedAt,
    id,
    packageName,
    title,
    body,
    postedAt,
    sharedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unparsed_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnparsedSampleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('posted_at')) {
      context.handle(
        _postedAtMeta,
        postedAt.isAcceptableOrUnknown(data['posted_at']!, _postedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_postedAtMeta);
    }
    if (data.containsKey('shared_at')) {
      context.handle(
        _sharedAtMeta,
        sharedAt.isAcceptableOrUnknown(data['shared_at']!, _sharedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnparsedSampleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnparsedSampleRow(
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      postedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}posted_at'],
      )!,
      sharedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shared_at'],
      ),
    );
  }

  @override
  $UnparsedSamplesTable createAlias(String alias) {
    return $UnparsedSamplesTable(attachedDatabase, alias);
  }
}

class UnparsedSampleRow extends DataClass
    implements Insertable<UnparsedSampleRow> {
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String id;
  final String packageName;
  final String title;
  final String body;
  final DateTime postedAt;

  /// When the user shared it. Null means it has never left the device.
  final DateTime? sharedAt;
  const UnparsedSampleRow({
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.id,
    required this.packageName,
    required this.title,
    required this.body,
    required this.postedAt,
    this.sharedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['package_name'] = Variable<String>(packageName);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['posted_at'] = Variable<DateTime>(postedAt);
    if (!nullToAbsent || sharedAt != null) {
      map['shared_at'] = Variable<DateTime>(sharedAt);
    }
    return map;
  }

  UnparsedSamplesCompanion toCompanion(bool nullToAbsent) {
    return UnparsedSamplesCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      packageName: Value(packageName),
      title: Value(title),
      body: Value(body),
      postedAt: Value(postedAt),
      sharedAt: sharedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sharedAt),
    );
  }

  factory UnparsedSampleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnparsedSampleRow(
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      postedAt: serializer.fromJson<DateTime>(json['postedAt']),
      sharedAt: serializer.fromJson<DateTime?>(json['sharedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'packageName': serializer.toJson<String>(packageName),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'postedAt': serializer.toJson<DateTime>(postedAt),
      'sharedAt': serializer.toJson<DateTime?>(sharedAt),
    };
  }

  UnparsedSampleRow copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    String? packageName,
    String? title,
    String? body,
    DateTime? postedAt,
    Value<DateTime?> sharedAt = const Value.absent(),
  }) => UnparsedSampleRow(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    title: title ?? this.title,
    body: body ?? this.body,
    postedAt: postedAt ?? this.postedAt,
    sharedAt: sharedAt.present ? sharedAt.value : this.sharedAt,
  );
  UnparsedSampleRow copyWithCompanion(UnparsedSamplesCompanion data) {
    return UnparsedSampleRow(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      postedAt: data.postedAt.present ? data.postedAt.value : this.postedAt,
      sharedAt: data.sharedAt.present ? data.sharedAt.value : this.sharedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedSampleRow(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('postedAt: $postedAt, ')
          ..write('sharedAt: $sharedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    createdAt,
    updatedAt,
    deletedAt,
    id,
    packageName,
    title,
    body,
    postedAt,
    sharedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnparsedSampleRow &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.title == this.title &&
          other.body == this.body &&
          other.postedAt == this.postedAt &&
          other.sharedAt == this.sharedAt);
}

class UnparsedSamplesCompanion extends UpdateCompanion<UnparsedSampleRow> {
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<String> packageName;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> postedAt;
  final Value<DateTime?> sharedAt;
  final Value<int> rowid;
  const UnparsedSamplesCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.postedAt = const Value.absent(),
    this.sharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnparsedSamplesCompanion.insert({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String id,
    required String packageName,
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    required DateTime postedAt,
    this.sharedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packageName = Value(packageName),
       postedAt = Value(postedAt);
  static Insertable<UnparsedSampleRow> custom({
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<String>? packageName,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? postedAt,
    Expression<DateTime>? sharedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (postedAt != null) 'posted_at': postedAt,
      if (sharedAt != null) 'shared_at': sharedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnparsedSamplesCompanion copyWith({
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<String>? packageName,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? postedAt,
    Value<DateTime?>? sharedAt,
    Value<int>? rowid,
  }) {
    return UnparsedSamplesCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      body: body ?? this.body,
      postedAt: postedAt ?? this.postedAt,
      sharedAt: sharedAt ?? this.sharedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (postedAt.present) {
      map['posted_at'] = Variable<DateTime>(postedAt.value);
    }
    if (sharedAt.present) {
      map['shared_at'] = Variable<DateTime>(sharedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnparsedSamplesCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('postedAt: $postedAt, ')
          ..write('sharedAt: $sharedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $BalanceSnapshotsTable balanceSnapshots = $BalanceSnapshotsTable(
    this,
  );
  late final $DebtsTable debts = $DebtsTable(this);
  late final $DebtPaymentsTable debtPayments = $DebtPaymentsTable(this);
  late final $FxRatesTable fxRates = $FxRatesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $PendingSuggestionsTable pendingSuggestions =
      $PendingSuggestionsTable(this);
  late final $UnparsedSamplesTable unparsedSamples = $UnparsedSamplesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    balanceSnapshots,
    debts,
    debtPayments,
    fxRates,
    settings,
    pendingSuggestions,
    unparsedSamples,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('balance_snapshots', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'debts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('debt_payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pending_suggestions', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String name,
      Value<String?> institution,
      required String currencyCode,
      required String type,
      Value<int?> colorArgb,
      Value<String?> notes,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> name,
      Value<String?> institution,
      Value<String> currencyCode,
      Value<String> type,
      Value<int?> colorArgb,
      Value<String?> notes,
      Value<bool> isArchived,
      Value<int> rowid,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRow> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BalanceSnapshotsTable, List<BalanceSnapshotRow>>
  _balanceSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.balanceSnapshots,
    aliasName: 'accounts__id__balance_snapshots__account_id',
  );

  $$BalanceSnapshotsTableProcessedTableManager get balanceSnapshotsRefs {
    final manager = $$BalanceSnapshotsTableTableManager(
      $_db,
      $_db.balanceSnapshots,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _balanceSnapshotsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PendingSuggestionsTable,
    List<PendingSuggestionRow>
  >
  _pendingSuggestionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.pendingSuggestions,
        aliasName: 'accounts__id__pending_suggestions__account_id',
      );

  $$PendingSuggestionsTableProcessedTableManager get pendingSuggestionsRefs {
    final manager = $$PendingSuggestionsTableTableManager(
      $_db,
      $_db.pendingSuggestions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pendingSuggestionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> balanceSnapshotsRefs(
    Expression<bool> Function($$BalanceSnapshotsTableFilterComposer f) f,
  ) {
    final $$BalanceSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pendingSuggestionsRefs(
    Expression<bool> Function($$PendingSuggestionsTableFilterComposer f) f,
  ) {
    final $$PendingSuggestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pendingSuggestions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PendingSuggestionsTableFilterComposer(
            $db: $db,
            $table: $db.pendingSuggestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> balanceSnapshotsRefs<T extends Object>(
    Expression<T> Function($$BalanceSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$BalanceSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.balanceSnapshots,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BalanceSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.balanceSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pendingSuggestionsRefs<T extends Object>(
    Expression<T> Function($$PendingSuggestionsTableAnnotationComposer a) f,
  ) {
    final $$PendingSuggestionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.pendingSuggestions,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PendingSuggestionsTableAnnotationComposer(
                $db: $db,
                $table: $db.pendingSuggestions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRow, $$AccountsTableReferences),
          AccountRow,
          PrefetchHooks Function({
            bool balanceSnapshotsRefs,
            bool pendingSuggestionsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> institution = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> colorArgb = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                name: name,
                institution: institution,
                currencyCode: currencyCode,
                type: type,
                colorArgb: colorArgb,
                notes: notes,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String name,
                Value<String?> institution = const Value.absent(),
                required String currencyCode,
                required String type,
                Value<int?> colorArgb = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                name: name,
                institution: institution,
                currencyCode: currencyCode,
                type: type,
                colorArgb: colorArgb,
                notes: notes,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({balanceSnapshotsRefs = false, pendingSuggestionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (balanceSnapshotsRefs) db.balanceSnapshots,
                    if (pendingSuggestionsRefs) db.pendingSuggestions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (balanceSnapshotsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          BalanceSnapshotRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._balanceSnapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).balanceSnapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pendingSuggestionsRefs)
                        await $_getPrefetchedData<
                          AccountRow,
                          $AccountsTable,
                          PendingSuggestionRow
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._pendingSuggestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).pendingSuggestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, $$AccountsTableReferences),
      AccountRow,
      PrefetchHooks Function({
        bool balanceSnapshotsRefs,
        bool pendingSuggestionsRefs,
      })
    >;
typedef $$BalanceSnapshotsTableCreateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String accountId,
      required int amountMinor,
      required String currencyCode,
      required DateTime observedAt,
      required String source,
      Value<int> rowid,
    });
typedef $$BalanceSnapshotsTableUpdateCompanionBuilder =
    BalanceSnapshotsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> accountId,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<DateTime> observedAt,
      Value<String> source,
      Value<int> rowid,
    });

final class $$BalanceSnapshotsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshotRow
        > {
  $$BalanceSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('balance_snapshots__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BalanceSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BalanceSnapshotsTable> {
  $$BalanceSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get observedAt => $composableBuilder(
    column: $table.observedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BalanceSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BalanceSnapshotsTable,
          BalanceSnapshotRow,
          $$BalanceSnapshotsTableFilterComposer,
          $$BalanceSnapshotsTableOrderingComposer,
          $$BalanceSnapshotsTableAnnotationComposer,
          $$BalanceSnapshotsTableCreateCompanionBuilder,
          $$BalanceSnapshotsTableUpdateCompanionBuilder,
          (BalanceSnapshotRow, $$BalanceSnapshotsTableReferences),
          BalanceSnapshotRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$BalanceSnapshotsTableTableManager(
    _$AppDatabase db,
    $BalanceSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BalanceSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BalanceSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BalanceSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> observedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                accountId: accountId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                observedAt: observedAt,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String accountId,
                required int amountMinor,
                required String currencyCode,
                required DateTime observedAt,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => BalanceSnapshotsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                accountId: accountId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                observedAt: observedAt,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BalanceSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$BalanceSnapshotsTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$BalanceSnapshotsTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BalanceSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BalanceSnapshotsTable,
      BalanceSnapshotRow,
      $$BalanceSnapshotsTableFilterComposer,
      $$BalanceSnapshotsTableOrderingComposer,
      $$BalanceSnapshotsTableAnnotationComposer,
      $$BalanceSnapshotsTableCreateCompanionBuilder,
      $$BalanceSnapshotsTableUpdateCompanionBuilder,
      (BalanceSnapshotRow, $$BalanceSnapshotsTableReferences),
      BalanceSnapshotRow,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$DebtsTableCreateCompanionBuilder =
    DebtsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String counterparty,
      required String direction,
      required int principalMinor,
      required String currencyCode,
      required String homeCurrencyCode,
      required int rateAtCreationScaled,
      required DateTime createdOn,
      Value<DateTime?> dueOn,
      Value<DateTime?> settledAt,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$DebtsTableUpdateCompanionBuilder =
    DebtsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> counterparty,
      Value<String> direction,
      Value<int> principalMinor,
      Value<String> currencyCode,
      Value<String> homeCurrencyCode,
      Value<int> rateAtCreationScaled,
      Value<DateTime> createdOn,
      Value<DateTime?> dueOn,
      Value<DateTime?> settledAt,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$DebtsTableReferences
    extends BaseReferences<_$AppDatabase, $DebtsTable, DebtRow> {
  $$DebtsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DebtPaymentsTable, List<DebtPaymentRow>>
  _debtPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.debtPayments,
    aliasName: 'debts__id__debt_payments__debt_id',
  );

  $$DebtPaymentsTableProcessedTableManager get debtPaymentsRefs {
    final manager = $$DebtPaymentsTableTableManager(
      $_db,
      $_db.debtPayments,
    ).filter((f) => f.debtId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_debtPaymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DebtsTableFilterComposer extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get principalMinor => $composableBuilder(
    column: $table.principalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeCurrencyCode => $composableBuilder(
    column: $table.homeCurrencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateAtCreationScaled => $composableBuilder(
    column: $table.rateAtCreationScaled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> debtPaymentsRefs(
    Expression<bool> Function($$DebtPaymentsTableFilterComposer f) f,
  ) {
    final $$DebtPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtPayments,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.debtPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get principalMinor => $composableBuilder(
    column: $table.principalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeCurrencyCode => $composableBuilder(
    column: $table.homeCurrencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateAtCreationScaled => $composableBuilder(
    column: $table.rateAtCreationScaled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DebtsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtsTable> {
  $$DebtsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get counterparty => $composableBuilder(
    column: $table.counterparty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get principalMinor => $composableBuilder(
    column: $table.principalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeCurrencyCode => $composableBuilder(
    column: $table.homeCurrencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rateAtCreationScaled => $composableBuilder(
    column: $table.rateAtCreationScaled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  GeneratedColumn<DateTime> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> debtPaymentsRefs<T extends Object>(
    Expression<T> Function($$DebtPaymentsTableAnnotationComposer a) f,
  ) {
    final $$DebtPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debtPayments,
      getReferencedColumn: (t) => t.debtId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.debtPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DebtsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtsTable,
          DebtRow,
          $$DebtsTableFilterComposer,
          $$DebtsTableOrderingComposer,
          $$DebtsTableAnnotationComposer,
          $$DebtsTableCreateCompanionBuilder,
          $$DebtsTableUpdateCompanionBuilder,
          (DebtRow, $$DebtsTableReferences),
          DebtRow,
          PrefetchHooks Function({bool debtPaymentsRefs})
        > {
  $$DebtsTableTableManager(_$AppDatabase db, $DebtsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> counterparty = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int> principalMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> homeCurrencyCode = const Value.absent(),
                Value<int> rateAtCreationScaled = const Value.absent(),
                Value<DateTime> createdOn = const Value.absent(),
                Value<DateTime?> dueOn = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                counterparty: counterparty,
                direction: direction,
                principalMinor: principalMinor,
                currencyCode: currencyCode,
                homeCurrencyCode: homeCurrencyCode,
                rateAtCreationScaled: rateAtCreationScaled,
                createdOn: createdOn,
                dueOn: dueOn,
                settledAt: settledAt,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String counterparty,
                required String direction,
                required int principalMinor,
                required String currencyCode,
                required String homeCurrencyCode,
                required int rateAtCreationScaled,
                required DateTime createdOn,
                Value<DateTime?> dueOn = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                counterparty: counterparty,
                direction: direction,
                principalMinor: principalMinor,
                currencyCode: currencyCode,
                homeCurrencyCode: homeCurrencyCode,
                rateAtCreationScaled: rateAtCreationScaled,
                createdOn: createdOn,
                dueOn: dueOn,
                settledAt: settledAt,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DebtsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({debtPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (debtPaymentsRefs) db.debtPayments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (debtPaymentsRefs)
                    await $_getPrefetchedData<
                      DebtRow,
                      $DebtsTable,
                      DebtPaymentRow
                    >(
                      currentTable: table,
                      referencedTable: $$DebtsTableReferences
                          ._debtPaymentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$DebtsTableReferences(
                        db,
                        table,
                        p0,
                      ).debtPaymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.debtId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DebtsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtsTable,
      DebtRow,
      $$DebtsTableFilterComposer,
      $$DebtsTableOrderingComposer,
      $$DebtsTableAnnotationComposer,
      $$DebtsTableCreateCompanionBuilder,
      $$DebtsTableUpdateCompanionBuilder,
      (DebtRow, $$DebtsTableReferences),
      DebtRow,
      PrefetchHooks Function({bool debtPaymentsRefs})
    >;
typedef $$DebtPaymentsTableCreateCompanionBuilder =
    DebtPaymentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String debtId,
      required int amountMinor,
      required String currencyCode,
      required DateTime paidOn,
      required int rateAtPaymentScaled,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$DebtPaymentsTableUpdateCompanionBuilder =
    DebtPaymentsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> debtId,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<DateTime> paidOn,
      Value<int> rateAtPaymentScaled,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$DebtPaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $DebtPaymentsTable, DebtPaymentRow> {
  $$DebtPaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DebtsTable _debtIdTable(_$AppDatabase db) =>
      db.debts.createAlias('debt_payments__debt_id__debts__id');

  $$DebtsTableProcessedTableManager get debtId {
    final $_column = $_itemColumn<String>('debt_id')!;

    final manager = $$DebtsTableTableManager(
      $_db,
      $_db.debts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_debtIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DebtPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateAtPaymentScaled => $composableBuilder(
    column: $table.rateAtPaymentScaled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$DebtsTableFilterComposer get debtId {
    final $$DebtsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableFilterComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateAtPaymentScaled => $composableBuilder(
    column: $table.rateAtPaymentScaled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$DebtsTableOrderingComposer get debtId {
    final $$DebtsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableOrderingComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebtPaymentsTable> {
  $$DebtPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidOn =>
      $composableBuilder(column: $table.paidOn, builder: (column) => column);

  GeneratedColumn<int> get rateAtPaymentScaled => $composableBuilder(
    column: $table.rateAtPaymentScaled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$DebtsTableAnnotationComposer get debtId {
    final $$DebtsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.debtId,
      referencedTable: $db.debts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebtsTableAnnotationComposer(
            $db: $db,
            $table: $db.debts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebtPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebtPaymentsTable,
          DebtPaymentRow,
          $$DebtPaymentsTableFilterComposer,
          $$DebtPaymentsTableOrderingComposer,
          $$DebtPaymentsTableAnnotationComposer,
          $$DebtPaymentsTableCreateCompanionBuilder,
          $$DebtPaymentsTableUpdateCompanionBuilder,
          (DebtPaymentRow, $$DebtPaymentsTableReferences),
          DebtPaymentRow,
          PrefetchHooks Function({bool debtId})
        > {
  $$DebtPaymentsTableTableManager(_$AppDatabase db, $DebtPaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebtPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebtPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebtPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> debtId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> paidOn = const Value.absent(),
                Value<int> rateAtPaymentScaled = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                debtId: debtId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                paidOn: paidOn,
                rateAtPaymentScaled: rateAtPaymentScaled,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String debtId,
                required int amountMinor,
                required String currencyCode,
                required DateTime paidOn,
                required int rateAtPaymentScaled,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebtPaymentsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                debtId: debtId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                paidOn: paidOn,
                rateAtPaymentScaled: rateAtPaymentScaled,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DebtPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({debtId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (debtId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.debtId,
                                referencedTable: $$DebtPaymentsTableReferences
                                    ._debtIdTable(db),
                                referencedColumn: $$DebtPaymentsTableReferences
                                    ._debtIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DebtPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebtPaymentsTable,
      DebtPaymentRow,
      $$DebtPaymentsTableFilterComposer,
      $$DebtPaymentsTableOrderingComposer,
      $$DebtPaymentsTableAnnotationComposer,
      $$DebtPaymentsTableCreateCompanionBuilder,
      $$DebtPaymentsTableUpdateCompanionBuilder,
      (DebtPaymentRow, $$DebtPaymentsTableReferences),
      DebtPaymentRow,
      PrefetchHooks Function({bool debtId})
    >;
typedef $$FxRatesTableCreateCompanionBuilder =
    FxRatesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String baseCode,
      required String quoteCode,
      required int rateScaled,
      required DateTime rateDate,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$FxRatesTableUpdateCompanionBuilder =
    FxRatesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> baseCode,
      Value<String> quoteCode,
      Value<int> rateScaled,
      Value<DateTime> rateDate,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$FxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCode => $composableBuilder(
    column: $table.baseCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteCode => $composableBuilder(
    column: $table.quoteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateScaled => $composableBuilder(
    column: $table.rateScaled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCode => $composableBuilder(
    column: $table.baseCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteCode => $composableBuilder(
    column: $table.quoteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateScaled => $composableBuilder(
    column: $table.rateScaled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get baseCode =>
      $composableBuilder(column: $table.baseCode, builder: (column) => column);

  GeneratedColumn<String> get quoteCode =>
      $composableBuilder(column: $table.quoteCode, builder: (column) => column);

  GeneratedColumn<int> get rateScaled => $composableBuilder(
    column: $table.rateScaled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$FxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FxRatesTable,
          CachedFxRate,
          $$FxRatesTableFilterComposer,
          $$FxRatesTableOrderingComposer,
          $$FxRatesTableAnnotationComposer,
          $$FxRatesTableCreateCompanionBuilder,
          $$FxRatesTableUpdateCompanionBuilder,
          (
            CachedFxRate,
            BaseReferences<_$AppDatabase, $FxRatesTable, CachedFxRate>,
          ),
          CachedFxRate,
          PrefetchHooks Function()
        > {
  $$FxRatesTableTableManager(_$AppDatabase db, $FxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> baseCode = const Value.absent(),
                Value<String> quoteCode = const Value.absent(),
                Value<int> rateScaled = const Value.absent(),
                Value<DateTime> rateDate = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FxRatesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                baseCode: baseCode,
                quoteCode: quoteCode,
                rateScaled: rateScaled,
                rateDate: rateDate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String baseCode,
                required String quoteCode,
                required int rateScaled,
                required DateTime rateDate,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => FxRatesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                baseCode: baseCode,
                quoteCode: quoteCode,
                rateScaled: rateScaled,
                rateDate: rateDate,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FxRatesTable,
      CachedFxRate,
      $$FxRatesTableFilterComposer,
      $$FxRatesTableOrderingComposer,
      $$FxRatesTableAnnotationComposer,
      $$FxRatesTableCreateCompanionBuilder,
      $$FxRatesTableUpdateCompanionBuilder,
      (
        CachedFxRate,
        BaseReferences<_$AppDatabase, $FxRatesTable, CachedFxRate>,
      ),
      CachedFxRate,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$PendingSuggestionsTableCreateCompanionBuilder =
    PendingSuggestionsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String ruleId,
      required String packageName,
      required int amountMinor,
      required String currencyCode,
      required String direction,
      Value<int?> balanceMinor,
      Value<String?> merchant,
      required DateTime postedAt,
      Value<String> rawTitle,
      Value<String> rawBody,
      Value<String?> accountId,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });
typedef $$PendingSuggestionsTableUpdateCompanionBuilder =
    PendingSuggestionsCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> ruleId,
      Value<String> packageName,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<String> direction,
      Value<int?> balanceMinor,
      Value<String?> merchant,
      Value<DateTime> postedAt,
      Value<String> rawTitle,
      Value<String> rawBody,
      Value<String?> accountId,
      Value<DateTime?> resolvedAt,
      Value<String?> resolution,
      Value<int> rowid,
    });

final class $$PendingSuggestionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PendingSuggestionsTable,
          PendingSuggestionRow
        > {
  $$PendingSuggestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('pending_suggestions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PendingSuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSuggestionsTable> {
  $$PendingSuggestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get postedAt => $composableBuilder(
    column: $table.postedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawTitle => $composableBuilder(
    column: $table.rawTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawBody => $composableBuilder(
    column: $table.rawBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSuggestionsTable> {
  $$PendingSuggestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get postedAt => $composableBuilder(
    column: $table.postedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawTitle => $composableBuilder(
    column: $table.rawTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawBody => $composableBuilder(
    column: $table.rawBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSuggestionsTable> {
  $$PendingSuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get balanceMinor => $composableBuilder(
    column: $table.balanceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<DateTime> get postedAt =>
      $composableBuilder(column: $table.postedAt, builder: (column) => column);

  GeneratedColumn<String> get rawTitle =>
      $composableBuilder(column: $table.rawTitle, builder: (column) => column);

  GeneratedColumn<String> get rawBody =>
      $composableBuilder(column: $table.rawBody, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PendingSuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSuggestionsTable,
          PendingSuggestionRow,
          $$PendingSuggestionsTableFilterComposer,
          $$PendingSuggestionsTableOrderingComposer,
          $$PendingSuggestionsTableAnnotationComposer,
          $$PendingSuggestionsTableCreateCompanionBuilder,
          $$PendingSuggestionsTableUpdateCompanionBuilder,
          (PendingSuggestionRow, $$PendingSuggestionsTableReferences),
          PendingSuggestionRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$PendingSuggestionsTableTableManager(
    _$AppDatabase db,
    $PendingSuggestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSuggestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSuggestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<int?> balanceMinor = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<DateTime> postedAt = const Value.absent(),
                Value<String> rawTitle = const Value.absent(),
                Value<String> rawBody = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingSuggestionsCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                ruleId: ruleId,
                packageName: packageName,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                direction: direction,
                balanceMinor: balanceMinor,
                merchant: merchant,
                postedAt: postedAt,
                rawTitle: rawTitle,
                rawBody: rawBody,
                accountId: accountId,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String ruleId,
                required String packageName,
                required int amountMinor,
                required String currencyCode,
                required String direction,
                Value<int?> balanceMinor = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                required DateTime postedAt,
                Value<String> rawTitle = const Value.absent(),
                Value<String> rawBody = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingSuggestionsCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                ruleId: ruleId,
                packageName: packageName,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                direction: direction,
                balanceMinor: balanceMinor,
                merchant: merchant,
                postedAt: postedAt,
                rawTitle: rawTitle,
                rawBody: rawBody,
                accountId: accountId,
                resolvedAt: resolvedAt,
                resolution: resolution,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PendingSuggestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$PendingSuggestionsTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$PendingSuggestionsTableReferences
                                        ._accountIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PendingSuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSuggestionsTable,
      PendingSuggestionRow,
      $$PendingSuggestionsTableFilterComposer,
      $$PendingSuggestionsTableOrderingComposer,
      $$PendingSuggestionsTableAnnotationComposer,
      $$PendingSuggestionsTableCreateCompanionBuilder,
      $$PendingSuggestionsTableUpdateCompanionBuilder,
      (PendingSuggestionRow, $$PendingSuggestionsTableReferences),
      PendingSuggestionRow,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$UnparsedSamplesTableCreateCompanionBuilder =
    UnparsedSamplesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      required String id,
      required String packageName,
      Value<String> title,
      Value<String> body,
      required DateTime postedAt,
      Value<DateTime?> sharedAt,
      Value<int> rowid,
    });
typedef $$UnparsedSamplesTableUpdateCompanionBuilder =
    UnparsedSamplesCompanion Function({
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<String> packageName,
      Value<String> title,
      Value<String> body,
      Value<DateTime> postedAt,
      Value<DateTime?> sharedAt,
      Value<int> rowid,
    });

class $$UnparsedSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $UnparsedSamplesTable> {
  $$UnparsedSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get postedAt => $composableBuilder(
    column: $table.postedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sharedAt => $composableBuilder(
    column: $table.sharedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnparsedSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $UnparsedSamplesTable> {
  $$UnparsedSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get postedAt => $composableBuilder(
    column: $table.postedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sharedAt => $composableBuilder(
    column: $table.sharedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnparsedSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnparsedSamplesTable> {
  $$UnparsedSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get postedAt =>
      $composableBuilder(column: $table.postedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sharedAt =>
      $composableBuilder(column: $table.sharedAt, builder: (column) => column);
}

class $$UnparsedSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnparsedSamplesTable,
          UnparsedSampleRow,
          $$UnparsedSamplesTableFilterComposer,
          $$UnparsedSamplesTableOrderingComposer,
          $$UnparsedSamplesTableAnnotationComposer,
          $$UnparsedSamplesTableCreateCompanionBuilder,
          $$UnparsedSamplesTableUpdateCompanionBuilder,
          (
            UnparsedSampleRow,
            BaseReferences<
              _$AppDatabase,
              $UnparsedSamplesTable,
              UnparsedSampleRow
            >,
          ),
          UnparsedSampleRow,
          PrefetchHooks Function()
        > {
  $$UnparsedSamplesTableTableManager(
    _$AppDatabase db,
    $UnparsedSamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnparsedSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnparsedSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnparsedSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> postedAt = const Value.absent(),
                Value<DateTime?> sharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnparsedSamplesCompanion(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                packageName: packageName,
                title: title,
                body: body,
                postedAt: postedAt,
                sharedAt: sharedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required String id,
                required String packageName,
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                required DateTime postedAt,
                Value<DateTime?> sharedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnparsedSamplesCompanion.insert(
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                id: id,
                packageName: packageName,
                title: title,
                body: body,
                postedAt: postedAt,
                sharedAt: sharedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnparsedSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnparsedSamplesTable,
      UnparsedSampleRow,
      $$UnparsedSamplesTableFilterComposer,
      $$UnparsedSamplesTableOrderingComposer,
      $$UnparsedSamplesTableAnnotationComposer,
      $$UnparsedSamplesTableCreateCompanionBuilder,
      $$UnparsedSamplesTableUpdateCompanionBuilder,
      (
        UnparsedSampleRow,
        BaseReferences<_$AppDatabase, $UnparsedSamplesTable, UnparsedSampleRow>,
      ),
      UnparsedSampleRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$BalanceSnapshotsTableTableManager get balanceSnapshots =>
      $$BalanceSnapshotsTableTableManager(_db, _db.balanceSnapshots);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db, _db.debts);
  $$DebtPaymentsTableTableManager get debtPayments =>
      $$DebtPaymentsTableTableManager(_db, _db.debtPayments);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db, _db.fxRates);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PendingSuggestionsTableTableManager get pendingSuggestions =>
      $$PendingSuggestionsTableTableManager(_db, _db.pendingSuggestions);
  $$UnparsedSamplesTableTableManager get unparsedSamples =>
      $$UnparsedSamplesTableTableManager(_db, _db.unparsedSamples);
}
