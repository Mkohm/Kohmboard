import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Config {
  ValueNotifier<GraphQLClient> setup() {
    final HttpLink httpLink = HttpLink(
        uri: 'https://api.entur.io/journey-planner/v2/graphql',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'ET-Client-Name': 'Kohm-kohmboard'
        });

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
      // OR
      // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
    );

    final Link link = authLink.concat(httpLink);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: link,
      ),
    );
    return client;
  }
}
