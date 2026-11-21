import { CHARACTERS } from './characters.js';
import { SCENES } from './scenes.js';

const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];

export function runLocalSceneEngine(input, state) {
  const text = input.trim().toLowerCase();

  if (input === '__action:pat' || /(쓰다듬|머리|안아|손\s*잡|외투)/.test(text)) {
    return {
      dialogue: pick([
        '"...갑자기 그렇게 다정하게 굴면 반칙이잖아. 심장 터질 것 같아." (하린이 네 소매를 슬며시 잡는다.)',
        '"응... 조금만 더 이렇게 있어줘. 이럴 때만 진짜 내 사람 같단 말이야."',
      ]),
      affectionDelta: 10,
      anxietyDelta: -10,
      statusOverride: '"조금 안심됨 🖤"',
    };
  }
  if (input === '__action:check_phone' || /(폰|카톡|전화|가야|집에)/.test(text)) {
    return {
      dialogue: '"지금 나 앞에 있는데 굳이 휴대폰을 보거나 갈 생각부터 해? ...나보다 중요한 게 있어?" (시선이 차갑게 식는다.)',
      affectionDelta: -7,
      anxietyDelta: 15,
      statusOverride: '"눈앞에서도 딴청"',
    };
  }
  if (input === '__action:tease') {
    return {
      dialogue: '"장난치지 마... 난 진짜 진지하단 말이야. 웃는 거 보니까 더 불안해지잖아."',
      affectionDelta: -3,
      anxietyDelta: 12,
      statusOverride: null,
    };
  }
  if (input === '__action:reassure' || /(사랑|좋아|너밖에|예뻐|미안|옆에|데려다)/.test(text)) {
    return {
      dialogue: '"진심이지...? 나 버리지 않을 거지? 약속한 거다, 오빠." (하린이 작게 고개를 끄덕인다.)',
      affectionDelta: 11,
      anxietyDelta: -12,
      statusOverride: '"오늘도 나만 봐줘 🖤"',
    };
  }
  if (/(그만|피곤|헤어|꺼져)/.test(text)) {
    return {
      dialogue: '"방금 그 말 진짜야...? 나 혼자 또 새벽까지 울게 둘 거야?" (목소리가 살짝 떨린다.)',
      affectionDelta: -16,
      anxietyDelta: 20,
      statusOverride: '"..."',
    };
  }

  return {
    dialogue: pick([
      '"응? 아까부터 내 눈 제대로 안 마주치는 것 같은데 기분 탓인가..."',
      '"오빠는 내가 이렇게 붙잡고 있으면 귀찮아? 솔직하게 말해봐."',
      '"오늘 몬스터 핑크 두 캔이나 마셨더니 심장이 너무 빨리 뛰어. 네 옆이라 그런가?"',
    ]),
    affectionDelta: 3,
    anxietyDelta: -2,
    statusOverride: null,
  };
}

export function runLocalChatEngine(userText, state) {
  const text = userText.trim().toLowerCase();
  const isLove = /(사랑|좋아|보고\s*싶|너밖에|예뻐|귀여|미안|내\s*꺼|안아)/.test(text);
  const isDismissive = /(바빠|나중에|그만|피곤|귀찮|몰라|헤어)/.test(text);
  const isShort = text.length <= 4 && !isLove;

  if (/(헤어|그만하|질려|꺼져)/.test(text)) {
    return {
      messages: ['방금 뭐라고 했어?', 'ㅋㅋㅋ 농담이지? 제발 농담이라고 해', '나 진짜 손 떨려 장난치지 마'],
      affectionDelta: -35,
      anxietyDelta: 35,
      statusOverride: '"..."',
    };
  }
  if (isLove && !isDismissive) {
    return {
      messages: state.anxiety >= 65
        ? ['진심이야...?', '그래도 네가 그렇게 말해주니까 조금 진정돼 ㅠㅠ']
        : pick([
            ['웅...? 진짜지? 🖤', '나도 오빠밖에 없어 진짜루...'],
            ['아 심장 아파 ㅋㅋㅋ', '갑자기 그런 말 하면 나 또 설레잖아 바보야'],
          ]),
      affectionDelta: 11,
      anxietyDelta: -12,
      statusOverride: null,
    };
  }
  if (isDismissive) {
    return {
      messages: pick([
        ['아... 그래 나만 또 방해했네', '알겠어 바쁘면 안 잡을게 ㅋㅋ'],
        ['내가 그렇게 귀찮아?', '변했네 진짜'],
      ]),
      affectionDelta: -12,
      anxietyDelta: 18,
      statusOverride: null,
    };
  }
  if (isShort) {
    return {
      messages: ['...그게 다야?', '단답 진짜 싫다... 말투 왜 이렇게 차가워?'],
      affectionDelta: -6,
      anxietyDelta: 14,
      statusOverride: null,
    };
  }
  return {
    messages: pick([
      ['웅... 계속 나랑만 톡해줘', '아까 답장 조금 늦어서 심장 떨어질 뻔했잖아'],
      ['ㅋㅋㅋ 진짜?', '근데 아까부터 궁금한 건데 나 진짜 좋아하긴 해?'],
    ]),
    affectionDelta: 3,
    anxietyDelta: -2,
    statusOverride: null,
  };
}

export function getIdleWarning(idleCount) {
  const pool = [
    { messages: ['자?', '왜 안 읽어...'], anxietyDelta: 8, affectionDelta: -2 },
    { messages: ['지금 누구랑 톡하는 중이야?', '나만 또 기다리지 ㅋㅋ'], anxietyDelta: 12, affectionDelta: -4 },
    { messages: ['야', '진짜 너무한다 어떻게 이렇게까지 답장이 없어?'], anxietyDelta: 16, affectionDelta: -6 },
  ];
  return pool[Math.min(idleCount, pool.length - 1)];
}

export async function runLlmEngine(mode, history, state, config) {
  const char = CHARACTERS[state.characterId] || CHARACTERS.harin;
  const space = state.exclusiveSpaceId
    ? char.exclusiveSpaces?.find((s) => s.id === state.exclusiveSpaceId) || char.exclusiveRoom
    : null;
  const scene = space || SCENES[state.locationId] || SCENES.seongsu;
  const modeDesc =
    mode === 'scene'
      ? `현재 장소는 "${scene.title}"이며, 1인칭 직접 만남 상황이다. 대사와 짧은 지문(행동 묘사)을 1~2문장으로 출력하라.`
      : '현재는 스마트폰 카톡 채팅 상황이다. 짧은 카톡 말풍선 1~3개로 나눠 보내라.';

  const systemPrompt = `너는 '${char.name}' (${char.age}세, ${char.role}) 역할의 1인칭 연애 시뮬레이션 캐릭터다.
컨셉: ${char.archetype} — ${char.summary}
성격: ${char.personality}
말투 특징: ${char.speechStyle}
불안 트리거: ${char.obsessionTrigger}
(자해/자살 등 위험한 묘사 금지)
${modeDesc}
현재 스탯: 애정도 ${state.affection}/100, 불안도 ${state.anxiety}/100, 턴 ${state.turn}.

반드시 순수 JSON만 응답하라:
{
  "messages": ["대사1", "대사2(선택)"],
  "affectionDelta": -15~15 정수,
  "anxietyDelta": -15~20 정수,
  "statusMessage": "상태메시지(선택)"
}`;

  const base = config.apiBase.replace(/\/+$/, '');
  const headers = { 'Content-Type': 'application/json' };
  if (config.apiKey) headers['Authorization'] = `Bearer ${config.apiKey}`;

  const res = await fetch(`${base}/chat/completions`, {
    method: 'POST',
    headers,
    body: JSON.stringify({
      model: config.model,
      messages: [{ role: 'system', content: systemPrompt }, ...history.slice(-12)],
      temperature: 0.85,
    }),
  });

  if (!res.ok) throw new Error(`API 오류 (${res.status})`);
  const data = await res.json();
  const raw = data.choices?.[0]?.message?.content || '';
  const match = raw.match(/\{[\s\S]*\}/);
  if (!match) return { messages: [raw.trim() || '...'], affectionDelta: 0, anxietyDelta: 2, statusOverride: null };

  const parsed = JSON.parse(match[0]);
  return {
    messages: Array.isArray(parsed.messages) && parsed.messages.length ? parsed.messages : ['...'],
    affectionDelta: Number(parsed.affectionDelta) || 0,
    anxietyDelta: Number(parsed.anxietyDelta) || 0,
    statusOverride: parsed.statusMessage || null,
  };
}
