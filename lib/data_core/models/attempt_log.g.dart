// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAttemptLogCollection on Isar {
  IsarCollection<AttemptLog> get attemptLogs => this.collection();
}

const AttemptLogSchema = CollectionSchema(
  name: r'AttemptLog',
  id: -7678239142211411327,
  properties: {
    r'column': PropertySchema(id: 0, name: r'column', type: IsarType.long),
    r'correct': PropertySchema(id: 1, name: r'correct', type: IsarType.bool),
    r'englishItemId': PropertySchema(
      id: 2,
      name: r'englishItemId',
      type: IsarType.string,
    ),
    r'row': PropertySchema(id: 3, name: r'row', type: IsarType.long),
    r'runLogId': PropertySchema(id: 4, name: r'runLogId', type: IsarType.long),
    r'spanishItemId': PropertySchema(
      id: 5,
      name: r'spanishItemId',
      type: IsarType.string,
    ),
    r'tier': PropertySchema(id: 6, name: r'tier', type: IsarType.long),
    r'timeRemainingMs': PropertySchema(
      id: 7,
      name: r'timeRemainingMs',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _attemptLogEstimateSize,
  serialize: _attemptLogSerialize,
  deserialize: _attemptLogDeserialize,
  deserializeProp: _attemptLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'runLogId': IndexSchema(
      id: -7463281627945293503,
      name: r'runLogId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'runLogId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _attemptLogGetId,
  getLinks: _attemptLogGetLinks,
  attach: _attemptLogAttach,
  version: '3.1.0+1',
);

int _attemptLogEstimateSize(
  AttemptLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.englishItemId.length * 3;
  bytesCount += 3 + object.spanishItemId.length * 3;
  return bytesCount;
}

void _attemptLogSerialize(
  AttemptLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.column);
  writer.writeBool(offsets[1], object.correct);
  writer.writeString(offsets[2], object.englishItemId);
  writer.writeLong(offsets[3], object.row);
  writer.writeLong(offsets[4], object.runLogId);
  writer.writeString(offsets[5], object.spanishItemId);
  writer.writeLong(offsets[6], object.tier);
  writer.writeLong(offsets[7], object.timeRemainingMs);
  writer.writeDateTime(offsets[8], object.timestamp);
}

AttemptLog _attemptLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AttemptLog();
  object.column = reader.readLong(offsets[0]);
  object.correct = reader.readBool(offsets[1]);
  object.englishItemId = reader.readString(offsets[2]);
  object.id = id;
  object.row = reader.readLong(offsets[3]);
  object.runLogId = reader.readLong(offsets[4]);
  object.spanishItemId = reader.readString(offsets[5]);
  object.tier = reader.readLong(offsets[6]);
  object.timeRemainingMs = reader.readLong(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  return object;
}

P _attemptLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _attemptLogGetId(AttemptLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _attemptLogGetLinks(AttemptLog object) {
  return [];
}

void _attemptLogAttach(IsarCollection<dynamic> col, Id id, AttemptLog object) {
  object.id = id;
}

extension AttemptLogQueryWhereSort
    on QueryBuilder<AttemptLog, AttemptLog, QWhere> {
  QueryBuilder<AttemptLog, AttemptLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhere> anyRunLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'runLogId'),
      );
    });
  }
}

extension AttemptLogQueryWhere
    on QueryBuilder<AttemptLog, AttemptLog, QWhereClause> {
  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> idBetween(
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

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> runLogIdEqualTo(
    int runLogId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'runLogId', value: [runLogId]),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> runLogIdNotEqualTo(
    int runLogId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runLogId',
                lower: [],
                upper: [runLogId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runLogId',
                lower: [runLogId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runLogId',
                lower: [runLogId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'runLogId',
                lower: [],
                upper: [runLogId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> runLogIdGreaterThan(
    int runLogId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'runLogId',
          lower: [runLogId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> runLogIdLessThan(
    int runLogId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'runLogId',
          lower: [],
          upper: [runLogId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterWhereClause> runLogIdBetween(
    int lowerRunLogId,
    int upperRunLogId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'runLogId',
          lower: [lowerRunLogId],
          includeLower: includeLower,
          upper: [upperRunLogId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AttemptLogQueryFilter
    on QueryBuilder<AttemptLog, AttemptLog, QFilterCondition> {
  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> columnEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'column', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> columnGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'column',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> columnLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'column',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> columnBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'column',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> correctEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'correct', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'englishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'englishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'englishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'englishItemId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'englishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'englishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'englishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'englishItemId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'englishItemId', value: ''),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  englishItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'englishItemId', value: ''),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> rowEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'row', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> rowGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'row',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> rowLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'row',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> rowBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'row',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> runLogIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'runLogId', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  runLogIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'runLogId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> runLogIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'runLogId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> runLogIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'runLogId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'spanishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'spanishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'spanishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'spanishItemId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'spanishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'spanishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'spanishItemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'spanishItemId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'spanishItemId', value: ''),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  spanishItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'spanishItemId', value: ''),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> tierEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tier', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> tierGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tier',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> tierLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tier',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> tierBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tier',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  timeRemainingMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timeRemainingMs', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  timeRemainingMsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timeRemainingMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  timeRemainingMsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timeRemainingMs',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  timeRemainingMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timeRemainingMs',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> timestampEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AttemptLogQueryObject
    on QueryBuilder<AttemptLog, AttemptLog, QFilterCondition> {}

extension AttemptLogQueryLinks
    on QueryBuilder<AttemptLog, AttemptLog, QFilterCondition> {}

extension AttemptLogQuerySortBy
    on QueryBuilder<AttemptLog, AttemptLog, QSortBy> {
  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByColumn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByColumnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByEnglishItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishItemId', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByEnglishItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishItemId', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByRunLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runLogId', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByRunLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runLogId', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortBySpanishItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spanishItemId', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortBySpanishItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spanishItemId', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByTimeRemainingMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeRemainingMs', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy>
  sortByTimeRemainingMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeRemainingMs', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AttemptLogQuerySortThenBy
    on QueryBuilder<AttemptLog, AttemptLog, QSortThenBy> {
  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByColumn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByColumnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'column', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByEnglishItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishItemId', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByEnglishItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'englishItemId', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByRunLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runLogId', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByRunLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runLogId', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenBySpanishItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spanishItemId', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenBySpanishItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spanishItemId', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByTierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tier', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByTimeRemainingMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeRemainingMs', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy>
  thenByTimeRemainingMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeRemainingMs', Sort.desc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AttemptLogQueryWhereDistinct
    on QueryBuilder<AttemptLog, AttemptLog, QDistinct> {
  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByColumn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'column');
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correct');
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByEnglishItemId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'englishItemId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'row');
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByRunLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'runLogId');
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctBySpanishItemId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'spanishItemId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByTier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tier');
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByTimeRemainingMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeRemainingMs');
    });
  }

  QueryBuilder<AttemptLog, AttemptLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension AttemptLogQueryProperty
    on QueryBuilder<AttemptLog, AttemptLog, QQueryProperty> {
  QueryBuilder<AttemptLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AttemptLog, int, QQueryOperations> columnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'column');
    });
  }

  QueryBuilder<AttemptLog, bool, QQueryOperations> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correct');
    });
  }

  QueryBuilder<AttemptLog, String, QQueryOperations> englishItemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'englishItemId');
    });
  }

  QueryBuilder<AttemptLog, int, QQueryOperations> rowProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'row');
    });
  }

  QueryBuilder<AttemptLog, int, QQueryOperations> runLogIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'runLogId');
    });
  }

  QueryBuilder<AttemptLog, String, QQueryOperations> spanishItemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spanishItemId');
    });
  }

  QueryBuilder<AttemptLog, int, QQueryOperations> tierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tier');
    });
  }

  QueryBuilder<AttemptLog, int, QQueryOperations> timeRemainingMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeRemainingMs');
    });
  }

  QueryBuilder<AttemptLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
