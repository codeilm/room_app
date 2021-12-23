import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';

part 'moor_database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tagName =>
      text().nullable().customConstraint('NULL REFERENCES tags(name)')();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(Constant(false))();
}

class Tags extends Table {
  TextColumn get name => text().withLength(min: 1, max: 20)();
  IntColumn get color => integer()();

  @override
  Set<Column> get primaryKey => {name};
}

class TaskWithTag {
  final Task task;
  final Tag? tag;
  TaskWithTag(this.task, {this.tag});
}

@UseMoor(tables: [Tasks, Tags], daos: [TaskDao, TagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          FlutterQueryExecutor.inDatabaseFolder(
              path: 'db.sqlite', logStatements: true),
        );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          await migrator.addColumn(tasks, tasks.tagName);
          await migrator.createTable(tags);
        },
        beforeOpen: (openingDetails) async {
          print('Enabling Pragma');
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

@UseDao(tables: [Tasks, Tags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  final AppDatabase db;
  TaskDao(this.db) : super(db);

  Stream<List<TaskWithTag>> watchCompletedTasks() =>
      (select(tasks)..where((task) => task.completed))
          .join([innerJoin(tags, tags.name.equalsExp(tasks.tagName))])
          .watch()
          .map((rows) => rows
              .map((row) =>
                  TaskWithTag(row.readTable(tasks), tag: row.readTable(tags)))
              .toList());

  Stream<List<TaskWithTag>> watchTasks() => select(tasks)
      .join([innerJoin(tags, tags.name.equalsExp(tasks.tagName))])
      .watch()
      .map((rows) => rows
          .map((row) =>
              TaskWithTag(row.readTable(tasks), tag: row.readTable(tags)))
          .toList());

  Stream<List<Task>> watchOnlyTasks() => select(tasks).watch();

  Future<int> insertTask(Insertable<Task> task) => into(tasks).insert(task);

  Future<bool> updateTask(Insertable<Task> task) => update(tasks).replace(task);

  Future<int> deleteTask(Insertable<Task> task) => delete(tasks).delete(task);
}

@UseDao(tables: [Tags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  final AppDatabase db;
  TagDao(this.db) : super(db);

  Stream<List<Tag>> watchTags() => select(tags).watch();
  Future<int> insertTag(Tag tag) => into(tags).insert(tag);
}
