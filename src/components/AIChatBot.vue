<template>
  <div class="chatbot-container">
    <transition name="slide-up">
      <div v-if="open" class="chat-panel glass-card" role="dialog" aria-label="Chat de asistente ExchangePro" @keydown.escape="togglePanel">
        <div class="chat-header">
          <div class="chat-header-left">
            <q-icon name="smart_toy" size="22px" color="primary" aria-hidden="true" />
            <span class="chat-header-title" id="chat-title">Asistente ExchangePro</span>
          </div>
          <div class="chat-header-actions">
            <span class="chat-header-time">{{ formatTime(new Date()) }}</span>
            <q-btn flat dense round icon="close" size="sm" color="grey" aria-label="Cerrar chat" @click="togglePanel" />
          </div>
        </div>

        <div class="chat-messages" ref="messagesRef" role="log" aria-live="polite" aria-atomic="false" aria-relevant="additions">
          <div v-for="(msg, idx) in messages" :key="idx" class="message-wrapper" :class="{ user: msg.isUser, bot: !msg.isUser }" :style="{ animationDelay: '0s' }">
            <div class="message-meta">
              <span class="message-label">{{ msg.isUser ? 'Tú' : 'Asistente' }}</span>
              <span class="message-time">{{ formatTime(msg.timestamp) }}</span>
            </div>
            <div class="message-bubble" :class="{ user: msg.isUser, bot: !msg.isUser }" v-html="formatText(msg.text)">
            </div>
          </div>
          <div v-if="loading" class="message-wrapper bot" aria-hidden="true">
            <div class="message-meta">
              <span class="message-label">Asistente</span>
            </div>
            <div class="message-bubble bot typing-indicator">
              <span class="dot"></span>
              <span class="dot"></span>
              <span class="dot"></span>
            </div>
          </div>
        </div>

        <div class="chat-input-area">
          <q-input
            v-model="newMessage"
            placeholder="Escribe un mensaje…"
            label="Mensaje"
            dark
            dense
            outlined
            class="chat-input"
            maxlength="500"
            @keyup.enter="sendMessage"
            @keydown.escape="togglePanel"
            :aria-label="'Escribe tu mensaje'"
          />
          <q-btn
            flat
            round
            color="primary"
            icon="send"
            aria-label="Enviar mensaje"
            :disable="!newMessage.trim() || loading"
            @click="sendMessage"
          />
        </div>
      </div>
    </transition>

    <q-btn
      class="fab-button"
      :class="{ pulse: !open, 'has-unread': unreadCount > 0 && !open }"
      round
      :size="open ? 'md' : 'lg'"
      :icon="open ? 'close' : 'support_agent'"
      :aria-label="open ? 'Cerrar chat' : 'Abrir chat de asistente'"
      @click="togglePanel"
    >
      <q-badge v-if="unreadCount > 0 && !open" floating color="negative" rounded>{{ unreadCount }}</q-badge>
    </q-btn>
  </div>
</template>

<script setup>
import { ref, nextTick, watch } from 'vue'
import api from '@/services/api'

const open = ref(false)
const messages = ref([])
const newMessage = ref('')
const loading = ref(false)
const messagesRef = ref(null)
const unreadCount = ref(0)

watch(open, (val) => {
  if (val) unreadCount.value = 0
})

watch(messages, (val) => {
  if (!open.value && val.length > 0) {
    const last = val[val.length - 1]
    if (!last.isUser) unreadCount.value++
  }
}, { deep: true })

function togglePanel() {
  open.value = !open.value
  if (open.value && messages.value.length === 0) {
    addBotMessage('¡Hola! Soy el asistente virtual de ExchangePro. ¿En qué puedo ayudarte?')
  }
}

function addBotMessage(text) {
  messages.value.push({ text, isUser: false, timestamp: new Date() })
}

function formatTime(date) {
  if (!date) return ''
  return date.toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit' })
}

function formatText(text) {
  if (!text) return ''
  let html = text
    .replace(/\n/g, '<br>')
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/_(.+?)_/g, '<em>$1</em>')
    .replace(/• (.+?)(?:<br>|$)/g, '<span class="chat-list-item">• $1</span><br>')
  return html
}

async function sendMessage() {
  const text = newMessage.value.trim()
  if (!text || loading.value) return

  messages.value.push({ text, isUser: true, timestamp: new Date() })
  newMessage.value = ''
  loading.value = true
  scrollToBottom()

  try {
    const { data } = await api.post('/api/Admin/chatbot', { mensaje: text })
    addBotMessage(data.respuesta || data.message || 'No pude procesar tu solicitud.')
  } catch {
    addBotMessage('Lo siento, ocurrió un error. Intenta de nuevo más tarde.')
  } finally {
    loading.value = false
    scrollToBottom()
  }
}

function scrollToBottom() {
  nextTick(() => {
    if (messagesRef.value) {
      messagesRef.value.scrollTo({ top: messagesRef.value.scrollHeight, behavior: 'smooth' })
    }
  })
}
</script>

<style scoped>
.chatbot-container {
  position: fixed;
  bottom: 24px;
  right: 24px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.fab-button {
  background: linear-gradient(135deg, var(--color-primary), var(--color-accent)) !important;
  box-shadow: 0 4px 20px rgba(124, 58, 237, 0.4);
  color: #fff;
  border-radius: 50%;
  transition: box-shadow 0.3s ease, transform 0.3s ease;
}

.fab-button:hover {
  transform: scale(1.05);
}

.fab-button.pulse {
  animation: pulse 2s infinite;
}

.fab-button.has-unread {
  animation: pulse-fast 1.5s infinite;
}

@media (prefers-reduced-motion: reduce) {
  .fab-button.pulse,
  .fab-button.has-unread {
    animation: none;
  }

  .dot {
    animation: none;
    opacity: 0.4;
  }

  .slide-up-enter-active,
  .slide-up-leave-active {
    transition: opacity 0.15s ease;
    transform: none;
  }

  .message-wrapper {
    animation: none !important;
  }
}

@keyframes pulse {
  0% { box-shadow: 0 4px 20px rgba(124, 58, 237, 0.4); }
  50% { box-shadow: 0 4px 30px rgba(124, 58, 237, 0.7); }
  100% { box-shadow: 0 4px 20px rgba(124, 58, 237, 0.4); }
}

@keyframes pulse-fast {
  0% { box-shadow: 0 4px 20px rgba(244, 63, 94, 0.4); }
  50% { box-shadow: 0 4px 30px rgba(244, 63, 94, 0.7); }
  100% { box-shadow: 0 4px 20px rgba(244, 63, 94, 0.4); }
}

.chat-panel {
  position: fixed;
  bottom: 90px;
  right: 24px;
  width: 350px;
  max-height: 500px;
  border-radius: 20px;
  z-index: 9998;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 16px 12px;
  border-bottom: 1px solid var(--glass-border);
}

.chat-header-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.chat-header-title {
  font-family: var(--font-body);
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--color-text);
}

.chat-header-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.chat-header-time {
  font-family: var(--font-mono);
  font-size: 0.65rem;
  color: var(--color-text-muted);
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.message-wrapper {
  display: flex;
  flex-direction: column;
  max-width: 80%;
  animation: message-in 0.25s ease both;
}

@keyframes message-in {
  from { opacity: 0; transform: translateY(8px) scale(0.97); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.message-wrapper.user {
  align-self: flex-end;
  align-items: flex-end;
}

.message-wrapper.bot {
  align-self: flex-start;
  align-items: flex-start;
}

.message-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.message-label {
  font-size: 0.7rem;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.message-time {
  font-family: var(--font-mono);
  font-size: 0.6rem;
  color: var(--color-text-muted);
  opacity: 0.7;
}

.message-bubble {
  padding: 10px 14px;
  font-family: var(--font-body);
  font-size: 0.88rem;
  line-height: 1.5;
  color: var(--color-text);
}

.message-bubble.user {
  background: var(--color-primary);
  border-radius: 16px 16px 4px 16px;
}

.message-bubble.bot {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--glass-border);
  border-radius: 16px 16px 16px 4px;
}

.typing-indicator {
  display: flex;
  gap: 4px;
  align-items: center;
  padding: 12px 16px;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-text-muted);
  animation: typing 1.4s infinite ease-in-out;
}

.dot:nth-child(2) { animation-delay: 0.2s; }
.dot:nth-child(3) { animation-delay: 0.4s; }

@keyframes typing {
  0%, 60%, 100% { opacity: 0.3; transform: scale(0.8); }
  30% { opacity: 1; transform: scale(1); }
}

.chat-input-area {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border-top: 1px solid var(--glass-border);
}

.chat-input {
  flex: 1;
}

.chat-input :deep(.q-field__control) {
  border-radius: 12px;
}

.chat-list-item {
  display: block;
  padding: 2px 0;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  opacity: 0;
  transform: translateY(20px);
}

@media (max-width: 480px) {
  .chat-panel {
    right: 12px;
    width: calc(100% - 24px);
    max-height: 60vh;
    bottom: 80px;
  }

  .fab-button {
    bottom: 16px;
    right: 16px;
  }

  .chatbot-container {
    bottom: 16px;
    right: 16px;
  }
}
</style>
