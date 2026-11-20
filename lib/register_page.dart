import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final email = emailController.text.trim();
    final password = passwordController.text;
    final nickname = nicknameController.text.trim();

    try {
      final current = auth.currentUser;
      User user;
      if (current != null && current.isAnonymous) {
        // ゲストのアカウントにメール/パスワードを紐付ける（uid と追加した項目を引き継ぐ）
        final credential =
            EmailAuthProvider.credential(email: email, password: password);
        user = (await current.linkWithCredential(credential)).user!;
      } else {
        user = (await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ))
            .user!;
      }
      if (nickname.isNotEmpty) {
        await user.updateDisplayName(nickname);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('会員登録が完了しました')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'weak-password' => 'パスワードが弱すぎます（6文字以上にしてください）',
        'email-already-in-use' ||
        'credential-already-in-use' =>
          'このメールアドレスは既に登録されています',
        'invalid-email' => 'メールアドレスの形式が正しくありません',
        _ => '登録に失敗しました: ${e.message}',
      };
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規登録'),
        backgroundColor: Color(0xFF212121),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: nicknameController,
              decoration: InputDecoration(labelText: 'ニックネーム'),
            ),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'パスワード'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}
