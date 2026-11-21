import { CHARACTERS } from './characters.js';
import { getIdleWarning, runLlmEngine, runLocalChatEngine, runLocalSceneEngine } from './engine.js';
import { SCENES } from './scenes.js';
import {
  ENDINGS,
  LLM_PRESETS,
  checkEnding,
  createInitialState,
  getMoodState,
  loadConfig,
  loadUnlockedEndings,
  saveConfig,
  saveUnlockedEnding,
} from './state.js';

const el = {
  locationPill: document.getElementById('locationPill'),
  sceneBgImg: document.getElementById('sceneBgImg'),
  characterSprite: document.getElementById('characterSprite'),
  affectionVal: document.getElementById('affectionVal'),
  anxietyVal: document.getElementById('anxietyVal'),
  affectionBar: document.getElementById('affectionBar'),
  anxietyBar: document.getElementById('anxietyBar'),
  engineModeLabel: document.getElementById('engineModeLabel'),
  moodBadge: document.getElementById('moodBadge'),
  statusMsg: document.getElementById('statusMsg'),
  vnText: document.getElementById('vnText'),
  vnChoices: document.getElementById('vnChoices'),
  sceneInput: document.getElementById('sceneInput'),
  sceneSendBtn: document.getElementById('sceneSendBtn'),
  moveSceneBtn: document.getElementById('moveSceneBtn'),
  charSelectBtn: document.getElementById('charSelectBtn'),
  charModal: document.getElementById('charModal'),
  charList: document.getElementById('charList'),
  closeCharBtn: document.getElementById('closeCharBtn'),
  speakerTag: document.querySelector('.speaker-tag'),
  chatPeerName: document.querySelector('.chat-peer strong'),
  locationModal: document.getElementById('locationModal'),
  locationList: document.getElementById('locationList'),
  closeLocationBtn: document.getElementById('closeLocationBtn'),
  swipeViewport: document.getElementById('swipeViewport'),
  swipeTrack: document.getElementById('swipeTrack'),
  goPhoneBtn: document.getElementById('goPhoneBtn'),
  exclusiveRoomBtn: document.getElementById('exclusiveRoomBtn'),
  exclusiveLivingBtn: document.getElementById('exclusiveLivingBtn'),
  goEncounterBtn: document.getElementById('goEncounterBtn'),
  pageEncounter: document.getElementById('pageEncounter'),
  phoneBadge: document.getElementById('phoneBadge'),
  phoneHome: document.getElementById('phoneHome'),
  phoneChatApp: document.getElementById('phoneChatApp'),
  openChatAppBtn: document.getElementById('openChatAppBtn'),
  chatAppDot: document.getElementById('chatAppDot'),
  backToHomeBtn: document.getElementById('backToHomeBtn'),
  homeHint: document.getElementById('homeHint'),
  chatBody: document.getElementById('chatBody'),
  typingBar: document.getElementById('typingBar'),
  chatIdlePill: document.getElementById('chatIdlePill'),
  msgInput: document.getElementById('msgInput'),
  sendBtn: document.getElementById('sendBtn'),
  endingOverlay: document.getElementById('endingOverlay'),
  endingTag: document.getElementById('endingTag'),
  endingTitle: document.getElementById('endingTitle'),
  endingDesc: document.getElementById('endingDesc'),
  endingRestartBtn: document.getElementById('endingRestartBtn'),
  endingCount: document.getElementById('endingCount'),
  endingList: document.getElementById('endingList'),
  dexBtn: document.getElementById('dexBtn'),
  dexModal: document.getElementById('dexModal'),
  closeDexBtn: document.getElementById('closeDexBtn'),
  resetBtn: document.getElementById('resetBtn'),
  settingsBtn: document.getElementById('settingsBtn'),
  settingsModal: document.getElementById('settingsModal'),
  closeSettingsBtn: document.getElementById('closeSettingsBtn'),
  saveSettingsBtn: document.getElementById('saveSettingsBtn'),
  modeSelect: document.getElementById('modeSelect'),
  llmFields: document.getElementById('llmFields'),
  apiBaseInput: document.getElementById('apiBaseInput'),
  modelInput: document.getElementById('modelInput'),
  apiKeyInput: document.getElementById('apiKeyInput'),
};

let config = loadConfig();
let unlockedEndings = loadUnlockedEndings();
let gameState = createInitialState();
let currentPage = 'encounter'; // 'phone' | 'encounter'
let unreadCount = 0;
let idleSeconds = 0;
let idleEscalations = 0;
let idleInterval = null;
let isBusy = false;

const clamp = (n, min, max) => Math.max(min, Math.min(max, n));
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const nowTimeStr = () => new Date().toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: false });

function setPage(page) {
  currentPage = page;
  const showPhone = page === 'phone';
  el.swipeTrack.classList.toggle('show-phone', showPhone);
  el.goPhoneBtn.classList.toggle('hidden', showPhone);
  el.exclusiveRoomBtn.classList.toggle('hidden', showPhone);
  el.exclusiveLivingBtn.classList.toggle('hidden', showPhone);
  el.goEncounterBtn.classList.toggle('hidden', !showPhone);

  if (showPhone && !el.phoneChatApp.classList.contains('hidden')) {
    unreadCount = 0;
    updateHUD();
  }
}

function applyBackdrop(bgImage, bgCss) {
  if (bgImage) {
    el.sceneBgImg.classList.remove('hidden');
    el.sceneBgImg.src = bgImage;
    el.pageEncounter.style.background = '#0c0812';
  } else {
    el.sceneBgImg.classList.add('hidden');
    el.pageEncounter.style.background = bgCss || '#0c0812';
  }
}

function renderScene(locationId, showIntro = true) {
  const scene = SCENES[locationId] || SCENES.seongsu;
  gameState.locationId = scene.id;
  gameState.exclusiveSpaceId = null;
  el.locationPill.textContent = scene.label;
  applyBackdrop(scene.bgImage, scene.bgCss);
  if (showIntro) el.vnText.textContent = scene.intro;

  el.vnChoices.innerHTML = '';
  scene.choices.forEach((c) => {
    const btn = document.createElement('button');
    btn.className = 'choice-btn';
    btn.dataset.action = c.action;
    btn.textContent = c.label;
    el.vnChoices.appendChild(btn);
  });
  updateHUD();
}

function toggleExclusiveSpace(spaceId = 'room') {
  const char = CHARACTERS[gameState.characterId] || CHARACTERS.harin;
  const space = char.exclusiveSpaces?.find((s) => s.id === spaceId) || char.exclusiveRoom;
  if (!space) return;
  if (gameState.exclusiveSpaceId === space.id) {
    renderScene(gameState.locationId, true);
    return;
  }
  gameState.exclusiveSpaceId = space.id;
  const prefix = space.id === 'living' ? '🛋️' : '🏠';
  el.locationPill.textContent = `${prefix} ${space.title}`;
  applyBackdrop(space.bgImage, space.bgCss);
  el.vnText.textContent = space.intro;
  setPage('encounter');
  updateHUD();
}

function renderLocationModal() {
  const char = CHARACTERS[gameState.characterId] || CHARACTERS.harin;
  el.locationList.innerHTML = '';
  (char.exclusiveSpaces || []).forEach((space) => {
    const btn = document.createElement('button');
    const active = gameState.exclusiveSpaceId === space.id;
    btn.className = `ending-slot${active ? ' unlocked' : ''}`;
    btn.textContent = `${space.buttonLabel} · ${space.title}${active ? ' (현재 위치)' : ''}`;
    btn.addEventListener('click', () => {
      gameState.exclusiveSpaceId = null;
      toggleExclusiveSpace(space.id);
      el.locationModal.classList.add('hidden');
    });
    el.locationList.appendChild(btn);
  });
  Object.values(SCENES).forEach((scene) => {
    const btn = document.createElement('button');
    const active = !gameState.exclusiveSpaceId && scene.id === gameState.locationId;
    btn.className = `ending-slot${active ? ' unlocked' : ''}`;
    btn.textContent = `${scene.label}${active ? ' (현재 위치)' : ''}`;
    btn.addEventListener('click', () => {
      renderScene(scene.id, true);
      el.locationModal.classList.add('hidden');
    });
    el.locationList.appendChild(btn);
  });
}

function renderEndingDex() {
  el.endingCount.textContent = unlockedEndings.size;
  el.endingList.querySelectorAll('.ending-slot').forEach((slot) => {
    const id = slot.dataset.id;
    if (unlockedEndings.has(id)) {
      slot.classList.add('unlocked');
      slot.textContent = ENDINGS[id].slotLabel;
    }
  });
}

function updateHUD() {
  el.affectionVal.textContent = gameState.affection;
  el.anxietyVal.textContent = gameState.anxiety;
  el.affectionBar.style.width = `${gameState.affection}%`;
  el.anxietyBar.style.width = `${gameState.anxiety}%`;

  const char = CHARACTERS[gameState.characterId] || CHARACTERS.harin;
  const mood = getMoodState(
    gameState.affection,
    gameState.anxiety,
    char,
    gameState.exclusiveSpaceId,
    gameState.locationId
  );
  el.moodBadge.textContent = mood.badge;
  el.speakerTag.textContent = char.name;
  el.chatPeerName.textContent = char.name;
  const roomSpace = char.exclusiveSpaces?.find((s) => s.id === 'room');
  const livingSpace = char.exclusiveSpaces?.find((s) => s.id === 'living');
  el.exclusiveRoomBtn.textContent = gameState.exclusiveSpaceId === 'room'
    ? '📍 서울로 나가기'
    : roomSpace?.buttonLabel || '🏠 방';
  el.exclusiveLivingBtn.textContent = gameState.exclusiveSpaceId === 'living'
    ? '📍 서울로 나가기'
    : livingSpace?.buttonLabel || '🛋️ 거실';
  el.exclusiveRoomBtn.classList.toggle('active', gameState.exclusiveSpaceId === 'room');
  el.exclusiveLivingBtn.classList.toggle('active', gameState.exclusiveSpaceId === 'living');
  if (el.characterSprite.getAttribute('src') !== mood.sprite) {
    el.characterSprite.src = mood.sprite;
  }
  el.statusMsg.textContent = gameState.statusOverride || mood.status;
  el.engineModeLabel.textContent = config.mode === 'llm' ? 'AI' : '로컬';

  const hasUnread = unreadCount > 0;
  el.phoneBadge.classList.toggle('hidden', !hasUnread);
  el.chatAppDot.classList.toggle('hidden', !hasUnread);
  el.phoneBadge.textContent = unreadCount;
  el.chatAppDot.textContent = unreadCount;
}

function applyDeltas(res) {
  gameState.affection = clamp(gameState.affection + res.affectionDelta, 0, 100);
  gameState.anxiety = clamp(gameState.anxiety + res.anxietyDelta, 0, 100);
  if (res.statusOverride) gameState.statusOverride = res.statusOverride;
  updateHUD();

  const ending = checkEnding(gameState);
  if (ending) {
    gameState.ended = true;
    clearInterval(idleInterval);
    unlockedEndings = saveUnlockedEnding(ending.id);
    renderEndingDex();
    setTimeout(() => {
      el.endingTag.textContent = ending.tag;
      el.endingTitle.textContent = ending.title;
      el.endingDesc.textContent = ending.desc;
      el.endingOverlay.classList.remove('hidden');
    }, 550);
  }
}

async function handleSceneAction(rawInput, displayLabel = null) {
  if (isBusy || gameState.ended) return;
  const text = rawInput.trim();
  if (!text) return;

  el.sceneInput.value = '';
  isBusy = true;
  gameState.turn += 1;
  idleSeconds = 0;
  gameState.history.push({ role: 'user', content: `[만남] ${displayLabel || text}` });

  try {
    let res;
    if (config.mode === 'llm') {
      el.vnText.textContent = '...';
      const llmRes = await runLlmEngine('scene', gameState.history, gameState, config);
      res = {
        dialogue: llmRes.messages.join(' '),
        affectionDelta: llmRes.affectionDelta,
        anxietyDelta: llmRes.anxietyDelta,
        statusOverride: llmRes.statusOverride,
      };
    } else {
      res = runLocalSceneEngine(text, gameState);
    }
    el.vnText.textContent = res.dialogue;
    gameState.history.push({ role: 'assistant', content: res.dialogue });
    applyDeltas(res);
  } catch {
    const fallback = runLocalSceneEngine(text, gameState);
    el.vnText.textContent = `${fallback.dialogue} (AI 연결 실패 → 로컬 응답)`;
    applyDeltas(fallback);
  } finally {
    isBusy = false;
  }
}

function appendChatMessage(role, text, showRead = false) {
  const row = document.createElement('div');
  row.className = `msg-row ${role}`;
  const wrap = document.createElement('div');
  wrap.className = 'bubble-wrap';
  const bubble = document.createElement('div');
  bubble.className = 'bubble';
  bubble.textContent = text;
  wrap.appendChild(bubble);

  if (role !== 'system') {
    const meta = document.createElement('div');
    meta.className = 'msg-meta';
    if (role === 'user' && showRead) {
      const read = document.createElement('span');
      read.className = 'read-mark';
      read.textContent = '1';
      meta.appendChild(read);
    }
    const time = document.createElement('span');
    time.textContent = nowTimeStr();
    meta.appendChild(time);
    wrap.appendChild(meta);
  }

  row.appendChild(wrap);
  el.chatBody.appendChild(row);
  el.chatBody.scrollTop = el.chatBody.scrollHeight;
}

async function deliverChatMessages(messages) {
  const isChatVisible = currentPage === 'phone' && !el.phoneChatApp.classList.contains('hidden');
  if (isChatVisible) el.typingBar.classList.remove('hidden');
  el.chatBody.querySelectorAll('.read-mark').forEach((n) => n.remove());

  for (const msg of messages) {
    await wait(450 + Math.min(msg.length * 20, 750));
    appendChatMessage('bot', msg);
    gameState.history.push({ role: 'assistant', content: `[카톡] ${msg}` });
    if (!isChatVisible) {
      unreadCount += 1;
      updateHUD();
    }
  }
  el.typingBar.classList.add('hidden');
}

async function handleChatSend(textOverride = null) {
  if (isBusy || gameState.ended) return;
  const text = (textOverride ?? el.msgInput.value).trim();
  if (!text) return;

  el.msgInput.value = '';
  idleSeconds = 0;
  isBusy = true;
  el.sendBtn.disabled = true;

  appendChatMessage('user', text, true);
  gameState.history.push({ role: 'user', content: `[카톡] ${text}` });
  gameState.turn += 1;

  try {
    const res =
      config.mode === 'llm'
        ? await runLlmEngine('chat', gameState.history, gameState, config)
        : runLocalChatEngine(text, gameState);
    await deliverChatMessages(res.messages);
    applyDeltas(res);
  } catch (err) {
    appendChatMessage('system', `⚠️ ${err.message} (로컬 시뮬레이터로 응답)`);
    const fallback = runLocalChatEngine(text, gameState);
    await deliverChatMessages(fallback.messages);
    applyDeltas(fallback);
  } finally {
    isBusy = false;
    el.sendBtn.disabled = false;
    el.msgInput.focus();
  }
}

function startIdleTimer() {
  clearInterval(idleInterval);
  idleSeconds = 0;
  idleEscalations = 0;

  idleInterval = setInterval(async () => {
    if (gameState.ended || isBusy) return;
    idleSeconds += 1;
    const remain = 22 - idleSeconds;
    el.chatIdlePill.textContent = remain > 0 ? `온라인 · 방치 ${remain}s` : '읽씹 감지!';

    if (idleSeconds >= 22) {
      idleSeconds = 0;
      const warn = getIdleWarning(idleEscalations);
      idleEscalations += 1;
      isBusy = true;
      await deliverChatMessages(warn.messages);
      applyDeltas(warn);
      isBusy = false;
    }
  }, 1000);
}

/* Swipe Gesture (Touch + Mouse Drag) */
let dragStartX = null;
function onPointerStart(x) {
  dragStartX = x;
}
function onPointerEnd(x) {
  if (dragStartX === null) return;
  const dx = x - dragStartX;
  dragStartX = null;
  if (dx > 50 && currentPage === 'encounter') setPage('phone');
  else if (dx < -50 && currentPage === 'phone') setPage('encounter');
}

el.swipeViewport.addEventListener('touchstart', (e) => onPointerStart(e.touches[0].clientX), { passive: true });
el.swipeViewport.addEventListener('touchend', (e) => onPointerEnd(e.changedTouches[0].clientX));
el.swipeViewport.addEventListener('mousedown', (e) => {
  if (['INPUT', 'BUTTON'].includes(e.target.tagName)) return;
  onPointerStart(e.clientX);
});
window.addEventListener('mouseup', (e) => onPointerEnd(e.clientX));

function renderCharModal() {
  el.charList.innerHTML = '';
  Object.values(CHARACTERS).forEach((ch) => {
    const btn = document.createElement('button');
    btn.className = `ending-slot${ch.id === gameState.characterId ? ' unlocked' : ''}`;
    btn.innerHTML = `
      <strong>${ch.name} (${ch.age}세)</strong> · ${ch.role}<br>
      <small style="color:#ffd1e8">${ch.archetype}</small><br>
      <small style="color:#a596ba">${ch.summary}</small><br>
      <small style="color:#b794f4">💬 ${ch.speechStyle}</small>
    `;
    btn.addEventListener('click', () => {
      el.charModal.classList.add('hidden');
      startNewGame(ch.id);
    });
    el.charList.appendChild(btn);
  });
}

function preloadCharacterSprites(char) {
  Object.values(char?.sprites || {}).forEach((src) => {
    const img = new Image();
    img.src = src;
  });
}

async function startNewGame(characterId = gameState.characterId || 'harin') {
  const char = CHARACTERS[characterId] || CHARACTERS.harin;
  preloadCharacterSprites(char);
  gameState = createInitialState(char.id);
  unreadCount = 0;
  setPage('encounter');
  el.endingOverlay.classList.add('hidden');
  el.chatBody.innerHTML = '<div class="date-divider">오늘 · 23:42</div>';
  renderScene('seongsu', false);
  el.vnText.textContent = char.intro;
  updateHUD();
  startIdleTimer();

  isBusy = true;
  await deliverChatMessages(['야', '앞에 있는데도 톡 하나 남겨둘게... 나 혼자 두지 마 🖤']);
  isBusy = false;
}

el.vnChoices.addEventListener('click', (e) => {
  const btn = e.target.closest('.choice-btn');
  if (btn) handleSceneAction(`__action:${btn.dataset.action}`, btn.textContent.trim());
});
el.sceneSendBtn.addEventListener('click', () => handleSceneAction(el.sceneInput.value));
el.sceneInput.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' && !e.isComposing) handleSceneAction(el.sceneInput.value);
});

el.goPhoneBtn.addEventListener('click', () => setPage('phone'));
el.exclusiveRoomBtn.addEventListener('click', () => toggleExclusiveSpace('room'));
el.exclusiveLivingBtn.addEventListener('click', () => toggleExclusiveSpace('living'));
el.goEncounterBtn.addEventListener('click', () => setPage('encounter'));

el.moveSceneBtn.addEventListener('click', () => {
  renderLocationModal();
  el.locationModal.classList.remove('hidden');
});
el.charSelectBtn.addEventListener('click', () => {
  renderCharModal();
  el.charModal.classList.remove('hidden');
});
el.closeCharBtn.addEventListener('click', () => el.charModal.classList.add('hidden'));
el.closeLocationBtn.addEventListener('click', () => el.locationModal.classList.add('hidden'));

el.openChatAppBtn.addEventListener('click', () => {
  el.phoneHome.classList.add('hidden');
  el.phoneChatApp.classList.remove('hidden');
  unreadCount = 0;
  updateHUD();
  el.chatBody.scrollTop = el.chatBody.scrollHeight;
});
el.backToHomeBtn.addEventListener('click', () => {
  el.phoneChatApp.classList.add('hidden');
  el.phoneHome.classList.remove('hidden');
});

document.querySelectorAll('.locked-app').forEach((btn) => {
  btn.addEventListener('click', () => {
    el.homeHint.innerHTML = `🔒 <strong>${btn.dataset.app}</strong> 앱은 추후 업데이트로 추가될 예정입니다!`;
  });
});

el.sendBtn.addEventListener('click', () => handleChatSend());
el.msgInput.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' && !e.isComposing) handleChatSend();
});
document.getElementById('quickChips').addEventListener('click', (e) => {
  const chip = e.target.closest('.chip');
  if (chip) handleChatSend(chip.dataset.text);
});

el.resetBtn.addEventListener('click', startNewGame);
el.endingRestartBtn.addEventListener('click', startNewGame);
el.dexBtn.addEventListener('click', () => el.dexModal.classList.remove('hidden'));
el.closeDexBtn.addEventListener('click', () => el.dexModal.classList.add('hidden'));

el.settingsBtn.addEventListener('click', () => {
  el.modeSelect.value = config.mode;
  el.apiBaseInput.value = config.apiBase || '';
  el.modelInput.value = config.model || '';
  el.apiKeyInput.value = config.apiKey || '';
  el.llmFields.classList.toggle('hidden', config.mode !== 'llm');
  el.settingsModal.classList.remove('hidden');
});
el.closeSettingsBtn.addEventListener('click', () => el.settingsModal.classList.add('hidden'));
el.modeSelect.addEventListener('change', () => {
  el.llmFields.classList.toggle('hidden', el.modeSelect.value !== 'llm');
});
document.querySelectorAll('.preset-btn').forEach((btn) => {
  btn.addEventListener('click', () => {
    const p = LLM_PRESETS[btn.dataset.preset];
    if (p) {
      el.apiBaseInput.value = p.apiBase;
      el.modelInput.value = p.model;
    }
  });
});
el.saveSettingsBtn.addEventListener('click', () => {
  config = {
    mode: el.modeSelect.value,
    apiBase: el.apiBaseInput.value.trim(),
    model: el.modelInput.value.trim(),
    apiKey: el.apiKeyInput.value.trim(),
  };
  saveConfig(config);
  el.settingsModal.classList.add('hidden');
  updateHUD();
});

// Preload active character sprites & public scenes cleanly
preloadCharacterSprites(CHARACTERS.harin);

renderEndingDex();
startNewGame();
