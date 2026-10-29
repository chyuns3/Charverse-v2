# Charverse v2 — GAI3008 중간프로젝트 저장소 (1인 1팀)

## 앱 소개

> 앱스토어 상품 페이지처럼 채웁니다. 칸 이름과 순서는 발표 자료의 "앱 소개" 장과 같습니다 — 바꾸지 않습니다.

### 앱 이름
Charverse v2

### 부제
글자를 학습하며 세계를 넓혀가자

### 카테고리
교육 · 언어 학습

### 대상 사용자 / 사용 상황
- 대상 사용자: 일본어 입문자와 JLPT 학습자 중 히라가나·가타카나·기초 한자를 직접 쓰며 익히려는 초급 학습자
- 사용 상황: 휴대폰의 짧은 학습 세션에서 글자를 검색하고 따라 쓴다. 넓은 창에서는 문자 목록과 캐릭터 보관함을 다열로 살펴본다.

### 스크린샷
제출용 앱 캡처는 아직 `docs/screenshots/`에 저장되지 않았다. 아래 파일을 실제 Charverse 화면 캡처로 추가해야 한다. 대화에 첨부된 유사앱 캡처는 참고 자료이며 Charverse 화면 캡처로 대체하지 않는다.

| 필요한 캡처 | 파일명 | 상태 |
|---|---|---|
| 재설계 기준 앱 v1 | `01_v1_current.png` | 기준 앱 미확정 · 캡처 미첨부 |
| Charverse 화면 A | `02_v2_a.png` | 미첨부 |
| Charverse 화면 B + C 진단서 모달 | `03_v2_b.png` | 미첨부 |
| Charverse 화면 D 보관함 | `04_v2_d.png` | 미첨부 |
| 넓은 창 적응형 화면 | `05_v2_wide.png` | 미첨부 |

### 설명
1. Charverse v2는 한글 자모, 히라가나, 가타카나, 기초 한자를 검색하고 직접 써 보며 익히는 UI 프로토타입이다. 학습 완료 캐릭터를 보관함에서 확인할 수 있다.
2. 리뷰 표본에서는 획 표기·콘텐츠 정확성, 조작 상태가 유지되지 않는 문제, 학습 상태 피드백과 복습 보관 요구가 나타났다(R02, R06–R08, R18). Charverse는 문자 가이드, 명시적 학습 상태, 즐겨찾기와 캐릭터 보관함을 중심으로 대응한다.
3. 핵심 가치는 문자 형태를 직접 보고 쓰는 연습, 학습 상태의 가시성, 사용자 통제, 캐릭터 수집을 하나의 학습 흐름에 연결하는 것이다. 실제 필기 인식·AI 분석·간격 반복 알고리즘은 제공하지 않는다.

### 새로운 기능
v2에서 바뀐 것 3개 — 원칙 카드(`docs/원칙카드.md`)의 P번호와 연결합니다.

| P번호 | 바뀐 것 (화면 · 요소 번호) | 근거 (리뷰 · 원칙) |
|---|---|---|
| P01, P03 | B-5 학습 완료를 학습 중 또는 미학습으로 되돌리는 상태 조작 | R08의 학습 상태 이동 오류 · 상태 가시성 및 사용자 통제 |
| P05, P06 | B-3 획순 가이드와 글자 실루엣, A-9 획수 필터 | R02의 가나 획 표기 지적 · 오류 예방과 재인 |
| P01, P07 | A-8 즐겨찾기, D-2 캐릭터 보관함과 미확인 표시 | R18의 한자 즐겨찾기·복습 요청 · 보관과 재방문 효율 |

### 평가 및 리뷰
사용자가 제공한 유사앱 리뷰 PDF에 정리된 20건의 표본 분석이다. 스토어 전체의 현재 평점이나 전체 리뷰 수가 아니다.

| 앱/스토어 표본 | 리뷰 수 | 평점 분포 | 표본 평균 |
|---|---:|---|---:|
| 일본어 공부: 히라가나, 가타카나, 한자, 카나 (App Store) | 4 | 5점 3건 · 4점 1건 | 4.75 / 5 |
| 이로이로 일본어 공부 JLPT 단어장: 한자도 한번에 (Google Play) | 16 | 5점 10건 · 4점 1건 · 3점 3건 · 2점 2건 | 4.19 / 5 |
| 합계 표본 | 20 | 5점 13건 · 4점 2건 · 3점 3건 · 2점 2건 | 4.30 / 5 |

| 리뷰 유형 (PDF 분류) | 건수 |
|---|---:|
| 기능 요청 | 11 |
| 버그 리포트 | 4 |
| 평가 | 3 |
| 사용 경험 | 2 |

대표 인용 (작성자 이름 미기재/제거):

- “계정 연동이 됐으면 좋겠어요.” — App Store · ★5 · 2022-11-09
- “히라가나·가타카나 중 글꼴이 다른 경우가 있는데…” — App Store · ★4 · 2023-02-04
- “퀴즈 풀기 할 때 유형선택 누르면 자꾸 자동선택으로 전환됨 나는 수동을 하고 싶다고요” — Google Play · ★2 · 2026-09-26
- “예문과 오디오에 오류가 빈번히 발견되어 앱에 대한 신뢰감이 사용할수록 떨어집니다.” — Google Play · ★3 · 2026-06-17
- “버튼을 꼭 눌러도 장기기억으로 한번에 안 보내지고 … 단기기억에 자꾸 남아 있는” — Google Play · ★3 · 2026-10-11
- “한자는 별도의 즐겨찾기나 복습 기능이 없는 것 같네요.” — Google Play · ★5 · 2026-05-28
- “UI가 굉장히 깔끔하고 직관적입니다.” — Google Play · ★5 · 2026-01-20
- “단어가 너무 연관성없이 이어집니다. 테마별로도 분류해서 단어가 띄워지면 암기에 더 도움이 되지 않을까 생각이 듭니다.” — Google Play · ★5 · 2026-05-11

출처: 사용자가 제공한 리뷰 PDF의 앱명·스토어·별점·날짜·리뷰 유형·리뷰 원문/요약. 인용은 OCR에서 읽히는 부분만 발췌했으며, OCR 문맥이 뒤섞인 대목은 직접 인용하지 않았다.

---

## 작성자 · 제출 정보

| 칸 | 내용 |
|---|---|
| 현행 앱 | 기준 재설계 앱 미확정. 리뷰 PDF는 위 두 유사앱의 표본 20건을 포함하며, 기획서에서 v1 대상 앱과 스토어 링크를 확정해야 함 |
| v2 한 문장 | 문자를 검색하고 직접 써 보며 학습 상태와 캐릭터 수집을 관리하는 일본어 문자 학습 UI 프로토타입 |
| 작성자 | 조현성 · 1인 1팀 |
| 데모 | 미첨부. 제출 전 `docs/영상/demo_1min.mp4` 또는 배포 URL 추가 필요 |
| AI 사용 | 규칙 `AGENTS.md` · 기록 `docs/prompt-log.md` · 셀프 논증 기록 `docs/셀프논증.md` · 기획 확정 태그 `v1-plan` (태그 존재 여부 확인 필요) |

> 이 저장소는 **UI만 구현**합니다(중간고사 안내문 5장). 학습 상태·즐겨찾기·미확인 표시·테마 선택은 메모리 안에서만 유지하며, 영구 저장·로그인·결제·실제 필기 분석은 없습니다.
> 화면 흐름: A 글자 도감 → B 글자 학습 상세(탭) → C 가상 진단서(모달), A에서 D 캐릭터 보관함(push).

---

## 0. 처음 받았을 때: 폴더 이름 · 앱 이름 바꾸기

1. **폴더(저장소) 이름**: `mid-project-template` → `<영문 앱 이름>-v2` (예: `mealapp-v2`). GitHub 저장소 이름도 같게.
   - ⚠ **경로 전체를 영문·숫자·하이픈으로** 둡니다. 경로에 한글이 한 글자라도 있으면 `flutter analyze`(Flutter 3.44)가 analysis server 오류로 멈추는 것을 확인했습니다(`dart analyze`는 됨). 바탕화면·문서 폴더 이름이 한글이면 `C:\dev\` · `~/dev/` 같은 곳으로 옮깁니다.
2. **앱 이름(화면에 보이는 이름)** — 아래만 바꾸면 됩니다:
   - `lib/main.dart` — `MaterialApp(title: …)`, 각 화면 `AppBar` 제목
   - Android: `android/app/src/main/AndroidManifest.xml`의 `android:label`
   - iOS: `ios/Runner/Info.plist`의 `CFBundleDisplayName`
   - 웹: `web/index.html`의 `<title>`, `web/manifest.json`의 `name`·`short_name`
3. **패키지 이름 `mid_project_template`는 그대로 두는 것을 권장**합니다(바꾸면 `pubspec.yaml`의 `name`과 `test/`의 `import 'package:mid_project_template/…'`를 모두 고쳐야 함). 조직 ID는 `kr.ac.yonsei.gai3008`.

## 1. 실행 방법 — 터미널 2개

준비물: Flutter(Dart SDK ^3.10), Node.js 18 이상.

**터미널 1 — 목업 서버(json-server)**

```bash
cd mock_server
npm install && npm start          # http://localhost:3000  (npm run mock 도 같음)
curl http://localhost:3000/items  # 확인: JSON 배열이 나오면 성공
```

**터미널 2 — 앱**

```bash
flutter pub get && flutter run    # 저장소 루트(pubspec.yaml 있는 곳)에서
flutter run -d chrome             # 웹으로 볼 때
```

| 실행 대상 | 앱이 부르는 주소 | 따로 할 일 |
|---|---|---|
| Chrome · macOS · Windows · iOS 시뮬레이터 | `http://localhost:3000` | 없음 |
| **Android 에뮬레이터** | **`http://10.0.2.2:3000`** | 없음 — `lib/api.dart`가 Android면 자동으로 10.0.2.2를 씀 |
| 실기기(같은 Wi-Fi) | PC IP | `flutter run --dart-define=API_BASE=http://192.168.0.10:3000` |
| Vercel 배포(가산) | 배포 주소 | `--dart-define=API_BASE=https://<프로젝트>.vercel.app/api` — `mock_server/README.md` 5장 |

- 서버가 꺼져 있으면 앱은 **오류 화면 + "다시 시도"**를 보여 줍니다(서버를 켜고 다시 시도 누르면 목록이 뜸).
- 서버 설정·`db.json` 바꾸는 법·CORS: `mock_server/README.md`.

### 상태 화면 시연 — `DEMO_STATE` (발표·영상용)

```bash
flutter run --dart-define=DEMO_STATE=loading   # 3초 로딩 (slow 도 같음)
flutter run --dart-define=DEMO_STATE=error     # 오류 + 다시 시도
flutter run --dart-define=DEMO_STATE=empty     # 빈 상태
```

서버 없이도 세 상태를 바로 보여 줄 수 있습니다. `API_BASE`와 함께 써도 됩니다.

## 2. 구조

```
mid-project-template/
├── README.md                 # 실행 방법 [필수]
├── AGENTS.md                 # AI 가드레일 (UI만) — CLAUDE.md는 이 파일을 따른다는 한 줄
├── pubspec.yaml              # 추가 패키지는 http 하나
├── lib/
│   ├── main.dart             # 앱 뼈대 · 화면 흐름 주석
│   ├── api.dart              # GET만 · API_BASE · DEMO_STATE
│   ├── models.dart           # JSON → 객체 (Dart 3 패턴 fromJson)
│   ├── widgets.dart          # LoadingView · ErrorView · EmptyView (+ NetImage)
│   └── screens/
│       ├── a_list_screen.dart    # 화면 A 목록 — GET /items, 3상태, 600dp 적응형
│       ├── b_detail_screen.dart  # 화면 B 상세 — push로 들어옴, 탭(정보|메모), GET /notes
│       ├── c_result_sheet.dart   # 화면 C 결과(임의) — 모달 시트, 미리 정한 결과
│       └── d_collection_screen.dart # 화면 D 보관함 — 미확인 캐릭터와 테마 선택
├── test/widget_test.dart     # 3상태 · push/tab/modal · 600dp 위젯 테스트
├── mock_server/
│   ├── db.json               # [필수] GET 데이터 (items · notes)
│   ├── package.json          # json-server 0.17.4 고정
│   ├── api/server.js · vercel.json   # (가산) 읽기 전용 배포
│   └── README.md
└── docs/
    ├── 디자인가이드.md       # 화면 목록 · 원칙 P01–P10 · 요소 분석 · 가이드 글 · 상태관리 포인트
    ├── 원칙카드.md           # 5칸 양식 (원칙 · 근거 · 적용 · 시연 · 판단)
    ├── prompt-log.md         # 4칸 (요청 · AI 결과 · 판단 · 이유)
    ├── 셀프논증.md           # 셀프 논증 기록: 내 주장 · 반론(AI) · 재반론 · 결론 · 근거 · 전/후
    ├── 자가평가.md           # 공개 배점 40/20/25/15 그대로
    ├── 영상/                 # demo_1min.mp4 · p01.mp4 …
    └── screenshots/          # README '앱 소개' 스크린샷 (01_v1_current.png …)
```

## 3. 화면 목록 ↔ 기획 문서 요소 번호

| 화면 | 이름 (비즈니스 명칭) | 파일 | 전환 | 요소 번호 |
|---|---|---|---|---|
| A | 글자 도감 및 학습 목록 | `lib/screens/a_list_screen.dart` | 첫 화면 · 허브/목록 전환 | A-1, A-2, A-4~A-9 |
| B | 글자 학습 및 습관 분석 상세 | `lib/screens/b_detail_screen.dart` | 쌓기(push) · 옆으로(tab) | B-1~B-9 |
| C | AI 글쓰기 습관 정밀 진단서 | `lib/screens/c_result_sheet.dart` | 덮기(modal) | C-1~C-4 |
| D | 내 캐릭터 보관함 | `lib/screens/d_collection_screen.dart` | 쌓기(push) | D-1~D-4 |

각 화면 파일 맨 위에 **디자인 가이드 대응표**(번호 · Flutter 위젯명 · 비즈니스 명칭 · 원칙) 주석이 있고, 코드 안에서 같은 번호(`// A-5 P09`)로 찾을 수 있습니다. `docs/디자인가이드.md`와 1:1로 맞춥니다. **가이드에 없는 화면은 만들지 않습니다**(감점).

**상태관리 포인트**는 구현하지 않고 주석으로만 표시합니다: `// STATE: <데이터> → <보여질 위젯>` — 모아 보기 `grep -rn "STATE:" lib`

## 4. 원칙 번호 추적 P01–P10 [권장]

P번호 = 닐슨 원칙 번호. 원칙 카드에 붙인 번호 하나를 다섯 곳에 그대로 씁니다.

| 어디 | 쓰는 법 |
|---|---|
| 디자인 가이드 | `docs/디자인가이드.md` 2장 표 · 요소 분석의 원칙 칸 |
| 코드 주석 | 그 원칙을 보여 주는 위젯 줄 끝: `); // A-5 P09` |
| 커밋 메시지 | `p09: 화면 A 오류 화면에 다시 시도` |
| 영상 | `docs/영상/p09.mp4` (원칙별 5–10초) |
| 발표 | 원칙 카드 P09 — 시연 칸 = p09.mp4 |

찾기: `grep -rn "P09" lib/` · `git log --oneline --grep="p09"`

## 5. 기준점 Git 태그 `v1-plan` [권장]

내가 화면 기획(흐름 · 요소 분석 · 가이드 글)을 확정한 직후 **한 번만** 붙입니다. 그 뒤 커밋이 UI 진행 기록이 되고, 셀프 논증 기록의 전 · 후 기준이 됩니다.

```bash
git tag -a v1-plan -m "화면 기획 확정"
git push origin v1-plan
git log v1-plan..HEAD --oneline        # 그 뒤 무엇이 바뀌었나
git diff v1-plan..HEAD --stat
```

기획이 바뀌면 셀프 논증 기록에 쟁점으로 남기고, 태그는 지우지 않습니다.

## 6. 영상 파일 이름

- `docs/영상/demo_1min.mp4` — 전체 흐름 1분 [필수 — 제출물 4, 배포 URL로 대신 가능]: 첫 화면 → 전환 → 임의 결과 → GET 목록 → 넓은 화면
- `docs/영상/p01.mp4`, `p09.mp4` … — 원칙별 5–10초 클립 [권장], 원칙 카드 번호와 같게
- 녹화 전: 개인정보 · 알림이 화면에 보이지 않는지 확인. GitHub는 100MB가 넘는 파일을 받지 않으니 큰 영상은 LMS·드라이브 링크로 README "데모" 칸에 적습니다.

## 7. 감점 점검 (제출 전, 결과가 비어 있어야 함)

```bash
grep -rnE "http\.(post|put|patch|delete)|SharedPreferences|sqflite|hive|FirebaseAuth|ChangeNotifierProvider|Riverpod|BlocProvider" lib/ pubspec.yaml
```

걸린 줄은 지웁니다(안내문 8장). 검색은 이름만 찾으므로 화면을 직접 눌러 보며 실제로 저장·전송되는 곳이 없는지도 확인합니다. 자세한 점검: `docs/자가평가.md`.

## 8. 제출 전 clone 테스트 [필수 확인]

내 컴퓨터에서만 되는 저장소를 막습니다. 다른 사람 입장에서 README 명령만으로 됩니까?

1. 새 폴더에 받기: `git clone <저장소 URL> clone-test`
2. 터미널 1: `cd clone-test/mock_server && npm install && npm start`
3. 서버 확인: `curl http://localhost:3000/items` (내가 바꾼 `db.json` 키로)
4. 터미널 2: `cd clone-test && flutter pub get`
5. 실행: `flutter run -d chrome` (Android 에뮬레이터는 그냥 `flutter run`)
6. 화면 전환 · GET 목록 · 로딩/오류/빈 상태(`DEMO_STATE`) · 넓은 화면(창 크기 늘리기) 확인 → 안 되면 README를 고치고 1부터 다시

자주 빠지는 것: `db.json`이 커밋되지 않음 · `node_modules/`까지 올림 · README의 폴더 이름이 실제와 다름.

## 9. 제출물 5종 체크 (LMS, 10/22(목) 15:00 전, 각자 제출)

- [ ] 1. 기획 문서 PDF (Figma/PPT 내보내기 — 1~5단계 포함)
- [ ] 2. 셀프 논증 기록 (양식 사용 — `docs/셀프논증.md`로 초안, 증거: `docs/prompt-log.md` · `docs/원칙카드.md`)
- [ ] 3. GitHub 저장소 URL — Flutter 코드 + `mock_server/db.json` + README(실행 방법) — **clone 테스트 통과**
- [ ] 4. 데모 영상 1분 또는 배포 URL
- [ ] 5. 발표 자료 (6분 발표 + 2분 질의)

## 10. 확인된 상태 (템플릿 배포 시점)

```bash
flutter analyze   # No issues found!  (경로가 영문일 때 — 0장 참고)
flutter test      # 4개 통과: 3상태(로딩·오류→다시 시도 · 빈) · push/tab/modal 흐름 · 600dp 격자
```

`pubspec.yaml` 의존성: `flutter`, `cupertino_icons`, `http`뿐. 플랫폼 설정: Android 디버그 빌드 평문 HTTP 허용(`android/app/src/debug/AndroidManifest.xml`), macOS 나가는 네트워크 허용(`macos/Runner/*.entitlements`).
