package com.mycompany.hosxpplusv5

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lockRefreshRate60()
    }

    // จอแท็บเล็ต 120 Hz ให้เวลาวาดแค่ 8.3 ms/เฟรม แต่หน้าที่มีฉาก 3D (WebView)
    // ใช้ ~13 ms เลยกระตุกตลอด ล็อก 60 Hz (16.6 ms/เฟรม) ได้ภาพนิ่งสม่ำเสมอกว่า
    private fun lockRefreshRate60() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val d = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display else windowManager.defaultDisplay
        d ?: return
        val cur = d.mode
        val mode = d.supportedModes
            .filter { it.physicalWidth == cur.physicalWidth && it.physicalHeight == cur.physicalHeight }
            .minByOrNull { Math.abs(it.refreshRate - 60f) } ?: return
        val lp = window.attributes
        lp.preferredDisplayModeId = mode.modeId
        window.attributes = lp
    }
}
