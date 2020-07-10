import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import './login.dart';
import '../graphql/model.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satory Paint'),
      ),
      body: SafeArea(
        child: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/satory_logo.png',
                        width: 200,
                      ),
                      (() {
                        if (context.watch<User>().connected) {
                          return Column(children: [
                            Text('Connected'),
                            GraphQLConsumer(builder: (GraphQLClient client) {
                              return RaisedButton(
                                onPressed: () async {
                                  context.read<User>().disconnect(client);
                                },
                                child: Text('Disconnect'),
                              );
                            })
                          ]);
                        } else {
                          return Column(children: [
                            Text(
                              'You are not connected',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            RaisedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              },
                              child: Text('Login'),
                            ),
                          ]);
                        }
                      }()),
                    ]))),
      ),
    );
  }
}
