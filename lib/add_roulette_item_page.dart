import 'package:flutter/material.dart';

/// 項目の追加・編集ページ。
/// [initialTitle] を渡すと編集モードになり、保存すると入力値を返して戻る。
class AddRouletteItemPage extends StatefulWidget {
  final String? initialTitle;

  const AddRouletteItemPage({super.key, this.initialTitle});

  @override
  State<AddRouletteItemPage> createState() => _AddRouletteItemPageState();
}

class _AddRouletteItemPageState extends State<AddRouletteItemPage> {
  // Firestore のルールと合わせた上限文字数
  static const int maxLength = 50;

  late final TextEditingController _controller =
      TextEditingController(text: widget.initialTitle ?? '');

  bool get _isEdit => widget.initialTitle != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String title = _controller.text.trim();
    if (title.isNotEmpty) {
      Navigator.pop(context, title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '項目を編集' : '項目を追加'),
        backgroundColor: Color(0xFF212121),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: maxLength,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: _isEdit ? '項目' : '新しい項目',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isEdit ? '保存' : '追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF212121),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
