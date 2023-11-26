import 'package:flutter/material.dart';

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
