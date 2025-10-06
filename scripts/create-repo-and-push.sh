#!/usr/bin/env bash
set -euo pipefail

REPO_NAME="${1:-kali-hardening}"
GITHUB_USER="${2:-USERNAME}"
PRIVATE="${3:-false}"   # true or false
DEFAULT_BRANCH="main"

# 사용자 알림
echo "Repo: $GITHUB_USER/$REPO_NAME (private=$PRIVATE)"
git init
git checkout -b "$DEFAULT_BRANCH"
git config user.email "$EMAIL" 2>/dev/null || true
git config user.name "$FULL_NAME" 2>/dev/null || true

# 민감파일 있는지 기본 체크
if grep -R --line-number -E "(PRIVATE_KEY|BEGIN RSA PRIVATE KEY|AWS_SECRET_ACCESS_KEY|API_TOKEN)" -n . || true; then
  echo "Note: 기본 민감정보 스캔을 실행했습니다 (grep). 수동 확인 필요."
fi

git add .
git commit -m "Initial commit: Kali hardening templates"
echo "Creating remote repo via gh..."
gh repo create "$GITHUB_USER/$REPO_NAME" --$([ "$PRIVATE" = "true" ] && echo "private" || echo "public") --source=. --remote=origin --push
