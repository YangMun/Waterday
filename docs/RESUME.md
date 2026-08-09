# Waterday 작업 재개 가이드

마지막 업데이트: 2026-08-09

## 현재 상태: v1.0 MVP 구현 완료 (시뮬레이터 1차 검증 완료)

기획서: `../PlantReminder-Planning/PLAN.md` (시장 근거·포지셔닝). 구현·검증됨: 식물 등록(이모지 16종 선택/사진 PhotosPicker·자동 다운스케일), Today 물주기 체크(연체 표시·주기 재계산), 케어 히스토리(물/비료/분갈이), 7일 선계산 아침 요약 알림, 홈/잠금 위젯, 테마 4종(리워드 해금), 배너 광고, 라이트/다크 Greenhouse 디자인 시스템.

## 남은 일 (우선순위 순)

1. ~~AdMob ID~~ — 완료(2026-08-09): 앱 ID ~1683111706, 배너/리워드 유닛 적용. DEBUG는 테스트 광고
2. ~~앱 아이콘~~ — 완료: 나노바나나 생성본 알파 제거·등록
3. ~~알림 실수신·위젯 데이터 검증~~ — 완료: 잠금화면 배너+위젯(실데이터) 캡처 확인. ⚠️ 시뮬레이터 위젯 검증 시 빌드에 `CODE_SIGNING_ALLOWED=NO` 쓰지 말 것 — entitlements 미포함으로 App Group 접근 실패해 위젯이 빈 데이터를 읽음
4. ~~Info.plist/Privacy Manifest 점검~~ — 완료: 권한 API 전수 검색(ATT만 사용, PhotosPicker는 권한 불필요), GAD ID·SKAdNetwork 50·ATT 문구·암호화 false·PrivacyInfo.xcprivacy(UserDefaults CA92.1) 빌드 산출물에서 검증
5. **실기기 테스트** — App Group `group.com.yangmunkyeong.waterday` 등록 필요
6. **App Store 준비** — 이름 "Waterday - Plant Care Reminder"(30자), Privacy 설문은 Dayline과 동일(AdMob 6개 항목), 개인정보처리방침 URL 호스팅(앱 내 문구는 LegalView.swift), 심사 노트는 Dayline 템플릿 참고
7. **GitHub 공개** — Dayline 패턴(시크릿 gitignore 검증 후 push)

## 주의사항

- 사업자등록 불가 → 광고 전용. DEBUG는 항상 Google 테스트 광고
- 새 Swift 파일 추가 시 `xcodegen generate` 재실행
- 위젯 타겟은 Plant.swift/AppStore.swift/DesignSystem.swift 공유 — UIKit 뷰 의존 추가 금지 (DesignSystem의 UIColor 사용은 OK)
- 모든 데이터 변경은 `CareActions` 경유 (위젯 리로드+알림 재계산 동기화)
- DEBUG 인자: -seedDemoData, -initialTab today|plants|settings
- 식물 아이콘은 이모지 16종(라이선스 무관) — Flaticon 교체 원하면 Settings About에 크레딧 추가 필요
