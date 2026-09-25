// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesAssistantChatState on State<ErFlowHomeWidget> {
  /// ประวัติการคุยทั้งหมด (ผู้ใช้ / ผู้ช่วย) ใช้ทั้งโชว์และส่งให้ LLM จำบริบท
  final List<_ChatTurn> _chatLog = [];
  final ScrollController _chatScroll = ScrollController();
}

extension _FeaturesAssistantChatPart on _ErFlowHomeWidgetState {
  void _logTurn(bool user, String text) {
    if (text.trim().isEmpty) return;
    _chatLog.add(_ChatTurn(user, text.trim(), _speechStep, DateTime.now()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.jumpTo(_chatScroll.position.maxScrollExtent);
      }
    });
  }

  /// บทสนทนาล่าสุดในรูปแบบข้อความของ LLM (จำกัดจำนวนกันบริบทยาว)
  List<Map<String, String>> _historyMessages({int max = 12}) => [
        for (final t
            in _chatLog.skip(_chatLog.length > max ? _chatLog.length - max : 0))
          {'role': t.user ? 'user' : 'assistant', 'content': t.text},
      ];

  /// แผงประวัติการคุย: ฟองข้อความสลับผู้ใช้/ผู้ช่วย พร้อมเวลาและขั้นที่คุย
  Widget _chatPanel() => Container(
        decoration: BoxDecoration(
          color: _panel,
          border: Border(right: BorderSide(color: _line)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16.0,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 6.0, 4.0),
              child: Row(
                children: [
                  const Icon(Icons.forum_outlined, size: 14.0, color: _blue),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                        'ประวัติการคุยกับผู้ช่วย · ${_chatLog.length} ข้อความ',
                        style: _t(10.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  InkWell(
                    onTap: () => setState(() => _chatOpen = false),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child:
                          Icon(Icons.close_rounded, size: 16.0, color: _ink3),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0, color: _line),
            Expanded(
              child: _chatLog.isEmpty
                  ? Center(
                      child: Text('ยังไม่มีบทสนทนา',
                          style: _t(10.5, color: _ink3)))
                  : ListView.builder(
                      controller: _chatScroll,
                      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                      itemCount: _chatLog.length,
                      itemBuilder: (context, i) {
                        final t = _chatLog[i];
                        final hh = t.at.hour.toString().padLeft(2, '0');
                        final mm = t.at.minute.toString().padLeft(2, '0');
                        final stepName = _steps[t.step].$2;
                        return Align(
                          alignment: t.user
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420.0),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6.0),
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 6.0, 10.0, 6.0),
                              decoration: BoxDecoration(
                                color: t.user
                                    ? _blue
                                    : _blue.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12.0),
                                  topRight: const Radius.circular(12.0),
                                  bottomLeft:
                                      Radius.circular(t.user ? 12.0 : 3.0),
                                  bottomRight:
                                      Radius.circular(t.user ? 3.0 : 12.0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.text,
                                      style: _t(10.5,
                                          color: t.user ? Colors.white : _ink,
                                          height: 1.35)),
                                  const SizedBox(height: 2.0),
                                  Text(
                                      '${t.user ? (ErSession.instance.user?.name ?? 'ผู้ใช้') : 'น้องช่วย'} · $hh:$mm · $stepName',
                                      style: _t(8.0,
                                          color:
                                              t.user ? Colors.white70 : _ink3)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
}
