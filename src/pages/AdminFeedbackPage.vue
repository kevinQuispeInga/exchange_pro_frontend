<template>
  <q-page class="admin-feedback">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Feedback</h1>
        <p class="page-subtitle">Opiniones y reportes de usuarios</p>
      </div>
    </div>

    <div class="stats-row row q-col-gutter-sm q-mb-lg">
      <div class="col-6 col-sm-3" v-for="s in feedbackStats" :key="s.label">
        <div class="mini-stat glass-card">
          <div class="mini-stat-value mono" :style="{ color: s.color }">{{ s.value }}</div>
          <div class="mini-stat-label">{{ s.label }}</div>
        </div>
      </div>
    </div>

    <div class="filter-tabs q-mb-md">
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

    <div class="table-wrapper glass-card">
      <q-table
        :rows="filteredFeedback"
        :columns="columns"
        row-key="id"
        flat
        :loading="loading"
        :bordered="false"
        hide-pagination
        class="custom-table"
      >
        <template v-slot:body-cell-tipo="props">
          <q-td :props="props">
            <q-badge
              :color="props.row.tipo === 'BUG_REPORT' ? 'negative' : 'primary'"
              rounded
              class="tipo-badge"
            >
              {{ props.row.tipo === 'BUG_REPORT' ? 'BUG REPORT' : 'RECOMENDACION' }}
            </q-badge>
          </q-td>
        </template>

        <template v-slot:body-cell-fecha="props">
          <q-td :props="props">
            <span class="fecha-cell">{{ formatDate(props.row.fechaCreacion) }}</span>
          </q-td>
        </template>

        <template v-slot:body-cell-estado="props">
          <q-td :props="props">
            <q-badge
              :color="props.row.estado === 'REVISADO' ? 'positive' : 'warning'"
              rounded
              class="estado-badge"
            >
              {{ props.row.estado === 'REVISADO' ? 'REVISADO' : 'PENDIENTE' }}
            </q-badge>
          </q-td>
        </template>

        <template v-slot:body-cell-acciones="props">
          <q-td :props="props">
            <q-btn
              flat
              dense
              icon="reply"
              size="sm"
              color="primary"
              class="action-btn"
              @click="abrirResponder(props.row)"
            >
              <q-tooltip>Responder</q-tooltip>
            </q-btn>
          </q-td>
        </template>

        <template v-slot:no-data>
          <div class="empty-state">
            <q-icon name="feedback" size="48px" color="text-muted" />
            <h3 class="empty-title">Sin feedback por revisar</h3>
            <p class="empty-desc">No hay elementos que coincidan con este filtro.</p>
          </div>
        </template>
      </q-table>
    </div>

    <q-dialog v-model="responderDialog" persistent>
      <q-card class="dialog-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="feedback" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Responder Feedback</h2>
        </div>

        <q-card-section class="q-px-lg q-pt-lg">
          <div class="field-group">
            <label class="field-label">Título</label>
            <div class="readonly-field">{{ feedbackActual?.titulo }}</div>
          </div>

          <div class="field-group">
            <label class="field-label">Descripción</label>
            <div class="readonly-field readonly-area">{{ feedbackActual?.descripcion }}</div>
          </div>

          <div class="field-group">
            <label class="field-label">Estado actual</label>
            <q-badge
              :color="feedbackActual?.estado === 'REVISADO' ? 'positive' : 'warning'"
              rounded
            >
              {{ feedbackActual?.estado === 'REVISADO' ? 'REVISADO' : 'PENDIENTE' }}
            </q-badge>
          </div>

          <div class="field-group">
            <label class="field-label">Respuesta del administrador</label>
            <q-input
              v-model="respuesta"
              type="textarea"
              outlined
              dense
              placeholder="Escribe tu respuesta..."
              class="dialog-input dialog-textarea"
              :rules="[val => !!val || 'La respuesta es requerida']"
              hide-bottom-space
            />
          </div>

          <div class="field-group">
            <q-checkbox
              v-model="marcarRevisado"
              label="Marcar como Revisado"
              color="positive"
              dense
              class="review-checkbox"
            />
          </div>

          <div class="dialog-actions">
            <q-btn
              label="Cancelar"
              flat
              no-caps
              class="btn-cancel"
              v-close-popup
            />
            <q-btn
              label="Enviar"
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
import api from '@/services/api'

const $q = useQuasar()
const loading = ref(false)
const allFeedback = ref([])
const filter = ref('todos')
const responderDialog = ref(false)
const feedbackActual = ref(null)
const respuesta = ref('')
const marcarRevisado = ref(true)
const enviando = ref(false)

const tabs = [
  { key: 'todos', label: 'Todos' },
  { key: 'RECOMENDACION', label: 'Recomendaciones' },
  { key: 'BUG_REPORT', label: 'Bug Reports' }
]

const columns = [
  { name: 'tipo', label: 'Tipo', field: 'tipo', align: 'left' },
  { name: 'titulo', label: 'Título', field: 'titulo', align: 'left' },
  { name: 'usuario', label: 'Usuario', field: row => row.usuario?.nombreUsuario || row.usuario?.email || row.usuario || '-', align: 'left' },
  { name: 'fecha', label: 'Fecha', field: 'fechaCreacion', align: 'left', sortable: true },
  { name: 'estado', label: 'Estado', field: 'estado', align: 'left' },
  { name: 'acciones', label: '', field: 'acciones', align: 'center' }
]

const filteredFeedback = computed(() => {
  if (filter.value === 'todos') return allFeedback.value
  return allFeedback.value.filter(f => f.tipo === filter.value)
})

const feedbackStats = computed(() => {
  const total = allFeedback.value.length
  const pendientes = allFeedback.value.filter(f => f.estado !== 'REVISADO').length
  const recomendaciones = allFeedback.value.filter(f => f.tipo === 'RECOMENDACION').length
  const bugs = allFeedback.value.filter(f => f.tipo === 'BUG_REPORT').length
  return [
    { label: 'Total', value: total, color: 'var(--color-text)' },
    { label: 'Pendientes', value: pendientes, color: 'var(--color-warning)' },
    { label: 'Recomendaciones', value: recomendaciones, color: 'var(--color-primary)' },
    { label: 'Bug Reports', value: bugs, color: 'var(--color-negative)' }
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
  marcarRevisado.value = feedback.estado !== 'REVISADO'
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
    await api.put(`/api/Feedback/${feedbackActual.value.id}/responder`, {
      respuesta: respuesta.value,
      marcarRevisado: marcarRevisado.value
    })
    $q.notify({
      type: 'positive',
      message: 'Respuesta enviada correctamente',
      position: 'top'
    })
    responderDialog.value = false
    await cargarFeedback()
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al enviar la respuesta',
      position: 'top'
    })
  } finally {
    enviando.value = false
  }
}

const cargarFeedback = async () => {
  loading.value = true
  try {
    const res = await api.get('/api/Feedback')
    allFeedback.value = Array.isArray(res.data) ? res.data : []
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al cargar feedback',
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
  padding: 28px 32px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 4px;
  color: var(--color-text);
}

.page-subtitle {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin: 0;
}

/* Mini stats */
.mini-stat {
  padding: 16px;
  text-align: center;
}

.mini-stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  line-height: 1.2;
}

.mini-stat-label {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
  margin-top: 4px;
}

.mono {
  font-family: var(--font-mono);
}

/* Filter tabs */
.filter-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-pill {
  font-family: var(--font-body);
  font-size: 0.82rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 100px;
  padding: 6px 18px;
  cursor: pointer;
  transition: background 0.2s ease, color 0.2s ease;
}

.filter-pill:hover {
  border-color: var(--color-primary);
  color: var(--color-text);
}

.filter-pill.active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: white;
}

/* Table wrapper */
.table-wrapper {
  overflow: hidden;
  border-radius: var(--radius-lg);
}

.custom-table :deep(.q-table) {
  font-family: var(--font-body);
}

.custom-table :deep(th) {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 14px 16px !important;
  background: var(--color-bg);
  border-bottom: 1px solid var(--color-border);
}

.custom-table :deep(td) {
  padding: 12px 16px !important;
  border-bottom: 1px solid var(--color-border);
  font-size: 0.88rem;
}

.custom-table :deep(.q-table tbody tr:hover) {
  background: rgba(124, 58, 237, 0.04);
}

.tipo-badge {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 4px 10px;
  letter-spacing: 0.03em;
}

.estado-badge {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 4px 10px;
}

.fecha-cell {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  color: var(--color-text-secondary);
}

.action-btn {
  border-radius: var(--radius-sm);
}

/* Empty state */
.empty-state {
  text-align: center;
  padding: 48px 24px;
}

.empty-title {
  font-family: var(--font-body);
  font-size: 1.15rem;
  font-weight: 600;
  margin: 12px 0 6px;
  color: var(--color-text);
}

.empty-desc {
  font-family: var(--font-body);
  font-size: 0.88rem;
  color: var(--color-text-secondary);
  margin: 0;
}

/* Dialog */
.dialog-card {
  min-width: 460px;
  border-radius: var(--radius-xl);
  overflow: hidden;
}

.dialog-card__header {
  background: var(--color-primary);
  padding: 24px;
  text-align: center;
}

.dialog-card__brand {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 10px;
}

.dialog-card__title {
  font-size: 1.1rem;
  font-weight: 700;
  color: white;
  margin: 0;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 16px;
}

.field-label {
  font-family: var(--font-body);
  font-size: 0.78rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.readonly-field {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text);
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: 10px 12px;
}

.readonly-area {
  min-height: 60px;
  line-height: 1.5;
}

.dialog-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  min-height: 44px;
}

.dialog-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

.dialog-textarea :deep(.q-field__native) {
  min-height: 100px;
}

.review-checkbox :deep(.q-checkbox__label) {
  font-family: var(--font-body);
  font-size: 0.88rem;
  color: var(--color-text);
}

.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding-top: 8px;
}

.btn-cancel {
  color: var(--color-text-secondary);
  font-weight: 500;
  border-radius: var(--radius-sm);
}

.btn-submit {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
}

@media (max-width: 768px) {
  .admin-feedback {
    padding: 20px 16px;
  }

  .dialog-card {
    min-width: auto;
  }
}
</style>
