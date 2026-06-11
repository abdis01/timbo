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

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, title, date, createdAt, isSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String title;
  final DateTime date;
  final DateTime createdAt;
  final bool isSynced;
  const Folder({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Folder copyWith({
    int? id,
    String? title,
    DateTime? date,
    DateTime? createdAt,
    bool? isSynced,
  }) => Folder(
    id: id ?? this.id,
    title: title ?? this.title,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, date, createdAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime date,
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
  }) : title = Value(title),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $TimbosTable extends Timbos with TableInfo<$TimbosTable, Timbo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimbosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTimestampMeta = const VerificationMeta(
    'reminderTimestamp',
  );
  @override
  late final GeneratedColumn<int> reminderTimestamp = GeneratedColumn<int>(
    'reminder_timestamp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderLabelMeta = const VerificationMeta(
    'reminderLabel',
  );
  @override
  late final GeneratedColumn<String> reminderLabel = GeneratedColumn<String>(
    'reminder_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderSetMeta = const VerificationMeta(
    'reminderSet',
  );
  @override
  late final GeneratedColumn<bool> reminderSet = GeneratedColumn<bool>(
    'reminder_set',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_set" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    title,
    createdAt,
    updatedAt,
    reminderTimestamp,
    reminderLabel,
    reminderSet,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timbos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Timbo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('reminder_timestamp')) {
      context.handle(
        _reminderTimestampMeta,
        reminderTimestamp.isAcceptableOrUnknown(
          data['reminder_timestamp']!,
          _reminderTimestampMeta,
        ),
      );
    }
    if (data.containsKey('reminder_label')) {
      context.handle(
        _reminderLabelMeta,
        reminderLabel.isAcceptableOrUnknown(
          data['reminder_label']!,
          _reminderLabelMeta,
        ),
      );
    }
    if (data.containsKey('reminder_set')) {
      context.handle(
        _reminderSetMeta,
        reminderSet.isAcceptableOrUnknown(
          data['reminder_set']!,
          _reminderSetMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Timbo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Timbo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      reminderTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_timestamp'],
      ),
      reminderLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_label'],
      ),
      reminderSet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_set'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $TimbosTable createAlias(String alias) {
    return $TimbosTable(attachedDatabase, alias);
  }
}

class Timbo extends DataClass implements Insertable<Timbo> {
  final int id;
  final int folderId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? reminderTimestamp;
  final String? reminderLabel;
  final bool reminderSet;
  final bool isSynced;
  const Timbo({
    required this.id,
    required this.folderId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.reminderTimestamp,
    this.reminderLabel,
    required this.reminderSet,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folder_id'] = Variable<int>(folderId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || reminderTimestamp != null) {
      map['reminder_timestamp'] = Variable<int>(reminderTimestamp);
    }
    if (!nullToAbsent || reminderLabel != null) {
      map['reminder_label'] = Variable<String>(reminderLabel);
    }
    map['reminder_set'] = Variable<bool>(reminderSet);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  TimbosCompanion toCompanion(bool nullToAbsent) {
    return TimbosCompanion(
      id: Value(id),
      folderId: Value(folderId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      reminderTimestamp: reminderTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTimestamp),
      reminderLabel: reminderLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderLabel),
      reminderSet: Value(reminderSet),
      isSynced: Value(isSynced),
    );
  }

  factory Timbo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Timbo(
      id: serializer.fromJson<int>(json['id']),
      folderId: serializer.fromJson<int>(json['folderId']),
      title: serializer.fromJson<String?>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      reminderTimestamp: serializer.fromJson<int?>(json['reminderTimestamp']),
      reminderLabel: serializer.fromJson<String?>(json['reminderLabel']),
      reminderSet: serializer.fromJson<bool>(json['reminderSet']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folderId': serializer.toJson<int>(folderId),
      'title': serializer.toJson<String?>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'reminderTimestamp': serializer.toJson<int?>(reminderTimestamp),
      'reminderLabel': serializer.toJson<String?>(reminderLabel),
      'reminderSet': serializer.toJson<bool>(reminderSet),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Timbo copyWith({
    int? id,
    int? folderId,
    Value<String?> title = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> reminderTimestamp = const Value.absent(),
    Value<String?> reminderLabel = const Value.absent(),
    bool? reminderSet,
    bool? isSynced,
  }) => Timbo(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    title: title.present ? title.value : this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    reminderTimestamp: reminderTimestamp.present
        ? reminderTimestamp.value
        : this.reminderTimestamp,
    reminderLabel: reminderLabel.present
        ? reminderLabel.value
        : this.reminderLabel,
    reminderSet: reminderSet ?? this.reminderSet,
    isSynced: isSynced ?? this.isSynced,
  );
  Timbo copyWithCompanion(TimbosCompanion data) {
    return Timbo(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      reminderTimestamp: data.reminderTimestamp.present
          ? data.reminderTimestamp.value
          : this.reminderTimestamp,
      reminderLabel: data.reminderLabel.present
          ? data.reminderLabel.value
          : this.reminderLabel,
      reminderSet: data.reminderSet.present
          ? data.reminderSet.value
          : this.reminderSet,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Timbo(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('reminderTimestamp: $reminderTimestamp, ')
          ..write('reminderLabel: $reminderLabel, ')
          ..write('reminderSet: $reminderSet, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    folderId,
    title,
    createdAt,
    updatedAt,
    reminderTimestamp,
    reminderLabel,
    reminderSet,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Timbo &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.reminderTimestamp == this.reminderTimestamp &&
          other.reminderLabel == this.reminderLabel &&
          other.reminderSet == this.reminderSet &&
          other.isSynced == this.isSynced);
}

class TimbosCompanion extends UpdateCompanion<Timbo> {
  final Value<int> id;
  final Value<int> folderId;
  final Value<String?> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> reminderTimestamp;
  final Value<String?> reminderLabel;
  final Value<bool> reminderSet;
  final Value<bool> isSynced;
  const TimbosCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.reminderTimestamp = const Value.absent(),
    this.reminderLabel = const Value.absent(),
    this.reminderSet = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  TimbosCompanion.insert({
    this.id = const Value.absent(),
    required int folderId,
    this.title = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.reminderTimestamp = const Value.absent(),
    this.reminderLabel = const Value.absent(),
    this.reminderSet = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : folderId = Value(folderId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Timbo> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? reminderTimestamp,
    Expression<String>? reminderLabel,
    Expression<bool>? reminderSet,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (reminderTimestamp != null) 'reminder_timestamp': reminderTimestamp,
      if (reminderLabel != null) 'reminder_label': reminderLabel,
      if (reminderSet != null) 'reminder_set': reminderSet,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  TimbosCompanion copyWith({
    Value<int>? id,
    Value<int>? folderId,
    Value<String?>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? reminderTimestamp,
    Value<String?>? reminderLabel,
    Value<bool>? reminderSet,
    Value<bool>? isSynced,
  }) {
    return TimbosCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderTimestamp: reminderTimestamp ?? this.reminderTimestamp,
      reminderLabel: reminderLabel ?? this.reminderLabel,
      reminderSet: reminderSet ?? this.reminderSet,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (reminderTimestamp.present) {
      map['reminder_timestamp'] = Variable<int>(reminderTimestamp.value);
    }
    if (reminderLabel.present) {
      map['reminder_label'] = Variable<String>(reminderLabel.value);
    }
    if (reminderSet.present) {
      map['reminder_set'] = Variable<bool>(reminderSet.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimbosCompanion(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('reminderTimestamp: $reminderTimestamp, ')
          ..write('reminderLabel: $reminderLabel, ')
          ..write('reminderSet: $reminderSet, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $BlocksTable extends Blocks with TableInfo<$BlocksTable, Block> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlocksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _timboIdMeta = const VerificationMeta(
    'timboId',
  );
  @override
  late final GeneratedColumn<int> timboId = GeneratedColumn<int>(
    'timbo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timbos (id)',
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textContentMeta = const VerificationMeta(
    'textContent',
  );
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
    'text_content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checklistJsonMeta = const VerificationMeta(
    'checklistJson',
  );
  @override
  late final GeneratedColumn<String> checklistJson = GeneratedColumn<String>(
    'checklist_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drawingDataMeta = const VerificationMeta(
    'drawingData',
  );
  @override
  late final GeneratedColumn<String> drawingData = GeneratedColumn<String>(
    'drawing_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fontFamilyMeta = const VerificationMeta(
    'fontFamily',
  );
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
    'font_family',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionXMeta = const VerificationMeta(
    'positionX',
  );
  @override
  late final GeneratedColumn<double> positionX = GeneratedColumn<double>(
    'position_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionYMeta = const VerificationMeta(
    'positionY',
  );
  @override
  late final GeneratedColumn<double> positionY = GeneratedColumn<double>(
    'position_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockWidthMeta = const VerificationMeta(
    'blockWidth',
  );
  @override
  late final GeneratedColumn<double> blockWidth = GeneratedColumn<double>(
    'block_width',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockHeightMeta = const VerificationMeta(
    'blockHeight',
  );
  @override
  late final GeneratedColumn<double> blockHeight = GeneratedColumn<double>(
    'block_height',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timboId,
    type,
    sortOrder,
    textContent,
    filePath,
    checklistJson,
    drawingData,
    fontFamily,
    positionX,
    positionY,
    blockWidth,
    blockHeight,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Block> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timbo_id')) {
      context.handle(
        _timboIdMeta,
        timboId.isAcceptableOrUnknown(data['timbo_id']!, _timboIdMeta),
      );
    } else if (isInserting) {
      context.missing(_timboIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
        _textContentMeta,
        textContent.isAcceptableOrUnknown(
          data['text_content']!,
          _textContentMeta,
        ),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('checklist_json')) {
      context.handle(
        _checklistJsonMeta,
        checklistJson.isAcceptableOrUnknown(
          data['checklist_json']!,
          _checklistJsonMeta,
        ),
      );
    }
    if (data.containsKey('drawing_data')) {
      context.handle(
        _drawingDataMeta,
        drawingData.isAcceptableOrUnknown(
          data['drawing_data']!,
          _drawingDataMeta,
        ),
      );
    }
    if (data.containsKey('font_family')) {
      context.handle(
        _fontFamilyMeta,
        fontFamily.isAcceptableOrUnknown(data['font_family']!, _fontFamilyMeta),
      );
    }
    if (data.containsKey('position_x')) {
      context.handle(
        _positionXMeta,
        positionX.isAcceptableOrUnknown(data['position_x']!, _positionXMeta),
      );
    }
    if (data.containsKey('position_y')) {
      context.handle(
        _positionYMeta,
        positionY.isAcceptableOrUnknown(data['position_y']!, _positionYMeta),
      );
    }
    if (data.containsKey('block_width')) {
      context.handle(
        _blockWidthMeta,
        blockWidth.isAcceptableOrUnknown(data['block_width']!, _blockWidthMeta),
      );
    }
    if (data.containsKey('block_height')) {
      context.handle(
        _blockHeightMeta,
        blockHeight.isAcceptableOrUnknown(
          data['block_height']!,
          _blockHeightMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Block map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Block(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timboId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timbo_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      textContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_content'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      checklistJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checklist_json'],
      ),
      drawingData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drawing_data'],
      ),
      fontFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}font_family'],
      ),
      positionX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_x'],
      ),
      positionY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_y'],
      ),
      blockWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}block_width'],
      ),
      blockHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}block_height'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $BlocksTable createAlias(String alias) {
    return $BlocksTable(attachedDatabase, alias);
  }
}

class Block extends DataClass implements Insertable<Block> {
  final int id;
  final int timboId;
  final String type;
  final int sortOrder;
  final String? textContent;
  final String? filePath;
  final String? checklistJson;
  final String? drawingData;
  final String? fontFamily;
  final double? positionX;
  final double? positionY;
  final double? blockWidth;
  final double? blockHeight;
  final DateTime createdAt;
  final bool isSynced;
  const Block({
    required this.id,
    required this.timboId,
    required this.type,
    required this.sortOrder,
    this.textContent,
    this.filePath,
    this.checklistJson,
    this.drawingData,
    this.fontFamily,
    this.positionX,
    this.positionY,
    this.blockWidth,
    this.blockHeight,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timbo_id'] = Variable<int>(timboId);
    map['type'] = Variable<String>(type);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || checklistJson != null) {
      map['checklist_json'] = Variable<String>(checklistJson);
    }
    if (!nullToAbsent || drawingData != null) {
      map['drawing_data'] = Variable<String>(drawingData);
    }
    if (!nullToAbsent || fontFamily != null) {
      map['font_family'] = Variable<String>(fontFamily);
    }
    if (!nullToAbsent || positionX != null) {
      map['position_x'] = Variable<double>(positionX);
    }
    if (!nullToAbsent || positionY != null) {
      map['position_y'] = Variable<double>(positionY);
    }
    if (!nullToAbsent || blockWidth != null) {
      map['block_width'] = Variable<double>(blockWidth);
    }
    if (!nullToAbsent || blockHeight != null) {
      map['block_height'] = Variable<double>(blockHeight);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  BlocksCompanion toCompanion(bool nullToAbsent) {
    return BlocksCompanion(
      id: Value(id),
      timboId: Value(timboId),
      type: Value(type),
      sortOrder: Value(sortOrder),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      checklistJson: checklistJson == null && nullToAbsent
          ? const Value.absent()
          : Value(checklistJson),
      drawingData: drawingData == null && nullToAbsent
          ? const Value.absent()
          : Value(drawingData),
      fontFamily: fontFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(fontFamily),
      positionX: positionX == null && nullToAbsent
          ? const Value.absent()
          : Value(positionX),
      positionY: positionY == null && nullToAbsent
          ? const Value.absent()
          : Value(positionY),
      blockWidth: blockWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(blockWidth),
      blockHeight: blockHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(blockHeight),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory Block.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Block(
      id: serializer.fromJson<int>(json['id']),
      timboId: serializer.fromJson<int>(json['timboId']),
      type: serializer.fromJson<String>(json['type']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      checklistJson: serializer.fromJson<String?>(json['checklistJson']),
      drawingData: serializer.fromJson<String?>(json['drawingData']),
      fontFamily: serializer.fromJson<String?>(json['fontFamily']),
      positionX: serializer.fromJson<double?>(json['positionX']),
      positionY: serializer.fromJson<double?>(json['positionY']),
      blockWidth: serializer.fromJson<double?>(json['blockWidth']),
      blockHeight: serializer.fromJson<double?>(json['blockHeight']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timboId': serializer.toJson<int>(timboId),
      'type': serializer.toJson<String>(type),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'textContent': serializer.toJson<String?>(textContent),
      'filePath': serializer.toJson<String?>(filePath),
      'checklistJson': serializer.toJson<String?>(checklistJson),
      'drawingData': serializer.toJson<String?>(drawingData),
      'fontFamily': serializer.toJson<String?>(fontFamily),
      'positionX': serializer.toJson<double?>(positionX),
      'positionY': serializer.toJson<double?>(positionY),
      'blockWidth': serializer.toJson<double?>(blockWidth),
      'blockHeight': serializer.toJson<double?>(blockHeight),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Block copyWith({
    int? id,
    int? timboId,
    String? type,
    int? sortOrder,
    Value<String?> textContent = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    Value<String?> checklistJson = const Value.absent(),
    Value<String?> drawingData = const Value.absent(),
    Value<String?> fontFamily = const Value.absent(),
    Value<double?> positionX = const Value.absent(),
    Value<double?> positionY = const Value.absent(),
    Value<double?> blockWidth = const Value.absent(),
    Value<double?> blockHeight = const Value.absent(),
    DateTime? createdAt,
    bool? isSynced,
  }) => Block(
    id: id ?? this.id,
    timboId: timboId ?? this.timboId,
    type: type ?? this.type,
    sortOrder: sortOrder ?? this.sortOrder,
    textContent: textContent.present ? textContent.value : this.textContent,
    filePath: filePath.present ? filePath.value : this.filePath,
    checklistJson: checklistJson.present
        ? checklistJson.value
        : this.checklistJson,
    drawingData: drawingData.present ? drawingData.value : this.drawingData,
    fontFamily: fontFamily.present ? fontFamily.value : this.fontFamily,
    positionX: positionX.present ? positionX.value : this.positionX,
    positionY: positionY.present ? positionY.value : this.positionY,
    blockWidth: blockWidth.present ? blockWidth.value : this.blockWidth,
    blockHeight: blockHeight.present ? blockHeight.value : this.blockHeight,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Block copyWithCompanion(BlocksCompanion data) {
    return Block(
      id: data.id.present ? data.id.value : this.id,
      timboId: data.timboId.present ? data.timboId.value : this.timboId,
      type: data.type.present ? data.type.value : this.type,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      textContent: data.textContent.present
          ? data.textContent.value
          : this.textContent,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      checklistJson: data.checklistJson.present
          ? data.checklistJson.value
          : this.checklistJson,
      drawingData: data.drawingData.present
          ? data.drawingData.value
          : this.drawingData,
      fontFamily: data.fontFamily.present
          ? data.fontFamily.value
          : this.fontFamily,
      positionX: data.positionX.present ? data.positionX.value : this.positionX,
      positionY: data.positionY.present ? data.positionY.value : this.positionY,
      blockWidth: data.blockWidth.present
          ? data.blockWidth.value
          : this.blockWidth,
      blockHeight: data.blockHeight.present
          ? data.blockHeight.value
          : this.blockHeight,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Block(')
          ..write('id: $id, ')
          ..write('timboId: $timboId, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('textContent: $textContent, ')
          ..write('filePath: $filePath, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('drawingData: $drawingData, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('blockWidth: $blockWidth, ')
          ..write('blockHeight: $blockHeight, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timboId,
    type,
    sortOrder,
    textContent,
    filePath,
    checklistJson,
    drawingData,
    fontFamily,
    positionX,
    positionY,
    blockWidth,
    blockHeight,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Block &&
          other.id == this.id &&
          other.timboId == this.timboId &&
          other.type == this.type &&
          other.sortOrder == this.sortOrder &&
          other.textContent == this.textContent &&
          other.filePath == this.filePath &&
          other.checklistJson == this.checklistJson &&
          other.drawingData == this.drawingData &&
          other.fontFamily == this.fontFamily &&
          other.positionX == this.positionX &&
          other.positionY == this.positionY &&
          other.blockWidth == this.blockWidth &&
          other.blockHeight == this.blockHeight &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class BlocksCompanion extends UpdateCompanion<Block> {
  final Value<int> id;
  final Value<int> timboId;
  final Value<String> type;
  final Value<int> sortOrder;
  final Value<String?> textContent;
  final Value<String?> filePath;
  final Value<String?> checklistJson;
  final Value<String?> drawingData;
  final Value<String?> fontFamily;
  final Value<double?> positionX;
  final Value<double?> positionY;
  final Value<double?> blockWidth;
  final Value<double?> blockHeight;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const BlocksCompanion({
    this.id = const Value.absent(),
    this.timboId = const Value.absent(),
    this.type = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.textContent = const Value.absent(),
    this.filePath = const Value.absent(),
    this.checklistJson = const Value.absent(),
    this.drawingData = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.blockWidth = const Value.absent(),
    this.blockHeight = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  BlocksCompanion.insert({
    this.id = const Value.absent(),
    required int timboId,
    required String type,
    required int sortOrder,
    this.textContent = const Value.absent(),
    this.filePath = const Value.absent(),
    this.checklistJson = const Value.absent(),
    this.drawingData = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.blockWidth = const Value.absent(),
    this.blockHeight = const Value.absent(),
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
  }) : timboId = Value(timboId),
       type = Value(type),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<Block> custom({
    Expression<int>? id,
    Expression<int>? timboId,
    Expression<String>? type,
    Expression<int>? sortOrder,
    Expression<String>? textContent,
    Expression<String>? filePath,
    Expression<String>? checklistJson,
    Expression<String>? drawingData,
    Expression<String>? fontFamily,
    Expression<double>? positionX,
    Expression<double>? positionY,
    Expression<double>? blockWidth,
    Expression<double>? blockHeight,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timboId != null) 'timbo_id': timboId,
      if (type != null) 'type': type,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (textContent != null) 'text_content': textContent,
      if (filePath != null) 'file_path': filePath,
      if (checklistJson != null) 'checklist_json': checklistJson,
      if (drawingData != null) 'drawing_data': drawingData,
      if (fontFamily != null) 'font_family': fontFamily,
      if (positionX != null) 'position_x': positionX,
      if (positionY != null) 'position_y': positionY,
      if (blockWidth != null) 'block_width': blockWidth,
      if (blockHeight != null) 'block_height': blockHeight,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  BlocksCompanion copyWith({
    Value<int>? id,
    Value<int>? timboId,
    Value<String>? type,
    Value<int>? sortOrder,
    Value<String?>? textContent,
    Value<String?>? filePath,
    Value<String?>? checklistJson,
    Value<String?>? drawingData,
    Value<String?>? fontFamily,
    Value<double?>? positionX,
    Value<double?>? positionY,
    Value<double?>? blockWidth,
    Value<double?>? blockHeight,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return BlocksCompanion(
      id: id ?? this.id,
      timboId: timboId ?? this.timboId,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      textContent: textContent ?? this.textContent,
      filePath: filePath ?? this.filePath,
      checklistJson: checklistJson ?? this.checklistJson,
      drawingData: drawingData ?? this.drawingData,
      fontFamily: fontFamily ?? this.fontFamily,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      blockWidth: blockWidth ?? this.blockWidth,
      blockHeight: blockHeight ?? this.blockHeight,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timboId.present) {
      map['timbo_id'] = Variable<int>(timboId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (checklistJson.present) {
      map['checklist_json'] = Variable<String>(checklistJson.value);
    }
    if (drawingData.present) {
      map['drawing_data'] = Variable<String>(drawingData.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (positionX.present) {
      map['position_x'] = Variable<double>(positionX.value);
    }
    if (positionY.present) {
      map['position_y'] = Variable<double>(positionY.value);
    }
    if (blockWidth.present) {
      map['block_width'] = Variable<double>(blockWidth.value);
    }
    if (blockHeight.present) {
      map['block_height'] = Variable<double>(blockHeight.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlocksCompanion(')
          ..write('id: $id, ')
          ..write('timboId: $timboId, ')
          ..write('type: $type, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('textContent: $textContent, ')
          ..write('filePath: $filePath, ')
          ..write('checklistJson: $checklistJson, ')
          ..write('drawingData: $drawingData, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('blockWidth: $blockWidth, ')
          ..write('blockHeight: $blockHeight, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
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
  @override
  List<GeneratedColumn> get $columns => [id, role, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String role;
  final String content;
  final DateTime createdAt;
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ChatMessage copyWith({
    int? id,
    String? role,
    String? content,
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    required String content,
    required DateTime createdAt,
  }) : role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$TimboDatabase extends GeneratedDatabase {
  _$TimboDatabase(QueryExecutor e) : super(e);
  $TimboDatabaseManager get managers => $TimboDatabaseManager(this);
  late final $CapturesTable captures = $CapturesTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $TimbosTable timbos = $TimbosTable(this);
  late final $BlocksTable blocks = $BlocksTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final FolderDao folderDao = FolderDao(this as TimboDatabase);
  late final TimboDao timboDao = TimboDao(this as TimboDatabase);
  late final BlockDao blockDao = BlockDao(this as TimboDatabase);
  late final ChatDao chatDao = ChatDao(this as TimboDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    captures,
    folders,
    timbos,
    blocks,
    chatMessages,
  ];
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
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      required String title,
      required DateTime date,
      required DateTime createdAt,
      Value<bool> isSynced,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$TimboDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimbosTable, List<Timbo>> _timbosRefsTable(
    _$TimboDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.timbos,
    aliasName: $_aliasNameGenerator(db.folders.id, db.timbos.folderId),
  );

  $$TimbosTableProcessedTableManager get timbosRefs {
    final manager = $$TimbosTableTableManager(
      $_db,
      $_db.timbos,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timbosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$TimboDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
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

  Expression<bool> timbosRefs(
    Expression<bool> Function($$TimbosTableFilterComposer f) f,
  ) {
    final $$TimbosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timbos,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimbosTableFilterComposer(
            $db: $db,
            $table: $db.timbos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$TimboDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
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
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$TimboDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> timbosRefs<T extends Object>(
    Expression<T> Function($$TimbosTableAnnotationComposer a) f,
  ) {
    final $$TimbosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timbos,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimbosTableAnnotationComposer(
            $db: $db,
            $table: $db.timbos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$TimboDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool timbosRefs})
        > {
  $$FoldersTableTableManager(_$TimboDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                title: title,
                date: date,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required DateTime date,
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                title: title,
                date: date,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timbosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (timbosRefs) db.timbos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timbosRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, Timbo>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences
                          ._timbosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).timbosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$TimboDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool timbosRefs})
    >;
typedef $$TimbosTableCreateCompanionBuilder =
    TimbosCompanion Function({
      Value<int> id,
      required int folderId,
      Value<String?> title,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int?> reminderTimestamp,
      Value<String?> reminderLabel,
      Value<bool> reminderSet,
      Value<bool> isSynced,
    });
typedef $$TimbosTableUpdateCompanionBuilder =
    TimbosCompanion Function({
      Value<int> id,
      Value<int> folderId,
      Value<String?> title,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> reminderTimestamp,
      Value<String?> reminderLabel,
      Value<bool> reminderSet,
      Value<bool> isSynced,
    });

final class $$TimbosTableReferences
    extends BaseReferences<_$TimboDatabase, $TimbosTable, Timbo> {
  $$TimbosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$TimboDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.timbos.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BlocksTable, List<Block>> _blocksRefsTable(
    _$TimboDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.blocks,
    aliasName: $_aliasNameGenerator(db.timbos.id, db.blocks.timboId),
  );

  $$BlocksTableProcessedTableManager get blocksRefs {
    final manager = $$BlocksTableTableManager(
      $_db,
      $_db.blocks,
    ).filter((f) => f.timboId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_blocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimbosTableFilterComposer
    extends Composer<_$TimboDatabase, $TimbosTable> {
  $$TimbosTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTimestamp => $composableBuilder(
    column: $table.reminderTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderLabel => $composableBuilder(
    column: $table.reminderLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderSet => $composableBuilder(
    column: $table.reminderSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> blocksRefs(
    Expression<bool> Function($$BlocksTableFilterComposer f) f,
  ) {
    final $$BlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blocks,
      getReferencedColumn: (t) => t.timboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlocksTableFilterComposer(
            $db: $db,
            $table: $db.blocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimbosTableOrderingComposer
    extends Composer<_$TimboDatabase, $TimbosTable> {
  $$TimbosTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTimestamp => $composableBuilder(
    column: $table.reminderTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderLabel => $composableBuilder(
    column: $table.reminderLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderSet => $composableBuilder(
    column: $table.reminderSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimbosTableAnnotationComposer
    extends Composer<_$TimboDatabase, $TimbosTable> {
  $$TimbosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get reminderTimestamp => $composableBuilder(
    column: $table.reminderTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderLabel => $composableBuilder(
    column: $table.reminderLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderSet => $composableBuilder(
    column: $table.reminderSet,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> blocksRefs<T extends Object>(
    Expression<T> Function($$BlocksTableAnnotationComposer a) f,
  ) {
    final $$BlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.blocks,
      getReferencedColumn: (t) => t.timboId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.blocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimbosTableTableManager
    extends
        RootTableManager<
          _$TimboDatabase,
          $TimbosTable,
          Timbo,
          $$TimbosTableFilterComposer,
          $$TimbosTableOrderingComposer,
          $$TimbosTableAnnotationComposer,
          $$TimbosTableCreateCompanionBuilder,
          $$TimbosTableUpdateCompanionBuilder,
          (Timbo, $$TimbosTableReferences),
          Timbo,
          PrefetchHooks Function({bool folderId, bool blocksRefs})
        > {
  $$TimbosTableTableManager(_$TimboDatabase db, $TimbosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimbosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimbosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimbosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> reminderTimestamp = const Value.absent(),
                Value<String?> reminderLabel = const Value.absent(),
                Value<bool> reminderSet = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => TimbosCompanion(
                id: id,
                folderId: folderId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                reminderTimestamp: reminderTimestamp,
                reminderLabel: reminderLabel,
                reminderSet: reminderSet,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int folderId,
                Value<String?> title = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int?> reminderTimestamp = const Value.absent(),
                Value<String?> reminderLabel = const Value.absent(),
                Value<bool> reminderSet = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => TimbosCompanion.insert(
                id: id,
                folderId: folderId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                reminderTimestamp: reminderTimestamp,
                reminderLabel: reminderLabel,
                reminderSet: reminderSet,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TimbosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, blocksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (blocksRefs) db.blocks],
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
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$TimbosTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$TimbosTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (blocksRefs)
                    await $_getPrefetchedData<Timbo, $TimbosTable, Block>(
                      currentTable: table,
                      referencedTable: $$TimbosTableReferences._blocksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TimbosTableReferences(db, table, p0).blocksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.timboId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TimbosTableProcessedTableManager =
    ProcessedTableManager<
      _$TimboDatabase,
      $TimbosTable,
      Timbo,
      $$TimbosTableFilterComposer,
      $$TimbosTableOrderingComposer,
      $$TimbosTableAnnotationComposer,
      $$TimbosTableCreateCompanionBuilder,
      $$TimbosTableUpdateCompanionBuilder,
      (Timbo, $$TimbosTableReferences),
      Timbo,
      PrefetchHooks Function({bool folderId, bool blocksRefs})
    >;
typedef $$BlocksTableCreateCompanionBuilder =
    BlocksCompanion Function({
      Value<int> id,
      required int timboId,
      required String type,
      required int sortOrder,
      Value<String?> textContent,
      Value<String?> filePath,
      Value<String?> checklistJson,
      Value<String?> drawingData,
      Value<String?> fontFamily,
      Value<double?> positionX,
      Value<double?> positionY,
      Value<double?> blockWidth,
      Value<double?> blockHeight,
      required DateTime createdAt,
      Value<bool> isSynced,
    });
typedef $$BlocksTableUpdateCompanionBuilder =
    BlocksCompanion Function({
      Value<int> id,
      Value<int> timboId,
      Value<String> type,
      Value<int> sortOrder,
      Value<String?> textContent,
      Value<String?> filePath,
      Value<String?> checklistJson,
      Value<String?> drawingData,
      Value<String?> fontFamily,
      Value<double?> positionX,
      Value<double?> positionY,
      Value<double?> blockWidth,
      Value<double?> blockHeight,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

final class $$BlocksTableReferences
    extends BaseReferences<_$TimboDatabase, $BlocksTable, Block> {
  $$BlocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimbosTable _timboIdTable(_$TimboDatabase db) => db.timbos
      .createAlias($_aliasNameGenerator(db.blocks.timboId, db.timbos.id));

  $$TimbosTableProcessedTableManager get timboId {
    final $_column = $_itemColumn<int>('timbo_id')!;

    final manager = $$TimbosTableTableManager(
      $_db,
      $_db.timbos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_timboIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BlocksTableFilterComposer
    extends Composer<_$TimboDatabase, $BlocksTable> {
  $$BlocksTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drawingData => $composableBuilder(
    column: $table.drawingData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get blockWidth => $composableBuilder(
    column: $table.blockWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get blockHeight => $composableBuilder(
    column: $table.blockHeight,
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

  $$TimbosTableFilterComposer get timboId {
    final $$TimbosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timboId,
      referencedTable: $db.timbos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimbosTableFilterComposer(
            $db: $db,
            $table: $db.timbos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlocksTableOrderingComposer
    extends Composer<_$TimboDatabase, $BlocksTable> {
  $$BlocksTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drawingData => $composableBuilder(
    column: $table.drawingData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get blockWidth => $composableBuilder(
    column: $table.blockWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get blockHeight => $composableBuilder(
    column: $table.blockHeight,
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

  $$TimbosTableOrderingComposer get timboId {
    final $$TimbosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timboId,
      referencedTable: $db.timbos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimbosTableOrderingComposer(
            $db: $db,
            $table: $db.timbos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlocksTableAnnotationComposer
    extends Composer<_$TimboDatabase, $BlocksTable> {
  $$BlocksTableAnnotationComposer({
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

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
    column: $table.textContent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get checklistJson => $composableBuilder(
    column: $table.checklistJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drawingData => $composableBuilder(
    column: $table.drawingData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fontFamily => $composableBuilder(
    column: $table.fontFamily,
    builder: (column) => column,
  );

  GeneratedColumn<double> get positionX =>
      $composableBuilder(column: $table.positionX, builder: (column) => column);

  GeneratedColumn<double> get positionY =>
      $composableBuilder(column: $table.positionY, builder: (column) => column);

  GeneratedColumn<double> get blockWidth => $composableBuilder(
    column: $table.blockWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get blockHeight => $composableBuilder(
    column: $table.blockHeight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$TimbosTableAnnotationComposer get timboId {
    final $$TimbosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timboId,
      referencedTable: $db.timbos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimbosTableAnnotationComposer(
            $db: $db,
            $table: $db.timbos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BlocksTableTableManager
    extends
        RootTableManager<
          _$TimboDatabase,
          $BlocksTable,
          Block,
          $$BlocksTableFilterComposer,
          $$BlocksTableOrderingComposer,
          $$BlocksTableAnnotationComposer,
          $$BlocksTableCreateCompanionBuilder,
          $$BlocksTableUpdateCompanionBuilder,
          (Block, $$BlocksTableReferences),
          Block,
          PrefetchHooks Function({bool timboId})
        > {
  $$BlocksTableTableManager(_$TimboDatabase db, $BlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> timboId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> textContent = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> checklistJson = const Value.absent(),
                Value<String?> drawingData = const Value.absent(),
                Value<String?> fontFamily = const Value.absent(),
                Value<double?> positionX = const Value.absent(),
                Value<double?> positionY = const Value.absent(),
                Value<double?> blockWidth = const Value.absent(),
                Value<double?> blockHeight = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => BlocksCompanion(
                id: id,
                timboId: timboId,
                type: type,
                sortOrder: sortOrder,
                textContent: textContent,
                filePath: filePath,
                checklistJson: checklistJson,
                drawingData: drawingData,
                fontFamily: fontFamily,
                positionX: positionX,
                positionY: positionY,
                blockWidth: blockWidth,
                blockHeight: blockHeight,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timboId,
                required String type,
                required int sortOrder,
                Value<String?> textContent = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> checklistJson = const Value.absent(),
                Value<String?> drawingData = const Value.absent(),
                Value<String?> fontFamily = const Value.absent(),
                Value<double?> positionX = const Value.absent(),
                Value<double?> positionY = const Value.absent(),
                Value<double?> blockWidth = const Value.absent(),
                Value<double?> blockHeight = const Value.absent(),
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
              }) => BlocksCompanion.insert(
                id: id,
                timboId: timboId,
                type: type,
                sortOrder: sortOrder,
                textContent: textContent,
                filePath: filePath,
                checklistJson: checklistJson,
                drawingData: drawingData,
                fontFamily: fontFamily,
                positionX: positionX,
                positionY: positionY,
                blockWidth: blockWidth,
                blockHeight: blockHeight,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BlocksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({timboId = false}) {
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
                    if (timboId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.timboId,
                                referencedTable: $$BlocksTableReferences
                                    ._timboIdTable(db),
                                referencedColumn: $$BlocksTableReferences
                                    ._timboIdTable(db)
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

typedef $$BlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$TimboDatabase,
      $BlocksTable,
      Block,
      $$BlocksTableFilterComposer,
      $$BlocksTableOrderingComposer,
      $$BlocksTableAnnotationComposer,
      $$BlocksTableCreateCompanionBuilder,
      $$BlocksTableUpdateCompanionBuilder,
      (Block, $$BlocksTableReferences),
      Block,
      PrefetchHooks Function({bool timboId})
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required String role,
      required String content,
      required DateTime createdAt,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$TimboDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
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

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$TimboDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$TimboDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$TimboDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$TimboDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$TimboDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                role: role,
                content: content,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String role,
                required String content,
                required DateTime createdAt,
              }) => ChatMessagesCompanion.insert(
                id: id,
                role: role,
                content: content,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$TimboDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$TimboDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;

class $TimboDatabaseManager {
  final _$TimboDatabase _db;
  $TimboDatabaseManager(this._db);
  $$CapturesTableTableManager get captures =>
      $$CapturesTableTableManager(_db, _db.captures);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$TimbosTableTableManager get timbos =>
      $$TimbosTableTableManager(_db, _db.timbos);
  $$BlocksTableTableManager get blocks =>
      $$BlocksTableTableManager(_db, _db.blocks);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
}
