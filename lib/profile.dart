import 'package:Satory_app/graphql/queries.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
          child: Column(
        children: [
          Query(
            options: QueryOptions(
              documentNode:
                  gql(meQuery), // this is the query string you just created
            ),
            builder: (QueryResult result,
                {VoidCallback refetch, FetchMore fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }

              if (result.loading) {
                return Text('Loading');
              }

              // it can be either Map or List
              List meInfos = [
                result.data['id'],
                result.data['username'],
                result.data['picture'],
              ];

              return ListView.builder(
                  itemCount: meInfos.length,
                  itemBuilder: (context, index) {
                    return Text(meInfos[index]);
                  });
            },
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Disconnect'),
          ),
        ],
      )),
    );
  }
}
