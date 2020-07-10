import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import './home.dart';
import './gqlclient.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GraphQLProvider(client: await gqlclient(), child: SatoryApp()));
}

class SatoryApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satory App',
      theme: ThemeData(
        fontFamily: 'Raleway',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Home'),
    );
  }
}
