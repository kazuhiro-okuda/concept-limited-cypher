import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore を使用するためのパッケージ
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_roulette_item_page.dart';
import 'login_page.dart';

/// Firestore の roulette_items の1件
class RouletteItem {
  final String id;
  final String title;
  final String? createdBy; // 古い項目には作成者が無い

  RouletteItem({required this.id, required this.title, this.createdBy});

  factory RouletteItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return RouletteItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      createdBy: data['createdBy'] as String?,
    );
  }
}

class RoulettePage extends StatefulWidget {
  @override
  _RoulettePageState createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> with SingleTickerProviderStateMixin {
  static const Color _buttonColor = Color(0xFF212121);

  final CollectionReference<Map<String, dynamic>> _itemsRef =
      FirebaseFirestore.instance.collection('roulette_items');

  List<RouletteItem> allItems = []; // Firestore から取得したデータを格納するリスト
  String selectedItem = '';
  User? _currentUser = FirebaseAuth.instance.currentUser;
  StreamSubscription<User?>? _authSubscription;
  late AnimationController _animationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();  // ここで初期化
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animationController.addListener(() {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(min(_animationController.value * 500, max)); // 500はスクロールの範囲を調整
    });
    // ログイン状態が変わったら、編集・削除ボタンの表示を更新する
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) setState(() => _currentUser = user);
    });
    _getAllItemsFromFirestore(); // Firestore からデータを取得
  }

  Future<void> _getAllItemsFromFirestore() async {
    try {
      final snapshot = await _itemsRef.get();
      if (!mounted) return;
      setState(() {
        allItems = snapshot.docs.map(RouletteItem.fromDoc).toList();
      });
    } catch (error) {
      debugPrint('データの取得に失敗しました: $error');
      _showMessage('項目の読み込みに失敗しました');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isMine(RouletteItem item) =>
      _currentUser != null && item.createdBy == _currentUser!.uid;

  void _spinRoulette() {
    if (allItems.isEmpty) {
      _showMessage('ルーレットの項目がありません');
      return;
    }
    setState(() {
      final random = Random();
      int index = random.nextInt(allItems.length);
      selectedItem = allItems[index].title;
      _animationController.reset();
      _animationController.forward();
      // アニメーション終了後の処理を追加する場合はここに記述
    });
  }

  Future<void> _navigateAndAddItem() async {
    final String? newTitle = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => AddRouletteItemPage()),
    );
    if (newTitle == null) return;
    try {
      // 未ログインならゲスト（匿名）としてサインインしてから保存する
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
      final doc = await _itemsRef.add({
        'title': newTitle,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        allItems.add(RouletteItem(id: doc.id, title: newTitle, createdBy: user.uid));
      });
    } catch (error) {
      _showMessage('項目の追加に失敗しました: $error');
    }
  }

  Future<void> _editItem(RouletteItem item) async {
    final String? newTitle = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => AddRouletteItemPage(initialTitle: item.title),
      ),
    );
    if (newTitle == null || newTitle == item.title) return;
    try {
      await _itemsRef.doc(item.id).update({
        'title': newTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        final index = allItems.indexWhere((e) => e.id == item.id);
        if (index != -1) {
          allItems[index] =
              RouletteItem(id: item.id, title: newTitle, createdBy: item.createdBy);
        }
      });
    } catch (error) {
      _showMessage('項目の編集に失敗しました: $error');
    }
  }

  Future<void> _deleteItem(RouletteItem item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('項目を削除'),
        content: Text('『 ${item.title} 』を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _itemsRef.doc(item.id).delete();
      if (!mounted) return;
      setState(() {
        allItems.removeWhere((e) => e.id == item.id);
      });
    } catch (error) {
      _showMessage('項目の削除に失敗しました: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: _buttonColor,
      foregroundColor: Colors.white,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('【CLC】Concept-Limited Cypher （コンセプト縛りCypher）'),
        backgroundColor: _buttonColor,
      ),
      body: Column(
        children: <Widget>[

          SizedBox(height: 50), // ボタン間のスペースを追加
          Text('選ばれたコンセプト\n『 $selectedItem 』',
            textAlign: TextAlign.center, // テキストを中央揃えにする
            style: TextStyle(
              fontSize: 24.0, // フォントサイズを24ピクセルに設定
              height: 2.0, // 行の高さをフォントサイズの2倍に設定
            ),
          ),

          SizedBox(height: 50), // ボタン間のスペースを追加
          ElevatedButton(
            onPressed: _spinRoulette,
            child: Text('ルーレットを回す'),
            style: buttonStyle,
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];
                return ListTile(
                  title: Text(item.title),
                  // 自分が追加した項目にだけ編集・削除ボタンを出す
                  trailing: _isMine(item)
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              tooltip: '編集',
                              onPressed: () => _editItem(item),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              tooltip: '削除',
                              onPressed: () => _deleteItem(item),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: _navigateAndAddItem,
            child: Text('ルーレット項目を追加'),
            style: buttonStyle,
          ),
          SizedBox(height: 20.0), // ボタン間のスペース

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('ログインはこちらから'),
            style: buttonStyle,
          ),
          SizedBox(height: 20.0), // 下の余白

        ],
      ),
    );
  }
}
