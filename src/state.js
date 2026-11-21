export const ENDINGS = {
  true: {
    id: 'true',
    tag: 'TRUE ENDING',
    title: '둘만의 우주 ☀️',
    desc: '만남에서도, 화면 너머에서도 진심을 다해 곁을 지켜주었다. 하린이는 이제 조금씩 너를 믿고 웃을 수 있게 되었다.',
    slotLabel: '☀️ 트루 엔딩: 둘만의 우주',
  },
  obsess: {
    id: 'obsess',
    tag: 'OBSESSIVE ENDING',
    title: '영원히 내 거 🖤',
    desc: '사랑은 깊지만 불안도 한계치를 넘었다. "이제 내 허락 없이 아무 데도 못 가, 알지?" 하린의 집착은 오늘도 계속된다.',
    slotLabel: '🖤 집착 엔딩: 영원히 내 거',
  },
  block: {
    id: 'block',
    tag: 'BAD ENDING',
    title: '차단된 사용자입니다 💔',
    desc: '불안이 폭발한 하린이가 결국 너를 차단했다. 프로필 사진이 기본 이미지로 바뀌고, 새벽 공기가 차갑게 식는다.',
    slotLabel: '💔 배드 엔딩: 차단된 사용자',
  },
  tired: {
    id: 'tired',
    tag: 'BAD ENDING',
    title: '지쳐버린 새벽 🌙',
    desc: '서로의 감정 소모 끝에 하린이 먼저 손을 놓았다. "우리 그냥 그만하자... 나도 이제 힘들어."',
    slotLabel: '🌙 배드 엔딩: 지쳐버린 새벽',
  },
};

export const LLM_PRESETS = {
  zai: { apiBase: 'https://api.z.ai/api/paas/v4', model: 'glm-4.7-flash' },
  groq: { apiBase: 'https://api.groq.com/openai/v1', model: 'qwen/qwen3-32b' },
  openrouter: { apiBase: 'https://openrouter.ai/api/v1', model: 'openrouter/free' },
  ollama: { apiBase: 'http://localhost:11434/v1', model: 'qwen2.5:7b' },
};

const STORAGE_KEY_CFG = 'menhera_chat_cfg_v2';
const STORAGE_KEY_ENDINGS = 'menhera_chat_endings_v2';

export function createInitialState(characterId = 'harin') {
  return {
    characterId,
    day: 1,
    locationId: 'seongsu',
    exclusiveSpaceId: null,
    affection: 55,
    anxiety: 35,
    turn: 0,
    ended: false,
    history: [],
    statusOverride: null,
  };
}

export function loadConfig() {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY_CFG) || 'null');
    if (saved) return saved;
  } catch {}
  return { mode: 'local', apiBase: LLM_PRESETS.groq.apiBase, model: LLM_PRESETS.groq.model, apiKey: '' };
}

export function saveConfig(cfg) {
  localStorage.setItem(STORAGE_KEY_CFG, JSON.stringify(cfg));
}

export function loadUnlockedEndings() {
  try {
    return new Set(JSON.parse(localStorage.getItem(STORAGE_KEY_ENDINGS) || '[]'));
  } catch {
    return new Set();
  }
}

export function saveUnlockedEnding(id) {
  const set = loadUnlockedEndings();
  set.add(id);
  localStorage.setItem(STORAGE_KEY_ENDINGS, JSON.stringify([...set]));
  return set;
}

export function getMoodState(affection, anxiety, character = null, exclusiveSpaceId = null, locationId = 'seongsu') {
  const sprites = character?.sprites || {
    normal: 'assets/harin-normal.png',
    happy: 'assets/harin-happy.png',
    pout: 'assets/harin-pout.png',
    anxious: 'assets/harin-anxious.png',
  };

  if (anxiety >= 88) {
    return {
      badge: '얀데레 각성',
      sprite: sprites.yandere || sprites.anxious || sprites.normal,
      status: '"어디도 못 가. 나만 보고 있어야지."',
    };
  }
  if (anxiety >= 72) {
    return { badge: '불안 발작', sprite: sprites.anxious || sprites.normal, status: '"왜 나만 매달리는 것 같지..."' };
  }
  if (anxiety >= 45) {
    return {
      badge: anxiety >= 60 ? '의심 MAX' : '살짝 삐짐',
      sprite: sprites.pout || sprites.normal,
      status: '"다 거짓말이었나."',
    };
  }
  if (affection >= 80 && anxiety <= 30) {
    return { badge: '심쿵 밀착', sprite: sprites.shy || sprites.happy || sprites.normal, status: '"지금 이대로 멈췄으면..."' };
  }
  if (affection >= 68 && anxiety <= 40) {
    if (!exclusiveSpaceId && ['seongsu', 'gangnam', 'namsan'].includes(locationId)) {
      return { badge: '설레는 데이트', sprite: sprites.date || sprites.happy, status: '"오늘 코디 너 보려고 입었는데 🖤"' };
    }
    if (!exclusiveSpaceId && ['rooftop', 'hongdae'].includes(locationId)) {
      return { badge: '심야 데이트', sprite: sprites.night || sprites.happy, status: '"밤공기 좋다... 집 가기 싫어 ✨"' };
    }
    return { badge: '애정 폭발', sprite: sprites.happy || sprites.normal, status: '"오늘도 나만 봐줘 🖤"' };
  }
  if (exclusiveSpaceId === 'room') {
    return { badge: '자취방 집콕', sprite: sprites.casual || sprites.normal, status: character?.defaultStatus || '"집이 제일 편해 🖤"' };
  }
  if (exclusiveSpaceId === 'living') {
    return { badge: '홈 라운지', sprite: sprites.lounge || sprites.normal, status: character?.defaultStatus || '"여기 앉아 🛋️"' };
  }
  if (['rooftop', 'hongdae'].includes(locationId)) {
    return { badge: '네온 밤거리', sprite: sprites.night || sprites.normal, status: character?.defaultStatus || '"밤엔 역시 여기지 ✨"' };
  }
  return { badge: '평온함', sprite: sprites.normal, status: character?.defaultStatus || '"나만의 햇살 ☀️"' };
}

export function checkEnding(state) {
  if (state.anxiety >= 100) return ENDINGS.block;
  if (state.affection <= 0) return ENDINGS.tired;
  if (state.turn >= 8 && state.affection >= 85 && state.anxiety <= 30) return ENDINGS.true;
  if (state.turn >= 8 && state.affection >= 75 && state.anxiety >= 80) return ENDINGS.obsess;
  return null;
}
