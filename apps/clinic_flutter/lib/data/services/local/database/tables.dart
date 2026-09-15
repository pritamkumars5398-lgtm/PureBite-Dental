import 'package:drift/drift.dart';

/// Local cache of patient records for offline reads.
class CachedPatients extends Table {
  TextColumn get id => text()();
  TextColumn get clinicId => text()();
  TextColumn get patientNumber => text().nullable()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get phone => text()();
  TextColumn get email => text()();
  TextColumn get dateOfBirth => text().nullable()();
  TextColumn get notes => text()();
  TextColumn get status => text()();
  BoolColumn get doNotContact => boolean()();
  IntColumn get updatedAt => integer()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local cache of appointment records for offline reads.
class CachedAppointments extends Table {
  TextColumn get id => text()();
  TextColumn get clinicId => text()();
  TextColumn get patientId => text().nullable()();
  TextColumn get professionalId => text()();
  IntColumn get startTime => integer()();
  IntColumn get endTime => integer()();
  TextColumn get status => text()();
  TextColumn get treatmentType => text().nullable()();
  TextColumn get patientName => text().nullable()();
  IntColumn get updatedAt => integer()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Pending REST writes replayed when connectivity returns.
class OutboxEntries extends Table {
  TextColumn get id => text()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get bodyJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Per-collection pull timestamps for incremental sync.
class SyncMeta extends Table {
  TextColumn get collection => text()();
  IntColumn get lastPulledAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {collection};
}
