import 'package:discord/discord.dart';
import 'package:discord/models/categories.dart';
import 'package:discord/models/channels.dart';
import 'package:discord/models/message.dart';
import 'package:discord/models/user.dart';
import 'package:discord/models/servers.dart';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  print("Enter username");
  var username = stdin.readLineSync().toString();
  print("Enter password");
  var password = stdin.readLineSync().toString();

  var user = await Users.Login(username: username, password: password);
  final servers = Servers();
  final categories = Categories();
  final channels = Channels();
  final messages = Messages();
  final dm = DmMessages();
  var server;
  var category;
  var channel;
  while (true) {
    print("Enter command you would like to do");
    final command = stdin.readLineSync().toString();
    switch (command) {
      case 'register':
        await Users.Register();
        break;
      case 'logout':
        await Users.Logout(user.username);
        break;
      case 'create':
        print('Enter Server Name');
        final name = stdin.readLineSync().toString();
        print('Enter Invite code');
        final inviteCode = stdin.readLineSync().toString();
        server = await Server.add(name, inviteCode, user.username);
      case 'join':
        print('Enter Invite Code');
        final inviteCode = stdin.readLineSync().toString();
        server = await servers.joinServer(inviteCode, user);
      case 'list':
        await servers.listServers(user);
      case 'create category':
        if (server == null) {
          print("Enter server");
          exit(1);
        } else {
          print("Enter category name");
          final name = stdin.readLineSync().toString();
          await Category.addCategory(name, server.name);
        }
        break;
      case 'list categories':
        if (server == null) {
          print("Enter server");
          exit(1);
        } else {
          await categories.listCategories(server.name);
        }
        break;
      case 'checkout category':
        if (server == null) {
          print("Enter server");
          exit(1);
        } else {
          category = await categories.checkoutCategory(server.name);
        }
      case 'create channel':
        if (category == null) {
          print("Enter category and server");
          exit(1);
        } else {
          print("Enter channel name");
          final channelname = stdin.readLineSync().toString();
          print("Enter channel type");
          final channeltype = stdin.readLineSync().toString();
          if (!(channeltype == 'text' || channeltype == 'announcement')) {
            print("Invalid channel type");
            exit(1);
          }
          await Channel.addChannel(channelname, category.name, channeltype);
        }
      case 'list channels':
        if (category == null) {
          print("Enter category");
          exit(1);
        } else {
          await channels.listChannels(category.name);
        }
      case 'fetch dm':
        await dm.listMessages(user);
      case 'send dm':
        print("to:");
        final to = stdin.readLineSync().toString();
        print("Enter message");
        final message = stdin.readLineSync().toString();
        await DmMessage.addMessage(user.username, message, to);
      case 'join channels':
        if (category == null) {
          print("Enter category");
          exit(1);
        } else {
          channel = await channels.joinChannel(category.name);
          bool channeljoined = true;
          while (channeljoined) {
            print("Channel command");
            final channelCommand = stdin.readLineSync().toString();
            switch (channelCommand) {
              case 'send message':
                if (channel == null) {
                  print("Enter channel");
                  exit(1);
                } else {
                  print("Enter message");
                  final message = stdin.readLineSync().toString();
                  await Message.addMessage(
                      user.username, message, channel.name);
                }
              case 'fetch message':
                if (channel == null) {
                  print("Enter channel");
                  exit(1);
                } else {
                  await messages.listMessages(channel.name);
                }
            }
          }
        }
      default:
        print("Not valid command");
        break;
    }
  }
}
