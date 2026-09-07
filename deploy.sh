#!/usr/bin/env bash
# 폴머니 배포 — 작업본 index.html을 공개 저장소로 옮기고 GitHub Pages에 올린다.
#
#   ./deploy.sh                    커밋 메시지 자동 (날짜·시각)
#   ./deploy.sh "추석 표시 수정"    메시지 직접 지정
#
# 작업 폴더(월급)에는 개인 파일이 있어 공개할 수 없으므로,
# 공개 대상인 index.html만 옆 폴더(polmoney)로 옮겨 올린다.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$(cd "$SRC_DIR/.." && pwd)/polmoney"
SITE="https://fishoil55-gif.github.io/polmoney/"
FILE="index.html"

if [ ! -f "$SRC_DIR/$FILE" ]; then
  echo "✗ 원본이 없습니다: $SRC_DIR/$FILE" >&2
  exit 1
fi

if [ ! -d "$DEST_DIR/.git" ]; then
  echo "✗ 배포 저장소가 없습니다: $DEST_DIR" >&2
  echo "  git clone https://github.com/fishoil55-gif/polmoney.git \"$DEST_DIR\"" >&2
  exit 1
fi

# 작업 폴더에 커밋 안 한 변경이 있으면 알려만 준다 (배포는 계속 진행)
if ! git -C "$SRC_DIR" diff --quiet -- "$FILE" 2>/dev/null; then
  echo "! 작업 폴더의 $FILE 에 커밋하지 않은 변경이 있습니다. 그 상태 그대로 올립니다."
fi

cp "$SRC_DIR/$FILE" "$DEST_DIR/$FILE"

# 내용이 같으면 빈 커밋을 만들지 않는다
if git -C "$DEST_DIR" diff --quiet -- "$FILE"; then
  echo "· 바뀐 내용이 없습니다. 이미 올라간 것과 같습니다."
  echo "  $SITE"
  exit 0
fi

MSG="${1:-업데이트 $(date '+%Y-%m-%d %H:%M')}"

git -C "$DEST_DIR" add "$FILE"
git -C "$DEST_DIR" commit -q -m "$MSG"
git -C "$DEST_DIR" push -q origin main

echo "✓ 올렸습니다 — $MSG"
echo "  $SITE"
echo "  사이트 반영까지 1~2분 걸립니다."
