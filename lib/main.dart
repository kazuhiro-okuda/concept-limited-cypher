import 'package:flutter/material.dart';
import 'dart:math';

void main() {
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

class RoulettePage extends StatefulWidget {
  @override
  _RoulettePageState createState() => _RoulettePageState();
}

// ルーレット項目の追加画面
class AddRouletteItemPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('項目を追加'),
          backgroundColor: Color(0xFF212121)
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '新しい項目',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String newItem = _controller.text;
                if (newItem.isNotEmpty) {
                  Navigator.pop(context, newItem);
                }
              },
              child: Text('追加'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoulettePageState extends State<RoulettePage> {
  List<String> items = ["膝を使う","スレッドを入れる","チェアーで終わる","ヘッドを使う","ジョーダンで終わる","2段階以上のフリーズ","トップロックだけ","フットワークだけ"];
  String selectedItem = '';

  void _addItem(String item) {
    setState(() {
      items.add(item);
    });
  }

  void _editItem(int index, String newItem) {
    setState(() {
      items[index] = newItem;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _spinRoulette() {
    setState(() {
      final random = Random();
      int index = random.nextInt(items.length);
      selectedItem = items[index];
    });
  }

  void _navigateAndAddItem() async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRouletteItemPage()),
    );
    if (newItem != null) {
      setState(() {
        items.add(newItem);
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
          // Add buttons for adding items

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
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  // Add buttons for edit and delete
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
        ],
      ),
    );
  }
}
