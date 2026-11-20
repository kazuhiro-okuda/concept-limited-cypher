import 'package:Concept_Limited_Cypher/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'roulette_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 未ログインならゲスト（匿名ユーザー）としてサインインしておく
  if (FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      // 失敗しても閲覧はできるので起動は続ける（追加時に再試行する）
      debugPrint('匿名サインインに失敗しました: $e');
    }
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'コンセプト縛りCypher',
      home: RoulettePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('トップページ'),
      ),
      body: Center(

      ),
    );
  }
}
