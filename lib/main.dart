import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  late final Ticker ticker;
  late Duration duration = const Duration();
  static const int threshold = 2000;

  @override
  void initState() {
    super.initState();

    ticker = Ticker(((elapsed) {
      if (elapsed.inMilliseconds - duration.inMilliseconds >= threshold) {
        print("tick");
        duration = elapsed;
        flushBuf();
      }
    }));

    ticker.start();
  }

  @override
  void dispose() {
    super.dispose();

    ticker.dispose();
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
              child: const Text("Click me and type"),
              onKeyEvent: (focusNode, event) {
                if (event is KeyDownEvent) {
                  print(event);
                  keyBuf.add(event.logicalKey.keyLabel);
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
      widgets.add(const Text("+"));
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
        TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: onFormat())),
            child: const Text("copy"))
      ],
    );
  }
}

class KeyComponent extends StatelessWidget {
  const KeyComponent(this.keyStr, {Key? key}) : super(key: key);

  final String keyStr;

  @override
  Widget build(BuildContext context) {
    return Text(keyStr);
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
