// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_meta.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserMetaCollection on Isar {
  IsarCollection<UserMeta> get userMetas => this.collection();
}

const UserMetaSchema = CollectionSchema(
  name: r'UserMeta',
  id: 810033086390408464,
  properties: {
    r'hasSeededVocabulary': PropertySchema(
      id: 0,
      name: r'hasSeededVocabulary',
      type: IsarType.bool,
    ),
    r'lastRunAt': PropertySchema(
      id: 1,
      name: r'lastRunAt',
      type: IsarType.dateTime,
    ),
    r'learnedCount': PropertySchema(
      id: 2,
      name: r'learnedCount',
      type: IsarType.long,
    ),
    r'level': PropertySchema(id: 3, name: r'level', type: IsarType.string),
    r'preferredRows': PropertySchema(
      id: 4,
      name: r'preferredRows',
      type: IsarType.long,
    ),
    r'rowBlasterCharges': PropertySchema(
      id: 5,
      name: r'rowBlasterCharges',
      type: IsarType.long,
    ),
    r'timeExtendTokens': PropertySchema(
      id: 6,
      name: r'timeExtendTokens',
      type: IsarType.long,
    ),
    r'troubleCount': PropertySchema(
      id: 7,
      name: r'troubleCount',
      type: IsarType.long,
    ),
  },
  estimateSize: _userMetaEstimateSize,
  serialize: _userMetaSerialize,
  deserialize: _userMetaDeserialize,
  deserializeProp: _userMetaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userMetaGetId,
  getLinks: _userMetaGetLinks,
  attach: _userMetaAttach,
  version: '3.1.0+1',
);

int _userMetaEstimateSize(
  UserMeta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.level.length * 3;
  return bytesCount;
}

void _userMetaSerialize(
  UserMeta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.hasSeededVocabulary);
  writer.writeDateTime(offsets[1], object.lastRunAt);
  writer.writeLong(offsets[2], object.learnedCount);
  writer.writeString(offsets[3], object.level);
  writer.writeLong(offsets[4], object.preferredRows);
  writer.writeLong(offsets[5], object.rowBlasterCharges);
  writer.writeLong(offsets[6], object.timeExtendTokens);
  writer.writeLong(offsets[7], object.troubleCount);
}

UserMeta _userMetaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserMeta();
  object.hasSeededVocabulary = reader.readBool(offsets[0]);
  object.id = id;
  object.lastRunAt = reader.readDateTimeOrNull(offsets[1]);
  object.learnedCount = reader.readLong(offsets[2]);
  object.level = reader.readString(offsets[3]);
  object.preferredRows = reader.readLong(offsets[4]);
  object.rowBlasterCharges = reader.readLong(offsets[5]);
  object.timeExtendTokens = reader.readLong(offsets[6]);
  object.troubleCount = reader.readLong(offsets[7]);
  return object;
}

P _userMetaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userMetaGetId(UserMeta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userMetaGetLinks(UserMeta object) {
  return [];
}

void _userMetaAttach(IsarCollection<dynamic> col, Id id, UserMeta object) {
  object.id = id;
}

extension UserMetaQueryWhereSort on QueryBuilder<UserMeta, UserMeta, QWhere> {
  QueryBuilder<UserMeta, UserMeta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserMetaQueryWhere on QueryBuilder<UserMeta, UserMeta, QWhereClause> {
  QueryBuilder<UserMeta, UserMeta, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserMeta, UserMeta, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterWhereClause> idBetween(
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

extension UserMetaQueryFilter
    on QueryBuilder<UserMeta, UserMeta, QFilterCondition> {
  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  hasSeededVocabularyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasSeededVocabulary', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> lastRunAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastRunAt'),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> lastRunAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastRunAt'),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> lastRunAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastRunAt', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> lastRunAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastRunAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> lastRunAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastRunAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> lastRunAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastRunAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> learnedCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'learnedCount', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  learnedCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'learnedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> learnedCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'learnedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> learnedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'learnedCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelGreaterThan(
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelLessThan(
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelBetween(
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'level', value: ''),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> levelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'level', value: ''),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> preferredRowsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'preferredRows', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  preferredRowsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'preferredRows',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> preferredRowsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'preferredRows',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> preferredRowsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'preferredRows',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  rowBlasterChargesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rowBlasterCharges', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  rowBlasterChargesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rowBlasterCharges',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  rowBlasterChargesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rowBlasterCharges',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  rowBlasterChargesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rowBlasterCharges',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  timeExtendTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timeExtendTokens', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  timeExtendTokensGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timeExtendTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  timeExtendTokensLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timeExtendTokens',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  timeExtendTokensBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timeExtendTokens',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> troubleCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'troubleCount', value: value),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition>
  troubleCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'troubleCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> troubleCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'troubleCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterFilterCondition> troubleCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'troubleCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserMetaQueryObject
    on QueryBuilder<UserMeta, UserMeta, QFilterCondition> {}

extension UserMetaQueryLinks
    on QueryBuilder<UserMeta, UserMeta, QFilterCondition> {}

extension UserMetaQuerySortBy on QueryBuilder<UserMeta, UserMeta, QSortBy> {
  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByHasSeededVocabulary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeededVocabulary', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy>
  sortByHasSeededVocabularyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeededVocabulary', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByLastRunAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRunAt', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByLastRunAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRunAt', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByLearnedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedCount', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByLearnedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedCount', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByPreferredRows() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredRows', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByPreferredRowsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredRows', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByRowBlasterCharges() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowBlasterCharges', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByRowBlasterChargesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowBlasterCharges', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByTimeExtendTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendTokens', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByTimeExtendTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendTokens', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByTroubleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleCount', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> sortByTroubleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleCount', Sort.desc);
    });
  }
}

extension UserMetaQuerySortThenBy
    on QueryBuilder<UserMeta, UserMeta, QSortThenBy> {
  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByHasSeededVocabulary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeededVocabulary', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy>
  thenByHasSeededVocabularyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSeededVocabulary', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByLastRunAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRunAt', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByLastRunAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastRunAt', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByLearnedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedCount', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByLearnedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnedCount', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByPreferredRows() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredRows', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByPreferredRowsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredRows', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByRowBlasterCharges() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowBlasterCharges', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByRowBlasterChargesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rowBlasterCharges', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByTimeExtendTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendTokens', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByTimeExtendTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeExtendTokens', Sort.desc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByTroubleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleCount', Sort.asc);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QAfterSortBy> thenByTroubleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'troubleCount', Sort.desc);
    });
  }
}

extension UserMetaQueryWhereDistinct
    on QueryBuilder<UserMeta, UserMeta, QDistinct> {
  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByHasSeededVocabulary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasSeededVocabulary');
    });
  }

  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByLastRunAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastRunAt');
    });
  }

  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByLearnedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learnedCount');
    });
  }

  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByLevel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByPreferredRows() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preferredRows');
    });
  }

  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByRowBlasterCharges() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rowBlasterCharges');
    });
  }

  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByTimeExtendTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeExtendTokens');
    });
  }

  QueryBuilder<UserMeta, UserMeta, QDistinct> distinctByTroubleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'troubleCount');
    });
  }
}

extension UserMetaQueryProperty
    on QueryBuilder<UserMeta, UserMeta, QQueryProperty> {
  QueryBuilder<UserMeta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserMeta, bool, QQueryOperations> hasSeededVocabularyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasSeededVocabulary');
    });
  }

  QueryBuilder<UserMeta, DateTime?, QQueryOperations> lastRunAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastRunAt');
    });
  }

  QueryBuilder<UserMeta, int, QQueryOperations> learnedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learnedCount');
    });
  }

  QueryBuilder<UserMeta, String, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<UserMeta, int, QQueryOperations> preferredRowsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredRows');
    });
  }

  QueryBuilder<UserMeta, int, QQueryOperations> rowBlasterChargesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rowBlasterCharges');
    });
  }

  QueryBuilder<UserMeta, int, QQueryOperations> timeExtendTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeExtendTokens');
    });
  }

  QueryBuilder<UserMeta, int, QQueryOperations> troubleCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'troubleCount');
    });
  }
}
