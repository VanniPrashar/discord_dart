import 'dart:io';
import 'package:discord/db/db.dart';
import 'package:discord/models/user.dart';
import 'package:sembast/sembast.dart';

class Server {
  late dynamic id; //id pf user
  late String name; //name of server
  late String inviteCode; // invite code of server
  late String usersnames; // usernames of user in the server

  Server(this.id, this.name, this.inviteCode, this.usersnames);
  static Future<Server> add(
      String name, String inviteCode, String usernames) async {
    try {
      await Db.connect(dbName: 'servers.db');
      final key = await Db.store.add(Db.db, '$name $inviteCode $usernames');
      return Server(key, name, inviteCode, usernames);
    } catch (e) {
      print(e);
      exit(1);
    }
  }
}

class Servers {
  final List<Server> _userServers = [];
  final List<Server> _servers = [];
  Future<void> serverDb() async {
    try {
      await Db.connect(dbName: 'servers.db');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getServers(String username) async {
    try {
      await serverDb();
      for (int i = 1; true; i++) {
        final res = await Db.get(key: i);
        if (res == null) {
          break;
        } else {
          final id = i;
          final name = res.split(' ')[0];
          final inviteCode = res.split(' ')[1];
          final usernames = res.split(' ')[2].toString();
          if (usernames.contains(username)) {
            _userServers.add(Server(id, name, inviteCode, usernames));
          }
          _servers.add(Server(id, name, inviteCode, usernames));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> listServers(Users user) async {
    await getServers(user.username);
    print('Available Servers:');
    for (final server in _userServers) {
      print('${server.name} - Invite Code: ${server.inviteCode}');
    }
  }

  Future<Server> joinServer(String inviteCode, Users user) async {
    await getServers('');
    final server = _servers.firstWhere(
      (s) => s.inviteCode == inviteCode,
      orElse: () => Server(0, '', '', user.username),
    );
    if (server.name == '') {
      print('Server with invite code "$inviteCode" not found.');
      exit(1);
    } else {
      print('Joined the server: ${server.name}');
      server.usersnames = server.usersnames + ',' + user.username;
      await Db.store.record(server.id).put(
          Db.db, '${server.name} ${server.inviteCode} ${server.usersnames}');
      return server;
    }
  }
}
