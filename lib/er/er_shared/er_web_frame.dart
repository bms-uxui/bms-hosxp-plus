/// โฮสต์ฉาก HTML (three.js) บนเว็บด้วย iframe แทน WebView + HttpServer ในเครื่อง
///
/// ฉากสามมิติฝั่งมือถือเสิร์ฟ HTML และไฟล์โมเดลผ่าน HttpServer ที่ 127.0.0.1
/// แล้วเปิดใน WebView ซึ่งทั้งสองอย่างใช้บนเว็บไม่ได้
/// บนเว็บจึงใส่ HTML เดียวกันลง iframe (srcdoc ต้นทางเดียวกับแอป)
/// แล้วแปลงชื่อไฟล์ที่ฉากขอ (เช่น /er_room.glb) เป็น URL ของ asset ของแอปตาม [ErRoute]
/// ช่องทางส่งข้อความ (window.<channel>.postMessage) ทำงานเหมือนบน WebView
library;

export 'er_web_frame_stub.dart'
    if (dart.library.js_interop) 'er_web_frame_web.dart';
export 'er_web_route.dart';
