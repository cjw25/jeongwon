#!/bin/bash
mkdir -p ~/kali-hardening/scripts
cat > ~/kali-hardening/scripts/kali_hardening.sh <<'EOF'
#!/bin/bash
set -euo pipefail

# -------------------------
# Kali 하드닝 스크립트
# 기본값
NEW_USER="kali"
SSH_PORT=2222
TIMEZONE="UTC"
EMAIL_FOR_UPDATES="cnjzzan@naver.com"   # unattended-upgrades에서 보고 받을 이메일
# -------------------------

echo "=== Kali 하드닝 시작 ==="
echo "주의: 실행 전 스크립트를 반드시 검토하세요. (테스트 VM 권장)"

# 0. 시간대 설정
if command -v timedatectl >/dev/null 2>&1; then
  echo "[*] 시간대 설정: $TIMEZONE"
  timedatectl set-timezone "$TIMEZONE" || true
fi

# 1. 시스템 업데이트 및 필수 패키지 설치
echo "[*] 패키지 업데이트 및 필수 패키지 설치"
apt update -y
DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
apt install -y sudo ufw fail2ban unattended-upgrades apt-listchanges apt-transport-https \
               debsums auditd audispd-plugins apparmor-utils rkhunter chkrootkit \
               logrotate cron libpam-pwquality

# 2. (선택) 불필요한 패키지 제거 - 주석처리되어 있음. 필요 시 주석 해제 후 사용.
# echo "[*] 불필요한 공격 툴 제거 예시 (주의: 환경에 따라 서비스 장애 가능)"
# apt purge -y metasploit-framework john hydra nmap netcat* wireshark* aircrack-ng || true
# apt autoremove -y || true

# 3. 새 비루트(non-root) 사용자 생성 및 sudo 권한 부여
echo "[*] 사용자 생성 및 sudo 설정: $NEW_USER"
if ! id -u "$NEW_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$NEW_USER"
  passwd -l "$NEW_USER"    # 암호 잠금(키 기반 권장)
  usermod -aG sudo "$NEW_USER"
  mkdir -p /home/"$NEW_USER"/.ssh
  chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/.ssh
  chmod 700 /home/"$NEW_USER"/.ssh
  echo "[*] 사용자 $NEW_USER 생성 완료 (비밀번호 잠김). 공개키를 /home/$NEW_USER/.ssh/authorized_keys 에 등록하세요."
else
  echo "[*] 사용자 $NEW_USER 이미 존재"
fi

# 4. SSH 설정 강화
SSHD_CONFIG="/etc/ssh/sshd_config"
echo "[*] SSH 설정 강화 (백업: ${SSHD_CONFIG}.bak)"
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.$(date +%F_%T)" || true

# 함수: 설정 변경(존재하면 교체, 없으면 추가)
set_or_replace() {
  local key="$1"
  local val="$2"
  if grep -qE "^\s*#?\s*${key}\b" "$SSHD_CONFIG"; then
    sed -ri "s|^\s*#?\s*${key}\b.*|${key} ${val}|" "$SSHD_CONFIG"
  else
    echo "${key} ${val}" >> "$SSHD_CONFIG"
  fi
}

set_or_replace "Port" "$SSH_PORT"
set_or_replace "PermitRootLogin" "no"
set_or_replace "PasswordAuthentication" "no"
set_or_replace "PubkeyAuthentication" "yes"
set_or_replace "PermitEmptyPasswords" "no"

# AllowUsers 로 로그인 사용자 제한 (필요시 수정)
if ! grep -q "^AllowUsers" "$SSHD_CONFIG"; then
  echo "AllowUsers $NEW_USER" >> "$SSHD_CONFIG"
fi

echo "[*] SSH 설정 업데이트 완료 (포트: $SSH_PORT). SSH 재시작은 스크립트 마지막에 수행됩니다."

# 5. UFW(방화벽) 설정
echo "[*] UFW 설정"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow "$SSH_PORT"/tcp
ufw allow 443/tcp
# 예: 내부 네트워크만 허용하려면 추가 규칙을 넣으세요:
# ufw allow from 192.168.1.0/24 to any port $SSH_PORT proto tcp
ufw --force enable

# 6. Fail2Ban 설치/설정 (SSH 보호)
echo "[*] Fail2Ban 설정"
cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
backend = auto

[sshd]
enabled = true
port = AUTO
logpath = %(sshd_log)s
EOF

systemctl enable --now fail2ban

# 7. 자동 업그레이드 설정 (unattended-upgrades)
echo "[*] Unattended Upgrades 설정"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

cat > /etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Mail "$EMAIL_FOR_UPDATES";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Allowed-Origins {
        "\${distro_id}:\${distro_codename}-security";
};
EOF

dpkg-reconfigure -plow unattended-upgrades || true

# 8. PAM: 암호 정책 (pwquality)
echo "[*] PAM 비밀번호 정책 설정 (pwquality)"
if [ -f /etc/security/pwquality.conf ]; then
  sed -i 's/^#\?\s*minlen\s*=.*/minlen = 12/' /etc/security/pwquality.conf || true
  sed -i 's/^#\?\s*dcredit\s*=.*/dcredit = -1/' /etc/security/pwquality.conf || true
  sed -i 's/^#\?\s*ucredit\s*=.*/ucredit = -1/' /etc/security/pwquality.conf || true
  sed -i 's/^#\?\s*ocredit\s*=.*/ocredit = -1/' /etc/security/pwquality.conf || true
  sed -i 's/^#\?\s*lcredit\s*=.*/lcredit = -1/' /etc/security/pwquality.conf || true
fi

# 비밀번호 만료 규칙 (새 사용자에 대해 설정)
chage --maxdays 90 --mindays 7 "$NEW_USER" || true

# 9. sysctl 커널/네트워크 하드닝
echo "[*] sysctl 네트워크 하드닝 적용"
cat > /etc/sysctl.d/99-kali-hardening.conf <<'EOF'
# 네트워크 보안
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.send_redirects = 0
# IPv6 비활성화 (필요 시 주석 처리)
net.ipv6.conf.all.disable_ipv6 = 1
EOF

sysctl --system || true

# 10. auditd 설정 (기본 룰 추가)
echo "[*] auditd 설정"
systemctl enable --now auditd || true

audit_rules_file="/etc/audit/rules.d/hardening.rules"
cat > "$audit_rules_file" <<'EOF'
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /var/log/auth.log -p wa -k auth_logs
EOF

augenrules --load || true

# 11. rkhunter, chkrootkit 초기검사 및 스케줄
echo "[*] rkhunter, chkrootkit 초기 업데이트 및 검사"
rkhunter --update || true
rkhunter --propupd || true
rkhunter --check --sk --nocolors || true

cat > /etc/cron.daily/rkhunter-scan <<'EOF'
#!/bin/bash
/usr/bin/rkhunter --update
/usr/bin/rkhunter --check --sk --nocolors
EOF
chmod +x /etc/cron.daily/rkhunter-scan || true

# 12. AppArmor (가능하면 활성화 및 프로파일 강제)
if command -v aa-status >/dev/null 2>&1; then
  echo "[*] AppArmor 활성화 시도"
  systemctl enable --now apparmor || true
  # 프로파일 enforce 시도 (일부 프로파일은 시스템에 따라 문제를 일으킬 수 있음)
  for prof in /etc/apparmor.d/*; do
    [ -f "$prof" ] && aa-enforce "$prof" >/dev/null 2>&1 || true
  done
fi

# 13. 로그 로테이션 (간단 예)
echo "[*] 로그 로테이션 설정"
cat > /etc/logrotate.d/custom <<'EOF'
/var/log/*.log {
    rotate 7
    daily
    missingok
    notifempty
    compress
    delaycompress
    create 0640 root adm
    sharedscripts
    postrotate
        /usr/bin/systemctl reload rsyslog >/dev/null 2>&1 || true
    endscript
}
EOF

# 14. 간단 백업 스크립트 (홈 디렉토리)
echo "[*] 백업 스크립트 생성 (/usr/local/sbin/backup_home.sh)"
cat > /usr/local/sbin/backup_home.sh <<'EOF'
#!/bin/bash
DEST="/var/backups/home_backup_$(date +%F).tar.gz"
tar -czf "\$DEST" /home --one-file-system
find /var/backups -type f -mtime +30 -name 'home_backup_*.tar.gz' -delete
EOF
chmod +x /usr/local/sbin/backup_home.sh
echo "0 3 * * * root /usr/local/sbin/backup_home.sh" > /etc/cron.d/backup_home

# 15. SSH 재시작 (주의: 현재 접속 세션 유지 확인)
echo "[*] SSH 데몬 재시작"
systemctl restart sshd || systemctl restart ssh || true

echo "=== 하드닝 완료 ==="
echo "다음 사항을 확인하세요:"
echo "- 사용자 '$NEW_USER' 의 /home/$NEW_USER/.ssh/authorized_keys 에 공개키 추가"
echo "- 민감 정보(SSH 개인키, 비밀번호, 토큰 등)를 커밋하지 마세요"
echo "- 시스템에 따라 일부 서비스/패키지 제거는 주의 필요"
EOF

chmod +x ~/kali-hardening/scripts/kali_hardening.sh
