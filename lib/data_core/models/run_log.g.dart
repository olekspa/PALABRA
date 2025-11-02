// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRunLogCollection on Isar {
  IsarCollection<RunLog> get runLogs => this.collection();
}

const RunLogSchema = CollectionSchema(
  name: r'RunLog',
  id: -3487839205789677665,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'deckComposition': PropertySchema(
      id: 1,
      name: r'deckComposition',
      type: IsarType.objectList,
      target: r'DeckLevelCount',
    ),
    r'learnedPromoted': PropertySchema(
      id: 2,
      name: r'learnedPromoted',
      type: IsarType.stringList,
    ),
    r'rowsUsed': PropertySchema(id: 3, name: r'rowsUsed', type: IsarType.long),
    r'startedAt': PropertySchema(
      id: 4,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'tierReached': PropertySchema(
      id: 5,
      name: r'tierReached',
      type: IsarType.long,
    ),
    r'timeExtendsUsed': PropertySchema(
      id: 6,
      name: r'timeExtendsUsed',
      type: IsarType.long,
    ),
    r'troubleDetected': PropertySchema(
      id: 7,
      name: r'troubleDetected',
      type: IsarType.stringList,
    ),
  },
  estimateSize: _runLogEstimateSize,
  serialize: _runLogSerialize,
  deserialize: _runLogDeserialize,
  deserializeProp: _runLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'DeckLevelCount': DeckLevelCountSchema},
  getId: _runLogGetId,
  getLinks: _runLogGetLinks,
  attach: _runLogAttach,
  version: '3.1.0+1',
);

int _runLogEstimateSize(
  RunLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deckComposition.length * 3;
  {
    final offsets = allOffsets[DeckLevelCount]!;
    for (var i = 0; i < object.deckComposition.length; i++) {
      final value = object.deckComposition[i];
      bytesCount += DeckLevelCountSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.learnedPromoted.length * 3;
  {
    for (var i = 0; i < object.learnedPromoted.length; i++) {
      final value = object.learnedPromoted[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.troubleDetected.length * 3;
  {
    for (var i = 0; i < object.troubleDetected.length; i++) {
      final value = object.troubleDetected[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _runLogSerialize(
  RunLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeObjectList<DeckLevelCount>(
    offsets[1],
    allOffsets,
    DeckLevelCountSchema.serialize,
    object.deckComposition,
  );
  writer.writeStringList(offsets[2], object.learnedPromoted);
  writer.writeLong(offsets[3], object.rowsUsed);
  writer.writeDateTime(offsets[4], object.startedAt);
  writer.writeLong(offsets[5], object.tierReached);
  writer.writeLong(offsets[6], object.timeExtendsUsed);
  writer.writeStringList(offsets[7], object.troubleDetected);
}

RunLog _runLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RunLog();
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.deckComposition =
      reader.readObjectList<DeckLevelCount>(
        offsets[1],
        DeckLevelCountSchema.deserialize,
        allOffsets,
        DeckLevelCount(),
      ) ??
      [];
  object.id = id;
  object.learnedPromoted = reader.readStringList(offsets[2]) ?? [];
  object.rowsUsed = reader.readLong(offsets[3]);
  object.startedAt = reader.readDateTime(offsets[4]);
  object.tierReached = reader.readLong(offsets[5]);
  object.timeExtendsUsed = reader.readLong(offsets[6]);
  object.troubleDetected = reader.readStringList(offsets[7]) ?? [];
  return object;
}

P _runLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<DeckLevelCount>(
                offset,
                DeckLevelCountSchema.deserialize,
                allOffsets,
                DeckLevelCount(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _runLogGetId(RunLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _runLogGetLinks(RunLog object) {
  return [];
}

void _runLogAttach(IsarCollection<dynamic> col, Id id, RunLog object) {
  object.id = id;
}

extension RunLogQueryWhereSort on QueryBuilder<RunLog, RunLog, QWhere> {
  QueryBuilder<RunLog, RunLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RunLogQueryWhere on QueryBuilder<RunLog, RunLog, QWhereClause> {
  QueryBuilder<RunLog, RunLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RunLog, RunLog, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterWhereClause> idBetween(
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

extension RunLogQueryFilter on QueryBuilder<RunLog, RunLog, QFilterCondition> {
  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> completedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  deckCompositionLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deckComposition', length, true, length, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> deckCompositionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deckComposition', 0, true, 0, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  deckCompositionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deckComposition', 0, false, 999999, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  deckCompositionLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'deckComposition', 0, true, length, include);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  deckCompositionLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deckComposition',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  deckCompositionLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deckComposition',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'learnedPromoted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'learnedPromoted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'learnedPromoted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'learnedPromoted',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'learnedPromoted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'learnedPromoted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'learnedPromoted',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'learnedPromoted',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'learnedPromoted', value: ''),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'learnedPromoted', value: ''),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedPromoted', length, true, length, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> learnedPromotedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedPromoted', 0, true, 0, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedPromoted', 0, false, 999999, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'learnedPromoted', 0, true, length, include);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learnedPromoted',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  learnedPromotedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'learnedPromoted',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> rowsUsedEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rowsUsed', value: value),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> rowsUsedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rowsUsed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> rowsUsedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rowsUsed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> rowsUsedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rowsUsed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> startedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> tierReachedEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tierReached', value: value),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> tierReachedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tierReached',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> tierReachedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tierReached',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> tierReachedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tierReached',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> timeExtendsUsedEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timeExtendsUsed', value: value),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  timeExtendsUsedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timeExtendsUsed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> timeExtendsUsedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timeExtendsUsed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> timeExtendsUsedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timeExtendsUsed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'troubleDetected',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'troubleDetected',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'troubleDetected',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'troubleDetected',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'troubleDetected',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'troubleDetected',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'troubleDetected',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'troubleDetected',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'troubleDetected', value: ''),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'troubleDetected', value: ''),
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'troubleDetected', length, true, length, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> troubleDetectedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'troubleDetected', 0, true, 0, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'troubleDetected', 0, false, 999999, true);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'troubleDetected', 0, true, length, include);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'troubleDetected',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterFilterCondition>
  troubleDetectedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'troubleDetected',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension RunLogQueryObject on QueryBuilder<RunLog, RunLog, QFilterCondition> {
  QueryBuilder<RunLog, RunLog, QAfterFilterCondition> deckCompositionElement(
    FilterQuery<DeckLevelCount> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'deckComposition');
    });
  }
}

extension RunLogQueryLinks on QueryBuilder<RunLog, RunLog, QFilterCondition> {}

extension RunLogQuerySortBy on QueryBuilder<RunLog, RunLog, QSortBy> {
  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByRowsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowsUsed', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByRowsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowsUsed', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByTierReached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tierReached', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByTierReachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tierReached', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByTimeExtendsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendsUsed', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> sortByTimeExtendsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendsUsed', Sort.desc);
    });
  }
}

extension RunLogQuerySortThenBy on QueryBuilder<RunLog, RunLog, QSortThenBy> {
  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByRowsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowsUsed', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByRowsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowsUsed', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByTierReached() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tierReached', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByTierReachedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tierReached', Sort.desc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByTimeExtendsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendsUsed', Sort.asc);
    });
  }

  QueryBuilder<RunLog, RunLog, QAfterSortBy> thenByTimeExtendsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendsUsed', Sort.desc);
    });
  }
}

extension RunLogQueryWhereDistinct on QueryBuilder<RunLog, RunLog, QDistinct> {
  QueryBuilder<RunLog, RunLog, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<RunLog, RunLog, QDistinct> distinctByLearnedPromoted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learnedPromoted');
    });
  }

  QueryBuilder<RunLog, RunLog, QDistinct> distinctByRowsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rowsUsed');
    });
  }

  QueryBuilder<RunLog, RunLog, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<RunLog, RunLog, QDistinct> distinctByTierReached() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tierReached');
    });
  }

  QueryBuilder<RunLog, RunLog, QDistinct> distinctByTimeExtendsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeExtendsUsed');
    });
  }

  QueryBuilder<RunLog, RunLog, QDistinct> distinctByTroubleDetected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'troubleDetected');
    });
  }
}

extension RunLogQueryProperty on QueryBuilder<RunLog, RunLog, QQueryProperty> {
  QueryBuilder<RunLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RunLog, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<RunLog, List<DeckLevelCount>, QQueryOperations>
  deckCompositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deckComposition');
    });
  }

  QueryBuilder<RunLog, List<String>, QQueryOperations>
  learnedPromotedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learnedPromoted');
    });
  }

  QueryBuilder<RunLog, int, QQueryOperations> rowsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rowsUsed');
    });
  }

  QueryBuilder<RunLog, DateTime, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<RunLog, int, QQueryOperations> tierReachedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tierReached');
    });
  }

  QueryBuilder<RunLog, int, QQueryOperations> timeExtendsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeExtendsUsed');
    });
  }

  QueryBuilder<RunLog, List<String>, QQueryOperations>
  troubleDetectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'troubleDetected');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const DeckLevelCountSchema = Schema(
  name: r'DeckLevelCount',
  id: -8273566515592775058,
  properties: {
    r'count': PropertySchema(id: 0, name: r'count', type: IsarType.long),
    r'level': PropertySchema(id: 1, name: r'level', type: IsarType.string),
  },
  estimateSize: _deckLevelCountEstimateSize,
  serialize: _deckLevelCountSerialize,
  deserialize: _deckLevelCountDeserialize,
  deserializeProp: _deckLevelCountDeserializeProp,
);

int _deckLevelCountEstimateSize(
  DeckLevelCount object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.level.length * 3;
  return bytesCount;
}

void _deckLevelCountSerialize(
  DeckLevelCount object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.count);
  writer.writeString(offsets[1], object.level);
}

DeckLevelCount _deckLevelCountDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DeckLevelCount();
  object.count = reader.readLong(offsets[0]);
  object.level = reader.readString(offsets[1]);
  return object;
}

P _deckLevelCountDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension DeckLevelCountQueryFilter
    on QueryBuilder<DeckLevelCount, DeckLevelCount, QFilterCondition> {
  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  countEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'count', value: value),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  countGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'count',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  countLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'count',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  countBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'count',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'level',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'level',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'level',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'level',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'level',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'level',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'level',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'level',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'level', value: ''),
      );
    });
  }

  QueryBuilder<DeckLevelCount, DeckLevelCount, QAfterFilterCondition>
  levelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'level', value: ''),
      );
    });
  }
}

extension DeckLevelCountQueryObject
    on QueryBuilder<DeckLevelCount, DeckLevelCount, QFilterCondition> {}
