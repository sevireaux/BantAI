// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PendingReportsTable extends PendingReports
    with TableInfo<$PendingReportsTable, PendingReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientUuidMeta =
      const VerificationMeta('clientUuid');
  @override
  late final GeneratedColumn<String> clientUuid = GeneratedColumn<String>(
      'client_uuid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subcategoryIdMeta =
      const VerificationMeta('subcategoryId');
  @override
  late final GeneratedColumn<String> subcategoryId = GeneratedColumn<String>(
      'subcategory_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lguIdMeta = const VerificationMeta('lguId');
  @override
  late final GeneratedColumn<String> lguId = GeneratedColumn<String>(
      'lgu_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _barangayIdMeta =
      const VerificationMeta('barangayId');
  @override
  late final GeneratedColumn<String> barangayId = GeneratedColumn<String>(
      'barangay_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathsJsonMeta =
      const VerificationMeta('photoPathsJson');
  @override
  late final GeneratedColumn<String> photoPathsJson = GeneratedColumn<String>(
      'photo_paths_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _deviceSubmittedAtMeta =
      const VerificationMeta('deviceSubmittedAt');
  @override
  late final GeneratedColumn<DateTime> deviceSubmittedAt =
      GeneratedColumn<DateTime>('device_submitted_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        clientUuid,
        categoryId,
        subcategoryId,
        title,
        description,
        address,
        lat,
        lng,
        lguId,
        barangayId,
        photoPathsJson,
        deviceSubmittedAt,
        status,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_reports';
  @override
  VerificationContext validateIntegrity(Insertable<PendingReport> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_uuid')) {
      context.handle(
          _clientUuidMeta,
          clientUuid.isAcceptableOrUnknown(
              data['client_uuid']!, _clientUuidMeta));
    } else if (isInserting) {
      context.missing(_clientUuidMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
          _subcategoryIdMeta,
          subcategoryId.isAcceptableOrUnknown(
              data['subcategory_id']!, _subcategoryIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('lgu_id')) {
      context.handle(
          _lguIdMeta, lguId.isAcceptableOrUnknown(data['lgu_id']!, _lguIdMeta));
    }
    if (data.containsKey('barangay_id')) {
      context.handle(
          _barangayIdMeta,
          barangayId.isAcceptableOrUnknown(
              data['barangay_id']!, _barangayIdMeta));
    }
    if (data.containsKey('photo_paths_json')) {
      context.handle(
          _photoPathsJsonMeta,
          photoPathsJson.isAcceptableOrUnknown(
              data['photo_paths_json']!, _photoPathsJsonMeta));
    }
    if (data.containsKey('device_submitted_at')) {
      context.handle(
          _deviceSubmittedAtMeta,
          deviceSubmittedAt.isAcceptableOrUnknown(
              data['device_submitted_at']!, _deviceSubmittedAtMeta));
    } else if (isInserting) {
      context.missing(_deviceSubmittedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientUuid};
  @override
  PendingReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingReport(
      clientUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_uuid'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      subcategoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subcategory_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      lguId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lgu_id']),
      barangayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barangay_id']),
      photoPathsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}photo_paths_json'])!,
      deviceSubmittedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}device_submitted_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $PendingReportsTable createAlias(String alias) {
    return $PendingReportsTable(attachedDatabase, alias);
  }
}

class PendingReport extends DataClass implements Insertable<PendingReport> {
  final String clientUuid;
  final String categoryId;
  final String? subcategoryId;
  final String title;
  final String description;
  final String? address;
  final double lat;
  final double lng;
  final String? lguId;
  final String? barangayId;
  final String photoPathsJson;
  final DateTime deviceSubmittedAt;
  final String status;
  final int retryCount;
  final String? lastError;
  const PendingReport(
      {required this.clientUuid,
      required this.categoryId,
      this.subcategoryId,
      required this.title,
      required this.description,
      this.address,
      required this.lat,
      required this.lng,
      this.lguId,
      this.barangayId,
      required this.photoPathsJson,
      required this.deviceSubmittedAt,
      required this.status,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_uuid'] = Variable<String>(clientUuid);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<String>(subcategoryId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || lguId != null) {
      map['lgu_id'] = Variable<String>(lguId);
    }
    if (!nullToAbsent || barangayId != null) {
      map['barangay_id'] = Variable<String>(barangayId);
    }
    map['photo_paths_json'] = Variable<String>(photoPathsJson);
    map['device_submitted_at'] = Variable<DateTime>(deviceSubmittedAt);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingReportsCompanion toCompanion(bool nullToAbsent) {
    return PendingReportsCompanion(
      clientUuid: Value(clientUuid),
      categoryId: Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      title: Value(title),
      description: Value(description),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      lat: Value(lat),
      lng: Value(lng),
      lguId:
          lguId == null && nullToAbsent ? const Value.absent() : Value(lguId),
      barangayId: barangayId == null && nullToAbsent
          ? const Value.absent()
          : Value(barangayId),
      photoPathsJson: Value(photoPathsJson),
      deviceSubmittedAt: Value(deviceSubmittedAt),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingReport.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingReport(
      clientUuid: serializer.fromJson<String>(json['clientUuid']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      subcategoryId: serializer.fromJson<String?>(json['subcategoryId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      address: serializer.fromJson<String?>(json['address']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      lguId: serializer.fromJson<String?>(json['lguId']),
      barangayId: serializer.fromJson<String?>(json['barangayId']),
      photoPathsJson: serializer.fromJson<String>(json['photoPathsJson']),
      deviceSubmittedAt:
          serializer.fromJson<DateTime>(json['deviceSubmittedAt']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientUuid': serializer.toJson<String>(clientUuid),
      'categoryId': serializer.toJson<String>(categoryId),
      'subcategoryId': serializer.toJson<String?>(subcategoryId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'address': serializer.toJson<String?>(address),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'lguId': serializer.toJson<String?>(lguId),
      'barangayId': serializer.toJson<String?>(barangayId),
      'photoPathsJson': serializer.toJson<String>(photoPathsJson),
      'deviceSubmittedAt': serializer.toJson<DateTime>(deviceSubmittedAt),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingReport copyWith(
          {String? clientUuid,
          String? categoryId,
          Value<String?> subcategoryId = const Value.absent(),
          String? title,
          String? description,
          Value<String?> address = const Value.absent(),
          double? lat,
          double? lng,
          Value<String?> lguId = const Value.absent(),
          Value<String?> barangayId = const Value.absent(),
          String? photoPathsJson,
          DateTime? deviceSubmittedAt,
          String? status,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      PendingReport(
        clientUuid: clientUuid ?? this.clientUuid,
        categoryId: categoryId ?? this.categoryId,
        subcategoryId:
            subcategoryId.present ? subcategoryId.value : this.subcategoryId,
        title: title ?? this.title,
        description: description ?? this.description,
        address: address.present ? address.value : this.address,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        lguId: lguId.present ? lguId.value : this.lguId,
        barangayId: barangayId.present ? barangayId.value : this.barangayId,
        photoPathsJson: photoPathsJson ?? this.photoPathsJson,
        deviceSubmittedAt: deviceSubmittedAt ?? this.deviceSubmittedAt,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  PendingReport copyWithCompanion(PendingReportsCompanion data) {
    return PendingReport(
      clientUuid:
          data.clientUuid.present ? data.clientUuid.value : this.clientUuid,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      address: data.address.present ? data.address.value : this.address,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      lguId: data.lguId.present ? data.lguId.value : this.lguId,
      barangayId:
          data.barangayId.present ? data.barangayId.value : this.barangayId,
      photoPathsJson: data.photoPathsJson.present
          ? data.photoPathsJson.value
          : this.photoPathsJson,
      deviceSubmittedAt: data.deviceSubmittedAt.present
          ? data.deviceSubmittedAt.value
          : this.deviceSubmittedAt,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingReport(')
          ..write('clientUuid: $clientUuid, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('lguId: $lguId, ')
          ..write('barangayId: $barangayId, ')
          ..write('photoPathsJson: $photoPathsJson, ')
          ..write('deviceSubmittedAt: $deviceSubmittedAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      clientUuid,
      categoryId,
      subcategoryId,
      title,
      description,
      address,
      lat,
      lng,
      lguId,
      barangayId,
      photoPathsJson,
      deviceSubmittedAt,
      status,
      retryCount,
      lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingReport &&
          other.clientUuid == this.clientUuid &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.title == this.title &&
          other.description == this.description &&
          other.address == this.address &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.lguId == this.lguId &&
          other.barangayId == this.barangayId &&
          other.photoPathsJson == this.photoPathsJson &&
          other.deviceSubmittedAt == this.deviceSubmittedAt &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class PendingReportsCompanion extends UpdateCompanion<PendingReport> {
  final Value<String> clientUuid;
  final Value<String> categoryId;
  final Value<String?> subcategoryId;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> address;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String?> lguId;
  final Value<String?> barangayId;
  final Value<String> photoPathsJson;
  final Value<DateTime> deviceSubmittedAt;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PendingReportsCompanion({
    this.clientUuid = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.lguId = const Value.absent(),
    this.barangayId = const Value.absent(),
    this.photoPathsJson = const Value.absent(),
    this.deviceSubmittedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingReportsCompanion.insert({
    required String clientUuid,
    required String categoryId,
    this.subcategoryId = const Value.absent(),
    this.title = const Value.absent(),
    required String description,
    this.address = const Value.absent(),
    required double lat,
    required double lng,
    this.lguId = const Value.absent(),
    this.barangayId = const Value.absent(),
    this.photoPathsJson = const Value.absent(),
    required DateTime deviceSubmittedAt,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : clientUuid = Value(clientUuid),
        categoryId = Value(categoryId),
        description = Value(description),
        lat = Value(lat),
        lng = Value(lng),
        deviceSubmittedAt = Value(deviceSubmittedAt);
  static Insertable<PendingReport> custom({
    Expression<String>? clientUuid,
    Expression<String>? categoryId,
    Expression<String>? subcategoryId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? address,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? lguId,
    Expression<String>? barangayId,
    Expression<String>? photoPathsJson,
    Expression<DateTime>? deviceSubmittedAt,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientUuid != null) 'client_uuid': clientUuid,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (lguId != null) 'lgu_id': lguId,
      if (barangayId != null) 'barangay_id': barangayId,
      if (photoPathsJson != null) 'photo_paths_json': photoPathsJson,
      if (deviceSubmittedAt != null) 'device_submitted_at': deviceSubmittedAt,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingReportsCompanion copyWith(
      {Value<String>? clientUuid,
      Value<String>? categoryId,
      Value<String?>? subcategoryId,
      Value<String>? title,
      Value<String>? description,
      Value<String?>? address,
      Value<double>? lat,
      Value<double>? lng,
      Value<String?>? lguId,
      Value<String?>? barangayId,
      Value<String>? photoPathsJson,
      Value<DateTime>? deviceSubmittedAt,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return PendingReportsCompanion(
      clientUuid: clientUuid ?? this.clientUuid,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      lguId: lguId ?? this.lguId,
      barangayId: barangayId ?? this.barangayId,
      photoPathsJson: photoPathsJson ?? this.photoPathsJson,
      deviceSubmittedAt: deviceSubmittedAt ?? this.deviceSubmittedAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientUuid.present) {
      map['client_uuid'] = Variable<String>(clientUuid.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<String>(subcategoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (lguId.present) {
      map['lgu_id'] = Variable<String>(lguId.value);
    }
    if (barangayId.present) {
      map['barangay_id'] = Variable<String>(barangayId.value);
    }
    if (photoPathsJson.present) {
      map['photo_paths_json'] = Variable<String>(photoPathsJson.value);
    }
    if (deviceSubmittedAt.present) {
      map['device_submitted_at'] = Variable<DateTime>(deviceSubmittedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingReportsCompanion(')
          ..write('clientUuid: $clientUuid, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('lguId: $lguId, ')
          ..write('barangayId: $barangayId, ')
          ..write('photoPathsJson: $photoPathsJson, ')
          ..write('deviceSubmittedAt: $deviceSubmittedAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedCategoriesTable extends CachedCategories
    with TableInfo<$CachedCategoriesTable, CachedCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subcategoriesJsonMeta =
      const VerificationMeta('subcategoriesJson');
  @override
  late final GeneratedColumn<String> subcategoriesJson =
      GeneratedColumn<String>('subcategories_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [id, name, subcategoriesJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_categories';
  @override
  VerificationContext validateIntegrity(Insertable<CachedCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subcategories_json')) {
      context.handle(
          _subcategoriesJsonMeta,
          subcategoriesJson.isAcceptableOrUnknown(
              data['subcategories_json']!, _subcategoriesJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      subcategoriesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}subcategories_json'])!,
    );
  }

  @override
  $CachedCategoriesTable createAlias(String alias) {
    return $CachedCategoriesTable(attachedDatabase, alias);
  }
}

class CachedCategory extends DataClass implements Insertable<CachedCategory> {
  final String id;
  final String name;
  final String subcategoriesJson;
  const CachedCategory(
      {required this.id, required this.name, required this.subcategoriesJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['subcategories_json'] = Variable<String>(subcategoriesJson);
    return map;
  }

  CachedCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CachedCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      subcategoriesJson: Value(subcategoriesJson),
    );
  }

  factory CachedCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      subcategoriesJson: serializer.fromJson<String>(json['subcategoriesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'subcategoriesJson': serializer.toJson<String>(subcategoriesJson),
    };
  }

  CachedCategory copyWith(
          {String? id, String? name, String? subcategoriesJson}) =>
      CachedCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        subcategoriesJson: subcategoriesJson ?? this.subcategoriesJson,
      );
  CachedCategory copyWithCompanion(CachedCategoriesCompanion data) {
    return CachedCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      subcategoriesJson: data.subcategoriesJson.present
          ? data.subcategoriesJson.value
          : this.subcategoriesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subcategoriesJson: $subcategoriesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, subcategoriesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.subcategoriesJson == this.subcategoriesJson);
}

class CachedCategoriesCompanion extends UpdateCompanion<CachedCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> subcategoriesJson;
  final Value<int> rowid;
  const CachedCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.subcategoriesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCategoriesCompanion.insert({
    required String id,
    required String name,
    this.subcategoriesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CachedCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? subcategoriesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (subcategoriesJson != null) 'subcategories_json': subcategoriesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? subcategoriesJson,
      Value<int>? rowid}) {
    return CachedCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      subcategoriesJson: subcategoriesJson ?? this.subcategoriesJson,
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
    if (subcategoriesJson.present) {
      map['subcategories_json'] = Variable<String>(subcategoriesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subcategoriesJson: $subcategoriesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedLgusTable extends CachedLgus
    with TableInfo<$CachedLgusTable, CachedLgusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedLgusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_lgus';
  @override
  VerificationContext validateIntegrity(Insertable<CachedLgusData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedLgusData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedLgusData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CachedLgusTable createAlias(String alias) {
    return $CachedLgusTable(attachedDatabase, alias);
  }
}

class CachedLgusData extends DataClass implements Insertable<CachedLgusData> {
  final String id;
  final String name;
  const CachedLgusData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedLgusCompanion toCompanion(bool nullToAbsent) {
    return CachedLgusCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory CachedLgusData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedLgusData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedLgusData copyWith({String? id, String? name}) => CachedLgusData(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  CachedLgusData copyWithCompanion(CachedLgusCompanion data) {
    return CachedLgusData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedLgusData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedLgusData &&
          other.id == this.id &&
          other.name == this.name);
}

class CachedLgusCompanion extends UpdateCompanion<CachedLgusData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CachedLgusCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedLgusCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CachedLgusData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedLgusCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return CachedLgusCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedLgusCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBarangaysTable extends CachedBarangays
    with TableInfo<$CachedBarangaysTable, CachedBarangay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBarangaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lguIdMeta = const VerificationMeta('lguId');
  @override
  late final GeneratedColumn<String> lguId = GeneratedColumn<String>(
      'lgu_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, lguId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_barangays';
  @override
  VerificationContext validateIntegrity(Insertable<CachedBarangay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lgu_id')) {
      context.handle(
          _lguIdMeta, lguId.isAcceptableOrUnknown(data['lgu_id']!, _lguIdMeta));
    } else if (isInserting) {
      context.missing(_lguIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBarangay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBarangay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lguId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lgu_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $CachedBarangaysTable createAlias(String alias) {
    return $CachedBarangaysTable(attachedDatabase, alias);
  }
}

class CachedBarangay extends DataClass implements Insertable<CachedBarangay> {
  final String id;
  final String lguId;
  final String name;
  const CachedBarangay(
      {required this.id, required this.lguId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lgu_id'] = Variable<String>(lguId);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedBarangaysCompanion toCompanion(bool nullToAbsent) {
    return CachedBarangaysCompanion(
      id: Value(id),
      lguId: Value(lguId),
      name: Value(name),
    );
  }

  factory CachedBarangay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBarangay(
      id: serializer.fromJson<String>(json['id']),
      lguId: serializer.fromJson<String>(json['lguId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lguId': serializer.toJson<String>(lguId),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedBarangay copyWith({String? id, String? lguId, String? name}) =>
      CachedBarangay(
        id: id ?? this.id,
        lguId: lguId ?? this.lguId,
        name: name ?? this.name,
      );
  CachedBarangay copyWithCompanion(CachedBarangaysCompanion data) {
    return CachedBarangay(
      id: data.id.present ? data.id.value : this.id,
      lguId: data.lguId.present ? data.lguId.value : this.lguId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBarangay(')
          ..write('id: $id, ')
          ..write('lguId: $lguId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lguId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBarangay &&
          other.id == this.id &&
          other.lguId == this.lguId &&
          other.name == this.name);
}

class CachedBarangaysCompanion extends UpdateCompanion<CachedBarangay> {
  final Value<String> id;
  final Value<String> lguId;
  final Value<String> name;
  final Value<int> rowid;
  const CachedBarangaysCompanion({
    this.id = const Value.absent(),
    this.lguId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBarangaysCompanion.insert({
    required String id,
    required String lguId,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        lguId = Value(lguId),
        name = Value(name);
  static Insertable<CachedBarangay> custom({
    Expression<String>? id,
    Expression<String>? lguId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lguId != null) 'lgu_id': lguId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBarangaysCompanion copyWith(
      {Value<String>? id,
      Value<String>? lguId,
      Value<String>? name,
      Value<int>? rowid}) {
    return CachedBarangaysCompanion(
      id: id ?? this.id,
      lguId: lguId ?? this.lguId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lguId.present) {
      map['lgu_id'] = Variable<String>(lguId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBarangaysCompanion(')
          ..write('id: $id, ')
          ..write('lguId: $lguId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PendingReportsTable pendingReports = $PendingReportsTable(this);
  late final $CachedCategoriesTable cachedCategories =
      $CachedCategoriesTable(this);
  late final $CachedLgusTable cachedLgus = $CachedLgusTable(this);
  late final $CachedBarangaysTable cachedBarangays =
      $CachedBarangaysTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [pendingReports, cachedCategories, cachedLgus, cachedBarangays];
}

typedef $$PendingReportsTableCreateCompanionBuilder = PendingReportsCompanion
    Function({
  required String clientUuid,
  required String categoryId,
  Value<String?> subcategoryId,
  Value<String> title,
  required String description,
  Value<String?> address,
  required double lat,
  required double lng,
  Value<String?> lguId,
  Value<String?> barangayId,
  Value<String> photoPathsJson,
  required DateTime deviceSubmittedAt,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$PendingReportsTableUpdateCompanionBuilder = PendingReportsCompanion
    Function({
  Value<String> clientUuid,
  Value<String> categoryId,
  Value<String?> subcategoryId,
  Value<String> title,
  Value<String> description,
  Value<String?> address,
  Value<double> lat,
  Value<double> lng,
  Value<String?> lguId,
  Value<String?> barangayId,
  Value<String> photoPathsJson,
  Value<DateTime> deviceSubmittedAt,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$PendingReportsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingReportsTable> {
  $$PendingReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subcategoryId => $composableBuilder(
      column: $table.subcategoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lguId => $composableBuilder(
      column: $table.lguId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barangayId => $composableBuilder(
      column: $table.barangayId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPathsJson => $composableBuilder(
      column: $table.photoPathsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deviceSubmittedAt => $composableBuilder(
      column: $table.deviceSubmittedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$PendingReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingReportsTable> {
  $$PendingReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subcategoryId => $composableBuilder(
      column: $table.subcategoryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lguId => $composableBuilder(
      column: $table.lguId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barangayId => $composableBuilder(
      column: $table.barangayId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPathsJson => $composableBuilder(
      column: $table.photoPathsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deviceSubmittedAt => $composableBuilder(
      column: $table.deviceSubmittedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$PendingReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingReportsTable> {
  $$PendingReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientUuid => $composableBuilder(
      column: $table.clientUuid, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get subcategoryId => $composableBuilder(
      column: $table.subcategoryId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get lguId =>
      $composableBuilder(column: $table.lguId, builder: (column) => column);

  GeneratedColumn<String> get barangayId => $composableBuilder(
      column: $table.barangayId, builder: (column) => column);

  GeneratedColumn<String> get photoPathsJson => $composableBuilder(
      column: $table.photoPathsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get deviceSubmittedAt => $composableBuilder(
      column: $table.deviceSubmittedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingReportsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingReportsTable,
    PendingReport,
    $$PendingReportsTableFilterComposer,
    $$PendingReportsTableOrderingComposer,
    $$PendingReportsTableAnnotationComposer,
    $$PendingReportsTableCreateCompanionBuilder,
    $$PendingReportsTableUpdateCompanionBuilder,
    (
      PendingReport,
      BaseReferences<_$AppDatabase, $PendingReportsTable, PendingReport>
    ),
    PendingReport,
    PrefetchHooks Function()> {
  $$PendingReportsTableTableManager(
      _$AppDatabase db, $PendingReportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> clientUuid = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String?> subcategoryId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<String?> lguId = const Value.absent(),
            Value<String?> barangayId = const Value.absent(),
            Value<String> photoPathsJson = const Value.absent(),
            Value<DateTime> deviceSubmittedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingReportsCompanion(
            clientUuid: clientUuid,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            title: title,
            description: description,
            address: address,
            lat: lat,
            lng: lng,
            lguId: lguId,
            barangayId: barangayId,
            photoPathsJson: photoPathsJson,
            deviceSubmittedAt: deviceSubmittedAt,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String clientUuid,
            required String categoryId,
            Value<String?> subcategoryId = const Value.absent(),
            Value<String> title = const Value.absent(),
            required String description,
            Value<String?> address = const Value.absent(),
            required double lat,
            required double lng,
            Value<String?> lguId = const Value.absent(),
            Value<String?> barangayId = const Value.absent(),
            Value<String> photoPathsJson = const Value.absent(),
            required DateTime deviceSubmittedAt,
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingReportsCompanion.insert(
            clientUuid: clientUuid,
            categoryId: categoryId,
            subcategoryId: subcategoryId,
            title: title,
            description: description,
            address: address,
            lat: lat,
            lng: lng,
            lguId: lguId,
            barangayId: barangayId,
            photoPathsJson: photoPathsJson,
            deviceSubmittedAt: deviceSubmittedAt,
            status: status,
            retryCount: retryCount,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PendingReportsTable, PendingReport>(table),
                    BaseReferences<_$AppDatabase, $PendingReportsTable,
                        PendingReport>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingReportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingReportsTable,
    PendingReport,
    $$PendingReportsTableFilterComposer,
    $$PendingReportsTableOrderingComposer,
    $$PendingReportsTableAnnotationComposer,
    $$PendingReportsTableCreateCompanionBuilder,
    $$PendingReportsTableUpdateCompanionBuilder,
    (
      PendingReport,
      BaseReferences<_$AppDatabase, $PendingReportsTable, PendingReport>
    ),
    PendingReport,
    PrefetchHooks Function()>;
typedef $$CachedCategoriesTableCreateCompanionBuilder
    = CachedCategoriesCompanion Function({
  required String id,
  required String name,
  Value<String> subcategoriesJson,
  Value<int> rowid,
});
typedef $$CachedCategoriesTableUpdateCompanionBuilder
    = CachedCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> subcategoriesJson,
  Value<int> rowid,
});

class $$CachedCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subcategoriesJson => $composableBuilder(
      column: $table.subcategoriesJson,
      builder: (column) => ColumnFilters(column));
}

class $$CachedCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subcategoriesJson => $composableBuilder(
      column: $table.subcategoriesJson,
      builder: (column) => ColumnOrderings(column));
}

class $$CachedCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get subcategoriesJson => $composableBuilder(
      column: $table.subcategoriesJson, builder: (column) => column);
}

class $$CachedCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedCategoriesTable,
    CachedCategory,
    $$CachedCategoriesTableFilterComposer,
    $$CachedCategoriesTableOrderingComposer,
    $$CachedCategoriesTableAnnotationComposer,
    $$CachedCategoriesTableCreateCompanionBuilder,
    $$CachedCategoriesTableUpdateCompanionBuilder,
    (
      CachedCategory,
      BaseReferences<_$AppDatabase, $CachedCategoriesTable, CachedCategory>
    ),
    CachedCategory,
    PrefetchHooks Function()> {
  $$CachedCategoriesTableTableManager(
      _$AppDatabase db, $CachedCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> subcategoriesJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedCategoriesCompanion(
            id: id,
            name: name,
            subcategoriesJson: subcategoriesJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> subcategoriesJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedCategoriesCompanion.insert(
            id: id,
            name: name,
            subcategoriesJson: subcategoriesJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedCategoriesTable, CachedCategory>(table),
                    BaseReferences<_$AppDatabase, $CachedCategoriesTable,
                        CachedCategory>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedCategoriesTable,
    CachedCategory,
    $$CachedCategoriesTableFilterComposer,
    $$CachedCategoriesTableOrderingComposer,
    $$CachedCategoriesTableAnnotationComposer,
    $$CachedCategoriesTableCreateCompanionBuilder,
    $$CachedCategoriesTableUpdateCompanionBuilder,
    (
      CachedCategory,
      BaseReferences<_$AppDatabase, $CachedCategoriesTable, CachedCategory>
    ),
    CachedCategory,
    PrefetchHooks Function()>;
typedef $$CachedLgusTableCreateCompanionBuilder = CachedLgusCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$CachedLgusTableUpdateCompanionBuilder = CachedLgusCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$CachedLgusTableFilterComposer
    extends Composer<_$AppDatabase, $CachedLgusTable> {
  $$CachedLgusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$CachedLgusTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedLgusTable> {
  $$CachedLgusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$CachedLgusTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedLgusTable> {
  $$CachedLgusTableAnnotationComposer({
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
}

class $$CachedLgusTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedLgusTable,
    CachedLgusData,
    $$CachedLgusTableFilterComposer,
    $$CachedLgusTableOrderingComposer,
    $$CachedLgusTableAnnotationComposer,
    $$CachedLgusTableCreateCompanionBuilder,
    $$CachedLgusTableUpdateCompanionBuilder,
    (
      CachedLgusData,
      BaseReferences<_$AppDatabase, $CachedLgusTable, CachedLgusData>
    ),
    CachedLgusData,
    PrefetchHooks Function()> {
  $$CachedLgusTableTableManager(_$AppDatabase db, $CachedLgusTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedLgusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedLgusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedLgusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedLgusCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedLgusCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedLgusTable, CachedLgusData>(table),
                    BaseReferences<_$AppDatabase, $CachedLgusTable,
                        CachedLgusData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedLgusTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedLgusTable,
    CachedLgusData,
    $$CachedLgusTableFilterComposer,
    $$CachedLgusTableOrderingComposer,
    $$CachedLgusTableAnnotationComposer,
    $$CachedLgusTableCreateCompanionBuilder,
    $$CachedLgusTableUpdateCompanionBuilder,
    (
      CachedLgusData,
      BaseReferences<_$AppDatabase, $CachedLgusTable, CachedLgusData>
    ),
    CachedLgusData,
    PrefetchHooks Function()>;
typedef $$CachedBarangaysTableCreateCompanionBuilder = CachedBarangaysCompanion
    Function({
  required String id,
  required String lguId,
  required String name,
  Value<int> rowid,
});
typedef $$CachedBarangaysTableUpdateCompanionBuilder = CachedBarangaysCompanion
    Function({
  Value<String> id,
  Value<String> lguId,
  Value<String> name,
  Value<int> rowid,
});

class $$CachedBarangaysTableFilterComposer
    extends Composer<_$AppDatabase, $CachedBarangaysTable> {
  $$CachedBarangaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lguId => $composableBuilder(
      column: $table.lguId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$CachedBarangaysTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedBarangaysTable> {
  $$CachedBarangaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lguId => $composableBuilder(
      column: $table.lguId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$CachedBarangaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedBarangaysTable> {
  $$CachedBarangaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lguId =>
      $composableBuilder(column: $table.lguId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedBarangaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedBarangaysTable,
    CachedBarangay,
    $$CachedBarangaysTableFilterComposer,
    $$CachedBarangaysTableOrderingComposer,
    $$CachedBarangaysTableAnnotationComposer,
    $$CachedBarangaysTableCreateCompanionBuilder,
    $$CachedBarangaysTableUpdateCompanionBuilder,
    (
      CachedBarangay,
      BaseReferences<_$AppDatabase, $CachedBarangaysTable, CachedBarangay>
    ),
    CachedBarangay,
    PrefetchHooks Function()> {
  $$CachedBarangaysTableTableManager(
      _$AppDatabase db, $CachedBarangaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBarangaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBarangaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBarangaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> lguId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedBarangaysCompanion(
            id: id,
            lguId: lguId,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String lguId,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedBarangaysCompanion.insert(
            id: id,
            lguId: lguId,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedBarangaysTable, CachedBarangay>(table),
                    BaseReferences<_$AppDatabase, $CachedBarangaysTable,
                        CachedBarangay>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedBarangaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedBarangaysTable,
    CachedBarangay,
    $$CachedBarangaysTableFilterComposer,
    $$CachedBarangaysTableOrderingComposer,
    $$CachedBarangaysTableAnnotationComposer,
    $$CachedBarangaysTableCreateCompanionBuilder,
    $$CachedBarangaysTableUpdateCompanionBuilder,
    (
      CachedBarangay,
      BaseReferences<_$AppDatabase, $CachedBarangaysTable, CachedBarangay>
    ),
    CachedBarangay,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PendingReportsTableTableManager get pendingReports =>
      $$PendingReportsTableTableManager(_db, _db.pendingReports);
  $$CachedCategoriesTableTableManager get cachedCategories =>
      $$CachedCategoriesTableTableManager(_db, _db.cachedCategories);
  $$CachedLgusTableTableManager get cachedLgus =>
      $$CachedLgusTableTableManager(_db, _db.cachedLgus);
  $$CachedBarangaysTableTableManager get cachedBarangays =>
      $$CachedBarangaysTableTableManager(_db, _db.cachedBarangays);
}
