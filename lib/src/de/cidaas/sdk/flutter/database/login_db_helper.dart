

import 'package:path/path.dart' as path;
import '../entity/token_entity.dart';
import 'package:sqflite/sqflite.dart' as sql;


class LoginDBHelper {
  static final loginTableName = 'login';


  static Future<bool> insert(TokenEntity tokenEntity) async {
    final sqlDb = await database();
    final tokenInfoToSave = {
      "sub": tokenEntity.sub,
      "access_token": tokenEntity.accessToken,
      "id_token": tokenEntity.idToken,
      "refresh_token": tokenEntity.refreshToken,
    };
    final userExists = await LoginDBHelper.checkUser(tokenEntity.sub);
    if (userExists) {
      await sqlDb.update(loginTableName, tokenInfoToSave, where: 'sub = ?', whereArgs: [tokenEntity.sub]);
    } else {
      await sqlDb.insert(loginTableName, tokenInfoToSave, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }
    return true;
  }

  static Future<bool> checkUser(String sub) async {
    final sqlDb = await database();

    List<Map> maps = await sqlDb.query(loginTableName, columns: ['sub'], where: 'sub = ?', whereArgs: [sub]);
    if (maps.length > 0) {
      return true;
    }
    return false;
  }

  static Future<TokenEntity> getCurrentToken() async {
    final sqlDb = await database();

    List<Map<String, dynamic>> records = await sqlDb.query(loginTableName);

    if (records.length > 0) {
      return TokenEntity.fromJson(records.first);
    }
    return null;
  }

  static Future<bool> deleteAllUser() async {
    final sqlDb = await database();

    List<Map<String, dynamic>> records = await sqlDb.query(loginTableName);

    if (records.length > 0) {
      for (var record in records) {
        final user = TokenEntity.fromJson(record);
        await sqlDb.delete(loginTableName, where: 'sub = ?', whereArgs: [user.sub]);
      }
    }

    return true;
  }

  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    final sqlDb = await sql.openDatabase(
      path.join(dbPath, 'cidaas.db'),
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE ${loginTableName} (sub TEXT PRIMARY KEY, access_token TEXT, id_token TEXT, refresh_token TEXT)');
        return;
      },
      version: 1,
    );
    return sqlDb;
  }

}
