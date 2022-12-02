import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AccessToken? _accessToken;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkIfisLoggedIn();
  }

  _checkIfisLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    log("firstAccessToken: $accessToken");
    setState(() {
      _checking = false;
    });

    if (accessToken != null) {
      log("IfTokenIsNotNull${accessToken.toJson()}");

      setState(() {});
    } else {
      _login();
    }
  }

  _login() async {
    final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile', 'user_friends'],
        loginBehavior: LoginBehavior.webOnly);

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      log("Se logueo con success accessToken: ${_accessToken!.toJson()}");
    } else {
      log("Result Status:${result.status}");
      log("Result Message${result.message}");
    }
    setState(() {
      _checking = false;
    });
  }

  _logout() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Facebook Auth Project'),
          actions: [
            TextButton(
              onPressed: _accessToken != null ? _logout : _login,
              child: Text(
                _accessToken != null ? 'logout' : 'login',
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        body: _checking
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Center(
                    child: Text(
                      "Your Friends",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future:
                          FacebookAuth.instance.getUserData(fields: "friends"),
                      builder: (context, snapshot) {
                        log("Snapshot.data: ${snapshot.data.toString()}");
                        if (snapshot.hasData) {
                          log("Entre al if snapshot.hasData");
                          return ListView.builder(
                            itemCount: snapshot.data!['friends']['data'].length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      snapshot.data!['data'][index]['picture']
                                          ['data']['url']),
                                ),
                                title:
                                    Text(snapshot.data!['data'][index]['name']),
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
