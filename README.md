# HOSxP Plus V5 — ER Dashboard

UX/UI prototype for the Emergency Room (ER) executive dashboard of a Thai hospital, built on top of the HOSxP Plus V5 Flutter app.

**Live demo:** https://bms-uxui.github.io/bms-hosxp-plus/

## Scope

This repo is focused on **visual design + interaction prototyping**. Data is mocked locally; Supabase wiring is out of scope for this phase.

Covered dashboard sections (6 of 10 from the spec):

1. **KPI Overview** — 8 key metrics, responsive 1/2/4-column grid
2. **Triage Classification** — 5-level segmented bar + interactive legend
3. **Patient Flow** — 24h horizontally scrollable line chart with current-time indicator
4. **Length of Stay (LOS)** — 7-step journey as segmented bar with bottleneck highlight
5. **Chief Complaints** — Hero + top-3 + detailed list for top-10 complaints
6. **Disposition** — Donut chart with interactive legend

## Design direction

- **Glassy + 3D** aesthetic: translucent gradients, `BackdropFilter` blur, layered shadows, gloss strips
- **Thai-primary** UX writing, supportive English secondary labels
- Tab-based navigation with dedicated **แดชบอร์ด** tab alongside the patient list tabs

## Screenshots

### ตัวชี้วัดสำคัญ (KPI Overview)
![KPI Overview](docs/screenshots/01-kpi-overview.png)

### แยกตามระดับความเร่งด่วน · กระแสผู้ป่วยรายชั่วโมง (Triage + Patient Flow)
![Triage & Patient Flow](docs/screenshots/02-triage-flow.png)

### ระยะเวลาแต่ละขั้นตอน (Length of Stay)
![Length of Stay](docs/screenshots/03-los.png)

### อาการนำที่พบบ่อย (Chief Complaints)
![Chief Complaints](docs/screenshots/04-complaints.png)

### ผลลัพธ์ของผู้ป่วย (Disposition)
![Disposition](docs/screenshots/05-disposition.png)

## ER workflow redesign (tablet)

Redesign of the ER working screens for doctors, nurses and triage nurses on a tablet, with a 3D patient body and a Thai voice assistant ("น้องช่วย"). Domain rules and design decisions are kept in [docs/knowledge.md](docs/knowledge.md).

### ภาพรวมห้องฉุกเฉิน (ER flow home)
Isometric view of the ER journey (triage → treatment → post-treatment) with live counts, over-limit alerts and a patient strip sorted by urgency.
![ER flow home](docs/screenshots/06-er-flow-home.png)

### มุมมองเตียง (Bed view)
3D bed scene per patient with the stage card, vital-sign trend and quick actions.
![ER bed view](docs/screenshots/07-er-bed-view.png)

### รายละเอียดผู้ป่วย (Patient detail)
Vital-sign trends, problems, allergies, medications, latest labs with H/L flags, imaging and next step around a 3D body (BodyParts3D) that highlights injured bones and symptom areas.
![Patient detail](docs/screenshots/08-er-patient-detail.png)

### ประวัติการตรวจร่างกาย (Exam timeline)
ROS / PE log across exam rounds so the doctor can compare changes (new, changed, improved) and continue recording in the "ครั้งนี้" column.
![Exam timeline](docs/screenshots/09-er-exam-timeline.png)

### ผู้ช่วยบันทึกด้วยเสียง (Voice agent)
Push-to-talk assistant that walks each role through its HOSxP forms step by step, fills fields from speech, and asks for confirmation before saving.
![Voice agent](docs/screenshots/10-er-voice-agent.png)

## Stack

- Flutter 3.41.5 / Dart 3.11.3 (stable)
- `fl_chart` for bar / line / pie charts
- `flutter_staggered_grid_view` for the KPI grid
- Hosted as a static build on GitHub Pages; auto-deployed by a GitHub Actions workflow on every push to `main`

## Running locally

```bash
flutter pub get
flutter run -d chrome          # or: flutter run -d web-server --web-port=8787
```

## Deploying

Push to `main`. The `.github/workflows/deploy.yml` workflow builds `flutter build web --release` and publishes to GitHub Pages automatically (~3 min).
