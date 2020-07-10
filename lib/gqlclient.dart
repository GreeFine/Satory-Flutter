import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:requests/requests.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import './graphql/queries.dart';
import './graphql/mutations.dart';

final String _host = "192.168.1.30";
final String _backend_url = "http://$_host:4000";
PersistCookieJar _persistCookieJar;

Future<String> getCookie() async {
  List<Cookie> results =
      _persistCookieJar.loadForRequest(Uri.parse(_backend_url));
  Cookie auth = results.firstWhere((element) => element.name == 'Authorization',
      orElse: () => null);
  if (auth != null) return "Authorization=${auth.value}";
  return '';
}

class ClientWithCookies extends IOClient {
  @override
  Future<IOStreamedResponse> send(BaseRequest request) async {
    String cookie = await getCookie();
    String getCookieString(String _) => cookie;
    request.headers.update('cookie', getCookieString);
    return super.send(request).then((response) {
      List<Cookie> cookies = List();
      final cookies_extracted =
          Requests.extractResponseCookies(response.headers);
      cookies_extracted.forEach((key, value) {
        cookies.add(Cookie(key, value));
      });
      _persistCookieJar.saveFromResponse(Uri.parse(_backend_url), cookies);
      return response;
    });
  }
}

Future<ValueNotifier<GraphQLClient>> gqlclient() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();

  _persistCookieJar = new PersistCookieJar(
    dir: appDocDir.path,
    ignoreExpires: true, //save/load even cookies that have expired.
  );

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

Future<bool> disconnect(GraphQLClient client) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(disconnectMutation),
  );
  final QueryResult result = await client.mutate(options);

  if (result.hasException) {
    print("disconnect error: ${result.exception.toString()}");
    return false;
  }
  _persistCookieJar.delete(Uri.parse(_backend_url));
  print("res: " + result.data.toString());
  return true;
}

bool connected() {
  List<Cookie> results =
      _persistCookieJar.loadForRequest(Uri.parse(_backend_url));
  return results.isNotEmpty &&
      results.firstWhere((element) => element.name == 'Authorization') != null;
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
