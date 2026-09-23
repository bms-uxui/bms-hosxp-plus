// สร้างอัตโนมัติจาก scratchpad/bp3d/render_regions.py — อย่าแก้ด้วยมือ
//
// กรอบของแต่ละ region บนภาพเงาร่างกาย เป็นสัดส่วน 0–1 ของภาพ
// ใช้หาว่าผู้ใช้แตะ region ไหน โดยไม่ต้องอ่านค่า alpha ของภาพตอนรัน
//
// ที่มาข้อมูล: BodyParts3D, © The Database Center for Life Science
// licensed under CC Attribution 4.0 International
import 'dart:ui';

/// ขนาดภาพต้นฉบับ (พิกเซล) ทุกชั้นซ้อนกันพอดี
const Size erBodyImageSize = Size(900, 1800);

const Map<String, Map<String, Rect>> erBodyRegionRects = {
  'front': <String, Rect>{
    'head': Rect.fromLTRB(0.4178, 0.0311, 0.5833, 0.1439),
    'neck': Rect.fromLTRB(0.46, 0.1283, 0.5411, 0.1817),
    'handRight': Rect.fromLTRB(0.7433, 0.4956, 0.8556, 0.5706),
    'handLeft': Rect.fromLTRB(0.1444, 0.4956, 0.2567, 0.5706),
    'footRight': Rect.fromLTRB(0.5489, 0.93, 0.6856, 0.9678),
    'footLeft': Rect.fromLTRB(0.3144, 0.93, 0.45, 0.9678),
    'armRight': Rect.fromLTRB(0.5, 0.1439, 0.8378, 0.5667),
    'armLeft': Rect.fromLTRB(0.1622, 0.1439, 0.5, 0.5661),
    'legRight': Rect.fromLTRB(0.5044, 0.4967, 0.6844, 0.9678),
    'legLeft': Rect.fromLTRB(0.3156, 0.4967, 0.4956, 0.9678),
    'chestFront': Rect.fromLTRB(0.3833, 0.1817, 0.6167, 0.3289),
    'abdomen': Rect.fromLTRB(0.4167, 0.3278, 0.5833, 0.5244),
    'pelvis': Rect.fromLTRB(0.3933, 0.4406, 0.6067, 0.5094),
  },
  'back': <String, Rect>{
    'head': Rect.fromLTRB(0.4178, 0.8567, 0.5833, 0.9694),
    'neck': Rect.fromLTRB(0.46, 0.82, 0.5411, 0.8722),
    'handRight': Rect.fromLTRB(0.7422, 0.43, 0.8556, 0.505),
    'handLeft': Rect.fromLTRB(0.1444, 0.43, 0.2567, 0.505),
    'footRight': Rect.fromLTRB(0.5489, 0.0328, 0.6856, 0.0706),
    'footLeft': Rect.fromLTRB(0.3144, 0.0328, 0.45, 0.0706),
    'armRight': Rect.fromLTRB(0.5, 0.4339, 0.8378, 0.8567),
    'armLeft': Rect.fromLTRB(0.1622, 0.4344, 0.5, 0.8567),
    'legRight': Rect.fromLTRB(0.5044, 0.0328, 0.6844, 0.5039),
    'legLeft': Rect.fromLTRB(0.3156, 0.0328, 0.4956, 0.5039),
    'chestBack': Rect.fromLTRB(0.4678, 0.6833, 0.5333, 0.82),
    'abdomen': Rect.fromLTRB(0.4167, 0.4761, 0.5833, 0.7117),
    'pelvis': Rect.fromLTRB(0.3933, 0.4911, 0.6067, 0.56),
  },
};
