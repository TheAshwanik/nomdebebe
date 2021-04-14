import 'dart:io';
import 'package:namekit/models/name.dart';
import 'package:namekit/models/sex.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:namekit/models/filter.dart';

class NamesProvider {
  final Database _db;
  static const int CURRENT_VERSION = 1;

  static Future<NamesProvider> load({bool? isTest}) async {
    Directory documents = await getApplicationDocumentsDirectory();
    String path = p.join(documents.path, "namekit.db");
    if (await FileSystemEntity.type(path) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(p.join("assets", "namekit.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await new File(path).writeAsBytes(bytes);
    }

    Database db;
    db = sqlite3.open(path, mutex: true);
    return NamesProvider._(db);
  }

  NamesProvider._(this._db) {
    while (_db.userVersion < CURRENT_VERSION) {
      if (_db.userVersion == 0) {
        _db.execute("begin transaction");
        try {
          _db.execute('''
            alter table names add column like boolean default null''');
          _db.execute('''
            create table name_ranks(
              id integer not null primary key,
              rank integer default null,
              foreign key(id) references names(id)
            )''');
          _db.userVersion = 1;
        } catch (e) {
          _db.execute("rollback transaction");
          throw e;
        }
        _db.execute("commit transaction");
      }
    }

    _db.execute("PRAGMA foreign_keys = ON");
  }

  void factoryReset() {
    _db.execute("begin transaction");
    try {
      _db.execute("delete from name_ranks");
      _db.execute("update names set like = null");
    } catch (e) {
      _db.execute("rollback transaction");
      throw e;
    }
    _db.execute("commit transaction");
  }

  String _formatFilterQuery(List<Filter> filters) {
    if (filters.isEmpty) return "";
    return "WHERE " + filters.map((f) => f.query).join(" AND ");
  }

  int countNames(List<Filter> filters) {
    ResultSet results = _db.select(
        "select count(*) from names ${_formatFilterQuery(filters)}",
        filters.expand((f) => f.args).toList());
    return results.first.columnAt(0);
  }

  List<Name> getNames(List<Filter> filters, int skip, int count) {
    String query =
        "select id, name, sex, like from names ${_formatFilterQuery(filters)} limit ? offset ?";
    PreparedStatement stmt = _db.prepare(query);
    List<Object> args = filters.expand((f) => f.args).toList() + [count, skip];
    //print(
    //"getNames query: `$query`, args: [${args.map((a) => a.toString()).join(',')}]");
    ResultSet results = stmt.select(args);
    List<Name> names = results.map((Row r) {
      int id = r['id'];
      String name = r['name'];
      String s = r['sex'];
      int? l = r['like'];
      bool? like;
      if (l == 1)
        like = true;
      else if (l == 0) like = false;
      return Name(id, name, sexFromString(s), like);
    }).toList();
    stmt.dispose();
    return names;
  }

  void setNameLike(int id, bool? like) {
    _db.execute("begin transaction");
    try {
      PreparedStatement stmt =
          _db.prepare("update names set like = ? where id = ?");
      int? l;
      if (like == true)
        l = 1;
      else if (like == false) l = 0;
      stmt.execute([l, id]);
      stmt.dispose();

      if (like == true) {
        PreparedStatement stmt2 = _db.prepare(
            "insert or ignore into name_ranks(id, rank) values(?, null)");
        stmt2.execute([id]);
        stmt2.dispose();
      } else {
        PreparedStatement stmt2 =
            _db.prepare("delete from name_ranks where id=?");
        stmt2.execute([id]);
        stmt2.dispose();
      }
    } catch (e) {
      _db.execute("rollback transaction");
      throw e;
    }
    _db.execute("commit transaction");
  }

  void rankLikedNames(List<int> sortedIds) {
    _db.execute("begin transaction");
    try {
      PreparedStatement stmt = _db
          .prepare("update name_ranks set rank=? where id=?", persistent: true);
      for (int i = 0; i < sortedIds.length; i++) {
        stmt.execute([i, sortedIds[i]]);
      }
      stmt.dispose();
    } catch (e) {
      _db.execute("rollback transaction");
      throw e;
    }
    _db.execute("commit transaction");
  }

  List<int> getRankedLikedNameIds(List<Filter> filters, int skip, int count) {
    List<Object> args = filters.expand((f) => f.args).toList() + [count, skip];
    ResultSet results = _db.select(
        "select names.id as id from names inner join name_ranks on name_ranks.id = names.id ${_formatFilterQuery(filters)} order by name_ranks.rank asc nulls last limit ? offset ?",
        args);
    return results.map((Row r) => r['id'] as int).toList();
  }

  List<Name> getRankedLikedNames(List<Filter> filters, int skip, int count) {
    List<Object> args = filters.expand((f) => f.args).toList() + [count, skip];
    ResultSet results = _db.select(
        "select names.id as id, names.name as name, names.sex as sex, names.like as like from names inner join name_ranks on name_ranks.id = names.id ${_formatFilterQuery(filters)} order by name_ranks.rank asc nulls last limit ? offset ?",
        args);
    return results.map((Row r) {
      int id = r['id'];
      String name = r['name'];
      String s = r['sex'];
      int? l = r['like'];
      bool? like;
      if (l == 1)
        like = true;
      else if (l == 0) like = false;
      return Name(id, name, sexFromString(s), like);
    }).toList();
  }
}
