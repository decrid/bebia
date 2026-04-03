// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_item.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimelineItemCollection on Isar {
  IsarCollection<TimelineItem> get timelineItems => this.collection();
}

const TimelineItemSchema = CollectionSchema(
  name: r'TimelineItem',
  id: 7897128962366655622,
  properties: {
    r'aiAnalyzedAt': PropertySchema(
      id: 0,
      name: r'aiAnalyzedAt',
      type: IsarType.dateTime,
    ),
    r'aiConfidence': PropertySchema(
      id: 1,
      name: r'aiConfidence',
      type: IsarType.double,
    ),
    r'aiCryProbability': PropertySchema(
      id: 2,
      name: r'aiCryProbability',
      type: IsarType.double,
    ),
    r'aiModelVersion': PropertySchema(
      id: 3,
      name: r'aiModelVersion',
      type: IsarType.string,
    ),
    r'aiProbableCause': PropertySchema(
      id: 4,
      name: r'aiProbableCause',
      type: IsarType.string,
    ),
    r'cryingDurationMinutes': PropertySchema(
      id: 5,
      name: r'cryingDurationMinutes',
      type: IsarType.long,
    ),
    r'cryingIntensity': PropertySchema(
      id: 6,
      name: r'cryingIntensity',
      type: IsarType.long,
    ),
    r'cryingResolved': PropertySchema(
      id: 7,
      name: r'cryingResolved',
      type: IsarType.bool,
    ),
    r'cryingSource': PropertySchema(
      id: 8,
      name: r'cryingSource',
      type: IsarType.string,
    ),
    r'diaperType': PropertySchema(
      id: 9,
      name: r'diaperType',
      type: IsarType.string,
    ),
    r'feedingAmountMl': PropertySchema(
      id: 10,
      name: r'feedingAmountMl',
      type: IsarType.long,
    ),
    r'feedingType': PropertySchema(
      id: 11,
      name: r'feedingType',
      type: IsarType.string,
    ),
    r'note': PropertySchema(id: 12, name: r'note', type: IsarType.string),
    r'sleepDurationMinutes': PropertySchema(
      id: 13,
      name: r'sleepDurationMinutes',
      type: IsarType.long,
    ),
    r'sleepEnd': PropertySchema(
      id: 14,
      name: r'sleepEnd',
      type: IsarType.dateTime,
    ),
    r'sleepStart': PropertySchema(
      id: 15,
      name: r'sleepStart',
      type: IsarType.dateTime,
    ),
    r'soothingMethod': PropertySchema(
      id: 16,
      name: r'soothingMethod',
      type: IsarType.string,
    ),
    r'subtitle': PropertySchema(
      id: 17,
      name: r'subtitle',
      type: IsarType.string,
    ),
    r'time': PropertySchema(id: 18, name: r'time', type: IsarType.dateTime),
    r'title': PropertySchema(id: 19, name: r'title', type: IsarType.string),
    r'type': PropertySchema(
      id: 20,
      name: r'type',
      type: IsarType.byte,
      enumMap: _TimelineItemtypeEnumValueMap,
    ),
  },

  estimateSize: _timelineItemEstimateSize,
  serialize: _timelineItemSerialize,
  deserialize: _timelineItemDeserialize,
  deserializeProp: _timelineItemDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _timelineItemGetId,
  getLinks: _timelineItemGetLinks,
  attach: _timelineItemAttach,
  version: '3.3.2',
);

int _timelineItemEstimateSize(
  TimelineItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiModelVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.aiProbableCause;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cryingSource;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.diaperType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.feedingType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.soothingMethod;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.subtitle.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _timelineItemSerialize(
  TimelineItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.aiAnalyzedAt);
  writer.writeDouble(offsets[1], object.aiConfidence);
  writer.writeDouble(offsets[2], object.aiCryProbability);
  writer.writeString(offsets[3], object.aiModelVersion);
  writer.writeString(offsets[4], object.aiProbableCause);
  writer.writeLong(offsets[5], object.cryingDurationMinutes);
  writer.writeLong(offsets[6], object.cryingIntensity);
  writer.writeBool(offsets[7], object.cryingResolved);
  writer.writeString(offsets[8], object.cryingSource);
  writer.writeString(offsets[9], object.diaperType);
  writer.writeLong(offsets[10], object.feedingAmountMl);
  writer.writeString(offsets[11], object.feedingType);
  writer.writeString(offsets[12], object.note);
  writer.writeLong(offsets[13], object.sleepDurationMinutes);
  writer.writeDateTime(offsets[14], object.sleepEnd);
  writer.writeDateTime(offsets[15], object.sleepStart);
  writer.writeString(offsets[16], object.soothingMethod);
  writer.writeString(offsets[17], object.subtitle);
  writer.writeDateTime(offsets[18], object.time);
  writer.writeString(offsets[19], object.title);
  writer.writeByte(offsets[20], object.type.index);
}

TimelineItem _timelineItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimelineItem();
  object.aiAnalyzedAt = reader.readDateTimeOrNull(offsets[0]);
  object.aiConfidence = reader.readDoubleOrNull(offsets[1]);
  object.aiCryProbability = reader.readDoubleOrNull(offsets[2]);
  object.aiModelVersion = reader.readStringOrNull(offsets[3]);
  object.aiProbableCause = reader.readStringOrNull(offsets[4]);
  object.cryingDurationMinutes = reader.readLongOrNull(offsets[5]);
  object.cryingIntensity = reader.readLongOrNull(offsets[6]);
  object.cryingResolved = reader.readBoolOrNull(offsets[7]);
  object.cryingSource = reader.readStringOrNull(offsets[8]);
  object.diaperType = reader.readStringOrNull(offsets[9]);
  object.feedingAmountMl = reader.readLongOrNull(offsets[10]);
  object.feedingType = reader.readStringOrNull(offsets[11]);
  object.id = id;
  object.note = reader.readStringOrNull(offsets[12]);
  object.sleepDurationMinutes = reader.readLongOrNull(offsets[13]);
  object.sleepEnd = reader.readDateTimeOrNull(offsets[14]);
  object.sleepStart = reader.readDateTimeOrNull(offsets[15]);
  object.soothingMethod = reader.readStringOrNull(offsets[16]);
  object.subtitle = reader.readString(offsets[17]);
  object.time = reader.readDateTime(offsets[18]);
  object.title = reader.readString(offsets[19]);
  object.type =
      _TimelineItemtypeValueEnumMap[reader.readByteOrNull(offsets[20])] ??
      EventType.feeding;
  return object;
}

P _timelineItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readBoolOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    case 14:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readDateTime(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (_TimelineItemtypeValueEnumMap[reader.readByteOrNull(offset)] ??
              EventType.feeding)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TimelineItemtypeEnumValueMap = {
  'feeding': 0,
  'sleep': 1,
  'diaper': 2,
  'crying': 3,
};
const _TimelineItemtypeValueEnumMap = {
  0: EventType.feeding,
  1: EventType.sleep,
  2: EventType.diaper,
  3: EventType.crying,
};

Id _timelineItemGetId(TimelineItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timelineItemGetLinks(TimelineItem object) {
  return [];
}

void _timelineItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  TimelineItem object,
) {
  object.id = id;
}

extension TimelineItemQueryWhereSort
    on QueryBuilder<TimelineItem, TimelineItem, QWhere> {
  QueryBuilder<TimelineItem, TimelineItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TimelineItemQueryWhere
    on QueryBuilder<TimelineItem, TimelineItem, QWhereClause> {
  QueryBuilder<TimelineItem, TimelineItem, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TimelineItemQueryFilter
    on QueryBuilder<TimelineItem, TimelineItem, QFilterCondition> {
  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiAnalyzedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aiAnalyzedAt'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiAnalyzedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aiAnalyzedAt'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiAnalyzedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aiAnalyzedAt', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiAnalyzedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiAnalyzedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiAnalyzedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiAnalyzedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiAnalyzedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiAnalyzedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiConfidenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aiConfidence'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiConfidenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aiConfidence'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiConfidenceEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiConfidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiConfidenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiConfidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiConfidenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiConfidence',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiConfidenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiConfidence',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiCryProbabilityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aiCryProbability'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiCryProbabilityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aiCryProbability'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiCryProbabilityEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiCryProbability',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiCryProbabilityGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiCryProbability',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiCryProbabilityLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiCryProbability',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiCryProbabilityBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiCryProbability',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aiModelVersion'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aiModelVersion'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiModelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiModelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiModelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiModelVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aiModelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aiModelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aiModelVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aiModelVersion',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aiModelVersion', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiModelVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aiModelVersion', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'aiProbableCause'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'aiProbableCause'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiProbableCause',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiProbableCause',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiProbableCause',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiProbableCause',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aiProbableCause',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aiProbableCause',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aiProbableCause',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aiProbableCause',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aiProbableCause', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  aiProbableCauseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aiProbableCause', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingDurationMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cryingDurationMinutes'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingDurationMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cryingDurationMinutes'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingDurationMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cryingDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingDurationMinutesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cryingDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingDurationMinutesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cryingDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingDurationMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cryingDurationMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingIntensityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cryingIntensity'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingIntensityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cryingIntensity'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingIntensityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cryingIntensity', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingIntensityGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cryingIntensity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingIntensityLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cryingIntensity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingIntensityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cryingIntensity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingResolvedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cryingResolved'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingResolvedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cryingResolved'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingResolvedEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cryingResolved', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cryingSource'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cryingSource'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cryingSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cryingSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cryingSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cryingSource',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cryingSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cryingSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cryingSource',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cryingSource',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cryingSource', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  cryingSourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cryingSource', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'diaperType'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'diaperType'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'diaperType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'diaperType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'diaperType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'diaperType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'diaperType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'diaperType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'diaperType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'diaperType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'diaperType', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  diaperTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'diaperType', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingAmountMlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'feedingAmountMl'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingAmountMlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'feedingAmountMl'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingAmountMlEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'feedingAmountMl', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingAmountMlGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feedingAmountMl',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingAmountMlLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feedingAmountMl',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingAmountMlBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feedingAmountMl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'feedingType'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'feedingType'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'feedingType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feedingType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feedingType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feedingType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'feedingType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'feedingType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'feedingType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'feedingType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'feedingType', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  feedingTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'feedingType', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepDurationMinutesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sleepDurationMinutes'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepDurationMinutesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sleepDurationMinutes'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepDurationMinutesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sleepDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepDurationMinutesGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sleepDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepDurationMinutesLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sleepDurationMinutes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepDurationMinutesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sleepDurationMinutes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sleepEnd'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sleepEnd'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sleepEnd', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepEndGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sleepEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepEndLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sleepEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sleepEnd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sleepStart'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sleepStart'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sleepStart', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepStartGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sleepStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepStartLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sleepStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  sleepStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sleepStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'soothingMethod'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'soothingMethod'),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'soothingMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'soothingMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'soothingMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'soothingMethod',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'soothingMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'soothingMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'soothingMethod',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'soothingMethod',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'soothingMethod', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  soothingMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'soothingMethod', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subtitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'subtitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subtitle', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  subtitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'subtitle', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> timeEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'time', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  timeGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> timeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'time',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> timeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'time',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> typeEqualTo(
    EventType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: value),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition>
  typeGreaterThan(EventType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> typeLessThan(
    EventType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterFilterCondition> typeBetween(
    EventType lower,
    EventType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TimelineItemQueryObject
    on QueryBuilder<TimelineItem, TimelineItem, QFilterCondition> {}

extension TimelineItemQueryLinks
    on QueryBuilder<TimelineItem, TimelineItem, QFilterCondition> {}

extension TimelineItemQuerySortBy
    on QueryBuilder<TimelineItem, TimelineItem, QSortBy> {
  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByAiAnalyzedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalyzedAt', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiAnalyzedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalyzedAt', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiCryProbability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCryProbability', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiCryProbabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCryProbability', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiModelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiModelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiProbableCause() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProbableCause', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByAiProbableCauseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProbableCause', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByCryingDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByCryingDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByCryingIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingIntensity', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByCryingIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingIntensity', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByCryingResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingResolved', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByCryingResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingResolved', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByCryingSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingSource', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByCryingSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingSource', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByDiaperType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diaperType', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByDiaperTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diaperType', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByFeedingAmountMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingAmountMl', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByFeedingAmountMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingAmountMl', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByFeedingType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingType', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortByFeedingTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingType', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortBySleepDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortBySleepDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortBySleepEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepEnd', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortBySleepEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepEnd', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortBySleepStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepStart', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortBySleepStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepStart', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortBySoothingMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soothingMethod', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  sortBySoothingMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soothingMethod', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TimelineItemQuerySortThenBy
    on QueryBuilder<TimelineItem, TimelineItem, QSortThenBy> {
  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByAiAnalyzedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalyzedAt', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiAnalyzedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalyzedAt', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiConfidenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiConfidence', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiCryProbability() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCryProbability', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiCryProbabilityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiCryProbability', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiModelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiModelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiProbableCause() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProbableCause', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByAiProbableCauseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProbableCause', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByCryingDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByCryingDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByCryingIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingIntensity', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByCryingIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingIntensity', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByCryingResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingResolved', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByCryingResolvedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingResolved', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByCryingSource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingSource', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByCryingSourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cryingSource', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByDiaperType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diaperType', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByDiaperTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diaperType', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByFeedingAmountMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingAmountMl', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByFeedingAmountMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingAmountMl', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByFeedingType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingType', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenByFeedingTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedingType', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenBySleepDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationMinutes', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenBySleepDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepDurationMinutes', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenBySleepEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepEnd', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenBySleepEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepEnd', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenBySleepStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepStart', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenBySleepStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepStart', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenBySoothingMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soothingMethod', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy>
  thenBySoothingMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'soothingMethod', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'time', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TimelineItemQueryWhereDistinct
    on QueryBuilder<TimelineItem, TimelineItem, QDistinct> {
  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByAiAnalyzedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiAnalyzedAt');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByAiConfidence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiConfidence');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct>
  distinctByAiCryProbability() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiCryProbability');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByAiModelVersion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'aiModelVersion',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct>
  distinctByAiProbableCause({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'aiProbableCause',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct>
  distinctByCryingDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cryingDurationMinutes');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct>
  distinctByCryingIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cryingIntensity');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct>
  distinctByCryingResolved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cryingResolved');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByCryingSource({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cryingSource', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByDiaperType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diaperType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct>
  distinctByFeedingAmountMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedingAmountMl');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByFeedingType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedingType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct>
  distinctBySleepDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepDurationMinutes');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctBySleepEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepEnd');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctBySleepStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepStart');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctBySoothingMethod({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'soothingMethod',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctBySubtitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'time');
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimelineItem, TimelineItem, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension TimelineItemQueryProperty
    on QueryBuilder<TimelineItem, TimelineItem, QQueryProperty> {
  QueryBuilder<TimelineItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TimelineItem, DateTime?, QQueryOperations>
  aiAnalyzedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiAnalyzedAt');
    });
  }

  QueryBuilder<TimelineItem, double?, QQueryOperations> aiConfidenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiConfidence');
    });
  }

  QueryBuilder<TimelineItem, double?, QQueryOperations>
  aiCryProbabilityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiCryProbability');
    });
  }

  QueryBuilder<TimelineItem, String?, QQueryOperations>
  aiModelVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiModelVersion');
    });
  }

  QueryBuilder<TimelineItem, String?, QQueryOperations>
  aiProbableCauseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiProbableCause');
    });
  }

  QueryBuilder<TimelineItem, int?, QQueryOperations>
  cryingDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cryingDurationMinutes');
    });
  }

  QueryBuilder<TimelineItem, int?, QQueryOperations> cryingIntensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cryingIntensity');
    });
  }

  QueryBuilder<TimelineItem, bool?, QQueryOperations> cryingResolvedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cryingResolved');
    });
  }

  QueryBuilder<TimelineItem, String?, QQueryOperations> cryingSourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cryingSource');
    });
  }

  QueryBuilder<TimelineItem, String?, QQueryOperations> diaperTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diaperType');
    });
  }

  QueryBuilder<TimelineItem, int?, QQueryOperations> feedingAmountMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedingAmountMl');
    });
  }

  QueryBuilder<TimelineItem, String?, QQueryOperations> feedingTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedingType');
    });
  }

  QueryBuilder<TimelineItem, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<TimelineItem, int?, QQueryOperations>
  sleepDurationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepDurationMinutes');
    });
  }

  QueryBuilder<TimelineItem, DateTime?, QQueryOperations> sleepEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepEnd');
    });
  }

  QueryBuilder<TimelineItem, DateTime?, QQueryOperations> sleepStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepStart');
    });
  }

  QueryBuilder<TimelineItem, String?, QQueryOperations>
  soothingMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'soothingMethod');
    });
  }

  QueryBuilder<TimelineItem, String, QQueryOperations> subtitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitle');
    });
  }

  QueryBuilder<TimelineItem, DateTime, QQueryOperations> timeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'time');
    });
  }

  QueryBuilder<TimelineItem, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<TimelineItem, EventType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
