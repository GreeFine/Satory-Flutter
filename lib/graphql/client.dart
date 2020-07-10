import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:requests/requests.dart';

import './queries.dart';

final String _host = "192.168.1.30";
final String _backendUrl = "http://$_host:4000";
PersistCookieJar _persistCookieJar;

Future<String> getCookie() async {
  List<Cookie> results =
      _persistCookieJar.loadForRequest(Uri.parse(_backendUrl));
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
      final cookiesExtracted =
          Requests.extractResponseCookies(response.headers);
      cookiesExtracted.forEach((key, value) {
        cookies.add(Cookie(key, value));
      });
      _persistCookieJar.saveFromResponse(Uri.parse(_backendUrl), cookies);
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
      uri: _backendUrl,
      httpClient: ClientWithCookies(),
      headers: {"cookie": await getCookie()});

  final client = GraphQLClient(
    cache: InMemoryCache(),
    link: httpLink,
  );
  ValueNotifier<GraphQLClient> valueNotifierClient = ValueNotifier(client);

  return valueNotifierClient;
}

bool connected() {
  List<Cookie> results =
      _persistCookieJar.loadForRequest(Uri.parse(_backendUrl));
  return results.isNotEmpty &&
      results.firstWhere((element) => element.name == 'Authorization') != null;
}

void clearCookies() {
  _persistCookieJar.delete(Uri.parse(_backendUrl));
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
