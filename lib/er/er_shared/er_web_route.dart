/// เส้นทางไฟล์ของฉาก: (regex ของ path ที่ฉากขอ, asset ของแอป ใช้ $1 แทนกลุ่มที่จับได้, ชนิดไฟล์)
/// ใช้ร่วมกันทั้ง HttpServer บนมือถือและ iframe บนเว็บ
typedef ErRoute = (String pattern, String asset, String mime);

/// path ที่ฉากขอ → (asset, ชนิดไฟล์) ไม่ตรงเส้นทางไหน = null
(String, String)? erRoute(List<ErRoute> routes, String path) {
  for (final (p, asset, mime) in routes) {
    final m = RegExp(p).firstMatch(path);
    if (m != null) {
      return (
        asset.replaceAllMapped(
            RegExp(r'\$(\d)'), (g) => m.group(int.parse(g.group(1)!)) ?? ''),
        mime
      );
    }
  }
  return null;
}
