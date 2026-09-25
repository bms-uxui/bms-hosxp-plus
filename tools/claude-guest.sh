#!/bin/sh
# รัน Claude Code ด้วย account ของผู้ร่วมงานใน Live Share (แยก login ต่อคน)
# ใช้ใน terminal ที่ host แชร์ให้: sh tools/claude-guest.sh <ชื่อ>
# ครั้งแรกให้พิมพ์ /login แล้วเปิดลิงก์ในเบราว์เซอร์ของตัวเอง
# เลิกงาน: /logout หรือให้ host ลบ ~/.claude-guests/<ชื่อ>
set -e
name="${1:?usage: sh tools/claude-guest.sh <name>}"
dir="$HOME/.claude-guests/$name"
mkdir -p "$dir"
cd "$(dirname "$0")/.."
echo "Claude ของ $name · config: $dir"
CLAUDE_CONFIG_DIR="$dir" exec claude
