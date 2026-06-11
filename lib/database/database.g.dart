// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CapturesTable extends Captures with TableInfo<$CapturesTable, Capture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _rawInputMeta = const VerificationMeta(
    'rawInput',
  );
  @override
  late final GeneratedColumn<String> rawInput = GeneratedColumn<String>(
    'raw_input',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAiProcessedMeta = const VerificationMeta(
    'isAiProcessed',
  );
  @override
  late final GeneratedColumn<bool> isAiProcessed = GeneratedColumn<bool>(
    'is_ai_processed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ai_processed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    rawInput,
    content,
    amount,
    category,
    scheduledAt,
    isCompleted,
    audioPath,
    createdAt,
    isSynced,
    isAiProcessed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'captures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Capture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('raw_input')) {
      context.handle(
        _rawInputMeta,
        rawInput.isAcceptableOrUnknown(data['raw_input']!, _rawInputMeta),
      );
    } else if (isInserting) {
      context.missing(_rawInputMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_ai_processed')) {
      context.handle(
        _isAiProcessedMeta,
        isAiProcessed.isAcceptableOrUnknown(
          data['is_ai_processed']!,
          _isAiProcessedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Capture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Capture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      rawInput: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_input'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isAiProcessed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ai_processed'],
      )!,
    );
  }

  @override
  $CapturesTable createAlias(String alias) {
    return $CapturesTable(attachedDatabase, alias);
  }
}

class Capture extends DataClass implements Insertable<Capture> {
  final int id;
  final String type;
  final String rawInput;
  final String content;
  final double? amount;
  final String? category;
  final DateTime? scheduledAt;
  final bool isCompleted;
  final String? audioPath;
  final DateTime createdAt;
  final bool isSynced;
  final bool isAiProcessed;
  const Capture({
    required this.id,
    required this.type,
    required this.rawInput,
    required this.content,
    this.amount,
    this.category,
    this.scheduledAt,
    required this.isCompleted,
    this.audioPath,
    required this.createdAt,
    required this.isSynced,
    required this.isAiProcessed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['raw_input'] = Variable<String>(rawInput);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_ai_processed'] = Variable<bool>(isAiProcessed);
    return map;
  }

  CapturesCompanion toCompanion(bool nullToAbsent) {
    return CapturesCompanion(
      id: Value(id),
      type: Value(type),
      rawInput: Value(rawInput),
      content: Value(content),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      isCompleted: Value(isCompleted),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
      isAiProcessed: Value(isAiProcessed),
    );
  }

  factory Capture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Capture(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      rawInput: serializer.fromJson<String>(json['rawInput']),
      content: serializer.fromJson<String>(json['content']),
      amount: serializer.fromJson<double?>(json['amount']),
      category: serializer.fromJson<String?>(json['category']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isAiProcessed: serializer.fromJson<bool>(json['isAiProcessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'rawInput': serializer.toJson<String>(rawInput),
      'content': serializer.toJson<String>(content),
      'amount': serializer.toJson<double?>(amount),
      'category': serializer.toJson<String?>(category),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'audioPath': serializer.toJson<String?>(audioPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isAiProcessed': serializer.toJson<bool>(isAiProcessed),
    };
  }

  Capture copyWith({
    int? id,
    String? type,
    String? rawInput,
    String? content,
    Value<double?> amount = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<DateTime?> scheduledAt = const Value.absent(),
    bool? isCompleted,
    Value<String?> audioPath = const Value.absent(),
    DateTime? createdAt,
    bool? isSynced,
    bool? isAiProcessed,
  }) => Capture(
    id: id ?? this.id,
    type: type ?? this.type,
    rawInput: rawInput ?? this.rawInput,
    content: content ?? this.content,
    amount: amount.present ? amount.value : this.amount,
    category: category.present ? category.value : this.category,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    isCompleted: isCompleted ?? this.isCompleted,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
    isAiProcessed: isAiProcessed ?? this.isAiProcessed,
  );
  Capture copyWithCompanion(CapturesCompanion data) {
    return Capture(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      rawInput: data.rawInput.present ? data.rawInput.value : this.rawInput,
      content: data.content.present ? data.content.value : this.content,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isAiProcessed: data.isAiProcessed.present
          ? data.isAiProcessed.value
          : this.isAiProcessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Capture(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rawInput: $rawInput, ')
          ..write('content: $content, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isAiProcessed: $isAiProcessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    rawInput,
    content,
    amount,
    category,
    scheduledAt,
    isCompleted,
    audioPath,
    createdAt,
    isSynced,
    isAiProcessed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Capture &&
          other.id == this.id &&
          other.type == this.type &&
          other.rawInput == this.rawInput &&
          other.content == this.content &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.scheduledAt == this.scheduledAt &&
          other.isCompleted == this.isCompleted &&
          other.audioPath == this.audioPath &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced &&
          other.isAiProcessed == this.isAiProcessed);
}

class CapturesCompanion extends UpdateCompanion<Capture> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> rawInput;
  final Value<String> content;
  final Value<double?> amount;
  final Value<String?> category;
  final Value<DateTime?> scheduledAt;
  final Value<bool> isCompleted;
  final Value<String?> audioPath;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<bool> isAiProcessed;
  const CapturesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.rawInput = const Value.absent(),
    this.content = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isAiProcessed = const Value.absent(),
  });
  CapturesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String rawInput,
    required String content,
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.audioPath = const Value.absent(),
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
    this.isAiProcessed = const Value.absent(),
  }) : type = Value(type),
       rawInput = Value(rawInput),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Capture> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? rawInput,
    Expression<String>? content,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<DateTime>? scheduledAt,
    Expression<bool>? isCompleted,
    Expression<String>? audioPath,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<bool>? isAiProcessed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (rawInput != null) 'raw_input': rawInput,
      if (content != null) 'content': content,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (audioPath != null) 'audio_path': audioPath,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (isAiProcessed != null) 'is_ai_processed': isAiProcessed,
    });
  }

  CapturesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? rawInput,
    Value<String>? content,
    Value<double?>? amount,
    Value<String?>? category,
    Value<DateTime?>? scheduledAt,
    Value<bool>? isCompleted,
    Value<String?>? audioPath,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
    Value<bool>? isAiProcessed,
  }) {
    return CapturesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      rawInput: rawInput ?? this.rawInput,
      content: content ?? this.content,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      isAiProcessed: isAiProcessed ?? this.isAiProcessed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rawInput.present) {
      map['raw_input'] = Variable<String>(rawInput.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isAiProcessed.present) {
      map['is_ai_processed'] = Variable<bool>(isAiProcessed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapturesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('rawInput: $rawInput, ')
          ..write('content: $content, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('audioPath: $audioPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('isAiProcessed: $isAiProcessed')
          ..write(')'))
        .toString();
  }
}

abstract class _$TimboDatabase extends GeneratedDatabase {
  _$TimboDatabase(QueryExecutor e) : super(e);
  $TimboDatabaseManager get managers => $TimboDatabaseManager(this);
  late final $CapturesTable captures = $CapturesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [captures];
}

typedef $$CapturesTableCreateCompanionBuilder =
    CapturesCompanion Function({
      Value<int> id,
      required String type,
      required String rawInput,
      required String content,
      Value<double?> amount,
      Value<String?> category,
      Value<DateTime?> scheduledAt,
      Value<bool> isCompleted,
      Value<String?> audioPath,
      required DateTime createdAt,
      Value<bool> isSynced,
      Value<bool> isAiProcessed,
    });
typedef $$CapturesTableUpdateCompanionBuilder =
    CapturesCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> rawInput,
      Value<String> content,
      Value<double?> amount,
      Value<String?> category,
      Value<DateTime?> scheduledAt,
      Value<bool> isCompleted,
      Value<String?> audioPath,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<bool> isAiProcessed,
    });

class $$CapturesTableFilterComposer
    extends Composer<_$TimboDatabase, $CapturesTable> {
  $$CapturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawInput => $composableBuilder(
    column: $table.rawInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAiProcessed => $composableBuilder(
    column: $table.isAiProcessed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapturesTableOrderingComposer
    extends Composer<_$TimboDatabase, $CapturesTable> {
  $$CapturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawInput => $composableBuilder(
    column: $table.rawInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAiProcessed => $composableBuilder(
    column: $table.isAiProcessed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapturesTableAnnotationComposer
    extends Composer<_$TimboDatabase, $CapturesTable> {
  $$CapturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get rawInput =>
      $composableBuilder(column: $table.rawInput, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isAiProcessed => $composableBuilder(
    column: $table.isAiProcessed,
    builder: (column) => column,
  );
}

class $$CapturesTableTableManager
    extends
        RootTableManager<
          _$TimboDatabase,
          $CapturesTable,
          Capture,
          $$CapturesTableFilterComposer,
          $$CapturesTableOrderingComposer,
          $$CapturesTableAnnotationComposer,
          $$CapturesTableCreateCompanionBuilder,
          $$CapturesTableUpdateCompanionBuilder,
          (Capture, BaseReferences<_$TimboDatabase, $CapturesTable, Capture>),
          Capture,
          PrefetchHooks Function()
        > {
  $$CapturesTableTableManager(_$TimboDatabase db, $CapturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> rawInput = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isAiProcessed = const Value.absent(),
              }) => CapturesCompanion(
                id: id,
                type: type,
                rawInput: rawInput,
                content: content,
                amount: amount,
                category: category,
                scheduledAt: scheduledAt,
                isCompleted: isCompleted,
                audioPath: audioPath,
                createdAt: createdAt,
                isSynced: isSynced,
                isAiProcessed: isAiProcessed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String rawInput,
                required String content,
                Value<double?> amount = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isAiProcessed = const Value.absent(),
              }) => CapturesCompanion.insert(
                id: id,
                type: type,
                rawInput: rawInput,
                content: content,
                amount: amount,
                category: category,
                scheduledAt: scheduledAt,
                isCompleted: isCompleted,
                audioPath: audioPath,
                createdAt: createdAt,
                isSynced: isSynced,
                isAiProcessed: isAiProcessed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CapturesTableProcessedTableManager =
    ProcessedTableManager<
      _$TimboDatabase,
      $CapturesTable,
      Capture,
      $$CapturesTableFilterComposer,
      $$CapturesTableOrderingComposer,
      $$CapturesTableAnnotationComposer,
      $$CapturesTableCreateCompanionBuilder,
      $$CapturesTableUpdateCompanionBuilder,
      (Capture, BaseReferences<_$TimboDatabase, $CapturesTable, Capture>),
      Capture,
      PrefetchHooks Function()
    >;

class $TimboDatabaseManager {
  final _$TimboDatabase _db;
  $TimboDatabaseManager(this._db);
  $$CapturesTableTableManager get captures =>
      $$CapturesTableTableManager(_db, _db.captures);
}
