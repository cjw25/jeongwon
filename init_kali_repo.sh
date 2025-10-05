#!/usr/bin/env bash
set -euo pipefail

# 기본값 (원하면 실행 전에 수정)
REPO_NAME="${1:-kali-hardening}"
GITHUB_USER="${2:-USERNAME}"        # 깃허브 사용자명 / 조직
EMAIL="${3:-you@example.com}"
FULL_NAME="${4:-Your Name}"
DEFAULT_BRANCH="main"

echo "Creating project: $REPO_NAME (local)"
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# 디렉토리 구조
mkdir -p scripts docs .github/workflows .github
cat > scripts/kali_hardening.sh <<'EOF'
#!/bin/bash
# Kali 하드닝 스크립트 (요약)
# 주의: 실행 전 검토하세요.
set -euo pipefail
# (스크립트 내용은 길어서 생략 — 실사용 시 본문 전체를 넣으세요)
echo "이 스크립트를 실제로 운용하기 전에 내용을 검토하세요."
EOF
chmod +x scripts/kali_hardening.sh

# README
cat > README.md <<EOF
# Kali Hardening & 운영 스크립트

Kali (VMware) 환경에서 시스템 하드닝과 운영 자동화를 돕는 스크립트 모음입니다.

## Quickstart
1. 검토 후 테스트 VM에서 실행: \`sudo bash scripts/kali_hardening.sh\`
2. 공개키를 \`/home/<user>/.ssh/authorized_keys\`에 추가하세요.
3. 민감 정보(키/비밀번호/API 토큰)는 절대 커밋 금지.

## License
MIT
EOF

# .gitignore
cat > .gitignore <<EOF
# Logs and backups
*.log
*.gz
*.bak
/private_keys/
*.pem
# Editor
.vscode/
.idea/
*.swp
# System
.vagrant/
EOF

# LICENSE (MIT)
cat > LICENSE <<EOF
MIT License

Copyright (c) $(date +%Y) $FULL_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy...
(표준 MIT 텍스트를 채워 넣으세요)
EOF

# SECURITY.md
cat > SECURITY.md <<EOF
# 보안 공지 및 보고 절차

취약점 보고: security@example.com

- 민감 정보 오커밋은 즉시 repo 소유자에게 보고하세요.
- 긴급 취약점은 "Critical"로 표시해주세요.
EOF

# CONTRIBUTING.md
cat > CONTRIBUTING.md <<EOF
기여 환영합니다.

- PR은 \`main\`이 아닌 브랜치에서 생성하세요.
- 모든 PR에는 최소 1명 리뷰가 필요합니다.
EOF

# 예시 GitHub Actions CI (ShellCheck)
cat > .github/workflows/ci.yml <<EOF
name: CI - shellcheck

on:
  push:
    branches: [ $DEFAULT_BRANCH ]
  pull_request:
    branches: [ $DEFAULT_BRANCH ]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: ShellCheck
        uses: ludeeus/action-shellcheck@v1
        with:
          shellcheck_version: '0.9.0'
          path: 'scripts/*.sh'
EOF

# dependabot
cat > .github/dependabot.yml <<EOF
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
EOF

# pre-commit example: shellcheck + detect-secrets 검사용 (선택)
cat > .pre-commit-config.yaml <<EOF
repos:
  - repo: https://github.com/koalaman/shellcheck
    rev: v0.9.0
    hooks:
      - id: shellcheck
        stages: [commit]
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.6.0
    hooks:
      - id: detect-secrets
        stages: [commit]
EOF

# helper: create-repo-and-push.sh (gh CLI 사용)
cat > create-repo-and-push.sh <<'EOF'
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
EOF
chmod +x create-repo-and-push.sh

# README 추가 안내
cat > docs/hardening-readme.md <<EOF
상세 사용 설명서는 README.md 및 스크립트 헤더를 참조하세요.
EOF

echo "Project scaffolding created in $(pwd)."
echo "다음 단계 예시:"
echo "  1) 파일 검토: less README.md"
echo "  2) 민감정보 확인 후: ./create-repo-and-push.sh $REPO_NAME $GITHUB_USER false"
