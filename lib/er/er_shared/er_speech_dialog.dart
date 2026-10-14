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

/// ช่องพิมพ์ + ไมค์ แบบฝังในหน้า (ไม่ใช่หน้าต่างลอย) · ใช้กับหน้าย่อยใน workflow
/// แตะไมค์เพื่อพูด / แตะอีกครั้งเพื่อหยุดและถอดเสียง (ต่อท้ายข้อความเดิม)
class ErSpeechEditor extends StatefulWidget {
  const ErSpeechEditor({
    super.key,
    required this.initial,
    required this.hint,
    required this.onChanged,
    this.textStyle,
    this.accent = const Color(0xFF001B7C),
    this.fill = const Color(0xFFF1F3F4),
    this.border = const Color(0xFFE3E6EA),
  });

  final String initial, hint;
  final ValueChanged<String> onChanged;
  final TextStyle? textStyle;
  final Color accent, fill, border;

  @override
  State<ErSpeechEditor> createState() => _ErSpeechEditorState();
}

class _ErSpeechEditorState extends State<ErSpeechEditor> {
  late final TextEditingController _text =
      TextEditingController(text: widget.initial);
  late final ErSpeechInput _speech = ErSpeechInput();
  ErSpeechState _previous = ErSpeechState.idle;

  @override
  void initState() {
    super.initState();
    _speech.addListener(_changed);
    _text.addListener(() => widget.onChanged(_text.text));
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.fill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: listening ? widget.accent : widget.border,
                  width: listening ? 1.5 : 1),
            ),
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  style: widget.textStyle,
                  decoration: InputDecoration(
                      hintText: widget.hint,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
              IconButton(
                tooltip: listening ? 'หยุดและถอดเสียง' : 'แตะเพื่อพูด',
                onPressed: _speech.busy ? null : _speech.toggle,
                style: IconButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    backgroundColor:
                        listening ? widget.accent : const Color(0xFFE8F0FE),
                    foregroundColor: listening ? Colors.white : widget.accent),
                icon: _speech.busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(listening ? Icons.stop_rounded : Icons.mic_rounded),
              ),
            ]),
          ),
          if (_speech.state != ErSpeechState.idle) ...[
            const SizedBox(height: 6),
            Text(
                '${_speech.message}${listening ? '  ${_speech.seconds} วินาที' : ''}',
                style: (widget.textStyle ?? const TextStyle())
                    .copyWith(fontSize: 12, color: widget.accent)),
          ],
        ]);
  }
}
