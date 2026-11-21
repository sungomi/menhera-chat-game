# HARIN.exe (`menhera-chat-game`)

한국어 멘헤라 컨셉 비주얼 노벨 & 스마트폰 채팅 연애 시뮬레이션 웹 게임입니다.

## 개요

- **기술 스택**: Vanilla HTML / CSS / JavaScript (ESM), Python 로컬 개발 서버, Swift(`AppKit`, `CoreImage`, `Vision`) 에셋 빌드 스크립트
- **콘텐츠 구성**:
  - **히로인 5명**: 백서윤(`seoyoon`), 유하린(`harin`), 한세아(`sea`), 강채원(`chaewon`), 송나연(`nayeon`)
  - **캐릭터 스프라이트 50종**: 캐릭터별 10가지 표정·착장 바리에이션 (`normal`, `happy`, `pout`, `anxious`, `yandere`, `shy`, `casual`, `lounge`, `date`, `night`)
  - **배경 17종**: 공용 서울 장소 7곳 + 캐릭터별 전용 방·거실 10곳
  - **대화 모드**: 로컬 규칙 기반 엔진 및 OpenAI 호환 API 연동 모드 지원

## 로컬 실행 방법

```bash
python3 scripts/dev_server.py
```

서버 실행 후 브라우저에서 아래 주소로 접속할 수 있습니다:

- **게임 실행**: `http://localhost:4173/index.html`
- **에셋 콘솔 (뷰어/QA/조합 스튜디오)**: `http://localhost:4173/assets-viewer.html`

## 디렉토리 구조

```text
menhera-chat-game/
├── index.html          # 메인 게임 UI
├── assets-viewer.html  # 에셋 콘솔 및 QA 대시보드
├── style.css           # 게임 스타일시트
├── src/                # 게임 로직 및 데이터 (ESM)
│   ├── characters.js   # 캐릭터·바리에이션·전용 공간 정의
│   ├── scenes.js       # 공용 장소 씬 및 선택지 정의
│   ├── state.js        # 상태·엔딩·설정 관리
│   ├── engine.js       # 로컬 및 OpenAI 호환 대화 엔진
│   └── main.js         # UI 컨트롤러 및 이벤트 루프
├── assets/             # 캐릭터 PNG 50종 + 배경 JPG 17종
└── scripts/
    ├── dev_server.py           # Live-reload 정적 개발 서버
    ├── build_all_assets.swift  # 캐릭터·배경 에셋 빌드 스크립트
    └── cutout.swift            # 전경 누끼 추출 유틸리티
```
