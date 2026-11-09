# 최정원 보안 교육 실습 자료

정보보안산업기사 과정평가형 교육의 네 실습을 정리한 포트폴리오 별도 자료입니다. 회사 실무 경력과 구분합니다.

| 실습 | 자료 | 교육 기간 |
|---|---|---|
| 보안취약점 로그분석 | [보고서](01-log-analysis/REPORT.md) · [증거 목록](01-log-analysis/evidence-register.csv) | 2025.09.17~2025.09.30 |
| 웹 해킹 실습 프로젝트 | [보고서](02-web-security/REPORT.md) · [증거 목록](02-web-security/evidence-register.csv) | 2025.08.26~2025.09.04 |
| 네트워크 보안 실습 | [보고서](03-network-security/REPORT.md) · [증거 목록](03-network-security/evidence-register.csv) | 2025.08.13~2025.08.25 |
| 데이터베이스 보안 실습 | [보고서](04-database-security/REPORT.md) · [증거 목록](04-database-security/evidence-register.csv) | 2025.07.17~2025.07.25 |

## 읽는 순서

각 보고서의 기존 기록 → 확인할 작업 과정 → 필요한 증거 → 결론 범위를 읽어주세요. `evidence-register.csv`에는 원본 증거가 필요한 항목과 현재 확보 상태를 기록했습니다.

## 현재 확인 수준

2026.11.09 노션의 실습 요약을 읽어 정리했습니다. 당시 PCAP·명령 출력·요청/응답·DB 변경 전후 자료는 확보되지 않았습니다. 기존 페이지의 서술은 원본 증거와 구분했으며 새로운 테스트를 수행한 것처럼 기록하지 않았습니다. 특히 공격 성공, 취약점 제거, TLS 적용 완료는 증거 확보 전 확정하지 않습니다.

## 구성

- 각 폴더의 `REPORT.md`: 주제별 실습 정리 및 검증 방법
- 각 폴더의 `evidence-register.csv`: 증거 확보 상태
- `templates/CASE_RECORD.md`: 실제 사례를 기록할 때 사용하는 양식
- `templates/ENVIRONMENT.md`: 실습 환경 기록 양식
- `EVIDENCE_GUIDE.md`: 결과를 입증하기 위해 남길 자료와 공개 기준
- `SOURCE_MAP.md`: 노션 원문과 자료별 확인 범위

이 문서들은 기존 요약을 바탕으로 AI 도움을 받아 작성했습니다. 직접 수행한 작업·도움받은 부분·확인 결과는 실제 자료와 대조해 보완합니다. 저장소 기존 하드닝 스크립트의 실행·안전성을 검증한 자료가 아닙니다.
