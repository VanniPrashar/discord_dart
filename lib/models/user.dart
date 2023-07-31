import 'package:discord/db/db.dart';
// import 'package:crypto/crypto.dart';
// import 'package:password_hash/password_hash.dart';

import 'dart:io';

import 'package:sembast/sembast.dart';

class Users {
  late dynamic id;
  late String username;
  late String password;

  Users(this.id, this.password, this.username);
  static Future<void> userDB() async {
    await Db.connect(dbName: 'users.db');
  }

  static Future<Users> Register() async {
    await userDB();
    print("Enter Username");
    final username = stdin.readLineSync().toString();
    print("Enter password");
    final password = stdin.readLineSync().toString();

    final id = await Db.store.add(Db.db, '$username $password true');
    return Users(id, password, username);
  }

  static Future<Users> Login(
      {required String username, required String password}) async {
    await userDB();
    for (int i = 1; true; i++) {
      final response = await Db.get(key: i);
      if (response == null) {
        print("Register First");
        final user = await Users.Register();
        return user;
      }
      final userName = response.split(' ')[0];
      final passWord = response.split(' ')[1];
      var isLoggedIn = response.split(' ')[2];
      if (username == userName) {
        if (password == passWord) {
          return Users(i, passWord, userName);
        } else {
          print("Invalid Password");
          exit(1);
        }
      } else {
        print("No such user register first");
        return await Users.Register();
      }
    }
  }

  static Future<void> Logout(String username) async {
    await userDB();
    for (var i = 0; true; i++) {
      final res = await Db.get(key: i);
      if (res == null) {
        break;
      } else {
        if (res.split(' ')[0] == username) {
          Db.delete(key: i);
        }
      }
    }
  }
}
