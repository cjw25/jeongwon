# Kali Hardening & 운영 스크립트

Kali (VMware) 환경에서 시스템 하드닝과 운영 자동화를 돕는 스크립트 모음입니다.
<<<<<<< HEAD
**목표:** 업데이트·SSH·방화벽·fail2ban·auditd·sysctl 등을 자동화하여 안전하게 운영.

## 사용법 (요약)
1. 스크립트 검토 후 테스트 VM에서 실행하세요.
2. 루트로 실행: `sudo bash scripts/kali_hardening.sh`
3. /home/SECUSER/.ssh/authorized_keys에 공개키를 넣고 비밀번호 인증은 비활성화하세요.

## 주의사항
- 민감 정보(키/비밀번호/토큰) 절대 커밋 금지.
- 프로덕션 적용 전 반드시 스냅샷/백업을 하세요.

## 라이선스
MIT License — LICENSE 파일을 확인하세요.

=======

## Quickstart
1. 검토 후 테스트 VM에서 실행: `sudo bash scripts/kali_hardening.sh`
2. 공개키를 `/home/<user>/.ssh/authorized_keys`에 추가하세요.
3. 민감 정보(키/비밀번호/API 토큰)는 절대 커밋 금지.

## License
MIT
>>>>>>> 30df3bc (Initial commit: kali hardening project)
