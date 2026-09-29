import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'er_speech_input.dart';

/// Shared voice editor. Speech never maps fields or invokes AI extraction.
class ErSpeechDialog extends StatefulWidget {
  const ErSpeechDialog(
      {super.key,
      required this.title,
      required this.initial,
      required this.hint,
      required this.okText,
      this.multiline = false,
      this.autoStart = false,
      this.input});
  final String title, initial, hint, okText;
  final bool multiline, autoStart;
  final ErSpeechInput? input;
  @override
  State<ErSpeechDialog> createState() => _ErSpeechDialogState();
}

class _ErSpeechDialogState extends State<ErSpeechDialog> {
  late final TextEditingController _text;
  late final ErSpeechInput _speech;
  ErSpeechState _previous = ErSpeechState.idle;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.initial);
    final local = ['localhost', '127.0.0.1', '::1'].contains(Uri.base.host);
    _speech = widget.input ??
        ErSpeechInput(
            unavailableReason: kIsWeb && Uri.base.scheme != 'https' && !local
                ? 'ไมค์ใช้ไม่ได้บน HTTP ของเครือข่าย · เปิดผ่าน HTTPS ที่เชื่อถือได้ หรือ localhost บนคอมพิวเตอร์'
                : null);
    _speech.addListener(_changed);
    if (widget.autoStart)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _speech.toggle();
      });
  }

  void _changed() {
    if (!mounted) return;
    if (_speech.state == ErSpeechState.success &&
        _previous != ErSpeechState.success) {
      final before = _text.text.trimRight();
      final result =
          before.isEmpty ? _speech.transcript : '$before ${_speech.transcript}';
      _text.value = TextEditingValue(
          text: result,
          selection: TextSelection.collapsed(offset: result.length));
    }
    _previous = _speech.state;
    setState(() {});
  }

  @override
  void dispose() {
    _speech.removeListener(_changed);
    _speech.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listening = _speech.state == ErSpeechState.listening;
    final primary = Theme.of(context).colorScheme.primary;
    return AlertDialog(
      title: Row(children: [
        Expanded(child: Text(widget.title)),
        IconButton.filledTonal(
          tooltip: listening ? 'หยุดและถอดเสียง' : 'เริ่มพูด',
          onPressed: _speech.busy ? null : _speech.toggle,
          icon: _speech.busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(listening ? Icons.stop_rounded : Icons.mic_none_rounded),
          style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              backgroundColor: listening ? primary : null,
              foregroundColor: listening ? Colors.white : primary),
        ),
      ]),
      content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                  liveRegion: true,
                  child: Text(
                      '${_speech.message}${listening ? ' · ${_speech.seconds} วินาที' : ''}',
                      key: const ValueKey('speech-status'),
                      style: TextStyle(color: primary, fontSize: 12))),
              const SizedBox(height: 12),
              TextField(
                  controller: _text,
                  autofocus: !widget.autoStart,
                  minLines: widget.multiline ? 4 : 2,
                  maxLines: widget.multiline ? 10 : 4,
                  keyboardType: widget.multiline
                      ? TextInputType.multiline
                      : TextInputType.text,
                  decoration: InputDecoration(
                      hintText: widget.hint,
                      border: const OutlineInputBorder())),
            ],
          ))),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก')),
        FilledButton(
            onPressed: _speech.busy || listening
                ? null
                : () => Navigator.pop(context, _text.text),
            child: Text(widget.okText)),
      ],
    );
  }
}
