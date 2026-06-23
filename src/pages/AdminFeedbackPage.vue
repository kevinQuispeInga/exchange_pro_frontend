<template>
  <q-page class="admin-feedback">
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title font-display text-gradient">Buzón de Feedback</h1>
        <p class="page-subtitle"
          >Revisa y responde las sugerencias y reportes de error de los
          usuarios</p
        >
      </div>
      <q-btn
        flat
        dense
        icon="refresh"
        class="refresh-btn"
        @click="cargarFeedback"
        :loading="loading"
      >
        <q-tooltip>Actualizar buzón</q-tooltip>
      </q-btn>
    </div>

    <!-- Stats Grid -->
    <div class="stats-row row q-col-gutter-md q-mb-xl">
      <div
        class="col-12 col-sm-6 col-md-3"
        v-for="s in feedbackStats"
        :key="s.label"
      >
        <div
          class="stat-card glass-card relative-position overflow-hidden"
          :style="{ '--glow-color': s.glow }"
        >
          <div class="stat-card-glow"></div>
          <div class="row items-center justify-between no-wrap">
            <div>
              <div class="stat-value mono">{{ s.value }}</div>
              <div class="stat-label">{{ s.label }}</div>
            </div>
            <div
              class="stat-icon-wrapper"
              :style="{ background: s.bg, color: s.color }"
            >
              <q-icon :name="s.icon" size="24px" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Controls Bar -->
    <div
      class="controls-bar row items-center justify-between q-col-gutter-sm q-mb-lg"
    >
      <!-- Search & Filters Left -->
      <div class="col-12 col-md-6 row items-center q-col-gutter-sm">
        <div class="col">
          <q-input
            v-model="searchQuery"
            placeholder="Buscar por título, contenido o usuario..."
            dense
            outlined
            dark
            clearable
            class="search-input"
          >
            <template v-slot:prepend>
              <q-icon name="search" color="grey-5" />
            </template>
          </q-input>
        </div>
      </div>

      <!-- Filters Right -->
      <div class="col-12 col-md-6 flex justify-end gap-sm items-center">
        <!-- Quick State Filter -->
        <q-btn-toggle
          v-model="statusFilter"
          toggle-color="primary"
          flat
          dark
          dense
          no-caps
          class="custom-toggle"
          :options="[
            { label: 'Todos', value: 'todos' },
            { label: 'Pendientes', value: 'PENDIENTE' },
            { label: 'Revisados', value: 'REVISADO' }
          ]"
        />

        <!-- Type Pills -->
        <div class="filter-tabs">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            class="filter-pill"
            :class="{ active: filter === tab.key }"
            @click="filter = tab.key"
          >
            {{ tab.label }}
          </button>
        </div>
      </div>
    </div>

    <div
      v-if="feedbackError"
      class="feedback-error glass-card q-pa-md q-mb-lg row items-center gap-sm"
    >
      <q-icon name="error" color="negative" />
      <div>
        <div class="text-white font-weight-bold">Error cargando feedback</div>
        <div class="text-muted">{{ feedbackError }}</div>
      </div>
    </div>

    <!-- Feedback Feed (Stunning alternative to standard table) -->
    <div v-if="loading" class="flex flex-center q-py-xl">
      <q-spinner-grid color="primary" size="48px" />
    </div>

    <div
      v-else-if="filteredFeedback.length === 0"
      class="empty-state glass-card q-py-xl text-center"
    >
      <q-icon name="inbox" size="64px" color="grey-6" class="q-mb-md" />
      <h3 class="empty-title font-display">Bandeja de entrada vacía</h3>
      <p class="empty-desc"
        >No se encontraron comentarios que coincidan con los filtros
        seleccionados.</p
      >
    </div>

    <div v-else class="feedback-feed">
      <div
        v-for="item in filteredFeedback"
        :key="item.idFeedback"
        class="feedback-card glass-card"
        :class="{
          'card-revisado': item.estado === 'REVISADO',
          expanded: expandedCard === item.idFeedback
        }"
      >
        <div
          class="card-header row items-start no-wrap justify-between"
          @click="toggleExpand(item.idFeedback)"
        >
          <div class="row items-center no-wrap gap-md">
            <!-- User Avatar / Initials with gradient -->
            <div class="avatar-gradient">
              {{ getInitials(item.usuarioNombre) }}
            </div>
            <div>
              <div class="row items-center gap-sm q-mb-xs">
                <q-badge
                  :color="item.tipo === 'BUG_REPORT' ? 'negative' : 'primary'"
                  class="type-badge text-uppercase"
                  rounded
                >
                  {{ item.tipo === 'BUG_REPORT' ? 'Bug' : 'Sugerencia' }}
                </q-badge>
                <q-badge
                  :color="item.estado === 'REVISADO' ? 'positive' : 'warning'"
                  class="status-badge"
                  rounded
                >
                  {{ item.estado === 'REVISADO' ? 'Revisado' : 'Pendiente' }}
                </q-badge>
                <span class="card-date">{{
                  formatDate(item.fechaCreacion)
                }}</span>
              </div>
              <h4 class="card-subject font-display">{{ item.titulo }}</h4>
              <div class="card-author">
                Por:
                <span class="text-white font-weight-bold">{{
                  item.usuarioNombre
                }}</span>
                <span class="text-muted q-ml-sm"
                  >({{ item.usuarioEmail }})</span
                >
              </div>
            </div>
          </div>

          <div class="row items-center gap-sm">
            <q-btn
              v-if="item.estado === 'PENDIENTE'"
              color="primary"
              unelevated
              no-caps
              label="Responder"
              size="sm"
              class="respond-btn"
              @click.stop="abrirResponder(item)"
            />
            <q-icon
              :name="
                expandedCard === item.idFeedback ? 'expand_less' : 'expand_more'
              "
              size="24px"
              color="grey-4"
              class="cursor-pointer"
            />
          </div>
        </div>

        <!-- Collapsible Content -->
        <q-slide-transition>
          <div
            v-show="expandedCard === item.idFeedback"
            class="card-expanded-content"
          >
            <div class="feedback-desc-section">
              <div class="content-label">Comentario del Usuario:</div>
              <p class="feedback-desc-text">{{ item.descripcion }}</p>
            </div>

            <!-- Admin Response Section (if exists) -->
            <div v-if="item.estado === 'REVISADO'" class="admin-response-box">
              <div class="row items-center gap-xs q-mb-sm text-positive">
                <q-icon name="check_circle" size="18px" />
                <span class="response-title">Respuesta del Administrador:</span>
              </div>
              <p class="response-text">{{
                item.respuestaAdmin || 'Revisado sin comentarios.'
              }}</p>
            </div>
          </div>
        </q-slide-transition>
      </div>
    </div>

    <!-- Responder Dialog -->
    <q-dialog v-model="responderDialog" persistent backdrop-filter="blur(8px)">
      <q-card class="dialog-card glass-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="feedback" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Responder Comentario</h2>
        </div>

        <q-card-section class="q-px-lg q-pt-lg">
          <div class="info-bubble q-mb-lg">
            <div class="row items-center gap-xs q-mb-xs">
              <q-badge
                :color="
                  feedbackActual?.tipo === 'BUG_REPORT' ? 'negative' : 'primary'
                "
              >
                {{
                  feedbackActual?.tipo === 'BUG_REPORT' ? 'BUG' : 'SUGERENCIA'
                }}
              </q-badge>
              <span class="info-author text-muted"
                >de {{ feedbackActual?.usuarioNombre }}</span
              >
            </div>
            <div class="info-title text-white font-weight-bold">{{
              feedbackActual?.titulo
            }}</div>
            <p class="info-desc text-muted q-mt-sm">{{
              feedbackActual?.descripcion
            }}</p>
          </div>

          <div class="field-group q-mb-md">
            <label class="field-label">Tu Respuesta</label>
            <q-input
              v-model="respuesta"
              type="textarea"
              outlined
              dense
              dark
              placeholder="Escribe un mensaje de agradecimiento o resolución..."
              class="dialog-input dialog-textarea"
              maxlength="500"
              :rules="[val => !!val || 'La respuesta es requerida']"
              hide-bottom-space
            />
          </div>

          <div class="dialog-actions q-mt-lg">
            <q-btn
              label="Cancelar"
              flat
              no-caps
              class="btn-cancel"
              v-close-popup
            />
            <q-btn
              label="Enviar Respuesta"
              color="primary"
              unelevated
              no-caps
              :loading="enviando"
              class="btn-submit"
              @click="enviarRespuesta"
            />
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useQuasar } from 'quasar'
import feedbackService from '@/services/feedbackService'

const $q = useQuasar()
const loading = ref(false)
const allFeedback = ref([])
const filter = ref('todos')
const statusFilter = ref('todos')
const searchQuery = ref('')
const responderDialog = ref(false)
const feedbackActual = ref(null)
const respuesta = ref('')
const enviando = ref(false)
const expandedCard = ref(null)
const feedbackError = ref('')

const tabs = [
  { key: 'todos', label: 'Todos' },
  { key: 'RECOMENDACION', label: 'Sugerencias' },
  { key: 'BUG_REPORT', label: 'Bugs' }
]

const toggleExpand = id => {
  if (expandedCard.value === id) {
    expandedCard.value = null
  } else {
    expandedCard.value = id
  }
}

const getInitials = name => {
  if (!name) return 'U'
  return name
    .split(' ')
    .map(n => n[0])
    .slice(0, 2)
    .join('')
    .toUpperCase()
}

const filteredFeedback = computed(() => {
  return allFeedback.value.filter(f => {
    // 1. Tipo Filter
    const matchesType = filter.value === 'todos' || f.tipo === filter.value

    // 2. Estado Filter
    const matchesStatus =
      statusFilter.value === 'todos' || f.estado === statusFilter.value

    // 3. Search Query Filter
    const query = searchQuery.value?.toLowerCase() || ''
    const matchesSearch =
      !query ||
      f.titulo?.toLowerCase().includes(query) ||
      f.descripcion?.toLowerCase().includes(query) ||
      f.usuarioNombre?.toLowerCase().includes(query) ||
      f.usuarioEmail?.toLowerCase().includes(query)

    return matchesType && matchesStatus && matchesSearch
  })
})

const feedbackStats = computed(() => {
  const total = allFeedback.value.length
  const pendientes = allFeedback.value.filter(
    f => f.estado !== 'REVISADO'
  ).length
  const recomendaciones = allFeedback.value.filter(
    f => f.tipo === 'RECOMENDACION'
  ).length
  const bugs = allFeedback.value.filter(f => f.tipo === 'BUG_REPORT').length
  return [
    {
      label: 'Total Recibido',
      value: total,
      icon: 'mark_email_unread',
      bg: 'rgba(124, 58, 237, 0.15)',
      color: '#7c3aed',
      glow: 'rgba(124, 58, 237, 0.3)'
    },
    {
      label: 'Por Revisar',
      value: pendientes,
      icon: 'pending_actions',
      bg: 'rgba(245, 158, 11, 0.15)',
      color: '#f59e0b',
      glow: 'rgba(245, 158, 11, 0.3)'
    },
    {
      label: 'Sugerencias',
      value: recomendaciones,
      icon: 'lightbulb',
      bg: 'rgba(59, 130, 246, 0.15)',
      color: '#3b82f6',
      glow: 'rgba(59, 130, 246, 0.3)'
    },
    {
      label: 'Bugs Reportados',
      value: bugs,
      icon: 'bug_report',
      bg: 'rgba(239, 68, 68, 0.15)',
      color: '#ef4848',
      glow: 'rgba(239, 68, 68, 0.3)'
    }
  ]
})

const formatDate = dateStr => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('es-PE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const abrirResponder = feedback => {
  feedbackActual.value = feedback
  respuesta.value = ''
  responderDialog.value = true
}

const enviarRespuesta = async () => {
  if (!respuesta.value) {
    $q.notify({
      type: 'warning',
      message: 'Escribe una respuesta antes de enviar',
      position: 'top'
    })
    return
  }

  enviando.value = true
  try {
    await feedbackService.respond(
      feedbackActual.value.idFeedback,
      respuesta.value
    )
    $q.notify({
      type: 'positive',
      message: 'Respuesta enviada correctamente',
      position: 'top'
    })
    responderDialog.value = false
    await cargarFeedback()
  } catch (err) {
    console.error('Error sending feedback response:', err.response?.data ?? err)
    const errorMessage =
      err.response?.data?.message ||
      err.response?.data?.error ||
      err.response?.statusText ||
      'Error al enviar la respuesta'
    $q.notify({
      type: 'negative',
      message: errorMessage,
      position: 'top'
    })
  } finally {
    enviando.value = false
  }
}

const cargarFeedback = async () => {
  loading.value = true
  try {
    const data = await feedbackService.getAll()
    allFeedback.value = Array.isArray(data) ? data : []
  } catch (err) {
    console.error('Error loading feedback:', err.response?.data ?? err)
    const responseData = err.response?.data
    const responseInfo = responseData
      ? typeof responseData === 'string'
        ? responseData
        : JSON.stringify(responseData)
      : ''
    const errorMessage =
      [
        `HTTP ${err.response?.status ?? ''}`,
        err.response?.statusText,
        responseInfo
      ]
        .filter(Boolean)
        .join(' - ') || 'Error al cargar feedback'
    feedbackError.value = errorMessage
    $q.notify({
      type: 'negative',
      message: errorMessage,
      position: 'top'
    })
  } finally {
    loading.value = false
  }
}

onMounted(cargarFeedback)
</script>

<style scoped>
.admin-feedback {
  padding: 32px 40px;
  max-width: 1300px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.page-title {
  font-size: 2rem;
  font-weight: 800;
  margin: 0 0 6px;
}

.page-subtitle {
  font-size: 0.95rem;
  color: var(--color-text-secondary);
  margin: 0;
}

.refresh-btn {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 12px;
  width: 44px;
  height: 44px;
  color: var(--color-text);
  transition: all 0.25s ease;
}

.refresh-btn:hover {
  background: rgba(124, 58, 237, 0.15);
  border-color: var(--color-primary);
  box-shadow: 0 0 15px rgba(124, 58, 237, 0.2);
}

/* Stat Cards */
.stat-card {
  padding: 24px;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  border-radius: 16px;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px -5px var(--glow-color, rgba(124, 58, 237, 0.15));
  border-color: var(--color-primary);
}

.stat-card-glow {
  position: absolute;
  top: -50%;
  right: -50%;
  width: 100%;
  height: 100%;
  background: radial-gradient(
    circle,
    var(--glow-color, rgba(124, 58, 237, 0.05)) 0%,
    transparent 70%
  );
  opacity: 0.5;
  pointer-events: none;
}

.stat-value {
  font-size: 2.2rem;
  font-weight: 800;
  line-height: 1.1;
  color: var(--color-text);
}

.stat-label {
  font-size: 0.82rem;
  color: var(--color-text-muted);
  font-weight: 500;
  margin-top: 6px;
  letter-spacing: 0.02em;
}

.stat-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Controls Bar */
.controls-bar {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 16px;
  padding: 16px 20px;
}

.search-input :deep(.q-field__control) {
  border-radius: 100px;
  background: rgba(255, 255, 255, 0.03);
}

.search-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 12px rgba(124, 58, 237, 0.15);
}

.custom-toggle {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid var(--glass-border);
  border-radius: 100px;
  padding: 2px;
}

.custom-toggle :deep(.q-btn) {
  border-radius: 100px;
  padding: 4px 16px;
  font-size: 0.82rem;
  font-weight: 500;
}

.filter-tabs {
  display: flex;
  gap: 6px;
}

.filter-pill {
  font-size: 0.82rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid var(--glass-border);
  border-radius: 100px;
  padding: 6px 16px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.filter-pill:hover {
  border-color: var(--color-primary);
  color: var(--color-text);
}

.filter-pill.active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: white;
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3);
}

/* Feedback Feed */
.feedback-feed {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.feedback-card {
  border-radius: 16px;
  padding: 20px 24px;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.2, 0.8, 0.2, 1);
}

.feedback-card:hover {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.03);
  transform: scale(1.005);
}

.feedback-card.expanded {
  border-color: rgba(124, 58, 237, 0.3);
  background: rgba(124, 58, 237, 0.02);
  box-shadow: 0 10px 30px -10px rgba(124, 58, 237, 0.1);
}

.card-header {
  outline: none;
}

.avatar-gradient {
  width: 46px;
  height: 46px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-primary) 0%, #3b82f6 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.95rem;
  color: white;
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.2);
  flex-shrink: 0;
}

.type-badge {
  font-size: 0.68rem;
  font-weight: 700;
  padding: 3px 8px;
  letter-spacing: 0.04em;
}

.status-badge {
  font-size: 0.68rem;
  font-weight: 700;
  padding: 3px 8px;
}

.card-date {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.card-subject {
  font-size: 1.15rem;
  font-weight: 700;
  margin: 4px 0;
  color: white;
}

.card-author {
  font-size: 0.82rem;
  color: var(--color-text-muted);
}

.respond-btn {
  border-radius: 8px;
  font-weight: 600;
  padding: 6px 14px;
}

/* Expanded Content */
.card-expanded-content {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid var(--color-border);
}

.content-label {
  font-size: 0.78rem;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--color-text-secondary);
  letter-spacing: 0.04em;
  margin-bottom: 8px;
}

.feedback-desc-text {
  font-size: 0.95rem;
  line-height: 1.6;
  color: var(--color-text-secondary);
  white-space: pre-wrap;
  margin: 0;
}

.admin-response-box {
  margin-top: 20px;
  background: rgba(16, 185, 129, 0.05);
  border: 1px solid rgba(16, 185, 129, 0.2);
  border-radius: 12px;
  padding: 16px;
}

.response-title {
  font-weight: 600;
  font-size: 0.88rem;
}

.response-text {
  font-size: 0.92rem;
  line-height: 1.5;
  color: var(--color-text-secondary);
  margin: 0;
  white-space: pre-wrap;
}

/* Empty State */
.empty-state {
  border-radius: 16px;
}

.empty-title {
  font-size: 1.3rem;
  font-weight: 700;
  margin-bottom: 6px;
}

.empty-desc {
  font-size: 0.9rem;
  color: var(--color-text-muted);
  max-width: 400px;
  margin: 0 auto;
}

/* Dialog */
.dialog-card {
  min-width: 500px;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.dialog-card__header {
  background: linear-gradient(135deg, var(--color-primary) 0%, #4f46e5 100%);
  padding: 24px;
  text-align: center;
}

.dialog-card__brand {
  width: 52px;
  height: 52px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
}

.dialog-card__title {
  font-size: 1.25rem;
  font-weight: 800;
  color: white;
  margin: 0;
}

.info-bubble {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 16px;
}

.info-title {
  font-size: 1rem;
}

.info-desc {
  font-size: 0.9rem;
  line-height: 1.5;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.field-label {
  font-size: 0.78rem;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--color-text-secondary);
  letter-spacing: 0.04em;
}

.dialog-input :deep(.q-field__control) {
  border-radius: 12px;
}

.dialog-textarea :deep(.q-field__native) {
  min-height: 120px;
}

.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn-cancel {
  border-radius: 10px;
  font-weight: 500;
}

.btn-submit {
  border-radius: 10px;
  font-weight: 600;
  padding: 10px 24px;
}

.gap-sm {
  gap: 8px;
}
.gap-md {
  gap: 16px;
}
.gap-xs {
  gap: 4px;
}

@media (max-width: 768px) {
  .admin-feedback {
    padding: 24px 16px;
  }

  .dialog-card {
    min-width: auto;
    width: 100%;
  }

  .controls-bar {
    padding: 12px;
  }

  .controls-bar > div {
    justify-content: flex-start !important;
  }

  .filter-tabs {
    overflow-x: auto;
    white-space: nowrap;
    width: 100%;
    padding-bottom: 4px;
  }
}
</style>
