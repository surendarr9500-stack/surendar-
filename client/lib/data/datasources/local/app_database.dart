// ignore_for_file: unused_import
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tables
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text()();
  TextColumn get displayName => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get deviceName => text()();
  TextColumn get platform => text()();
  DateTimeColumn get registeredAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Components extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  TextColumn get manufacturer => text()();
  TextColumn get model => text()();
  TextColumn get meshId => text().unique()();
  RealColumn get x => real().withDefault(const Constant(0.0))();
  RealColumn get y => real().withDefault(const Constant(0.0))();
  RealColumn get z => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('UNKNOWN'))();
  TextColumn get installationLocation => text()();
  TextColumn get possibleFaults => text().withDefault(const Constant('[]'))(); // JSON
  TextColumn get maintenanceProcedures => text().withDefault(const Constant('[]'))();
  TextColumn get trainingReferences => text().withDefault(const Constant('[]'))();
  TextColumn get documentationReferences => text().withDefault(const Constant('[]'))();
  DateTimeColumn get lastInspection => dateTime().nullable()();
  DateTimeColumn get nextMaintenance => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class DigitalTwinModels extends Table {
  TextColumn get id => text()();
  TextColumn get componentId => text().nullable()();
  TextColumn get meshId => text().unique()();
  TextColumn get filePath => text()();
  TextColumn get fileUrl => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get checksum => text().nullable()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  TextColumn get difficulty => text().withDefault(const Constant('beginner'))();
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(true))();
  BoolColumn get offlineAvailable => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Modules extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get title => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  TextColumn get description => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Lessons extends Table {
  TextColumn get id => text()();
  TextColumn get moduleId => text()();
  TextColumn get title => text()();
  TextColumn get type => text().withDefault(const Constant('video'))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();
  TextColumn get contentPath => text().nullable()();
  TextColumn get contentUrl => text().nullable()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get checksum => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Media extends Table {
  TextColumn get id => text()();
  TextColumn get lessonId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get filePath => text().nullable()();
  TextColumn get fileUrl => text().nullable()();
  TextColumn get fileType => text()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  TextColumn get checksum => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  RealColumn get downloadProgress => real().withDefault(const Constant(0.0))();
  IntColumn get playbackPosition => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get category => text()();
  TextColumn get componentId => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get filePath => text().nullable()();
  TextColumn get fileUrl => text().nullable()();
  TextColumn get checksum => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get offlineAvailable => boolean().withDefault(const Constant(false))();
  TextColumn get ftsContent => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Quizzes extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().nullable()();
  TextColumn get lessonId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get passingScore => integer().withDefault(const Constant(70))();
  IntColumn get timeLimitMinutes => integer().withDefault(const Constant(30))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(true))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Questions extends Table {
  TextColumn get id => text()();
  TextColumn get quizId => text()();
  TextColumn get questionText => text()();
  TextColumn get type => text().withDefault(const Constant('multiple_choice'))();
  TextColumn get options => text()(); // JSON
  TextColumn get correctAnswer => text()();
  TextColumn get explanation => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get points => integer().withDefault(const Constant(1))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class QuizAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get quizId => text()();
  TextColumn get userId => text()();
  RealColumn get score => real().withDefault(const Constant(0.0))();
  IntColumn get maxScore => integer().withDefault(const Constant(0))();
  BoolColumn get passed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get answers => text().withDefault(const Constant('{}'))(); // JSON
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Diagnostics extends Table {
  TextColumn get id => text()();
  TextColumn get componentId => text()();
  TextColumn get reportedBy => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get aiAnalysis => text().nullable()(); // JSON
  TextColumn get faultCode => text().nullable()();
  TextColumn get severity => text().withDefault(const Constant('MEDIUM'))();
  TextColumn get status => text().withDefault(const Constant('OPEN'))();
  TextColumn get recommendedActions => text().withDefault(const Constant('[]'))(); // JSON
  TextColumn get technicianAction => text().nullable()();
  TextColumn get resolutionNotes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class MaintenanceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get componentId => text()();
  TextColumn get diagnosticId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get description => text()();
  TextColumn get performedBy => text()();
  DateTimeColumn get performedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get nextDue => dateTime().nullable()();
  TextColumn get attachments => text().withDefault(const Constant('[]'))();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Progress extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get courseId => text()();
  TextColumn get lessonId => text().nullable()();
  RealColumn get progressPercent => real().withDefault(const Constant(0.0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastAccessed => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get transactionId => text()();
  TextColumn get deviceId => text()();
  TextColumn get userId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get errorMessage => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {transactionId};
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text()();
  TextColumn get deviceId => text()();
  TextColumn get event => text()();
  TextColumn get entityType => text().nullable()();
  TextColumn get entityId => text().nullable()();
  TextColumn get result => text()();
  TextColumn get metadata => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {key};
}

class KnowledgeBase extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get chunkIndex => integer().withDefault(const Constant(0))();
  TextColumn get metadata => text().nullable()(); // JSON
  TextColumn get sourceDocumentId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Users,
  Devices,
  Components,
  DigitalTwinModels,
  Courses,
  Modules,
  Lessons,
  Media,
  Documents,
  Quizzes,
  Questions,
  QuizAttempts,
  Diagnostics,
  MaintenanceRecords,
  Progress,
  SyncQueue,
  AuditLogs,
  Settings,
  KnowledgeBase,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Seed data will be inserted via separate service
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA journal_mode = WAL');
      },
    );
  }

  // DAOs getters
  late final usersDao = UsersDao(this);
  late final componentsDao = ComponentsDao(this);
  late final coursesDao = CoursesDao(this);
  late final diagnosticsDao = DiagnosticsDao(this);
  late final syncQueueDao = SyncQueueDao(this);
  late final auditLogsDao = AuditLogsDao(this);
  late final knowledgeBaseDao = KnowledgeBaseDao(this);
  late final settingsDao = SettingsDao(this);
  late final quizDao = QuizDao(this);
  late final progressDao = ProgressDao(this);
  late final documentsDao = DocumentsDao(this);
  late final mediaDao = MediaDao(this);
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'capacity_connect.db',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}

// DAO Implementations
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);
  
  Future<List<User>> getAllUsers() => select(users).get();
  Future<User?> getUserById(String id) => (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  Future<User?> getUserByUsername(String username) => (select(users)..where((u) => u.username.equals(username))).getSingleOrNull();
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);
  Future<bool> updateUser(UsersCompanion user) => update(users).replace(user);
  Future<int> deleteUser(String id) => (delete(users)..where((u) => u.id.equals(id))).go();
}

@DriftAccessor(tables: [Components])
class ComponentsDao extends DatabaseAccessor<AppDatabase> with _$ComponentsDaoMixin {
  ComponentsDao(super.db);
  
  Future<List<Component>> getAllComponents() => select(components).get();
  Future<Component?> getComponentById(String id) => (select(components)..where((c) => c.id.equals(id))).getSingleOrNull();
  Future<Component?> getComponentByMeshId(String meshId) => (select(components)..where((c) => c.meshId.equals(meshId))).getSingleOrNull();
  Future<List<Component>> getComponentsByStatus(String status) => (select(components)..where((c) => c.status.equals(status))).get();
  Future<int> insertComponent(ComponentsCompanion comp) => into(components).insert(comp);
  Future<bool> updateComponent(ComponentsCompanion comp) => update(components).replace(comp);
  Future<int> updateComponentStatus(String id, String status) => (update(components)..where((c) => c.id.equals(id))).write(ComponentsCompanion(status: Value(status), updatedAt: Value(DateTime.now())));
  Future<int> deleteComponent(String id) => (delete(components)..where((c) => c.id.equals(id))).go();
  
  // Search
  Future<List<Component>> searchComponents(String query) {
    return (select(components)..where((c) => c.name.like('%$query%') | c.description.like('%$query%') | c.id.like('%$query%'))).get();
  }
}

@DriftAccessor(tables: [Courses, Modules, Lessons])
class CoursesDao extends DatabaseAccessor<AppDatabase> with _$CoursesDaoMixin {
  CoursesDao(super.db);
  
  Future<List<Course>> getAllCourses() => select(courses).get();
  Future<Course?> getCourseById(String id) => (select(courses)..where((c) => c.id.equals(id))).getSingleOrNull();
  Future<List<Module>> getModulesForCourse(String courseId) => (select(modules)..where((m) => m.courseId.equals(courseId))..orderBy([(m) => OrderingTerm.asc(m.orderIndex)])).get();
  Future<List<Lesson>> getLessonsForModule(String moduleId) => (select(lessons)..where((l) => l.moduleId.equals(moduleId))..orderBy([(l) => OrderingTerm.asc(l.orderIndex)])).get();
  Future<int> insertCourse(CoursesCompanion course) => into(courses).insert(course);
  Future<int> insertModule(ModulesCompanion module) => into(modules).insert(module);
  Future<int> insertLesson(LessonsCompanion lesson) => into(lessons).insert(lesson);
}

@DriftAccessor(tables: [Diagnostics])
class DiagnosticsDao extends DatabaseAccessor<AppDatabase> with _$DiagnosticsDaoMixin {
  DiagnosticsDao(super.db);
  
  Future<List<Diagnostic>> getAllDiagnostics() => (select(diagnostics)..orderBy([(d) => OrderingTerm.desc(d.createdAt)])).get();
  Future<Diagnostic?> getDiagnosticById(String id) => (select(diagnostics)..where((d) => d.id.equals(id))).getSingleOrNull();
  Future<List<Diagnostic>> getDiagnosticsByComponent(String componentId) => (select(diagnostics)..where((d) => d.componentId.equals(componentId))).get();
  Future<List<Diagnostic>> getDiagnosticsByStatus(String status) => (select(diagnostics)..where((d) => d.status.equals(status))).get();
  Future<int> insertDiagnostic(DiagnosticsCompanion diag) => into(diagnostics).insert(diag);
  Future<bool> updateDiagnostic(DiagnosticsCompanion diag) => update(diagnostics).replace(diag);
  Future<int> deleteDiagnostic(String id) => (delete(diagnostics)..where((d) => d.id.equals(id))).go();
}

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);
  
  Future<List<SyncQueueData>> getAll() => select(syncQueue).get();
  Future<List<SyncQueueData>> getByStatus(String status) => (select(syncQueue)..where((s) => s.syncStatus.equals(status))).get();
  Future<List<SyncQueueData>> getPending({int limit = 50}) => (select(syncQueue)..where((s) => s.syncStatus.equals('PENDING'))..orderBy([(s) => OrderingTerm.asc(s.createdAt)])..limit(limit)).get();
  Future<List<SyncQueueData>> getPendingForEntity(String entityType, String entityId) => (select(syncQueue)..where((s) => s.entityType.equals(entityType) & s.entityId.equals(entityId) & s.syncStatus.equals('PENDING'))).get();
  Future<SyncQueueData?> getByTransactionId(String txId) => (select(syncQueue)..where((s) => s.transactionId.equals(txId))).getSingleOrNull();
  Future<int> insertTransaction(SyncQueueCompanion tx) => into(syncQueue).insert(tx);
  Future<int> updateStatus(String txId, String status, {String? errorMessage}) => (update(syncQueue)..where((s) => s.transactionId.equals(txId))).write(SyncQueueCompanion(syncStatus: Value(status), errorMessage: errorMessage != null ? Value(errorMessage) : const Value.absent(), updatedAt: Value(DateTime.now())));
  Future<int> incrementRetry(String txId) async {
    final existing = await getByTransactionId(txId);
    if (existing == null) return 0;
    return (update(syncQueue)..where((s) => s.transactionId.equals(txId))).write(SyncQueueCompanion(retryCount: Value(existing.retryCount + 1)));
  }
  Future<int> updatePayload(String txId, String payload) => (update(syncQueue)..where((s) => s.transactionId.equals(txId))).write(SyncQueueCompanion(payload: Value(payload), updatedAt: Value(DateTime.now())));
  Future<int> deleteSynced() => (delete(syncQueue)..where((s) => s.syncStatus.equals('SYNCED'))).go();
}

@DriftAccessor(tables: [AuditLogs])
class AuditLogsDao extends DatabaseAccessor<AppDatabase> with _$AuditLogsDaoMixin {
  AuditLogsDao(super.db);
  
  Future<List<AuditLog>> getAllLogs() => (select(auditLogs)..orderBy([(a) => OrderingTerm.desc(a.timestamp)])).get();
  Future<List<AuditLog>> getLogsByUser(String userId) => (select(auditLogs)..where((a) => a.userId.equals(userId))..orderBy([(a) => OrderingTerm.desc(a.timestamp)])).get();
  Future<List<AuditLog>> getLogsByEvent(String event) => (select(auditLogs)..where((a) => a.event.equals(event))).get();
  Future<int> insertLog(AuditLogsCompanion log) => into(auditLogs).insert(log);
  Future<List<AuditLog>> getPendingSync() => (select(auditLogs)..where((a) => a.syncStatus.equals('PENDING'))).get();
}

@DriftAccessor(tables: [KnowledgeBase])
class KnowledgeBaseDao extends DatabaseAccessor<AppDatabase> with _$KnowledgeBaseDaoMixin {
  KnowledgeBaseDao(super.db);
  
  Future<List<KnowledgeBaseData>> getAll() => select(knowledgeBase).get();
  Future<List<KnowledgeBaseData>> search(String query) {
    // Simple LIKE search for now, FTS5 would be better but requires custom setup
    return (select(knowledgeBase)..where((k) => k.title.like('%$query%') | k.content.like('%$query%'))).get();
  }
  Future<int> insertChunk(KnowledgeBaseCompanion chunk) => into(knowledgeBase).insert(chunk);
  Future<int> insertChunks(List<KnowledgeBaseCompanion> chunks) async {
    int count = 0;
    for (final chunk in chunks) {
      await into(knowledgeBase).insert(chunk);
      count++;
    }
    return count;
  }
}

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);
  
  Future<Setting?> getSetting(String key) => (select(settings)..where((s) => s.key.equals(key))).getSingleOrNull();
  Future<String?> getValue(String key) async {
    final setting = await getSetting(key);
    return setting?.value;
  }
  Future<int> setSetting(String key, String value) => into(settings).insertOnConflictUpdate(SettingsCompanion(key: Value(key), value: Value(value), updatedAt: Value(DateTime.now())));
}

@DriftAccessor(tables: [Quizzes, Questions, QuizAttempts])
class QuizDao extends DatabaseAccessor<AppDatabase> with _$QuizDaoMixin {
  QuizDao(super.db);
  
  Future<List<Quiz>> getAllQuizzes() => select(quizzes).get();
  Future<Quiz?> getQuizById(String id) => (select(quizzes)..where((q) => q.id.equals(id))).getSingleOrNull();
  Future<List<Question>> getQuestionsForQuiz(String quizId) => (select(questions)..where((q) => q.quizId.equals(quizId))..orderBy([(q) => OrderingTerm.asc(q.orderIndex)])).get();
  Future<int> insertQuiz(QuizzesCompanion quiz) => into(quizzes).insert(quiz);
  Future<int> insertQuestion(QuestionsCompanion question) => into(questions).insert(question);
  Future<int> insertAttempt(QuizAttemptsCompanion attempt) => into(quizAttempts).insert(attempt);
  Future<List<QuizAttempt>> getAttemptsForUser(String userId) => (select(quizAttempts)..where((a) => a.userId.equals(userId))..orderBy([(a) => OrderingTerm.desc(a.startedAt)])).get();
  Future<List<QuizAttempt>> getAttemptsForQuiz(String quizId) => (select(quizAttempts)..where((a) => a.quizId.equals(quizId))).get();
}

@DriftAccessor(tables: [Progress])
class ProgressDao extends DatabaseAccessor<AppDatabase> with _$ProgressDaoMixin {
  ProgressDao(super.db);
  
  Future<List<ProgressData>> getProgressForUser(String userId) => (select(progress)..where((p) => p.userId.equals(userId))).get();
  Future<ProgressData?> getProgress(String userId, String courseId, {String? lessonId}) {
    var query = select(progress)..where((p) => p.userId.equals(userId) & p.courseId.equals(courseId));
    if (lessonId != null) {
      query = query..where((p) => p.lessonId.equals(lessonId));
    }
    return query.getSingleOrNull();
  }
  Future<int> upsertProgress(ProgressCompanion prog) => into(progress).insertOnConflictUpdate(prog);
}

@DriftAccessor(tables: [Documents])
class DocumentsDao extends DatabaseAccessor<AppDatabase> with _$DocumentsDaoMixin {
  DocumentsDao(super.db);
  
  Future<List<Document>> getAllDocuments() => select(documents).get();
  Future<Document?> getDocumentById(String id) => (select(documents)..where((d) => d.id.equals(id))).getSingleOrNull();
  Future<List<Document>> searchDocuments(String query) => (select(documents)..where((d) => d.title.like('%$query%') | d.ftsContent.like('%$query%'))).get();
  Future<int> insertDocument(DocumentsCompanion doc) => into(documents).insert(doc);
}

@DriftAccessor(tables: [Media])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);
  
  Future<List<MediaData>> getAllMedia() => select(media).get();
  Future<MediaData?> getMediaById(String id) => (select(media)..where((m) => m.id.equals(id))).getSingleOrNull();
  Future<List<MediaData>> getMediaForLesson(String lessonId) => (select(media)..where((m) => m.lessonId.equals(lessonId))).get();
  Future<int> insertMedia(MediaCompanion m) => into(media).insert(m);
  Future<int> updateProgress(String id, double progress) => (update(media)..where((m) => m.id.equals(id))).write(MediaCompanion(downloadProgress: Value(progress)));
  Future<int> updatePlaybackPosition(String id, int position) => (update(media)..where((m) => m.id.equals(id))).write(MediaCompanion(playbackPosition: Value(position)));
}
