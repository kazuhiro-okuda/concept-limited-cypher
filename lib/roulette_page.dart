import 'package:flutter/material.dart';
import 'dart:math';
import 'add_roulette_item_page.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore を使用するためのパッケージ

class RoulettePage extends StatefulWidget {
  @override
  _RoulettePageState createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> with SingleTickerProviderStateMixin {
  List<String> itemHistory = [];
  List<String> allItems = []; // Firestore から取得したデータを格納するリスト
  // List<String> allItems = ["膝を使う","スレッドを入れる","チェアーで終わる","ヘッドを使う","ジョーダンで終わる","2段階以上のフリーズ","トップロックだけ","フットワークだけ"];
  String selectedItem = '';
  late AnimationController _animationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();  // ここで初期化
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animationController.addListener(() {
      _scrollController.jumpTo(_animationController.value * 500); // 500はスクロールの範囲を調整
    });
    _getAllItemsFromFirestore(); // Firestore からデータを取得
  }

  void _getAllItemsFromFirestore() {
    FirebaseFirestore.instance.collection('roulette_items').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          allItems.add(doc['title']); // Firestore のフィールド名に合わせて修正
        });
      });
    }).catchError((error) {
      print('データの取得に失敗しました: $error');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _spinRoulette() {
    setState(() {
      final random = Random();
      int index = random.nextInt(allItems.length);
      selectedItem = allItems[index];
      _animationController.reset();
      _animationController.forward();
      // アニメーション終了後の処理を追加する場合はここに記述
    });
  }

  void _navigateAndAddItem() async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRouletteItemPage()),
    );
    if (newItem != null) {
      setState(() {
        allItems.add(newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('【CLC】Concept-Limited Cypher （コンセプト縛りCypher）'),
        backgroundColor: Color(0xFF212121),
      ),
      body: Column(
        children: <Widget>[

          SizedBox(height: 50), // ボタン間のスペースを追加
          Text('選ばれたコンセプト\n『 $selectedItem 』',
            textAlign: TextAlign.center, // テキストを中央揃えにする
            style: TextStyle(
              fontSize: 24.0, // フォントサイズを24ピクセルに設定
              height: 2.0, // 行の高さをフォントサイズの1.5倍に設定
            ),
          ),
          // Add buttons for adding allItems

          SizedBox(height: 50), // ボタン間のスペースを追加
          ElevatedButton(
            onPressed: _spinRoulette,
            child: Text('ルーレットを回す'),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF212121),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // title: Text(allItems[index])
                  title: Center( // This centers the ListTile's content
                    child: Align( // This aligns the text to the left within the centered content
                      alignment: Alignment.centerLeft,
                      child: Text(allItems[index]),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 0), // ボタン間のスペースを追加
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRouletteItemPage()),
              );
            },
            child: Text('ルーレット項目を追加'),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 20.0), // ここで下に16ピクセルのスペースを作ります

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('ログインはこちらから'),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 20.0), // ここで下に16ピクセルのスペースを作ります

        ],
      ),
    );
  }
}


