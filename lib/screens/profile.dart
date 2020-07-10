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
              print("DEBUG: ${result.data['me']['id']}");
              List meInfos = [
                result.data['me']['id'],
                result.data['me']['username'],
                result.data['me']['picture'],
              ];
              print("DEBUG!!: $meInfos");

              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: meInfos.length,
                  itemBuilder: (context, index) {
                    return Container(child: Text(meInfos[index]));
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
