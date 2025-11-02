// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_state.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserItemStateCollection on Isar {
  IsarCollection<UserItemState> get userItemStates => this.collection();
}

const UserItemStateSchema = CollectionSchema(
  name: r'UserItemState',
  id: 3286792171900863119,
  properties: {
    r'correctStreak': PropertySchema(
      id: 0,
      name: r'correctStreak',
      type: IsarType.long,
    ),
    r'itemId': PropertySchema(id: 1, name: r'itemId', type: IsarType.string),
    r'lastSeenAt': PropertySchema(
      id: 2,
      name: r'lastSeenAt',
      type: IsarType.dateTime,
    ),
    r'learnedAt': PropertySchema(
      id: 3,
      name: r'learnedAt',
      type: IsarType.dateTime,
    ),
    r'seenCount': PropertySchema(
      id: 4,
      name: r'seenCount',
      type: IsarType.long,
    ),
    r'troubleAt': PropertySchema(
      id: 5,
      name: r'troubleAt',
      type: IsarType.dateTime,
    ),
    r'wrongCount': PropertySchema(
      id: 6,
      name: r'wrongCount',
      type: IsarType.long,
    ),
  },
  estimateSize: _userItemStateEstimateSize,
  serialize: _userItemStateSerialize,
  deserialize: _userItemStateDeserialize,
  deserializeProp: _userItemStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _userItemStateGetId,
  getLinks: _userItemStateGetLinks,
  attach: _userItemStateAttach,
  version: '3.1.0+1',
);

int _userItemStateEstimateSize(
  UserItemState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.itemId.length * 3;
  return bytesCount;
}

void _userItemStateSerialize(
  UserItemState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.correctStreak);
  writer.writeString(offsets[1], object.itemId);
  writer.writeDateTime(offsets[2], object.lastSeenAt);
  writer.writeDateTime(offsets[3], object.learnedAt);
  writer.writeLong(offsets[4], object.seenCount);
  writer.writeDateTime(offsets[5], object.troubleAt);
  writer.writeLong(offsets[6], object.wrongCount);
}

UserItemState _userItemStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserItemState();
  object.correctStreak = reader.readLong(offsets[0]);
  object.id = id;
  object.itemId = reader.readString(offsets[1]);
  object.lastSeenAt = reader.readDateTimeOrNull(offsets[2]);
  object.learnedAt = reader.readDateTimeOrNull(offsets[3]);
  object.seenCount = reader.readLong(offsets[4]);
  object.troubleAt = reader.readDateTimeOrNull(offsets[5]);
  object.wrongCount = reader.readLong(offsets[6]);
  return object;
}

P _userItemStateDeserializeProp<P>(
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
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userItemStateGetId(UserItemState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userItemStateGetLinks(UserItemState object) {
  return [];
}

void _userItemStateAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserItemState object,
) {
  object.id = id;
}

extension UserItemStateByIndex on IsarCollection<UserItemState> {
  Future<UserItemState?> getByItemId(String itemId) {
    return getByIndex(r'itemId', [itemId]);
  }

  UserItemState? getByItemIdSync(String itemId) {
    return getByIndexSync(r'itemId', [itemId]);
  }

  Future<bool> deleteByItemId(String itemId) {
    return deleteByIndex(r'itemId', [itemId]);
  }

  bool deleteByItemIdSync(String itemId) {
    return deleteByIndexSync(r'itemId', [itemId]);
  }

  Future<List<UserItemState?>> getAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'itemId', values);
  }

  List<UserItemState?> getAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'itemId', values);
  }

  Future<int> deleteAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'itemId', values);
  }

  int deleteAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'itemId', values);
  }

  Future<Id> putByItemId(UserItemState object) {
    return putByIndex(r'itemId', object);
  }

  Id putByItemIdSync(UserItemState object, {bool saveLinks = true}) {
    return putByIndexSync(r'itemId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByItemId(List<UserItemState> objects) {
    return putAllByIndex(r'itemId', objects);
  }

  List<Id> putAllByItemIdSync(
    List<UserItemState> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'itemId', objects, saveLinks: saveLinks);
  }
}

extension UserItemStateQueryWhereSort
    on QueryBuilder<UserItemState, UserItemState, QWhere> {
  QueryBuilder<UserItemState, UserItemState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserItemStateQueryWhere
    on QueryBuilder<UserItemState, UserItemState, QWhereClause> {
  QueryBuilder<UserItemState, UserItemState, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<UserItemState, UserItemState, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserItemState, UserItemState, QAfterWhereClause> itemIdEqualTo(
    String itemId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'itemId', value: [itemId]),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterWhereClause>
  itemIdNotEqualTo(String itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [],
                upper: [itemId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [itemId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [itemId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [],
                upper: [itemId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension UserItemStateQueryFilter
    on QueryBuilder<UserItemState, UserItemState, QFilterCondition> {
  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  correctStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'correctStreak', value: value),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  correctStreakGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'correctStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  correctStreakLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'correctStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  correctStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'correctStreak',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itemId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itemId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemId', value: ''),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itemId', value: ''),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  lastSeenAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSeenAt'),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  lastSeenAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSeenAt'),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  lastSeenAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSeenAt', value: value),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  lastSeenAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSeenAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  lastSeenAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSeenAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  lastSeenAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSeenAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  learnedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'learnedAt'),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  learnedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'learnedAt'),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  learnedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'learnedAt', value: value),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  learnedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'learnedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  learnedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'learnedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  learnedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'learnedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  seenCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'seenCount', value: value),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  seenCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'seenCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  seenCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'seenCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  seenCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'seenCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  troubleAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'troubleAt'),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  troubleAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'troubleAt'),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  troubleAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'troubleAt', value: value),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  troubleAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'troubleAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  troubleAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'troubleAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  troubleAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'troubleAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  wrongCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'wrongCount', value: value),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  wrongCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'wrongCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  wrongCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'wrongCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterFilterCondition>
  wrongCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'wrongCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserItemStateQueryObject
    on QueryBuilder<UserItemState, UserItemState, QFilterCondition> {}

extension UserItemStateQueryLinks
    on QueryBuilder<UserItemState, UserItemState, QFilterCondition> {}

extension UserItemStateQuerySortBy
    on QueryBuilder<UserItemState, UserItemState, QSortBy> {
  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  sortByCorrectStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctStreak', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  sortByCorrectStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctStreak', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> sortByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  sortByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> sortByLearnedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedAt', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  sortByLearnedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedAt', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> sortBySeenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenCount', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  sortBySeenCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenCount', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> sortByTroubleAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleAt', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  sortByTroubleAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleAt', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> sortByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  sortByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension UserItemStateQuerySortThenBy
    on QueryBuilder<UserItemState, UserItemState, QSortThenBy> {
  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  thenByCorrectStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctStreak', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  thenByCorrectStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctStreak', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  thenByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenByLearnedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedAt', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  thenByLearnedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedAt', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenBySeenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenCount', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  thenBySeenCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seenCount', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenByTroubleAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleAt', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  thenByTroubleAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleAt', Sort.desc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy> thenByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.asc);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QAfterSortBy>
  thenByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrongCount', Sort.desc);
    });
  }
}

extension UserItemStateQueryWhereDistinct
    on QueryBuilder<UserItemState, UserItemState, QDistinct> {
  QueryBuilder<UserItemState, UserItemState, QDistinct>
  distinctByCorrectStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctStreak');
    });
  }

  QueryBuilder<UserItemState, UserItemState, QDistinct> distinctByItemId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserItemState, UserItemState, QDistinct> distinctByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeenAt');
    });
  }

  QueryBuilder<UserItemState, UserItemState, QDistinct> distinctByLearnedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learnedAt');
    });
  }

  QueryBuilder<UserItemState, UserItemState, QDistinct> distinctBySeenCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seenCount');
    });
  }

  QueryBuilder<UserItemState, UserItemState, QDistinct> distinctByTroubleAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'troubleAt');
    });
  }

  QueryBuilder<UserItemState, UserItemState, QDistinct> distinctByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wrongCount');
    });
  }
}

extension UserItemStateQueryProperty
    on QueryBuilder<UserItemState, UserItemState, QQueryProperty> {
  QueryBuilder<UserItemState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserItemState, int, QQueryOperations> correctStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctStreak');
    });
  }

  QueryBuilder<UserItemState, String, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<UserItemState, DateTime?, QQueryOperations>
  lastSeenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeenAt');
    });
  }

  QueryBuilder<UserItemState, DateTime?, QQueryOperations> learnedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learnedAt');
    });
  }

  QueryBuilder<UserItemState, int, QQueryOperations> seenCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seenCount');
    });
  }

  QueryBuilder<UserItemState, DateTime?, QQueryOperations> troubleAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'troubleAt');
    });
  }

  QueryBuilder<UserItemState, int, QQueryOperations> wrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wrongCount');
    });
  }
}
