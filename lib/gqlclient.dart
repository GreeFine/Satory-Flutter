import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:requests/requests.dart';

import './graphql/queries.dart';
import './graphql/mutations.dart';

final String _host = "192.168.1.30";
final String _backend_url = "http://$_host:4000";

Future<String> getCookie() async {
  Map<String, String> cookie = await Requests.getStoredCookies(_host);
  if (cookie.containsKey("Authorization"))
    return "Authorization=${cookie['Authorization']}";
  return '';
}

class ClientWithCookies extends IOClient {
  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    String cookie = await getCookie();
    String getCookieString(String _) => cookie;
    request.headers.update('cookie', getCookieString);
    return super.send(request).then((response) {
      Requests.setStoredCookies(
          _host, Requests.extractResponseCookies(response.headers));
      return response;
    });
  }
}

Future<ValueNotifier<GraphQLClient>> gqlclient() async {
  final HttpLink httpLink = HttpLink(
      uri: _backend_url,
      httpClient: ClientWithCookies(),
      headers: {"cookie": await getCookie()});

  final client = GraphQLClient(
    cache: InMemoryCache(),
    link: httpLink,
  );
  ValueNotifier<GraphQLClient> valueNotifierClient = ValueNotifier(client);

  return valueNotifierClient;
}

Future<bool> login(
    GraphQLClient client, String username, String password) async {
  print("Logins: $password  $username");
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
  print("res: " + result.data.toString());
  return true;
}

void me(GraphQLClient client) async {
  final QueryOptions options = QueryOptions(
    documentNode: gql(meQuery),
  );
  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print(result.exception.toString());
  }
  print("res: " + result.data.toString());
}
