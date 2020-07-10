import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'profile.dart';
import '../graphql/model.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Satory Paint'),
      ),
      body: SafeArea(
          child: Form(
        key: _formKey,
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
                    Text(
                      'Login',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Pseudo",
                      ),
                      onChanged: (value) => {
                        setState(() {
                          _username = value;
                        })
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Mot de passe",
                      ),
                      onChanged: (value) => {
                        setState(() {
                          _password = value;
                        })
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    GraphQLConsumer(
                      builder: (GraphQLClient client) {
                        return Container(
                          child: RaisedButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                final success = await context
                                    .read<User>()
                                    .login(client, _username, _password);
                                (client);
                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage()),
                                  );
                                }
                              }
                            },
                            child: Text('Submit'),
                          ),
                        );
                      },
                    )
                  ],
                ))),
      )),
    );
  }
}
