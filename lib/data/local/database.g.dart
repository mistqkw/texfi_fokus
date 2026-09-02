// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _punishmentMeta = const VerificationMeta(
    'punishment',
  );
  @override
  late final GeneratedColumn<String> punishment = GeneratedColumn<String>(
    'punishment',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 300,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyTypeMeta = const VerificationMeta(
    'frequencyType',
  );
  @override
  late final GeneratedColumn<int> frequencyType = GeneratedColumn<int>(
    'frequency_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weekdayMaskMeta = const VerificationMeta(
    'weekdayMask',
  );
  @override
  late final GeneratedColumn<int> weekdayMask = GeneratedColumn<int>(
    'weekday_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0x7F),
  );
  static const VerificationMeta _timesPerWeekMeta = const VerificationMeta(
    'timesPerWeek',
  );
  @override
  late final GeneratedColumn<int> timesPerWeek = GeneratedColumn<int>(
    'times_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  @override
  late final GeneratedColumn<String> reward = GeneratedColumn<String>(
    'reward',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardStreakDaysMeta = const VerificationMeta(
    'rewardStreakDays',
  );
  @override
  late final GeneratedColumn<int> rewardStreakDays = GeneratedColumn<int>(
    'reward_streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _freezeIntervalDaysMeta =
      const VerificationMeta('freezeIntervalDays');
  @override
  late final GeneratedColumn<int> freezeIntervalDays = GeneratedColumn<int>(
    'freeze_interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta(
    'reminderMinutes',
  );
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    punishment,
    frequencyType,
    weekdayMask,
    timesPerWeek,
    reward,
    rewardStreakDays,
    freezeIntervalDays,
    reminderMinutes,
    archived,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('punishment')) {
      context.handle(
        _punishmentMeta,
        punishment.isAcceptableOrUnknown(data['punishment']!, _punishmentMeta),
      );
    } else if (isInserting) {
      context.missing(_punishmentMeta);
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
        _frequencyTypeMeta,
        frequencyType.isAcceptableOrUnknown(
          data['frequency_type']!,
          _frequencyTypeMeta,
        ),
      );
    }
    if (data.containsKey('weekday_mask')) {
      context.handle(
        _weekdayMaskMeta,
        weekdayMask.isAcceptableOrUnknown(
          data['weekday_mask']!,
          _weekdayMaskMeta,
        ),
      );
    }
    if (data.containsKey('times_per_week')) {
      context.handle(
        _timesPerWeekMeta,
        timesPerWeek.isAcceptableOrUnknown(
          data['times_per_week']!,
          _timesPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    }
    if (data.containsKey('reward_streak_days')) {
      context.handle(
        _rewardStreakDaysMeta,
        rewardStreakDays.isAcceptableOrUnknown(
          data['reward_streak_days']!,
          _rewardStreakDaysMeta,
        ),
      );
    }
    if (data.containsKey('freeze_interval_days')) {
      context.handle(
        _freezeIntervalDaysMeta,
        freezeIntervalDays.isAcceptableOrUnknown(
          data['freeze_interval_days']!,
          _freezeIntervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(
          data['reminder_minutes']!,
          _reminderMinutesMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      punishment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}punishment'],
      )!,
      frequencyType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_type'],
      )!,
      weekdayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_mask'],
      )!,
      timesPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_week'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward'],
      ),
      rewardStreakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_streak_days'],
      )!,
      freezeIntervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freeze_interval_days'],
      )!,
      reminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final String id;
  final String name;

  /// Текст, который пользователь вписал сам. Приложение его только хранит
  /// и показывает в напоминании — никакой автоматизации.
  final String punishment;

  /// Индекс `HabitFrequencyType`: 0 — по дням недели, 1 — N раз в неделю.
  final int frequencyType;

  /// Битовая маска дней недели, бит 0 — понедельник. 0x7F — каждый день.
  /// Осмысленна только при `frequencyType == 0`.
  final int weekdayMask;

  /// Сколько раз в неделю нужно закрыть привычку без привязки к дням.
  /// Осмысленно только при `frequencyType == 1`.
  final int timesPerWeek;

  /// Награда, которую пользователь назначил себе сам за стрик. null —
  /// не задана; приложение её не автоматизирует, только показывает.
  final String? reward;

  /// За сколько дней подряд полагается [reward].
  final int rewardStreakDays;

  /// Как часто можно «заморозить» день, не теряя стрик. 0 — заморозки
  /// выключены для этой привычки.
  final int freezeIntervalDays;

  /// Минуты от полуночи для персонального напоминания; null — выключено.
  final int? reminderMinutes;
  final bool archived;
  final int sortOrder;
  final DateTime createdAt;
  const Habit({
    required this.id,
    required this.name,
    required this.punishment,
    required this.frequencyType,
    required this.weekdayMask,
    required this.timesPerWeek,
    this.reward,
    required this.rewardStreakDays,
    required this.freezeIntervalDays,
    this.reminderMinutes,
    required this.archived,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['punishment'] = Variable<String>(punishment);
    map['frequency_type'] = Variable<int>(frequencyType);
    map['weekday_mask'] = Variable<int>(weekdayMask);
    map['times_per_week'] = Variable<int>(timesPerWeek);
    if (!nullToAbsent || reward != null) {
      map['reward'] = Variable<String>(reward);
    }
    map['reward_streak_days'] = Variable<int>(rewardStreakDays);
    map['freeze_interval_days'] = Variable<int>(freezeIntervalDays);
    if (!nullToAbsent || reminderMinutes != null) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes);
    }
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      punishment: Value(punishment),
      frequencyType: Value(frequencyType),
      weekdayMask: Value(weekdayMask),
      timesPerWeek: Value(timesPerWeek),
      reward: reward == null && nullToAbsent
          ? const Value.absent()
          : Value(reward),
      rewardStreakDays: Value(rewardStreakDays),
      freezeIntervalDays: Value(freezeIntervalDays),
      reminderMinutes: reminderMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutes),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      punishment: serializer.fromJson<String>(json['punishment']),
      frequencyType: serializer.fromJson<int>(json['frequencyType']),
      weekdayMask: serializer.fromJson<int>(json['weekdayMask']),
      timesPerWeek: serializer.fromJson<int>(json['timesPerWeek']),
      reward: serializer.fromJson<String?>(json['reward']),
      rewardStreakDays: serializer.fromJson<int>(json['rewardStreakDays']),
      freezeIntervalDays: serializer.fromJson<int>(json['freezeIntervalDays']),
      reminderMinutes: serializer.fromJson<int?>(json['reminderMinutes']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'punishment': serializer.toJson<String>(punishment),
      'frequencyType': serializer.toJson<int>(frequencyType),
      'weekdayMask': serializer.toJson<int>(weekdayMask),
      'timesPerWeek': serializer.toJson<int>(timesPerWeek),
      'reward': serializer.toJson<String?>(reward),
      'rewardStreakDays': serializer.toJson<int>(rewardStreakDays),
      'freezeIntervalDays': serializer.toJson<int>(freezeIntervalDays),
      'reminderMinutes': serializer.toJson<int?>(reminderMinutes),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    String? punishment,
    int? frequencyType,
    int? weekdayMask,
    int? timesPerWeek,
    Value<String?> reward = const Value.absent(),
    int? rewardStreakDays,
    int? freezeIntervalDays,
    Value<int?> reminderMinutes = const Value.absent(),
    bool? archived,
    int? sortOrder,
    DateTime? createdAt,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    punishment: punishment ?? this.punishment,
    frequencyType: frequencyType ?? this.frequencyType,
    weekdayMask: weekdayMask ?? this.weekdayMask,
    timesPerWeek: timesPerWeek ?? this.timesPerWeek,
    reward: reward.present ? reward.value : this.reward,
    rewardStreakDays: rewardStreakDays ?? this.rewardStreakDays,
    freezeIntervalDays: freezeIntervalDays ?? this.freezeIntervalDays,
    reminderMinutes: reminderMinutes.present
        ? reminderMinutes.value
        : this.reminderMinutes,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      punishment: data.punishment.present
          ? data.punishment.value
          : this.punishment,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      weekdayMask: data.weekdayMask.present
          ? data.weekdayMask.value
          : this.weekdayMask,
      timesPerWeek: data.timesPerWeek.present
          ? data.timesPerWeek.value
          : this.timesPerWeek,
      reward: data.reward.present ? data.reward.value : this.reward,
      rewardStreakDays: data.rewardStreakDays.present
          ? data.rewardStreakDays.value
          : this.rewardStreakDays,
      freezeIntervalDays: data.freezeIntervalDays.present
          ? data.freezeIntervalDays.value
          : this.freezeIntervalDays,
      reminderMinutes: data.reminderMinutes.present
          ? data.reminderMinutes.value
          : this.reminderMinutes,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('punishment: $punishment, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('reward: $reward, ')
          ..write('rewardStreakDays: $rewardStreakDays, ')
          ..write('freezeIntervalDays: $freezeIntervalDays, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    punishment,
    frequencyType,
    weekdayMask,
    timesPerWeek,
    reward,
    rewardStreakDays,
    freezeIntervalDays,
    reminderMinutes,
    archived,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.punishment == this.punishment &&
          other.frequencyType == this.frequencyType &&
          other.weekdayMask == this.weekdayMask &&
          other.timesPerWeek == this.timesPerWeek &&
          other.reward == this.reward &&
          other.rewardStreakDays == this.rewardStreakDays &&
          other.freezeIntervalDays == this.freezeIntervalDays &&
          other.reminderMinutes == this.reminderMinutes &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> punishment;
  final Value<int> frequencyType;
  final Value<int> weekdayMask;
  final Value<int> timesPerWeek;
  final Value<String?> reward;
  final Value<int> rewardStreakDays;
  final Value<int> freezeIntervalDays;
  final Value<int?> reminderMinutes;
  final Value<bool> archived;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.punishment = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.reward = const Value.absent(),
    this.rewardStreakDays = const Value.absent(),
    this.freezeIntervalDays = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    required String punishment,
    this.frequencyType = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.reward = const Value.absent(),
    this.rewardStreakDays = const Value.absent(),
    this.freezeIntervalDays = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       punishment = Value(punishment);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? punishment,
    Expression<int>? frequencyType,
    Expression<int>? weekdayMask,
    Expression<int>? timesPerWeek,
    Expression<String>? reward,
    Expression<int>? rewardStreakDays,
    Expression<int>? freezeIntervalDays,
    Expression<int>? reminderMinutes,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (punishment != null) 'punishment': punishment,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (weekdayMask != null) 'weekday_mask': weekdayMask,
      if (timesPerWeek != null) 'times_per_week': timesPerWeek,
      if (reward != null) 'reward': reward,
      if (rewardStreakDays != null) 'reward_streak_days': rewardStreakDays,
      if (freezeIntervalDays != null)
        'freeze_interval_days': freezeIntervalDays,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? punishment,
    Value<int>? frequencyType,
    Value<int>? weekdayMask,
    Value<int>? timesPerWeek,
    Value<String?>? reward,
    Value<int>? rewardStreakDays,
    Value<int>? freezeIntervalDays,
    Value<int?>? reminderMinutes,
    Value<bool>? archived,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      punishment: punishment ?? this.punishment,
      frequencyType: frequencyType ?? this.frequencyType,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      reward: reward ?? this.reward,
      rewardStreakDays: rewardStreakDays ?? this.rewardStreakDays,
      freezeIntervalDays: freezeIntervalDays ?? this.freezeIntervalDays,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (punishment.present) {
      map['punishment'] = Variable<String>(punishment.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<int>(frequencyType.value);
    }
    if (weekdayMask.present) {
      map['weekday_mask'] = Variable<int>(weekdayMask.value);
    }
    if (timesPerWeek.present) {
      map['times_per_week'] = Variable<int>(timesPerWeek.value);
    }
    if (reward.present) {
      map['reward'] = Variable<String>(reward.value);
    }
    if (rewardStreakDays.present) {
      map['reward_streak_days'] = Variable<int>(rewardStreakDays.value);
    }
    if (freezeIntervalDays.present) {
      map['freeze_interval_days'] = Variable<int>(freezeIntervalDays.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('punishment: $punishment, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('reward: $reward, ')
          ..write('rewardStreakDays: $rewardStreakDays, ')
          ..write('freezeIntervalDays: $freezeIntervalDays, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitCompletionsTable extends HabitCompletions
    with TableInfo<$HabitCompletionsTable, HabitCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitId, day, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $HabitCompletionsTable createAlias(String alias) {
    return $HabitCompletionsTable(attachedDatabase, alias);
  }
}

class HabitCompletion extends DataClass implements Insertable<HabitCompletion> {
  final String id;

  /// Ссылается на `Habits.id` (без декларативного FK — как в texfi-money,
  /// целостность держат репозитории).
  final String habitId;

  /// День, нормализованный к локальной полуночи.
  final DateTime day;
  final DateTime completedAt;
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.day,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['day'] = Variable<DateTime>(day);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  HabitCompletionsCompanion toCompanion(bool nullToAbsent) {
    return HabitCompletionsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      day: Value(day),
      completedAt: Value(completedAt),
    );
  }

  factory HabitCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCompletion(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      day: serializer.fromJson<DateTime>(json['day']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'day': serializer.toJson<DateTime>(day),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? day,
    DateTime? completedAt,
  }) => HabitCompletion(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    day: day ?? this.day,
    completedAt: completedAt ?? this.completedAt,
  );
  HabitCompletion copyWithCompanion(HabitCompletionsCompanion data) {
    return HabitCompletion(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      day: data.day.present ? data.day.value : this.day,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, day, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCompletion &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.day == this.day &&
          other.completedAt == this.completedAt);
}

class HabitCompletionsCompanion extends UpdateCompanion<HabitCompletion> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> day;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const HabitCompletionsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.day = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitCompletionsCompanion.insert({
    required String id,
    required String habitId,
    required DateTime day,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       day = Value(day);
  static Insertable<HabitCompletion> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? day,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (day != null) 'day': day,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? day,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return HabitCompletionsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      day: day ?? this.day,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitFreezesTable extends HabitFreezes
    with TableInfo<$HabitFreezesTable, HabitFreeze> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitFreezesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitId, day, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_freezes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitFreeze> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitFreeze map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitFreeze(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitFreezesTable createAlias(String alias) {
    return $HabitFreezesTable(attachedDatabase, alias);
  }
}

class HabitFreeze extends DataClass implements Insertable<HabitFreeze> {
  final String id;

  /// Ссылается на `Habits.id`.
  final String habitId;

  /// День, нормализованный к локальной полуночи.
  final DateTime day;
  final DateTime createdAt;
  const HabitFreeze({
    required this.id,
    required this.habitId,
    required this.day,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['day'] = Variable<DateTime>(day);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitFreezesCompanion toCompanion(bool nullToAbsent) {
    return HabitFreezesCompanion(
      id: Value(id),
      habitId: Value(habitId),
      day: Value(day),
      createdAt: Value(createdAt),
    );
  }

  factory HabitFreeze.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitFreeze(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      day: serializer.fromJson<DateTime>(json['day']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'day': serializer.toJson<DateTime>(day),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HabitFreeze copyWith({
    String? id,
    String? habitId,
    DateTime? day,
    DateTime? createdAt,
  }) => HabitFreeze(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    day: day ?? this.day,
    createdAt: createdAt ?? this.createdAt,
  );
  HabitFreeze copyWithCompanion(HabitFreezesCompanion data) {
    return HabitFreeze(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      day: data.day.present ? data.day.value : this.day,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitFreeze(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, day, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitFreeze &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.day == this.day &&
          other.createdAt == this.createdAt);
}

class HabitFreezesCompanion extends UpdateCompanion<HabitFreeze> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> day;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const HabitFreezesCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.day = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitFreezesCompanion.insert({
    required String id,
    required String habitId,
    required DateTime day,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       day = Value(day);
  static Insertable<HabitFreeze> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? day,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (day != null) 'day': day,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitFreezesCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? day,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return HabitFreezesCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      day: day ?? this.day,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitFreezesCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('day: $day, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    category,
    difficulty,
    createdAt,
    lastUsedAt,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;

  /// Индекс `TaskCategory`.
  final int category;

  /// Индекс `TaskDifficulty`.
  final int difficulty;
  final DateTime createdAt;

  /// Последнее использование — по нему список сортируется.
  final DateTime? lastUsedAt;
  final bool archived;
  const Task({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    this.lastUsedAt,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<int>(category);
    map['difficulty'] = Variable<int>(difficulty);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      category: Value(category),
      difficulty: Value(difficulty),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      archived: Value(archived),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<int>(json['category']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<int>(category),
      'difficulty': serializer.toJson<int>(difficulty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    int? category,
    int? difficulty,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
    bool? archived,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    archived: archived ?? this.archived,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    category,
    difficulty,
    createdAt,
    lastUsedAt,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.archived == this.archived);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> category;
  final Value<int> difficulty;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  final Value<bool> archived;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? category,
    Expression<int>? difficulty,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? category,
    Value<int>? difficulty,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayPlanEntriesTable extends DayPlanEntries
    with TableInfo<$DayPlanEntriesTable, DayPlanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayPlanEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    taskId,
    sortOrder,
    done,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_plan_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayPlanEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayPlanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayPlanEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DayPlanEntriesTable createAlias(String alias) {
    return $DayPlanEntriesTable(attachedDatabase, alias);
  }
}

class DayPlanEntry extends DataClass implements Insertable<DayPlanEntry> {
  final String id;

  /// День плана, нормализованный к локальной полуночи.
  final DateTime day;

  /// Ссылается на `Tasks.id`. Всегда заполнена: в план попадают только
  /// сохранённые задачи — иначе из плана нельзя было бы стартовать сессию
  /// с той же категорией и сложностью.
  final String taskId;

  /// Порядок в плане — «примерный порядок» из спецификации.
  final int sortOrder;

  /// Пользователь отметил пункт плана выполненным.
  final bool done;
  final DateTime createdAt;
  const DayPlanEntry({
    required this.id,
    required this.day,
    required this.taskId,
    required this.sortOrder,
    required this.done,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<DateTime>(day);
    map['task_id'] = Variable<String>(taskId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['done'] = Variable<bool>(done);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DayPlanEntriesCompanion toCompanion(bool nullToAbsent) {
    return DayPlanEntriesCompanion(
      id: Value(id),
      day: Value(day),
      taskId: Value(taskId),
      sortOrder: Value(sortOrder),
      done: Value(done),
      createdAt: Value(createdAt),
    );
  }

  factory DayPlanEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayPlanEntry(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<DateTime>(json['day']),
      taskId: serializer.fromJson<String>(json['taskId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      done: serializer.fromJson<bool>(json['done']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<DateTime>(day),
      'taskId': serializer.toJson<String>(taskId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'done': serializer.toJson<bool>(done),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DayPlanEntry copyWith({
    String? id,
    DateTime? day,
    String? taskId,
    int? sortOrder,
    bool? done,
    DateTime? createdAt,
  }) => DayPlanEntry(
    id: id ?? this.id,
    day: day ?? this.day,
    taskId: taskId ?? this.taskId,
    sortOrder: sortOrder ?? this.sortOrder,
    done: done ?? this.done,
    createdAt: createdAt ?? this.createdAt,
  );
  DayPlanEntry copyWithCompanion(DayPlanEntriesCompanion data) {
    return DayPlanEntry(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      done: data.done.present ? data.done.value : this.done,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayPlanEntry(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('taskId: $taskId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, taskId, sortOrder, done, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayPlanEntry &&
          other.id == this.id &&
          other.day == this.day &&
          other.taskId == this.taskId &&
          other.sortOrder == this.sortOrder &&
          other.done == this.done &&
          other.createdAt == this.createdAt);
}

class DayPlanEntriesCompanion extends UpdateCompanion<DayPlanEntry> {
  final Value<String> id;
  final Value<DateTime> day;
  final Value<String> taskId;
  final Value<int> sortOrder;
  final Value<bool> done;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DayPlanEntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.taskId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayPlanEntriesCompanion.insert({
    required String id,
    required DateTime day,
    required String taskId,
    this.sortOrder = const Value.absent(),
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       taskId = Value(taskId);
  static Insertable<DayPlanEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? day,
    Expression<String>? taskId,
    Expression<int>? sortOrder,
    Expression<bool>? done,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (taskId != null) 'task_id': taskId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (done != null) 'done': done,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayPlanEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? day,
    Value<String>? taskId,
    Value<int>? sortOrder,
    Value<bool>? done,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DayPlanEntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      taskId: taskId ?? this.taskId,
      sortOrder: sortOrder ?? this.sortOrder,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayPlanEntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('taskId: $taskId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks with TableInfo<$SubtasksTable, Subtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, title, sortOrder, done];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }
}

class Subtask extends DataClass implements Insertable<Subtask> {
  final String id;

  /// Ссылается на `Tasks.id`.
  final String taskId;
  final String title;
  final int sortOrder;
  final bool done;
  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    required this.sortOrder,
    required this.done,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['sort_order'] = Variable<int>(sortOrder);
    map['done'] = Variable<bool>(done);
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      sortOrder: Value(sortOrder),
      done: Value(done),
    );
  }

  factory Subtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subtask(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      done: serializer.fromJson<bool>(json['done']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'done': serializer.toJson<bool>(done),
    };
  }

  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    int? sortOrder,
    bool? done,
  }) => Subtask(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    sortOrder: sortOrder ?? this.sortOrder,
    done: done ?? this.done,
  );
  Subtask copyWithCompanion(SubtasksCompanion data) {
    return Subtask(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      done: data.done.present ? data.done.value : this.done,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subtask(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, title, sortOrder, done);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subtask &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.sortOrder == this.sortOrder &&
          other.done == this.done);
}

class SubtasksCompanion extends UpdateCompanion<Subtask> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<int> sortOrder;
  final Value<bool> done;
  final Value<int> rowid;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubtasksCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.sortOrder = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       title = Value(title);
  static Insertable<Subtask> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<int>? sortOrder,
    Expression<bool>? done,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (done != null) 'done': done,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubtasksCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? title,
    Value<int>? sortOrder,
    Value<bool>? done,
    Value<int>? rowid,
  }) {
    return SubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      done: done ?? this.done,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('done: $done, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskTitleMeta = const VerificationMeta(
    'taskTitle',
  );
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
    'task_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _techniqueMeta = const VerificationMeta(
    'technique',
  );
  @override
  late final GeneratedColumn<String> technique = GeneratedColumn<String>(
    'technique',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedFocusMinutesMeta =
      const VerificationMeta('plannedFocusMinutes');
  @override
  late final GeneratedColumn<int> plannedFocusMinutes = GeneratedColumn<int>(
    'planned_focus_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedBreakMinutesMeta =
      const VerificationMeta('plannedBreakMinutes');
  @override
  late final GeneratedColumn<int> plannedBreakMinutes = GeneratedColumn<int>(
    'planned_break_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedCyclesMeta = const VerificationMeta(
    'plannedCycles',
  );
  @override
  late final GeneratedColumn<int> plannedCycles = GeneratedColumn<int>(
    'planned_cycles',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualFocusSecondsMeta =
      const VerificationMeta('actualFocusSeconds');
  @override
  late final GeneratedColumn<int> actualFocusSeconds = GeneratedColumn<int>(
    'actual_focus_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<int> outcome = GeneratedColumn<int>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextKeyMeta = const VerificationMeta(
    'contextKey',
  );
  @override
  late final GeneratedColumn<String> contextKey = GeneratedColumn<String>(
    'context_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wasRecommendedMeta = const VerificationMeta(
    'wasRecommended',
  );
  @override
  late final GeneratedColumn<bool> wasRecommended = GeneratedColumn<bool>(
    'was_recommended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_recommended" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _wasManualOverrideMeta = const VerificationMeta(
    'wasManualOverride',
  );
  @override
  late final GeneratedColumn<bool> wasManualOverride = GeneratedColumn<bool>(
    'was_manual_override',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_manual_override" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _interruptionReasonMeta =
      const VerificationMeta('interruptionReason');
  @override
  late final GeneratedColumn<String> interruptionReason =
      GeneratedColumn<String>(
        'interruption_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sessionNoteMeta = const VerificationMeta(
    'sessionNote',
  );
  @override
  late final GeneratedColumn<String> sessionNote = GeneratedColumn<String>(
    'session_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    taskTitle,
    category,
    difficulty,
    mood,
    technique,
    plannedFocusMinutes,
    plannedBreakMinutes,
    plannedCycles,
    actualFocusSeconds,
    outcome,
    rating,
    startedAt,
    endedAt,
    contextKey,
    wasRecommended,
    wasManualOverride,
    interruptionReason,
    sessionNote,
    photoPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('task_title')) {
      context.handle(
        _taskTitleMeta,
        taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTitleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('technique')) {
      context.handle(
        _techniqueMeta,
        technique.isAcceptableOrUnknown(data['technique']!, _techniqueMeta),
      );
    } else if (isInserting) {
      context.missing(_techniqueMeta);
    }
    if (data.containsKey('planned_focus_minutes')) {
      context.handle(
        _plannedFocusMinutesMeta,
        plannedFocusMinutes.isAcceptableOrUnknown(
          data['planned_focus_minutes']!,
          _plannedFocusMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedFocusMinutesMeta);
    }
    if (data.containsKey('planned_break_minutes')) {
      context.handle(
        _plannedBreakMinutesMeta,
        plannedBreakMinutes.isAcceptableOrUnknown(
          data['planned_break_minutes']!,
          _plannedBreakMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedBreakMinutesMeta);
    }
    if (data.containsKey('planned_cycles')) {
      context.handle(
        _plannedCyclesMeta,
        plannedCycles.isAcceptableOrUnknown(
          data['planned_cycles']!,
          _plannedCyclesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedCyclesMeta);
    }
    if (data.containsKey('actual_focus_seconds')) {
      context.handle(
        _actualFocusSecondsMeta,
        actualFocusSeconds.isAcceptableOrUnknown(
          data['actual_focus_seconds']!,
          _actualFocusSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualFocusSecondsMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('context_key')) {
      context.handle(
        _contextKeyMeta,
        contextKey.isAcceptableOrUnknown(data['context_key']!, _contextKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_contextKeyMeta);
    }
    if (data.containsKey('was_recommended')) {
      context.handle(
        _wasRecommendedMeta,
        wasRecommended.isAcceptableOrUnknown(
          data['was_recommended']!,
          _wasRecommendedMeta,
        ),
      );
    }
    if (data.containsKey('was_manual_override')) {
      context.handle(
        _wasManualOverrideMeta,
        wasManualOverride.isAcceptableOrUnknown(
          data['was_manual_override']!,
          _wasManualOverrideMeta,
        ),
      );
    }
    if (data.containsKey('interruption_reason')) {
      context.handle(
        _interruptionReasonMeta,
        interruptionReason.isAcceptableOrUnknown(
          data['interruption_reason']!,
          _interruptionReasonMeta,
        ),
      );
    }
    if (data.containsKey('session_note')) {
      context.handle(
        _sessionNoteMeta,
        sessionNote.isAcceptableOrUnknown(
          data['session_note']!,
          _sessionNoteMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      taskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      technique: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technique'],
      )!,
      plannedFocusMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_focus_minutes'],
      )!,
      plannedBreakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_break_minutes'],
      )!,
      plannedCycles: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_cycles'],
      )!,
      actualFocusSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_focus_seconds'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outcome'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      contextKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_key'],
      )!,
      wasRecommended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_recommended'],
      )!,
      wasManualOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_manual_override'],
      )!,
      interruptionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interruption_reason'],
      ),
      sessionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_note'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;

  /// Ссылается на `Tasks.id`; null — задачу ввели разово и не сохранили.
  final String? taskId;

  /// Название задачи копируется в сессию: удаление задачи не должно стирать
  /// историю.
  final String taskTitle;

  /// Индекс `TaskCategory`.
  final int category;

  /// Индекс `TaskDifficulty`.
  final int difficulty;

  /// Индекс `Mood`.
  final int mood;

  /// Строковый ключ `FocusTechnique`.
  final String technique;
  final int plannedFocusMinutes;
  final int plannedBreakMinutes;
  final int plannedCycles;

  /// Фактическое время в фокусе, без перерывов.
  final int actualFocusSeconds;

  /// Индекс `SessionOutcome`.
  final int outcome;

  /// Субъективная оценка 1–5; null — пользователь пропустил вопрос.
  final int? rating;
  final DateTime startedAt;
  final DateTime endedAt;

  /// Полный ключ контекста на момент старта.
  final String contextKey;
  final bool wasRecommended;

  /// Пользователь открыл «настроить вручную» и выбрал технику, отличную от
  /// предложенной. Это не то же самое, что [wasRecommended]: там про «сессия
  /// шла не по совету», здесь — про явное несогласие с советом.
  final bool wasManualOverride;

  /// Ключ `InterruptionReason`; null — сессия не прервана либо причину
  /// не назвали.
  final String? interruptionReason;

  /// Короткая заметка «как прошло». null — пропустили.
  final String? sessionNote;

  /// Путь к прикреплённому фото — тетрадь, экран, стол. null — фото не
  /// прикладывали, и это обычный случай.
  ///
  /// Хранится путь, а не сам файл: картинка в BLOB раздула бы базу, которую
  /// приложение экспортирует и импортирует целиком. Файл лежит в документах
  /// приложения и никуда не уходит — принцип «всё локально» сохраняется.
  final String? photoPath;
  const Session({
    required this.id,
    this.taskId,
    required this.taskTitle,
    required this.category,
    required this.difficulty,
    required this.mood,
    required this.technique,
    required this.plannedFocusMinutes,
    required this.plannedBreakMinutes,
    required this.plannedCycles,
    required this.actualFocusSeconds,
    required this.outcome,
    this.rating,
    required this.startedAt,
    required this.endedAt,
    required this.contextKey,
    required this.wasRecommended,
    required this.wasManualOverride,
    this.interruptionReason,
    this.sessionNote,
    this.photoPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['task_title'] = Variable<String>(taskTitle);
    map['category'] = Variable<int>(category);
    map['difficulty'] = Variable<int>(difficulty);
    map['mood'] = Variable<int>(mood);
    map['technique'] = Variable<String>(technique);
    map['planned_focus_minutes'] = Variable<int>(plannedFocusMinutes);
    map['planned_break_minutes'] = Variable<int>(plannedBreakMinutes);
    map['planned_cycles'] = Variable<int>(plannedCycles);
    map['actual_focus_seconds'] = Variable<int>(actualFocusSeconds);
    map['outcome'] = Variable<int>(outcome);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['context_key'] = Variable<String>(contextKey);
    map['was_recommended'] = Variable<bool>(wasRecommended);
    map['was_manual_override'] = Variable<bool>(wasManualOverride);
    if (!nullToAbsent || interruptionReason != null) {
      map['interruption_reason'] = Variable<String>(interruptionReason);
    }
    if (!nullToAbsent || sessionNote != null) {
      map['session_note'] = Variable<String>(sessionNote);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      taskTitle: Value(taskTitle),
      category: Value(category),
      difficulty: Value(difficulty),
      mood: Value(mood),
      technique: Value(technique),
      plannedFocusMinutes: Value(plannedFocusMinutes),
      plannedBreakMinutes: Value(plannedBreakMinutes),
      plannedCycles: Value(plannedCycles),
      actualFocusSeconds: Value(actualFocusSeconds),
      outcome: Value(outcome),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      contextKey: Value(contextKey),
      wasRecommended: Value(wasRecommended),
      wasManualOverride: Value(wasManualOverride),
      interruptionReason: interruptionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(interruptionReason),
      sessionNote: sessionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionNote),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      taskTitle: serializer.fromJson<String>(json['taskTitle']),
      category: serializer.fromJson<int>(json['category']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      mood: serializer.fromJson<int>(json['mood']),
      technique: serializer.fromJson<String>(json['technique']),
      plannedFocusMinutes: serializer.fromJson<int>(
        json['plannedFocusMinutes'],
      ),
      plannedBreakMinutes: serializer.fromJson<int>(
        json['plannedBreakMinutes'],
      ),
      plannedCycles: serializer.fromJson<int>(json['plannedCycles']),
      actualFocusSeconds: serializer.fromJson<int>(json['actualFocusSeconds']),
      outcome: serializer.fromJson<int>(json['outcome']),
      rating: serializer.fromJson<int?>(json['rating']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      contextKey: serializer.fromJson<String>(json['contextKey']),
      wasRecommended: serializer.fromJson<bool>(json['wasRecommended']),
      wasManualOverride: serializer.fromJson<bool>(json['wasManualOverride']),
      interruptionReason: serializer.fromJson<String?>(
        json['interruptionReason'],
      ),
      sessionNote: serializer.fromJson<String?>(json['sessionNote']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String?>(taskId),
      'taskTitle': serializer.toJson<String>(taskTitle),
      'category': serializer.toJson<int>(category),
      'difficulty': serializer.toJson<int>(difficulty),
      'mood': serializer.toJson<int>(mood),
      'technique': serializer.toJson<String>(technique),
      'plannedFocusMinutes': serializer.toJson<int>(plannedFocusMinutes),
      'plannedBreakMinutes': serializer.toJson<int>(plannedBreakMinutes),
      'plannedCycles': serializer.toJson<int>(plannedCycles),
      'actualFocusSeconds': serializer.toJson<int>(actualFocusSeconds),
      'outcome': serializer.toJson<int>(outcome),
      'rating': serializer.toJson<int?>(rating),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'contextKey': serializer.toJson<String>(contextKey),
      'wasRecommended': serializer.toJson<bool>(wasRecommended),
      'wasManualOverride': serializer.toJson<bool>(wasManualOverride),
      'interruptionReason': serializer.toJson<String?>(interruptionReason),
      'sessionNote': serializer.toJson<String?>(sessionNote),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  Session copyWith({
    String? id,
    Value<String?> taskId = const Value.absent(),
    String? taskTitle,
    int? category,
    int? difficulty,
    int? mood,
    String? technique,
    int? plannedFocusMinutes,
    int? plannedBreakMinutes,
    int? plannedCycles,
    int? actualFocusSeconds,
    int? outcome,
    Value<int?> rating = const Value.absent(),
    DateTime? startedAt,
    DateTime? endedAt,
    String? contextKey,
    bool? wasRecommended,
    bool? wasManualOverride,
    Value<String?> interruptionReason = const Value.absent(),
    Value<String?> sessionNote = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    taskId: taskId.present ? taskId.value : this.taskId,
    taskTitle: taskTitle ?? this.taskTitle,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    mood: mood ?? this.mood,
    technique: technique ?? this.technique,
    plannedFocusMinutes: plannedFocusMinutes ?? this.plannedFocusMinutes,
    plannedBreakMinutes: plannedBreakMinutes ?? this.plannedBreakMinutes,
    plannedCycles: plannedCycles ?? this.plannedCycles,
    actualFocusSeconds: actualFocusSeconds ?? this.actualFocusSeconds,
    outcome: outcome ?? this.outcome,
    rating: rating.present ? rating.value : this.rating,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    contextKey: contextKey ?? this.contextKey,
    wasRecommended: wasRecommended ?? this.wasRecommended,
    wasManualOverride: wasManualOverride ?? this.wasManualOverride,
    interruptionReason: interruptionReason.present
        ? interruptionReason.value
        : this.interruptionReason,
    sessionNote: sessionNote.present ? sessionNote.value : this.sessionNote,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      category: data.category.present ? data.category.value : this.category,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      mood: data.mood.present ? data.mood.value : this.mood,
      technique: data.technique.present ? data.technique.value : this.technique,
      plannedFocusMinutes: data.plannedFocusMinutes.present
          ? data.plannedFocusMinutes.value
          : this.plannedFocusMinutes,
      plannedBreakMinutes: data.plannedBreakMinutes.present
          ? data.plannedBreakMinutes.value
          : this.plannedBreakMinutes,
      plannedCycles: data.plannedCycles.present
          ? data.plannedCycles.value
          : this.plannedCycles,
      actualFocusSeconds: data.actualFocusSeconds.present
          ? data.actualFocusSeconds.value
          : this.actualFocusSeconds,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      rating: data.rating.present ? data.rating.value : this.rating,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      contextKey: data.contextKey.present
          ? data.contextKey.value
          : this.contextKey,
      wasRecommended: data.wasRecommended.present
          ? data.wasRecommended.value
          : this.wasRecommended,
      wasManualOverride: data.wasManualOverride.present
          ? data.wasManualOverride.value
          : this.wasManualOverride,
      interruptionReason: data.interruptionReason.present
          ? data.interruptionReason.value
          : this.interruptionReason,
      sessionNote: data.sessionNote.present
          ? data.sessionNote.value
          : this.sessionNote,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('mood: $mood, ')
          ..write('technique: $technique, ')
          ..write('plannedFocusMinutes: $plannedFocusMinutes, ')
          ..write('plannedBreakMinutes: $plannedBreakMinutes, ')
          ..write('plannedCycles: $plannedCycles, ')
          ..write('actualFocusSeconds: $actualFocusSeconds, ')
          ..write('outcome: $outcome, ')
          ..write('rating: $rating, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('contextKey: $contextKey, ')
          ..write('wasRecommended: $wasRecommended, ')
          ..write('wasManualOverride: $wasManualOverride, ')
          ..write('interruptionReason: $interruptionReason, ')
          ..write('sessionNote: $sessionNote, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    taskId,
    taskTitle,
    category,
    difficulty,
    mood,
    technique,
    plannedFocusMinutes,
    plannedBreakMinutes,
    plannedCycles,
    actualFocusSeconds,
    outcome,
    rating,
    startedAt,
    endedAt,
    contextKey,
    wasRecommended,
    wasManualOverride,
    interruptionReason,
    sessionNote,
    photoPath,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.taskTitle == this.taskTitle &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.mood == this.mood &&
          other.technique == this.technique &&
          other.plannedFocusMinutes == this.plannedFocusMinutes &&
          other.plannedBreakMinutes == this.plannedBreakMinutes &&
          other.plannedCycles == this.plannedCycles &&
          other.actualFocusSeconds == this.actualFocusSeconds &&
          other.outcome == this.outcome &&
          other.rating == this.rating &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.contextKey == this.contextKey &&
          other.wasRecommended == this.wasRecommended &&
          other.wasManualOverride == this.wasManualOverride &&
          other.interruptionReason == this.interruptionReason &&
          other.sessionNote == this.sessionNote &&
          other.photoPath == this.photoPath);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String?> taskId;
  final Value<String> taskTitle;
  final Value<int> category;
  final Value<int> difficulty;
  final Value<int> mood;
  final Value<String> technique;
  final Value<int> plannedFocusMinutes;
  final Value<int> plannedBreakMinutes;
  final Value<int> plannedCycles;
  final Value<int> actualFocusSeconds;
  final Value<int> outcome;
  final Value<int?> rating;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<String> contextKey;
  final Value<bool> wasRecommended;
  final Value<bool> wasManualOverride;
  final Value<String?> interruptionReason;
  final Value<String?> sessionNote;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.mood = const Value.absent(),
    this.technique = const Value.absent(),
    this.plannedFocusMinutes = const Value.absent(),
    this.plannedBreakMinutes = const Value.absent(),
    this.plannedCycles = const Value.absent(),
    this.actualFocusSeconds = const Value.absent(),
    this.outcome = const Value.absent(),
    this.rating = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.contextKey = const Value.absent(),
    this.wasRecommended = const Value.absent(),
    this.wasManualOverride = const Value.absent(),
    this.interruptionReason = const Value.absent(),
    this.sessionNote = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    this.taskId = const Value.absent(),
    required String taskTitle,
    required int category,
    required int difficulty,
    required int mood,
    required String technique,
    required int plannedFocusMinutes,
    required int plannedBreakMinutes,
    required int plannedCycles,
    required int actualFocusSeconds,
    required int outcome,
    this.rating = const Value.absent(),
    required DateTime startedAt,
    required DateTime endedAt,
    required String contextKey,
    this.wasRecommended = const Value.absent(),
    this.wasManualOverride = const Value.absent(),
    this.interruptionReason = const Value.absent(),
    this.sessionNote = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskTitle = Value(taskTitle),
       category = Value(category),
       difficulty = Value(difficulty),
       mood = Value(mood),
       technique = Value(technique),
       plannedFocusMinutes = Value(plannedFocusMinutes),
       plannedBreakMinutes = Value(plannedBreakMinutes),
       plannedCycles = Value(plannedCycles),
       actualFocusSeconds = Value(actualFocusSeconds),
       outcome = Value(outcome),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       contextKey = Value(contextKey);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? taskTitle,
    Expression<int>? category,
    Expression<int>? difficulty,
    Expression<int>? mood,
    Expression<String>? technique,
    Expression<int>? plannedFocusMinutes,
    Expression<int>? plannedBreakMinutes,
    Expression<int>? plannedCycles,
    Expression<int>? actualFocusSeconds,
    Expression<int>? outcome,
    Expression<int>? rating,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? contextKey,
    Expression<bool>? wasRecommended,
    Expression<bool>? wasManualOverride,
    Expression<String>? interruptionReason,
    Expression<String>? sessionNote,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (taskTitle != null) 'task_title': taskTitle,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (mood != null) 'mood': mood,
      if (technique != null) 'technique': technique,
      if (plannedFocusMinutes != null)
        'planned_focus_minutes': plannedFocusMinutes,
      if (plannedBreakMinutes != null)
        'planned_break_minutes': plannedBreakMinutes,
      if (plannedCycles != null) 'planned_cycles': plannedCycles,
      if (actualFocusSeconds != null)
        'actual_focus_seconds': actualFocusSeconds,
      if (outcome != null) 'outcome': outcome,
      if (rating != null) 'rating': rating,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (contextKey != null) 'context_key': contextKey,
      if (wasRecommended != null) 'was_recommended': wasRecommended,
      if (wasManualOverride != null) 'was_manual_override': wasManualOverride,
      if (interruptionReason != null) 'interruption_reason': interruptionReason,
      if (sessionNote != null) 'session_note': sessionNote,
      if (photoPath != null) 'photo_path': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? taskId,
    Value<String>? taskTitle,
    Value<int>? category,
    Value<int>? difficulty,
    Value<int>? mood,
    Value<String>? technique,
    Value<int>? plannedFocusMinutes,
    Value<int>? plannedBreakMinutes,
    Value<int>? plannedCycles,
    Value<int>? actualFocusSeconds,
    Value<int>? outcome,
    Value<int?>? rating,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<String>? contextKey,
    Value<bool>? wasRecommended,
    Value<bool>? wasManualOverride,
    Value<String?>? interruptionReason,
    Value<String?>? sessionNote,
    Value<String?>? photoPath,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      mood: mood ?? this.mood,
      technique: technique ?? this.technique,
      plannedFocusMinutes: plannedFocusMinutes ?? this.plannedFocusMinutes,
      plannedBreakMinutes: plannedBreakMinutes ?? this.plannedBreakMinutes,
      plannedCycles: plannedCycles ?? this.plannedCycles,
      actualFocusSeconds: actualFocusSeconds ?? this.actualFocusSeconds,
      outcome: outcome ?? this.outcome,
      rating: rating ?? this.rating,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      contextKey: contextKey ?? this.contextKey,
      wasRecommended: wasRecommended ?? this.wasRecommended,
      wasManualOverride: wasManualOverride ?? this.wasManualOverride,
      interruptionReason: interruptionReason ?? this.interruptionReason,
      sessionNote: sessionNote ?? this.sessionNote,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (technique.present) {
      map['technique'] = Variable<String>(technique.value);
    }
    if (plannedFocusMinutes.present) {
      map['planned_focus_minutes'] = Variable<int>(plannedFocusMinutes.value);
    }
    if (plannedBreakMinutes.present) {
      map['planned_break_minutes'] = Variable<int>(plannedBreakMinutes.value);
    }
    if (plannedCycles.present) {
      map['planned_cycles'] = Variable<int>(plannedCycles.value);
    }
    if (actualFocusSeconds.present) {
      map['actual_focus_seconds'] = Variable<int>(actualFocusSeconds.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(outcome.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (contextKey.present) {
      map['context_key'] = Variable<String>(contextKey.value);
    }
    if (wasRecommended.present) {
      map['was_recommended'] = Variable<bool>(wasRecommended.value);
    }
    if (wasManualOverride.present) {
      map['was_manual_override'] = Variable<bool>(wasManualOverride.value);
    }
    if (interruptionReason.present) {
      map['interruption_reason'] = Variable<String>(interruptionReason.value);
    }
    if (sessionNote.present) {
      map['session_note'] = Variable<String>(sessionNote.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('mood: $mood, ')
          ..write('technique: $technique, ')
          ..write('plannedFocusMinutes: $plannedFocusMinutes, ')
          ..write('plannedBreakMinutes: $plannedBreakMinutes, ')
          ..write('plannedCycles: $plannedCycles, ')
          ..write('actualFocusSeconds: $actualFocusSeconds, ')
          ..write('outcome: $outcome, ')
          ..write('rating: $rating, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('contextKey: $contextKey, ')
          ..write('wasRecommended: $wasRecommended, ')
          ..write('wasManualOverride: $wasManualOverride, ')
          ..write('interruptionReason: $interruptionReason, ')
          ..write('sessionNote: $sessionNote, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MoodEntriesTable extends MoodEntries
    with TableInfo<$MoodEntriesTable, MoodEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, mood, recordedAt, sessionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoodEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
    );
  }

  @override
  $MoodEntriesTable createAlias(String alias) {
    return $MoodEntriesTable(attachedDatabase, alias);
  }
}

class MoodEntry extends DataClass implements Insertable<MoodEntry> {
  final String id;

  /// Индекс `Mood`.
  final int mood;
  final DateTime recordedAt;

  /// Ссылается на `Sessions.id`; null — сессия не состоялась.
  final String? sessionId;
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.recordedAt,
    this.sessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mood'] = Variable<int>(mood);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    return map;
  }

  MoodEntriesCompanion toCompanion(bool nullToAbsent) {
    return MoodEntriesCompanion(
      id: Value(id),
      mood: Value(mood),
      recordedAt: Value(recordedAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
    );
  }

  factory MoodEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodEntry(
      id: serializer.fromJson<String>(json['id']),
      mood: serializer.fromJson<int>(json['mood']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mood': serializer.toJson<int>(mood),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'sessionId': serializer.toJson<String?>(sessionId),
    };
  }

  MoodEntry copyWith({
    String? id,
    int? mood,
    DateTime? recordedAt,
    Value<String?> sessionId = const Value.absent(),
  }) => MoodEntry(
    id: id ?? this.id,
    mood: mood ?? this.mood,
    recordedAt: recordedAt ?? this.recordedAt,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
  );
  MoodEntry copyWithCompanion(MoodEntriesCompanion data) {
    return MoodEntry(
      id: data.id.present ? data.id.value : this.id,
      mood: data.mood.present ? data.mood.value : this.mood,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntry(')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mood, recordedAt, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodEntry &&
          other.id == this.id &&
          other.mood == this.mood &&
          other.recordedAt == this.recordedAt &&
          other.sessionId == this.sessionId);
}

class MoodEntriesCompanion extends UpdateCompanion<MoodEntry> {
  final Value<String> id;
  final Value<int> mood;
  final Value<DateTime> recordedAt;
  final Value<String?> sessionId;
  final Value<int> rowid;
  const MoodEntriesCompanion({
    this.id = const Value.absent(),
    this.mood = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoodEntriesCompanion.insert({
    required String id,
    required int mood,
    this.recordedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mood = Value(mood);
  static Insertable<MoodEntry> custom({
    Expression<String>? id,
    Expression<int>? mood,
    Expression<DateTime>? recordedAt,
    Expression<String>? sessionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mood != null) 'mood': mood,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoodEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? mood,
    Value<DateTime>? recordedAt,
    Value<String?>? sessionId,
    Value<int>? rowid,
  }) {
    return MoodEntriesCompanion(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      recordedAt: recordedAt ?? this.recordedAt,
      sessionId: sessionId ?? this.sessionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationWeightsTable extends RecommendationWeights
    with TableInfo<$RecommendationWeightsTable, RecommendationWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contextKeyMeta = const VerificationMeta(
    'contextKey',
  );
  @override
  late final GeneratedColumn<String> contextKey = GeneratedColumn<String>(
    'context_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _techniqueKeyMeta = const VerificationMeta(
    'techniqueKey',
  );
  @override
  late final GeneratedColumn<String> techniqueKey = GeneratedColumn<String>(
    'technique_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alphaMeta = const VerificationMeta('alpha');
  @override
  late final GeneratedColumn<double> alpha = GeneratedColumn<double>(
    'alpha',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _betaMeta = const VerificationMeta('beta');
  @override
  late final GeneratedColumn<double> beta = GeneratedColumn<double>(
    'beta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
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
  @override
  List<GeneratedColumn> get $columns => [
    contextKey,
    techniqueKey,
    alpha,
    beta,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendation_weights';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecommendationWeight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('context_key')) {
      context.handle(
        _contextKeyMeta,
        contextKey.isAcceptableOrUnknown(data['context_key']!, _contextKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_contextKeyMeta);
    }
    if (data.containsKey('technique_key')) {
      context.handle(
        _techniqueKeyMeta,
        techniqueKey.isAcceptableOrUnknown(
          data['technique_key']!,
          _techniqueKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_techniqueKeyMeta);
    }
    if (data.containsKey('alpha')) {
      context.handle(
        _alphaMeta,
        alpha.isAcceptableOrUnknown(data['alpha']!, _alphaMeta),
      );
    }
    if (data.containsKey('beta')) {
      context.handle(
        _betaMeta,
        beta.isAcceptableOrUnknown(data['beta']!, _betaMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contextKey, techniqueKey};
  @override
  RecommendationWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecommendationWeight(
      contextKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_key'],
      )!,
      techniqueKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technique_key'],
      )!,
      alpha: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alpha'],
      )!,
      beta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}beta'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RecommendationWeightsTable createAlias(String alias) {
    return $RecommendationWeightsTable(attachedDatabase, alias);
  }
}

class RecommendationWeight extends DataClass
    implements Insertable<RecommendationWeight> {
  /// Ключ контекста: `mood|category|difficulty|timeOfDay|weekday`, либо
  /// один из огрублённых вариантов (`mood|category`, `mood`).
  final String contextKey;

  /// Строковый ключ `FocusTechnique`.
  final String techniqueKey;
  final double alpha;
  final double beta;
  final DateTime updatedAt;
  const RecommendationWeight({
    required this.contextKey,
    required this.techniqueKey,
    required this.alpha,
    required this.beta,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['context_key'] = Variable<String>(contextKey);
    map['technique_key'] = Variable<String>(techniqueKey);
    map['alpha'] = Variable<double>(alpha);
    map['beta'] = Variable<double>(beta);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecommendationWeightsCompanion toCompanion(bool nullToAbsent) {
    return RecommendationWeightsCompanion(
      contextKey: Value(contextKey),
      techniqueKey: Value(techniqueKey),
      alpha: Value(alpha),
      beta: Value(beta),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecommendationWeight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecommendationWeight(
      contextKey: serializer.fromJson<String>(json['contextKey']),
      techniqueKey: serializer.fromJson<String>(json['techniqueKey']),
      alpha: serializer.fromJson<double>(json['alpha']),
      beta: serializer.fromJson<double>(json['beta']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contextKey': serializer.toJson<String>(contextKey),
      'techniqueKey': serializer.toJson<String>(techniqueKey),
      'alpha': serializer.toJson<double>(alpha),
      'beta': serializer.toJson<double>(beta),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecommendationWeight copyWith({
    String? contextKey,
    String? techniqueKey,
    double? alpha,
    double? beta,
    DateTime? updatedAt,
  }) => RecommendationWeight(
    contextKey: contextKey ?? this.contextKey,
    techniqueKey: techniqueKey ?? this.techniqueKey,
    alpha: alpha ?? this.alpha,
    beta: beta ?? this.beta,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecommendationWeight copyWithCompanion(RecommendationWeightsCompanion data) {
    return RecommendationWeight(
      contextKey: data.contextKey.present
          ? data.contextKey.value
          : this.contextKey,
      techniqueKey: data.techniqueKey.present
          ? data.techniqueKey.value
          : this.techniqueKey,
      alpha: data.alpha.present ? data.alpha.value : this.alpha,
      beta: data.beta.present ? data.beta.value : this.beta,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationWeight(')
          ..write('contextKey: $contextKey, ')
          ..write('techniqueKey: $techniqueKey, ')
          ..write('alpha: $alpha, ')
          ..write('beta: $beta, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(contextKey, techniqueKey, alpha, beta, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecommendationWeight &&
          other.contextKey == this.contextKey &&
          other.techniqueKey == this.techniqueKey &&
          other.alpha == this.alpha &&
          other.beta == this.beta &&
          other.updatedAt == this.updatedAt);
}

class RecommendationWeightsCompanion
    extends UpdateCompanion<RecommendationWeight> {
  final Value<String> contextKey;
  final Value<String> techniqueKey;
  final Value<double> alpha;
  final Value<double> beta;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecommendationWeightsCompanion({
    this.contextKey = const Value.absent(),
    this.techniqueKey = const Value.absent(),
    this.alpha = const Value.absent(),
    this.beta = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecommendationWeightsCompanion.insert({
    required String contextKey,
    required String techniqueKey,
    this.alpha = const Value.absent(),
    this.beta = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contextKey = Value(contextKey),
       techniqueKey = Value(techniqueKey);
  static Insertable<RecommendationWeight> custom({
    Expression<String>? contextKey,
    Expression<String>? techniqueKey,
    Expression<double>? alpha,
    Expression<double>? beta,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contextKey != null) 'context_key': contextKey,
      if (techniqueKey != null) 'technique_key': techniqueKey,
      if (alpha != null) 'alpha': alpha,
      if (beta != null) 'beta': beta,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecommendationWeightsCompanion copyWith({
    Value<String>? contextKey,
    Value<String>? techniqueKey,
    Value<double>? alpha,
    Value<double>? beta,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecommendationWeightsCompanion(
      contextKey: contextKey ?? this.contextKey,
      techniqueKey: techniqueKey ?? this.techniqueKey,
      alpha: alpha ?? this.alpha,
      beta: beta ?? this.beta,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contextKey.present) {
      map['context_key'] = Variable<String>(contextKey.value);
    }
    if (techniqueKey.present) {
      map['technique_key'] = Variable<String>(techniqueKey.value);
    }
    if (alpha.present) {
      map['alpha'] = Variable<double>(alpha.value);
    }
    if (beta.present) {
      map['beta'] = Variable<double>(beta.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationWeightsCompanion(')
          ..write('contextKey: $contextKey, ')
          ..write('techniqueKey: $techniqueKey, ')
          ..write('alpha: $alpha, ')
          ..write('beta: $beta, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerProgressTable extends PlayerProgress
    with TableInfo<$PlayerProgressTable, PlayerProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(gameSingletonId),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _drifterKillsMeta = const VerificationMeta(
    'drifterKills',
  );
  @override
  late final GeneratedColumn<int> drifterKills = GeneratedColumn<int>(
    'drifter_kills',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bossKillsMeta = const VerificationMeta(
    'bossKills',
  );
  @override
  late final GeneratedColumn<int> bossKills = GeneratedColumn<int>(
    'boss_kills',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    totalXp,
    drifterKills,
    bossKills,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('drifter_kills')) {
      context.handle(
        _drifterKillsMeta,
        drifterKills.isAcceptableOrUnknown(
          data['drifter_kills']!,
          _drifterKillsMeta,
        ),
      );
    }
    if (data.containsKey('boss_kills')) {
      context.handle(
        _bossKillsMeta,
        bossKills.isAcceptableOrUnknown(data['boss_kills']!, _bossKillsMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      drifterKills: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}drifter_kills'],
      )!,
      bossKills: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}boss_kills'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlayerProgressTable createAlias(String alias) {
    return $PlayerProgressTable(attachedDatabase, alias);
  }
}

class PlayerProgressData extends DataClass
    implements Insertable<PlayerProgressData> {
  /// Singleton-строка: игрок в приложении один.
  final int id;
  final int totalXp;

  /// Счётчики для экрана персонажа. Считать их каждый раз по карте нельзя:
  /// побеждённые дриферы на пройденных узлах перезаписываются, а история
  /// побед должна оставаться.
  final int drifterKills;
  final int bossKills;
  final DateTime updatedAt;
  const PlayerProgressData({
    required this.id,
    required this.totalXp,
    required this.drifterKills,
    required this.bossKills,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['total_xp'] = Variable<int>(totalXp);
    map['drifter_kills'] = Variable<int>(drifterKills);
    map['boss_kills'] = Variable<int>(bossKills);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlayerProgressCompanion toCompanion(bool nullToAbsent) {
    return PlayerProgressCompanion(
      id: Value(id),
      totalXp: Value(totalXp),
      drifterKills: Value(drifterKills),
      bossKills: Value(bossKills),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlayerProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerProgressData(
      id: serializer.fromJson<int>(json['id']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      drifterKills: serializer.fromJson<int>(json['drifterKills']),
      bossKills: serializer.fromJson<int>(json['bossKills']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'totalXp': serializer.toJson<int>(totalXp),
      'drifterKills': serializer.toJson<int>(drifterKills),
      'bossKills': serializer.toJson<int>(bossKills),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlayerProgressData copyWith({
    int? id,
    int? totalXp,
    int? drifterKills,
    int? bossKills,
    DateTime? updatedAt,
  }) => PlayerProgressData(
    id: id ?? this.id,
    totalXp: totalXp ?? this.totalXp,
    drifterKills: drifterKills ?? this.drifterKills,
    bossKills: bossKills ?? this.bossKills,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlayerProgressData copyWithCompanion(PlayerProgressCompanion data) {
    return PlayerProgressData(
      id: data.id.present ? data.id.value : this.id,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      drifterKills: data.drifterKills.present
          ? data.drifterKills.value
          : this.drifterKills,
      bossKills: data.bossKills.present ? data.bossKills.value : this.bossKills,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProgressData(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('drifterKills: $drifterKills, ')
          ..write('bossKills: $bossKills, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, totalXp, drifterKills, bossKills, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerProgressData &&
          other.id == this.id &&
          other.totalXp == this.totalXp &&
          other.drifterKills == this.drifterKills &&
          other.bossKills == this.bossKills &&
          other.updatedAt == this.updatedAt);
}

class PlayerProgressCompanion extends UpdateCompanion<PlayerProgressData> {
  final Value<int> id;
  final Value<int> totalXp;
  final Value<int> drifterKills;
  final Value<int> bossKills;
  final Value<DateTime> updatedAt;
  const PlayerProgressCompanion({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.drifterKills = const Value.absent(),
    this.bossKills = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlayerProgressCompanion.insert({
    this.id = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.drifterKills = const Value.absent(),
    this.bossKills = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<PlayerProgressData> custom({
    Expression<int>? id,
    Expression<int>? totalXp,
    Expression<int>? drifterKills,
    Expression<int>? bossKills,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (totalXp != null) 'total_xp': totalXp,
      if (drifterKills != null) 'drifter_kills': drifterKills,
      if (bossKills != null) 'boss_kills': bossKills,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlayerProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? totalXp,
    Value<int>? drifterKills,
    Value<int>? bossKills,
    Value<DateTime>? updatedAt,
  }) {
    return PlayerProgressCompanion(
      id: id ?? this.id,
      totalXp: totalXp ?? this.totalXp,
      drifterKills: drifterKills ?? this.drifterKills,
      bossKills: bossKills ?? this.bossKills,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (drifterKills.present) {
      map['drifter_kills'] = Variable<int>(drifterKills.value);
    }
    if (bossKills.present) {
      map['boss_kills'] = Variable<int>(bossKills.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProgressCompanion(')
          ..write('id: $id, ')
          ..write('totalXp: $totalXp, ')
          ..write('drifterKills: $drifterKills, ')
          ..write('bossKills: $bossKills, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MapNodesTable extends MapNodes with TableInfo<$MapNodesTable, MapNode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _worldMeta = const VerificationMeta('world');
  @override
  late final GeneratedColumn<int> world = GeneratedColumn<int>(
    'world',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<int> species = GeneratedColumn<int>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxHpMeta = const VerificationMeta('maxHp');
  @override
  late final GeneratedColumn<int> maxHp = GeneratedColumn<int>(
    'max_hp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentHpMeta = const VerificationMeta(
    'currentHp',
  );
  @override
  late final GeneratedColumn<int> currentHp = GeneratedColumn<int>(
    'current_hp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerHpMeta = const VerificationMeta(
    'playerHp',
  );
  @override
  late final GeneratedColumn<int> playerHp = GeneratedColumn<int>(
    'player_hp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _goldenMeta = const VerificationMeta('golden');
  @override
  late final GeneratedColumn<bool> golden = GeneratedColumn<bool>(
    'golden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("golden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _abandonedCountMeta = const VerificationMeta(
    'abandonedCount',
  );
  @override
  late final GeneratedColumn<int> abandonedCount = GeneratedColumn<int>(
    'abandoned_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastFoughtAtMeta = const VerificationMeta(
    'lastFoughtAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFoughtAt = GeneratedColumn<DateTime>(
    'last_fought_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    world,
    position,
    kind,
    status,
    species,
    maxHp,
    currentHp,
    playerHp,
    golden,
    abandonedCount,
    lastFoughtAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'map_nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MapNode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('world')) {
      context.handle(
        _worldMeta,
        world.isAcceptableOrUnknown(data['world']!, _worldMeta),
      );
    } else if (isInserting) {
      context.missing(_worldMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    }
    if (data.containsKey('max_hp')) {
      context.handle(
        _maxHpMeta,
        maxHp.isAcceptableOrUnknown(data['max_hp']!, _maxHpMeta),
      );
    } else if (isInserting) {
      context.missing(_maxHpMeta);
    }
    if (data.containsKey('current_hp')) {
      context.handle(
        _currentHpMeta,
        currentHp.isAcceptableOrUnknown(data['current_hp']!, _currentHpMeta),
      );
    } else if (isInserting) {
      context.missing(_currentHpMeta);
    }
    if (data.containsKey('player_hp')) {
      context.handle(
        _playerHpMeta,
        playerHp.isAcceptableOrUnknown(data['player_hp']!, _playerHpMeta),
      );
    }
    if (data.containsKey('golden')) {
      context.handle(
        _goldenMeta,
        golden.isAcceptableOrUnknown(data['golden']!, _goldenMeta),
      );
    }
    if (data.containsKey('abandoned_count')) {
      context.handle(
        _abandonedCountMeta,
        abandonedCount.isAcceptableOrUnknown(
          data['abandoned_count']!,
          _abandonedCountMeta,
        ),
      );
    }
    if (data.containsKey('last_fought_at')) {
      context.handle(
        _lastFoughtAtMeta,
        lastFoughtAt.isAcceptableOrUnknown(
          data['last_fought_at']!,
          _lastFoughtAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MapNode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapNode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      world: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}world'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kind'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species'],
      )!,
      maxHp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_hp'],
      )!,
      currentHp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_hp'],
      )!,
      playerHp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_hp'],
      )!,
      golden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}golden'],
      )!,
      abandonedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}abandoned_count'],
      )!,
      lastFoughtAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fought_at'],
      ),
    );
  }

  @override
  $MapNodesTable createAlias(String alias) {
    return $MapNodesTable(attachedDatabase, alias);
  }
}

class MapNode extends DataClass implements Insertable<MapNode> {
  /// `w1n2` — мир и позиция. Строкой: так id читаем в логах и не разъедется
  /// при смене нумерации.
  final String id;

  /// 1-based номер мира.
  final int world;

  /// 1-based позиция внутри мира.
  final int position;

  /// `MapNodeKind`: обычный дрифер или босс.
  final int kind;

  /// `MapNodeStatus`: locked / current / completed.
  final int status;

  /// `DrifterSpecies` — какой именно силуэт здесь стоит.
  final int species;
  final int maxHp;
  final int currentHp;

  /// Запас персонажа на текущем заходе к боссу.
  final int playerHp;

  /// Редкая окраска дрифера. Решается один раз — в тот момент, когда узел
  /// становится текущим, — и с тех пор хранится: цвет противника не должен
  /// меняться между запусками приложения.
  ///
  /// Колонка, а не вычисление на лету: детерминированная формула от id узла
  /// дала бы одну и ту же карту всем и превратила бы редкость в расписание.
  final bool golden;

  /// Сколько раз заход на этот узел обрывался, не добив противника.
  ///
  /// Считается только для того, чтобы дрифер мог об этом обмолвиться при
  /// следующей встрече. Ни в HP, ни в уроне, ни в опыте счётчик не участвует:
  /// приложение просит останавливаться честно, и превращать честную
  /// остановку в механический штраф означало бы просить об одном, а
  /// наказывать за другое.
  final int abandonedCount;

  /// Когда по узлу били в последний раз — от этого зависит, успел ли
  /// недобитый дрифер восстановиться.
  final DateTime? lastFoughtAt;
  const MapNode({
    required this.id,
    required this.world,
    required this.position,
    required this.kind,
    required this.status,
    required this.species,
    required this.maxHp,
    required this.currentHp,
    required this.playerHp,
    required this.golden,
    required this.abandonedCount,
    this.lastFoughtAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['world'] = Variable<int>(world);
    map['position'] = Variable<int>(position);
    map['kind'] = Variable<int>(kind);
    map['status'] = Variable<int>(status);
    map['species'] = Variable<int>(species);
    map['max_hp'] = Variable<int>(maxHp);
    map['current_hp'] = Variable<int>(currentHp);
    map['player_hp'] = Variable<int>(playerHp);
    map['golden'] = Variable<bool>(golden);
    map['abandoned_count'] = Variable<int>(abandonedCount);
    if (!nullToAbsent || lastFoughtAt != null) {
      map['last_fought_at'] = Variable<DateTime>(lastFoughtAt);
    }
    return map;
  }

  MapNodesCompanion toCompanion(bool nullToAbsent) {
    return MapNodesCompanion(
      id: Value(id),
      world: Value(world),
      position: Value(position),
      kind: Value(kind),
      status: Value(status),
      species: Value(species),
      maxHp: Value(maxHp),
      currentHp: Value(currentHp),
      playerHp: Value(playerHp),
      golden: Value(golden),
      abandonedCount: Value(abandonedCount),
      lastFoughtAt: lastFoughtAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFoughtAt),
    );
  }

  factory MapNode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapNode(
      id: serializer.fromJson<String>(json['id']),
      world: serializer.fromJson<int>(json['world']),
      position: serializer.fromJson<int>(json['position']),
      kind: serializer.fromJson<int>(json['kind']),
      status: serializer.fromJson<int>(json['status']),
      species: serializer.fromJson<int>(json['species']),
      maxHp: serializer.fromJson<int>(json['maxHp']),
      currentHp: serializer.fromJson<int>(json['currentHp']),
      playerHp: serializer.fromJson<int>(json['playerHp']),
      golden: serializer.fromJson<bool>(json['golden']),
      abandonedCount: serializer.fromJson<int>(json['abandonedCount']),
      lastFoughtAt: serializer.fromJson<DateTime?>(json['lastFoughtAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'world': serializer.toJson<int>(world),
      'position': serializer.toJson<int>(position),
      'kind': serializer.toJson<int>(kind),
      'status': serializer.toJson<int>(status),
      'species': serializer.toJson<int>(species),
      'maxHp': serializer.toJson<int>(maxHp),
      'currentHp': serializer.toJson<int>(currentHp),
      'playerHp': serializer.toJson<int>(playerHp),
      'golden': serializer.toJson<bool>(golden),
      'abandonedCount': serializer.toJson<int>(abandonedCount),
      'lastFoughtAt': serializer.toJson<DateTime?>(lastFoughtAt),
    };
  }

  MapNode copyWith({
    String? id,
    int? world,
    int? position,
    int? kind,
    int? status,
    int? species,
    int? maxHp,
    int? currentHp,
    int? playerHp,
    bool? golden,
    int? abandonedCount,
    Value<DateTime?> lastFoughtAt = const Value.absent(),
  }) => MapNode(
    id: id ?? this.id,
    world: world ?? this.world,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    species: species ?? this.species,
    maxHp: maxHp ?? this.maxHp,
    currentHp: currentHp ?? this.currentHp,
    playerHp: playerHp ?? this.playerHp,
    golden: golden ?? this.golden,
    abandonedCount: abandonedCount ?? this.abandonedCount,
    lastFoughtAt: lastFoughtAt.present ? lastFoughtAt.value : this.lastFoughtAt,
  );
  MapNode copyWithCompanion(MapNodesCompanion data) {
    return MapNode(
      id: data.id.present ? data.id.value : this.id,
      world: data.world.present ? data.world.value : this.world,
      position: data.position.present ? data.position.value : this.position,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      species: data.species.present ? data.species.value : this.species,
      maxHp: data.maxHp.present ? data.maxHp.value : this.maxHp,
      currentHp: data.currentHp.present ? data.currentHp.value : this.currentHp,
      playerHp: data.playerHp.present ? data.playerHp.value : this.playerHp,
      golden: data.golden.present ? data.golden.value : this.golden,
      abandonedCount: data.abandonedCount.present
          ? data.abandonedCount.value
          : this.abandonedCount,
      lastFoughtAt: data.lastFoughtAt.present
          ? data.lastFoughtAt.value
          : this.lastFoughtAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapNode(')
          ..write('id: $id, ')
          ..write('world: $world, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('species: $species, ')
          ..write('maxHp: $maxHp, ')
          ..write('currentHp: $currentHp, ')
          ..write('playerHp: $playerHp, ')
          ..write('golden: $golden, ')
          ..write('abandonedCount: $abandonedCount, ')
          ..write('lastFoughtAt: $lastFoughtAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    world,
    position,
    kind,
    status,
    species,
    maxHp,
    currentHp,
    playerHp,
    golden,
    abandonedCount,
    lastFoughtAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapNode &&
          other.id == this.id &&
          other.world == this.world &&
          other.position == this.position &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.species == this.species &&
          other.maxHp == this.maxHp &&
          other.currentHp == this.currentHp &&
          other.playerHp == this.playerHp &&
          other.golden == this.golden &&
          other.abandonedCount == this.abandonedCount &&
          other.lastFoughtAt == this.lastFoughtAt);
}

class MapNodesCompanion extends UpdateCompanion<MapNode> {
  final Value<String> id;
  final Value<int> world;
  final Value<int> position;
  final Value<int> kind;
  final Value<int> status;
  final Value<int> species;
  final Value<int> maxHp;
  final Value<int> currentHp;
  final Value<int> playerHp;
  final Value<bool> golden;
  final Value<int> abandonedCount;
  final Value<DateTime?> lastFoughtAt;
  final Value<int> rowid;
  const MapNodesCompanion({
    this.id = const Value.absent(),
    this.world = const Value.absent(),
    this.position = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.species = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.currentHp = const Value.absent(),
    this.playerHp = const Value.absent(),
    this.golden = const Value.absent(),
    this.abandonedCount = const Value.absent(),
    this.lastFoughtAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MapNodesCompanion.insert({
    required String id,
    required int world,
    required int position,
    required int kind,
    required int status,
    this.species = const Value.absent(),
    required int maxHp,
    required int currentHp,
    this.playerHp = const Value.absent(),
    this.golden = const Value.absent(),
    this.abandonedCount = const Value.absent(),
    this.lastFoughtAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       world = Value(world),
       position = Value(position),
       kind = Value(kind),
       status = Value(status),
       maxHp = Value(maxHp),
       currentHp = Value(currentHp);
  static Insertable<MapNode> custom({
    Expression<String>? id,
    Expression<int>? world,
    Expression<int>? position,
    Expression<int>? kind,
    Expression<int>? status,
    Expression<int>? species,
    Expression<int>? maxHp,
    Expression<int>? currentHp,
    Expression<int>? playerHp,
    Expression<bool>? golden,
    Expression<int>? abandonedCount,
    Expression<DateTime>? lastFoughtAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (world != null) 'world': world,
      if (position != null) 'position': position,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (species != null) 'species': species,
      if (maxHp != null) 'max_hp': maxHp,
      if (currentHp != null) 'current_hp': currentHp,
      if (playerHp != null) 'player_hp': playerHp,
      if (golden != null) 'golden': golden,
      if (abandonedCount != null) 'abandoned_count': abandonedCount,
      if (lastFoughtAt != null) 'last_fought_at': lastFoughtAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MapNodesCompanion copyWith({
    Value<String>? id,
    Value<int>? world,
    Value<int>? position,
    Value<int>? kind,
    Value<int>? status,
    Value<int>? species,
    Value<int>? maxHp,
    Value<int>? currentHp,
    Value<int>? playerHp,
    Value<bool>? golden,
    Value<int>? abandonedCount,
    Value<DateTime?>? lastFoughtAt,
    Value<int>? rowid,
  }) {
    return MapNodesCompanion(
      id: id ?? this.id,
      world: world ?? this.world,
      position: position ?? this.position,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      species: species ?? this.species,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      playerHp: playerHp ?? this.playerHp,
      golden: golden ?? this.golden,
      abandonedCount: abandonedCount ?? this.abandonedCount,
      lastFoughtAt: lastFoughtAt ?? this.lastFoughtAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (world.present) {
      map['world'] = Variable<int>(world.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (species.present) {
      map['species'] = Variable<int>(species.value);
    }
    if (maxHp.present) {
      map['max_hp'] = Variable<int>(maxHp.value);
    }
    if (currentHp.present) {
      map['current_hp'] = Variable<int>(currentHp.value);
    }
    if (playerHp.present) {
      map['player_hp'] = Variable<int>(playerHp.value);
    }
    if (golden.present) {
      map['golden'] = Variable<bool>(golden.value);
    }
    if (abandonedCount.present) {
      map['abandoned_count'] = Variable<int>(abandonedCount.value);
    }
    if (lastFoughtAt.present) {
      map['last_fought_at'] = Variable<DateTime>(lastFoughtAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapNodesCompanion(')
          ..write('id: $id, ')
          ..write('world: $world, ')
          ..write('position: $position, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('species: $species, ')
          ..write('maxHp: $maxHp, ')
          ..write('currentHp: $currentHp, ')
          ..write('playerHp: $playerHp, ')
          ..write('golden: $golden, ')
          ..write('abandonedCount: $abandonedCount, ')
          ..write('lastFoughtAt: $lastFoughtAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSettingsTable extends GameSettings
    with TableInfo<$GameSettingsTable, GameSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(gameSingletonId),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $GameSettingsTable createAlias(String alias) {
    return $GameSettingsTable(attachedDatabase, alias);
  }
}

class GameSetting extends DataClass implements Insertable<GameSetting> {
  final int id;

  /// Игровой режим включён. По умолчанию выключен: обычный трекер остаётся
  /// поведением по умолчанию, игра — осознанный выбор.
  final bool enabled;
  const GameSetting({required this.id, required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  GameSettingsCompanion toCompanion(bool nullToAbsent) {
    return GameSettingsCompanion(id: Value(id), enabled: Value(enabled));
  }

  factory GameSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSetting(
      id: serializer.fromJson<int>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  GameSetting copyWith({int? id, bool? enabled}) =>
      GameSetting(id: id ?? this.id, enabled: enabled ?? this.enabled);
  GameSetting copyWithCompanion(GameSettingsCompanion data) {
    return GameSetting(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSetting(')
          ..write('id: $id, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSetting &&
          other.id == this.id &&
          other.enabled == this.enabled);
}

class GameSettingsCompanion extends UpdateCompanion<GameSetting> {
  final Value<int> id;
  final Value<bool> enabled;
  const GameSettingsCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  GameSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  static Insertable<GameSetting> custom({
    Expression<int>? id,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
    });
  }

  GameSettingsCompanion copyWith({Value<int>? id, Value<bool>? enabled}) {
    return GameSettingsCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSettingsCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitCompletionsTable habitCompletions = $HabitCompletionsTable(
    this,
  );
  late final $HabitFreezesTable habitFreezes = $HabitFreezesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $DayPlanEntriesTable dayPlanEntries = $DayPlanEntriesTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $MoodEntriesTable moodEntries = $MoodEntriesTable(this);
  late final $RecommendationWeightsTable recommendationWeights =
      $RecommendationWeightsTable(this);
  late final $PlayerProgressTable playerProgress = $PlayerProgressTable(this);
  late final $MapNodesTable mapNodes = $MapNodesTable(this);
  late final $GameSettingsTable gameSettings = $GameSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habits,
    habitCompletions,
    habitFreezes,
    tasks,
    dayPlanEntries,
    subtasks,
    sessions,
    moodEntries,
    recommendationWeights,
    playerProgress,
    mapNodes,
    gameSettings,
  ];
}

typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      required String name,
      required String punishment,
      Value<int> frequencyType,
      Value<int> weekdayMask,
      Value<int> timesPerWeek,
      Value<String?> reward,
      Value<int> rewardStreakDays,
      Value<int> freezeIntervalDays,
      Value<int?> reminderMinutes,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> punishment,
      Value<int> frequencyType,
      Value<int> weekdayMask,
      Value<int> timesPerWeek,
      Value<String?> reward,
      Value<int> rewardStreakDays,
      Value<int> freezeIntervalDays,
      Value<int?> reminderMinutes,
      Value<bool> archived,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get punishment => $composableBuilder(
    column: $table.punishment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardStreakDays => $composableBuilder(
    column: $table.rewardStreakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freezeIntervalDays => $composableBuilder(
    column: $table.freezeIntervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get punishment => $composableBuilder(
    column: $table.punishment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardStreakDays => $composableBuilder(
    column: $table.rewardStreakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freezeIntervalDays => $composableBuilder(
    column: $table.freezeIntervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get punishment => $composableBuilder(
    column: $table.punishment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);

  GeneratedColumn<int> get rewardStreakDays => $composableBuilder(
    column: $table.rewardStreakDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freezeIntervalDays => $composableBuilder(
    column: $table.freezeIntervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> punishment = const Value.absent(),
                Value<int> frequencyType = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<String?> reward = const Value.absent(),
                Value<int> rewardStreakDays = const Value.absent(),
                Value<int> freezeIntervalDays = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                punishment: punishment,
                frequencyType: frequencyType,
                weekdayMask: weekdayMask,
                timesPerWeek: timesPerWeek,
                reward: reward,
                rewardStreakDays: rewardStreakDays,
                freezeIntervalDays: freezeIntervalDays,
                reminderMinutes: reminderMinutes,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String punishment,
                Value<int> frequencyType = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<String?> reward = const Value.absent(),
                Value<int> rewardStreakDays = const Value.absent(),
                Value<int> freezeIntervalDays = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                punishment: punishment,
                frequencyType: frequencyType,
                weekdayMask: weekdayMask,
                timesPerWeek: timesPerWeek,
                reward: reward,
                rewardStreakDays: rewardStreakDays,
                freezeIntervalDays: freezeIntervalDays,
                reminderMinutes: reminderMinutes,
                archived: archived,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitCompletionsTableCreateCompanionBuilder =
    HabitCompletionsCompanion Function({
      required String id,
      required String habitId,
      required DateTime day,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });
typedef $$HabitCompletionsTableUpdateCompanionBuilder =
    HabitCompletionsCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> day,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$HabitCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$HabitCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitCompletionsTable,
          HabitCompletion,
          $$HabitCompletionsTableFilterComposer,
          $$HabitCompletionsTableOrderingComposer,
          $$HabitCompletionsTableAnnotationComposer,
          $$HabitCompletionsTableCreateCompanionBuilder,
          $$HabitCompletionsTableUpdateCompanionBuilder,
          (
            HabitCompletion,
            BaseReferences<
              _$AppDatabase,
              $HabitCompletionsTable,
              HabitCompletion
            >,
          ),
          HabitCompletion,
          PrefetchHooks Function()
        > {
  $$HabitCompletionsTableTableManager(
    _$AppDatabase db,
    $HabitCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion(
                id: id,
                habitId: habitId,
                day: day,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime day,
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion.insert(
                id: id,
                habitId: habitId,
                day: day,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitCompletionsTable,
      HabitCompletion,
      $$HabitCompletionsTableFilterComposer,
      $$HabitCompletionsTableOrderingComposer,
      $$HabitCompletionsTableAnnotationComposer,
      $$HabitCompletionsTableCreateCompanionBuilder,
      $$HabitCompletionsTableUpdateCompanionBuilder,
      (
        HabitCompletion,
        BaseReferences<_$AppDatabase, $HabitCompletionsTable, HabitCompletion>,
      ),
      HabitCompletion,
      PrefetchHooks Function()
    >;
typedef $$HabitFreezesTableCreateCompanionBuilder =
    HabitFreezesCompanion Function({
      required String id,
      required String habitId,
      required DateTime day,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$HabitFreezesTableUpdateCompanionBuilder =
    HabitFreezesCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> day,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$HabitFreezesTableFilterComposer
    extends Composer<_$AppDatabase, $HabitFreezesTable> {
  $$HabitFreezesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitFreezesTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitFreezesTable> {
  $$HabitFreezesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitFreezesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitFreezesTable> {
  $$HabitFreezesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitFreezesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitFreezesTable,
          HabitFreeze,
          $$HabitFreezesTableFilterComposer,
          $$HabitFreezesTableOrderingComposer,
          $$HabitFreezesTableAnnotationComposer,
          $$HabitFreezesTableCreateCompanionBuilder,
          $$HabitFreezesTableUpdateCompanionBuilder,
          (
            HabitFreeze,
            BaseReferences<_$AppDatabase, $HabitFreezesTable, HabitFreeze>,
          ),
          HabitFreeze,
          PrefetchHooks Function()
        > {
  $$HabitFreezesTableTableManager(_$AppDatabase db, $HabitFreezesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitFreezesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitFreezesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitFreezesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitFreezesCompanion(
                id: id,
                habitId: habitId,
                day: day,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime day,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitFreezesCompanion.insert(
                id: id,
                habitId: habitId,
                day: day,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitFreezesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitFreezesTable,
      HabitFreeze,
      $$HabitFreezesTableFilterComposer,
      $$HabitFreezesTableOrderingComposer,
      $$HabitFreezesTableAnnotationComposer,
      $$HabitFreezesTableCreateCompanionBuilder,
      $$HabitFreezesTableUpdateCompanionBuilder,
      (
        HabitFreeze,
        BaseReferences<_$AppDatabase, $HabitFreezesTable, HabitFreeze>,
      ),
      HabitFreeze,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String title,
      Value<int> category,
      Value<int> difficulty,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> category,
      Value<int> difficulty,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
      Value<bool> archived,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> category = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                category: category,
                difficulty: difficulty,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<int> category = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                category: category,
                difficulty: difficulty,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$DayPlanEntriesTableCreateCompanionBuilder =
    DayPlanEntriesCompanion Function({
      required String id,
      required DateTime day,
      required String taskId,
      Value<int> sortOrder,
      Value<bool> done,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DayPlanEntriesTableUpdateCompanionBuilder =
    DayPlanEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> day,
      Value<String> taskId,
      Value<int> sortOrder,
      Value<bool> done,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DayPlanEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DayPlanEntriesTable> {
  $$DayPlanEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayPlanEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayPlanEntriesTable> {
  $$DayPlanEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayPlanEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayPlanEntriesTable> {
  $$DayPlanEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DayPlanEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayPlanEntriesTable,
          DayPlanEntry,
          $$DayPlanEntriesTableFilterComposer,
          $$DayPlanEntriesTableOrderingComposer,
          $$DayPlanEntriesTableAnnotationComposer,
          $$DayPlanEntriesTableCreateCompanionBuilder,
          $$DayPlanEntriesTableUpdateCompanionBuilder,
          (
            DayPlanEntry,
            BaseReferences<_$AppDatabase, $DayPlanEntriesTable, DayPlanEntry>,
          ),
          DayPlanEntry,
          PrefetchHooks Function()
        > {
  $$DayPlanEntriesTableTableManager(
    _$AppDatabase db,
    $DayPlanEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayPlanEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayPlanEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayPlanEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayPlanEntriesCompanion(
                id: id,
                day: day,
                taskId: taskId,
                sortOrder: sortOrder,
                done: done,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime day,
                required String taskId,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayPlanEntriesCompanion.insert(
                id: id,
                day: day,
                taskId: taskId,
                sortOrder: sortOrder,
                done: done,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayPlanEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayPlanEntriesTable,
      DayPlanEntry,
      $$DayPlanEntriesTableFilterComposer,
      $$DayPlanEntriesTableOrderingComposer,
      $$DayPlanEntriesTableAnnotationComposer,
      $$DayPlanEntriesTableCreateCompanionBuilder,
      $$DayPlanEntriesTableUpdateCompanionBuilder,
      (
        DayPlanEntry,
        BaseReferences<_$AppDatabase, $DayPlanEntriesTable, DayPlanEntry>,
      ),
      DayPlanEntry,
      PrefetchHooks Function()
    >;
typedef $$SubtasksTableCreateCompanionBuilder =
    SubtasksCompanion Function({
      required String id,
      required String taskId,
      required String title,
      Value<int> sortOrder,
      Value<bool> done,
      Value<int> rowid,
    });
typedef $$SubtasksTableUpdateCompanionBuilder =
    SubtasksCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> title,
      Value<int> sortOrder,
      Value<bool> done,
      Value<int> rowid,
    });

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);
}

class $$SubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtasksTable,
          Subtask,
          $$SubtasksTableFilterComposer,
          $$SubtasksTableOrderingComposer,
          $$SubtasksTableAnnotationComposer,
          $$SubtasksTableCreateCompanionBuilder,
          $$SubtasksTableUpdateCompanionBuilder,
          (Subtask, BaseReferences<_$AppDatabase, $SubtasksTable, Subtask>),
          Subtask,
          PrefetchHooks Function()
        > {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtasksCompanion(
                id: id,
                taskId: taskId,
                title: title,
                sortOrder: sortOrder,
                done: done,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String title,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubtasksCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                sortOrder: sortOrder,
                done: done,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtasksTable,
      Subtask,
      $$SubtasksTableFilterComposer,
      $$SubtasksTableOrderingComposer,
      $$SubtasksTableAnnotationComposer,
      $$SubtasksTableCreateCompanionBuilder,
      $$SubtasksTableUpdateCompanionBuilder,
      (Subtask, BaseReferences<_$AppDatabase, $SubtasksTable, Subtask>),
      Subtask,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      Value<String?> taskId,
      required String taskTitle,
      required int category,
      required int difficulty,
      required int mood,
      required String technique,
      required int plannedFocusMinutes,
      required int plannedBreakMinutes,
      required int plannedCycles,
      required int actualFocusSeconds,
      required int outcome,
      Value<int?> rating,
      required DateTime startedAt,
      required DateTime endedAt,
      required String contextKey,
      Value<bool> wasRecommended,
      Value<bool> wasManualOverride,
      Value<String?> interruptionReason,
      Value<String?> sessionNote,
      Value<String?> photoPath,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String?> taskId,
      Value<String> taskTitle,
      Value<int> category,
      Value<int> difficulty,
      Value<int> mood,
      Value<String> technique,
      Value<int> plannedFocusMinutes,
      Value<int> plannedBreakMinutes,
      Value<int> plannedCycles,
      Value<int> actualFocusSeconds,
      Value<int> outcome,
      Value<int?> rating,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<String> contextKey,
      Value<bool> wasRecommended,
      Value<bool> wasManualOverride,
      Value<String?> interruptionReason,
      Value<String?> sessionNote,
      Value<String?> photoPath,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get technique => $composableBuilder(
    column: $table.technique,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedFocusMinutes => $composableBuilder(
    column: $table.plannedFocusMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedBreakMinutes => $composableBuilder(
    column: $table.plannedBreakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedCycles => $composableBuilder(
    column: $table.plannedCycles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualFocusSeconds => $composableBuilder(
    column: $table.actualFocusSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasRecommended => $composableBuilder(
    column: $table.wasRecommended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasManualOverride => $composableBuilder(
    column: $table.wasManualOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interruptionReason => $composableBuilder(
    column: $table.interruptionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionNote => $composableBuilder(
    column: $table.sessionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technique => $composableBuilder(
    column: $table.technique,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedFocusMinutes => $composableBuilder(
    column: $table.plannedFocusMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedBreakMinutes => $composableBuilder(
    column: $table.plannedBreakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedCycles => $composableBuilder(
    column: $table.plannedCycles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualFocusSeconds => $composableBuilder(
    column: $table.actualFocusSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasRecommended => $composableBuilder(
    column: $table.wasRecommended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasManualOverride => $composableBuilder(
    column: $table.wasManualOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interruptionReason => $composableBuilder(
    column: $table.interruptionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionNote => $composableBuilder(
    column: $table.sessionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get technique =>
      $composableBuilder(column: $table.technique, builder: (column) => column);

  GeneratedColumn<int> get plannedFocusMinutes => $composableBuilder(
    column: $table.plannedFocusMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedBreakMinutes => $composableBuilder(
    column: $table.plannedBreakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedCycles => $composableBuilder(
    column: $table.plannedCycles,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualFocusSeconds => $composableBuilder(
    column: $table.actualFocusSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasRecommended => $composableBuilder(
    column: $table.wasRecommended,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasManualOverride => $composableBuilder(
    column: $table.wasManualOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interruptionReason => $composableBuilder(
    column: $table.interruptionReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionNote => $composableBuilder(
    column: $table.sessionNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String> taskTitle = const Value.absent(),
                Value<int> category = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<String> technique = const Value.absent(),
                Value<int> plannedFocusMinutes = const Value.absent(),
                Value<int> plannedBreakMinutes = const Value.absent(),
                Value<int> plannedCycles = const Value.absent(),
                Value<int> actualFocusSeconds = const Value.absent(),
                Value<int> outcome = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<String> contextKey = const Value.absent(),
                Value<bool> wasRecommended = const Value.absent(),
                Value<bool> wasManualOverride = const Value.absent(),
                Value<String?> interruptionReason = const Value.absent(),
                Value<String?> sessionNote = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                taskId: taskId,
                taskTitle: taskTitle,
                category: category,
                difficulty: difficulty,
                mood: mood,
                technique: technique,
                plannedFocusMinutes: plannedFocusMinutes,
                plannedBreakMinutes: plannedBreakMinutes,
                plannedCycles: plannedCycles,
                actualFocusSeconds: actualFocusSeconds,
                outcome: outcome,
                rating: rating,
                startedAt: startedAt,
                endedAt: endedAt,
                contextKey: contextKey,
                wasRecommended: wasRecommended,
                wasManualOverride: wasManualOverride,
                interruptionReason: interruptionReason,
                sessionNote: sessionNote,
                photoPath: photoPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> taskId = const Value.absent(),
                required String taskTitle,
                required int category,
                required int difficulty,
                required int mood,
                required String technique,
                required int plannedFocusMinutes,
                required int plannedBreakMinutes,
                required int plannedCycles,
                required int actualFocusSeconds,
                required int outcome,
                Value<int?> rating = const Value.absent(),
                required DateTime startedAt,
                required DateTime endedAt,
                required String contextKey,
                Value<bool> wasRecommended = const Value.absent(),
                Value<bool> wasManualOverride = const Value.absent(),
                Value<String?> interruptionReason = const Value.absent(),
                Value<String?> sessionNote = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                taskId: taskId,
                taskTitle: taskTitle,
                category: category,
                difficulty: difficulty,
                mood: mood,
                technique: technique,
                plannedFocusMinutes: plannedFocusMinutes,
                plannedBreakMinutes: plannedBreakMinutes,
                plannedCycles: plannedCycles,
                actualFocusSeconds: actualFocusSeconds,
                outcome: outcome,
                rating: rating,
                startedAt: startedAt,
                endedAt: endedAt,
                contextKey: contextKey,
                wasRecommended: wasRecommended,
                wasManualOverride: wasManualOverride,
                interruptionReason: interruptionReason,
                sessionNote: sessionNote,
                photoPath: photoPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$MoodEntriesTableCreateCompanionBuilder =
    MoodEntriesCompanion Function({
      required String id,
      required int mood,
      Value<DateTime> recordedAt,
      Value<String?> sessionId,
      Value<int> rowid,
    });
typedef $$MoodEntriesTableUpdateCompanionBuilder =
    MoodEntriesCompanion Function({
      Value<String> id,
      Value<int> mood,
      Value<DateTime> recordedAt,
      Value<String?> sessionId,
      Value<int> rowid,
    });

class $$MoodEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoodEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoodEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodEntriesTable> {
  $$MoodEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);
}

class $$MoodEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodEntriesTable,
          MoodEntry,
          $$MoodEntriesTableFilterComposer,
          $$MoodEntriesTableOrderingComposer,
          $$MoodEntriesTableAnnotationComposer,
          $$MoodEntriesTableCreateCompanionBuilder,
          $$MoodEntriesTableUpdateCompanionBuilder,
          (
            MoodEntry,
            BaseReferences<_$AppDatabase, $MoodEntriesTable, MoodEntry>,
          ),
          MoodEntry,
          PrefetchHooks Function()
        > {
  $$MoodEntriesTableTableManager(_$AppDatabase db, $MoodEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> mood = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodEntriesCompanion(
                id: id,
                mood: mood,
                recordedAt: recordedAt,
                sessionId: sessionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int mood,
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodEntriesCompanion.insert(
                id: id,
                mood: mood,
                recordedAt: recordedAt,
                sessionId: sessionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoodEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodEntriesTable,
      MoodEntry,
      $$MoodEntriesTableFilterComposer,
      $$MoodEntriesTableOrderingComposer,
      $$MoodEntriesTableAnnotationComposer,
      $$MoodEntriesTableCreateCompanionBuilder,
      $$MoodEntriesTableUpdateCompanionBuilder,
      (MoodEntry, BaseReferences<_$AppDatabase, $MoodEntriesTable, MoodEntry>),
      MoodEntry,
      PrefetchHooks Function()
    >;
typedef $$RecommendationWeightsTableCreateCompanionBuilder =
    RecommendationWeightsCompanion Function({
      required String contextKey,
      required String techniqueKey,
      Value<double> alpha,
      Value<double> beta,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$RecommendationWeightsTableUpdateCompanionBuilder =
    RecommendationWeightsCompanion Function({
      Value<String> contextKey,
      Value<String> techniqueKey,
      Value<double> alpha,
      Value<double> beta,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RecommendationWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationWeightsTable> {
  $$RecommendationWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techniqueKey => $composableBuilder(
    column: $table.techniqueKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alpha => $composableBuilder(
    column: $table.alpha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get beta => $composableBuilder(
    column: $table.beta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecommendationWeightsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationWeightsTable> {
  $$RecommendationWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techniqueKey => $composableBuilder(
    column: $table.techniqueKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alpha => $composableBuilder(
    column: $table.alpha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get beta => $composableBuilder(
    column: $table.beta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecommendationWeightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationWeightsTable> {
  $$RecommendationWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get techniqueKey => $composableBuilder(
    column: $table.techniqueKey,
    builder: (column) => column,
  );

  GeneratedColumn<double> get alpha =>
      $composableBuilder(column: $table.alpha, builder: (column) => column);

  GeneratedColumn<double> get beta =>
      $composableBuilder(column: $table.beta, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecommendationWeightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecommendationWeightsTable,
          RecommendationWeight,
          $$RecommendationWeightsTableFilterComposer,
          $$RecommendationWeightsTableOrderingComposer,
          $$RecommendationWeightsTableAnnotationComposer,
          $$RecommendationWeightsTableCreateCompanionBuilder,
          $$RecommendationWeightsTableUpdateCompanionBuilder,
          (
            RecommendationWeight,
            BaseReferences<
              _$AppDatabase,
              $RecommendationWeightsTable,
              RecommendationWeight
            >,
          ),
          RecommendationWeight,
          PrefetchHooks Function()
        > {
  $$RecommendationWeightsTableTableManager(
    _$AppDatabase db,
    $RecommendationWeightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationWeightsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecommendationWeightsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecommendationWeightsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> contextKey = const Value.absent(),
                Value<String> techniqueKey = const Value.absent(),
                Value<double> alpha = const Value.absent(),
                Value<double> beta = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecommendationWeightsCompanion(
                contextKey: contextKey,
                techniqueKey: techniqueKey,
                alpha: alpha,
                beta: beta,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String contextKey,
                required String techniqueKey,
                Value<double> alpha = const Value.absent(),
                Value<double> beta = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecommendationWeightsCompanion.insert(
                contextKey: contextKey,
                techniqueKey: techniqueKey,
                alpha: alpha,
                beta: beta,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecommendationWeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecommendationWeightsTable,
      RecommendationWeight,
      $$RecommendationWeightsTableFilterComposer,
      $$RecommendationWeightsTableOrderingComposer,
      $$RecommendationWeightsTableAnnotationComposer,
      $$RecommendationWeightsTableCreateCompanionBuilder,
      $$RecommendationWeightsTableUpdateCompanionBuilder,
      (
        RecommendationWeight,
        BaseReferences<
          _$AppDatabase,
          $RecommendationWeightsTable,
          RecommendationWeight
        >,
      ),
      RecommendationWeight,
      PrefetchHooks Function()
    >;
typedef $$PlayerProgressTableCreateCompanionBuilder =
    PlayerProgressCompanion Function({
      Value<int> id,
      Value<int> totalXp,
      Value<int> drifterKills,
      Value<int> bossKills,
      Value<DateTime> updatedAt,
    });
typedef $$PlayerProgressTableUpdateCompanionBuilder =
    PlayerProgressCompanion Function({
      Value<int> id,
      Value<int> totalXp,
      Value<int> drifterKills,
      Value<int> bossKills,
      Value<DateTime> updatedAt,
    });

class $$PlayerProgressTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerProgressTable> {
  $$PlayerProgressTableFilterComposer({
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

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drifterKills => $composableBuilder(
    column: $table.drifterKills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bossKills => $composableBuilder(
    column: $table.bossKills,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerProgressTable> {
  $$PlayerProgressTableOrderingComposer({
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

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drifterKills => $composableBuilder(
    column: $table.drifterKills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bossKills => $composableBuilder(
    column: $table.bossKills,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerProgressTable> {
  $$PlayerProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get drifterKills => $composableBuilder(
    column: $table.drifterKills,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bossKills =>
      $composableBuilder(column: $table.bossKills, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlayerProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerProgressTable,
          PlayerProgressData,
          $$PlayerProgressTableFilterComposer,
          $$PlayerProgressTableOrderingComposer,
          $$PlayerProgressTableAnnotationComposer,
          $$PlayerProgressTableCreateCompanionBuilder,
          $$PlayerProgressTableUpdateCompanionBuilder,
          (
            PlayerProgressData,
            BaseReferences<
              _$AppDatabase,
              $PlayerProgressTable,
              PlayerProgressData
            >,
          ),
          PlayerProgressData,
          PrefetchHooks Function()
        > {
  $$PlayerProgressTableTableManager(
    _$AppDatabase db,
    $PlayerProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> drifterKills = const Value.absent(),
                Value<int> bossKills = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlayerProgressCompanion(
                id: id,
                totalXp: totalXp,
                drifterKills: drifterKills,
                bossKills: bossKills,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> drifterKills = const Value.absent(),
                Value<int> bossKills = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlayerProgressCompanion.insert(
                id: id,
                totalXp: totalXp,
                drifterKills: drifterKills,
                bossKills: bossKills,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerProgressTable,
      PlayerProgressData,
      $$PlayerProgressTableFilterComposer,
      $$PlayerProgressTableOrderingComposer,
      $$PlayerProgressTableAnnotationComposer,
      $$PlayerProgressTableCreateCompanionBuilder,
      $$PlayerProgressTableUpdateCompanionBuilder,
      (
        PlayerProgressData,
        BaseReferences<_$AppDatabase, $PlayerProgressTable, PlayerProgressData>,
      ),
      PlayerProgressData,
      PrefetchHooks Function()
    >;
typedef $$MapNodesTableCreateCompanionBuilder =
    MapNodesCompanion Function({
      required String id,
      required int world,
      required int position,
      required int kind,
      required int status,
      Value<int> species,
      required int maxHp,
      required int currentHp,
      Value<int> playerHp,
      Value<bool> golden,
      Value<int> abandonedCount,
      Value<DateTime?> lastFoughtAt,
      Value<int> rowid,
    });
typedef $$MapNodesTableUpdateCompanionBuilder =
    MapNodesCompanion Function({
      Value<String> id,
      Value<int> world,
      Value<int> position,
      Value<int> kind,
      Value<int> status,
      Value<int> species,
      Value<int> maxHp,
      Value<int> currentHp,
      Value<int> playerHp,
      Value<bool> golden,
      Value<int> abandonedCount,
      Value<DateTime?> lastFoughtAt,
      Value<int> rowid,
    });

class $$MapNodesTableFilterComposer
    extends Composer<_$AppDatabase, $MapNodesTable> {
  $$MapNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get world => $composableBuilder(
    column: $table.world,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHp => $composableBuilder(
    column: $table.maxHp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentHp => $composableBuilder(
    column: $table.currentHp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playerHp => $composableBuilder(
    column: $table.playerHp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get golden => $composableBuilder(
    column: $table.golden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get abandonedCount => $composableBuilder(
    column: $table.abandonedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFoughtAt => $composableBuilder(
    column: $table.lastFoughtAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MapNodesTableOrderingComposer
    extends Composer<_$AppDatabase, $MapNodesTable> {
  $$MapNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get world => $composableBuilder(
    column: $table.world,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHp => $composableBuilder(
    column: $table.maxHp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentHp => $composableBuilder(
    column: $table.currentHp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playerHp => $composableBuilder(
    column: $table.playerHp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get golden => $composableBuilder(
    column: $table.golden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get abandonedCount => $composableBuilder(
    column: $table.abandonedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFoughtAt => $composableBuilder(
    column: $table.lastFoughtAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MapNodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapNodesTable> {
  $$MapNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get world =>
      $composableBuilder(column: $table.world, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<int> get maxHp =>
      $composableBuilder(column: $table.maxHp, builder: (column) => column);

  GeneratedColumn<int> get currentHp =>
      $composableBuilder(column: $table.currentHp, builder: (column) => column);

  GeneratedColumn<int> get playerHp =>
      $composableBuilder(column: $table.playerHp, builder: (column) => column);

  GeneratedColumn<bool> get golden =>
      $composableBuilder(column: $table.golden, builder: (column) => column);

  GeneratedColumn<int> get abandonedCount => $composableBuilder(
    column: $table.abandonedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFoughtAt => $composableBuilder(
    column: $table.lastFoughtAt,
    builder: (column) => column,
  );
}

class $$MapNodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MapNodesTable,
          MapNode,
          $$MapNodesTableFilterComposer,
          $$MapNodesTableOrderingComposer,
          $$MapNodesTableAnnotationComposer,
          $$MapNodesTableCreateCompanionBuilder,
          $$MapNodesTableUpdateCompanionBuilder,
          (MapNode, BaseReferences<_$AppDatabase, $MapNodesTable, MapNode>),
          MapNode,
          PrefetchHooks Function()
        > {
  $$MapNodesTableTableManager(_$AppDatabase db, $MapNodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MapNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MapNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MapNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> world = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> species = const Value.absent(),
                Value<int> maxHp = const Value.absent(),
                Value<int> currentHp = const Value.absent(),
                Value<int> playerHp = const Value.absent(),
                Value<bool> golden = const Value.absent(),
                Value<int> abandonedCount = const Value.absent(),
                Value<DateTime?> lastFoughtAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MapNodesCompanion(
                id: id,
                world: world,
                position: position,
                kind: kind,
                status: status,
                species: species,
                maxHp: maxHp,
                currentHp: currentHp,
                playerHp: playerHp,
                golden: golden,
                abandonedCount: abandonedCount,
                lastFoughtAt: lastFoughtAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int world,
                required int position,
                required int kind,
                required int status,
                Value<int> species = const Value.absent(),
                required int maxHp,
                required int currentHp,
                Value<int> playerHp = const Value.absent(),
                Value<bool> golden = const Value.absent(),
                Value<int> abandonedCount = const Value.absent(),
                Value<DateTime?> lastFoughtAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MapNodesCompanion.insert(
                id: id,
                world: world,
                position: position,
                kind: kind,
                status: status,
                species: species,
                maxHp: maxHp,
                currentHp: currentHp,
                playerHp: playerHp,
                golden: golden,
                abandonedCount: abandonedCount,
                lastFoughtAt: lastFoughtAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MapNodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MapNodesTable,
      MapNode,
      $$MapNodesTableFilterComposer,
      $$MapNodesTableOrderingComposer,
      $$MapNodesTableAnnotationComposer,
      $$MapNodesTableCreateCompanionBuilder,
      $$MapNodesTableUpdateCompanionBuilder,
      (MapNode, BaseReferences<_$AppDatabase, $MapNodesTable, MapNode>),
      MapNode,
      PrefetchHooks Function()
    >;
typedef $$GameSettingsTableCreateCompanionBuilder =
    GameSettingsCompanion Function({Value<int> id, Value<bool> enabled});
typedef $$GameSettingsTableUpdateCompanionBuilder =
    GameSettingsCompanion Function({Value<int> id, Value<bool> enabled});

class $$GameSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSettingsTable> {
  $$GameSettingsTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSettingsTable> {
  $$GameSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSettingsTable> {
  $$GameSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$GameSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSettingsTable,
          GameSetting,
          $$GameSettingsTableFilterComposer,
          $$GameSettingsTableOrderingComposer,
          $$GameSettingsTableAnnotationComposer,
          $$GameSettingsTableCreateCompanionBuilder,
          $$GameSettingsTableUpdateCompanionBuilder,
          (
            GameSetting,
            BaseReferences<_$AppDatabase, $GameSettingsTable, GameSetting>,
          ),
          GameSetting,
          PrefetchHooks Function()
        > {
  $$GameSettingsTableTableManager(_$AppDatabase db, $GameSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => GameSettingsCompanion(id: id, enabled: enabled),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => GameSettingsCompanion.insert(id: id, enabled: enabled),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSettingsTable,
      GameSetting,
      $$GameSettingsTableFilterComposer,
      $$GameSettingsTableOrderingComposer,
      $$GameSettingsTableAnnotationComposer,
      $$GameSettingsTableCreateCompanionBuilder,
      $$GameSettingsTableUpdateCompanionBuilder,
      (
        GameSetting,
        BaseReferences<_$AppDatabase, $GameSettingsTable, GameSetting>,
      ),
      GameSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(_db, _db.habitCompletions);
  $$HabitFreezesTableTableManager get habitFreezes =>
      $$HabitFreezesTableTableManager(_db, _db.habitFreezes);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$DayPlanEntriesTableTableManager get dayPlanEntries =>
      $$DayPlanEntriesTableTableManager(_db, _db.dayPlanEntries);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$MoodEntriesTableTableManager get moodEntries =>
      $$MoodEntriesTableTableManager(_db, _db.moodEntries);
  $$RecommendationWeightsTableTableManager get recommendationWeights =>
      $$RecommendationWeightsTableTableManager(_db, _db.recommendationWeights);
  $$PlayerProgressTableTableManager get playerProgress =>
      $$PlayerProgressTableTableManager(_db, _db.playerProgress);
  $$MapNodesTableTableManager get mapNodes =>
      $$MapNodesTableTableManager(_db, _db.mapNodes);
  $$GameSettingsTableTableManager get gameSettings =>
      $$GameSettingsTableTableManager(_db, _db.gameSettings);
}
