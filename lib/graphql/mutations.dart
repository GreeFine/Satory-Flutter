String loginMutation = r'''
  mutation connect($username: String!, $password: String!) {
    login(username: $username, password: $password) {
      id
      username
      picture
    }
  }
''';
