import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keyer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Keyer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 티커
  late Timer timer;
  late Duration duration = const Duration();
  static const Duration threshold = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();

    timer = Timer(threshold, flushBuf);
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
  }

  List<String> keyBuf = [];
  List<List<String>> shortcuts = [];

  void flushBuf() {
    if (keyBuf.isEmpty) {
      return;
    }

    print(keyBuf);
    print(shortcuts);

    setState(() {
      shortcuts.add(keyBuf);
      keyBuf = [];
    });
  }

  Format format = Format.plain;

  var focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    String currentInputs = keyBuf.isEmpty ? "Click me and type" : keyBuf.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 포맷 선택
            FormatSelector(
              format: format,
              onValueChanged: (f) => setState(() => format = f!),
            ),

            // OS 선택(MacOS/Windows-Linux)

            // 입력
            Focus(
              autofocus: true,
              child: Text(currentInputs),
              onKeyEvent: (focusNode, event) {
                if (event is KeyDownEvent) {
                  log(event.toString());
                  setState(() => keyBuf.add(event.logicalKey.keyLabel));
                  timer.cancel();
                  timer = Timer(threshold, flushBuf);
                }

                return KeyEventResult.handled;
              },
            ),

            // 입력된 내용 표시
            ...shortcuts.map((e) => ShortcutComponent(e, format)).toList(),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

enum Format {
  plain,
  markdown,
  html;

  String _formatPlain(String k) {
    return k;
  }

  String _formatMarkdown(String k) {
    return "`$k`";
  }

  String _formatHtml(String k) {
    return "<kbd>$k</kbd>";
  }

  String format(String input) {
    switch (this) {
      case Format.plain:
        return _formatPlain(input);
      case Format.markdown:
        return _formatMarkdown(input);
      case Format.html:
        return _formatHtml(input);
    }
  }
}

class ShortcutComponent extends StatelessWidget {
  const ShortcutComponent(this.keys, this.format, {Key? key}) : super(key: key);

  final List<String> keys;
  final Format format;

  String onFormat() {
    return keys.map(format.format).join(" + ");
  }

  List<Widget> drawWithPlus(List<String> keys) {
    List<Widget> widgets = [KeyComponent(keys[0])];

    for (var i = 1; i < keys.length; i++) {
      widgets.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Text("+"),
      ));
      widgets.add(KeyComponent(keys[i]));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // print(onFormat());
    return Row(
      children: [
        Row(
          children: drawWithPlus(keys),
        ),
        TextButton(onPressed: () => Clipboard.setData(ClipboardData(text: onFormat())), child: const Text("copy"))
      ],
    );
  }
}

class KeyComponent extends StatelessWidget {
  const KeyComponent(this.keyStr, {Key? key}) : super(key: key);

  final String keyStr;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      padding: const EdgeInsets.all(3),
      child: Text(
        keyStr,
        style: const TextStyle(
          fontFamily: 'NotoSansMono',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class FormatSelector extends StatelessWidget {
  const FormatSelector({
    Key? key,
    required this.format,
    required this.onValueChanged,
  }) : super(key: key);

  final Format format;
  final ValueChanged<Format?> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RadioListTile<Format>(
          title: const Text("plain"),
          value: Format.plain,
          groupValue: format,
          onChanged: onValueChanged,
        ),
        RadioListTile<Format>(
          title: const Text("markdown"),
          value: Format.markdown,
          groupValue: format,
          onChanged: onValueChanged,
        ),
        RadioListTile<Format>(
          title: const Text("html"),
          value: Format.html,
          groupValue: format,
          onChanged: onValueChanged,
        ),
      ],
    );
  }
}
