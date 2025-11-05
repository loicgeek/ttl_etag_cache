// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_ttl_etag_response.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedTtlEtagResponseCollection on Isar {
  IsarCollection<CachedTtlEtagResponse> get cachedTtlEtagResponses =>
      this.collection();
}

const CachedTtlEtagResponseSchema = CollectionSchema(
  name: r'CachedTtlEtagResponse',
  id: 3277880744264082073,
  properties: {
    r'data': PropertySchema(id: 0, name: r'data', type: IsarType.string),
    r'etag': PropertySchema(id: 1, name: r'etag', type: IsarType.string),
    r'isStale': PropertySchema(id: 2, name: r'isStale', type: IsarType.bool),
    r'timestamp': PropertySchema(
      id: 3,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'ttlSeconds': PropertySchema(
      id: 4,
      name: r'ttlSeconds',
      type: IsarType.long,
    ),
    r'url': PropertySchema(id: 5, name: r'url', type: IsarType.string),
  },

  estimateSize: _cachedTtlEtagResponseEstimateSize,
  serialize: _cachedTtlEtagResponseSerialize,
  deserialize: _cachedTtlEtagResponseDeserialize,
  deserializeProp: _cachedTtlEtagResponseDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _cachedTtlEtagResponseGetId,
  getLinks: _cachedTtlEtagResponseGetLinks,
  attach: _cachedTtlEtagResponseAttach,
  version: '3.3.0-dev.3',
);

int _cachedTtlEtagResponseEstimateSize(
  CachedTtlEtagResponse object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.data.length * 3;
  {
    final value = object.etag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _cachedTtlEtagResponseSerialize(
  CachedTtlEtagResponse object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.data);
  writer.writeString(offsets[1], object.etag);
  writer.writeBool(offsets[2], object.isStale);
  writer.writeDateTime(offsets[3], object.timestamp);
  writer.writeLong(offsets[4], object.ttlSeconds);
  writer.writeString(offsets[5], object.url);
}

CachedTtlEtagResponse _cachedTtlEtagResponseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedTtlEtagResponse();
  object.data = reader.readString(offsets[0]);
  object.etag = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.isStale = reader.readBool(offsets[2]);
  object.timestamp = reader.readDateTime(offsets[3]);
  object.ttlSeconds = reader.readLong(offsets[4]);
  object.url = reader.readString(offsets[5]);
  return object;
}

P _cachedTtlEtagResponseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedTtlEtagResponseGetId(CachedTtlEtagResponse object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedTtlEtagResponseGetLinks(
  CachedTtlEtagResponse object,
) {
  return [];
}

void _cachedTtlEtagResponseAttach(
  IsarCollection<dynamic> col,
  Id id,
  CachedTtlEtagResponse object,
) {
  object.id = id;
}

extension CachedTtlEtagResponseQueryWhereSort
    on QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QWhere> {
  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedTtlEtagResponseQueryWhere
    on
        QueryBuilder<
          CachedTtlEtagResponse,
          CachedTtlEtagResponse,
          QWhereClause
        > {
  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterWhereClause>
  idBetween(
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

extension CachedTtlEtagResponseQueryFilter
    on
        QueryBuilder<
          CachedTtlEtagResponse,
          CachedTtlEtagResponse,
          QFilterCondition
        > {
  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'data',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'data',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'data',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'data',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'data',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'data',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'data',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'data',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'data', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  dataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'data', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'etag'),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'etag'),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'etag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'etag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'etag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'etag', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  etagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'etag', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  idBetween(
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

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  isStaleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isStale', value: value),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  timestampLessThan(DateTime value, {bool include = false}) {
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

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  timestampBetween(
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

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  ttlSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ttlSeconds', value: value),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  ttlSecondsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ttlSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  ttlSecondsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ttlSeconds',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  ttlSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ttlSeconds',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedTtlEtagResponse,
    CachedTtlEtagResponse,
    QAfterFilterCondition
  >
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }
}

extension CachedTtlEtagResponseQueryObject
    on
        QueryBuilder<
          CachedTtlEtagResponse,
          CachedTtlEtagResponse,
          QFilterCondition
        > {}

extension CachedTtlEtagResponseQueryLinks
    on
        QueryBuilder<
          CachedTtlEtagResponse,
          CachedTtlEtagResponse,
          QFilterCondition
        > {}

extension CachedTtlEtagResponseQuerySortBy
    on QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QSortBy> {
  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByIsStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByTtlSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension CachedTtlEtagResponseQuerySortThenBy
    on QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QSortThenBy> {
  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'etag', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByIsStaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isStale', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByTtlSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ttlSeconds', Sort.desc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QAfterSortBy>
  thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension CachedTtlEtagResponseQueryWhereDistinct
    on QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QDistinct> {
  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QDistinct>
  distinctByData({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QDistinct>
  distinctByEtag({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'etag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QDistinct>
  distinctByIsStale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isStale');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QDistinct>
  distinctByTtlSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ttlSeconds');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, CachedTtlEtagResponse, QDistinct>
  distinctByUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension CachedTtlEtagResponseQueryProperty
    on
        QueryBuilder<
          CachedTtlEtagResponse,
          CachedTtlEtagResponse,
          QQueryProperty
        > {
  QueryBuilder<CachedTtlEtagResponse, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, String, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, String?, QQueryOperations>
  etagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'etag');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, bool, QQueryOperations>
  isStaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isStale');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, int, QQueryOperations>
  ttlSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ttlSeconds');
    });
  }

  QueryBuilder<CachedTtlEtagResponse, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
