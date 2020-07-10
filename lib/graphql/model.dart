import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import './client.dart' as gqlclient;
import './mutations.dart';

class User with ChangeNotifier {
  bool _connected = gqlclient.connected();
  bool get connected => _connected;

  void connection(bool state) {
    _connected = state;
    notifyListeners();
  }

  Future<bool> login(
      GraphQLClient client, String username, String password) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(loginMutation),
      variables: <String, dynamic>{
        'username': username,
        'password': password,
      },
    );
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print("login error: ${result.exception.toString()}");
      return false;
    }
    connection(true);
    print("res: " + result.data.toString());
    return true;
  }

  Future<bool> disconnect(GraphQLClient client) async {
    final MutationOptions options = MutationOptions(
      documentNode: gql(disconnectMutation),
    );
    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print("disconnect error: ${result.exception.toString()}");
      return false;
    }
    gqlclient.clearCookies();
    connection(false);
    print("res: " + result.data.toString());
    return true;
  }
}
