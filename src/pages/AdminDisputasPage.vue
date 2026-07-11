<template>
  <q-page class="admin-disputas">
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title font-display text-gradient">Gestión de Disputas</h1>
        <p class="page-subtitle">Revisa y resuelve las disputas pendientes</p>
      </div>
      <q-badge color="accent" rounded class="pending-badge">
        {{ disputas.length }} pendientes
      </q-badge>
    </div>

    <!-- Controls Bar -->
    <div class="controls-bar row items-center justify-between q-col-gutter-sm q-mb-lg">
      <!-- Search Left -->
      <div class="col-12 col-md-6">
        <q-input
          v-model="searchQuery"
          placeholder="Buscar por ID de disputa, motivo, usuario..."
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

      <!-- Filter Right -->
      <div class="col-12 col-md-6 flex justify-end">
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
            { label: 'Pendientes', value: 'ABIERTA' },
            { label: 'Resueltas', value: 'RESUELTA' }
          ]"
        />
      </div>
    </div>

    <!-- Disputas Feed (Stunning alternative to standard table) -->
    <div v-if="loading" class="flex flex-center q-py-xl">
      <q-spinner-grid color="primary" size="48px" />
    </div>

    <div v-else-if="filteredDisputas.length === 0" class="empty-state glass-card q-py-xl text-center">
      <q-icon name="gavel" size="64px" color="grey-6" class="q-mb-md" />
      <h3 class="empty-title font-display">No hay disputas pendientes</h3>
      <p class="empty-desc">No se encontraron disputas que coincidan con los filtros seleccionados.</p>
    </div>

    <div v-else class="disputas-feed">
      <div
        v-for="item in filteredDisputas"
        :key="item.idDisputa"
        class="disputa-card glass-card"
        :class="{ 'card-resolved': item.estado === 'RESUELTA', 'expanded': expandedCard === item.idDisputa }"
      >
        <div class="card-header row items-start no-wrap justify-between" @click="toggleExpand(item.idDisputa)">
          <div class="row items-center no-wrap gap-md">
            <!-- Dispute ID with gradient -->
            <div class="dispute-id-gradient">
              #{{ item.idDisputa }}
            </div>
            <div>
              <div class="row items-center gap-sm q-mb-xs">
                <q-badge
                  :color="item.estado === 'RESUELTA' ? 'positive' : 'warning'"
                  class="status-badge"
                  rounded
                >
                  {{ item.estado === 'RESUELTA' ? 'Resuelta' : 'Pendiente' }}
                </q-badge>
                <span class="card-date">{{ formatDate(item.fechaCreacion) }}</span>
              </div>
              <h4 class="card-subject font-display">{{ item.motivo || 'Sin motivo especificado' }}</h4>
              <div class="card-meta">
                <span class="meta-item">
                  <q-icon name="receipt" size="14px" color="grey-5" class="q-mr-xs" />
                  Transacción: #{{ item.idTransaccion }}
                </span>
                <span class="meta-item">
                  <q-icon name="person" size="14px" color="grey-5" class="q-mr-xs" />
                  Reportado por: {{ item.usuarioReportaNombre }}
                </span>
              </div>
            </div>
          </div>

          <div class="row items-center gap-sm">
            <q-btn
              v-if="item.estado === 'ABIERTA'"
              color="primary"
              unelevated
              no-caps
              label="Resolver"
              size="sm"
              class="resolve-btn"
              @click.stop="abrirResolver(item)"
            />
            <q-icon
              :name="expandedCard === item.idDisputa ? 'expand_less' : 'expand_more'"
              size="24px"
              color="grey-4"
              class="cursor-pointer"
            />
          </div>
        </div>

        <!-- Collapsible Content -->
        <q-slide-transition>
          <div v-show="expandedCard === item.idDisputa" class="card-expanded-content">
            <div class="dispute-details-grid">
              <!-- Transaction Info -->
              <div class="detail-section">
                <div class="section-title">
                  <q-icon name="receipt" size="18px" color="primary" class="q-mr-xs" />
                  Detalles de Transacción
                </div>
                <div class="detail-item">
                  <span class="detail-label">Monto:</span>
                  <span class="detail-value">${{ item.transaccionMonto.toFixed(2) }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">Estado:</span>
                  <q-badge
                    :color="item.transaccionEstado === 'COMPLETADA' ? 'positive' : item.transaccionEstado === 'CANCELADA' ? 'negative' : 'warning'"
                    size="xs"
                    class="q-ml-xs"
                  >
                    {{ formatEstado(item.transaccionEstado) }}
                  </q-badge>
                </div>
                <div class="detail-item">
                  <span class="detail-label">Comprador:</span>
                  <span class="detail-value">{{ item.compradorNombre }}</span>
                </div>
                <div class="detail-item">
                  <span class="detail-label">Vendedor:</span>
                  <span class="detail-value">{{ item.vendedorNombre }}</span>
                </div>
              </div>

              <!-- Evidence Section -->
              <div class="detail-section">
                <div class="section-title">
                  <q-icon name="attach_file" size="18px" color="primary" class="q-mr-xs" />
                  Archivos de Evidencia ({{ item.evidencias.length }})
                </div>
                <div v-if="item.evidencias.length === 0" class="no-evidence">
                  <q-icon name="warning" size="20px" color="warning" class="q-mr-xs" />
                  <span>Sin evidencias subidas</span>
                </div>
                <div v-else class="evidence-list">
                  <div
                    v-for="(evidencia, index) in item.evidencias"
                    :key="index"
                    class="evidence-item"
                  >
                    <q-icon name="image" size="16px" color="primary" class="q-mr-xs" />
                    <a :href="evidencia" target="_blank" class="evidence-link">
                      {{ evidencia.split('/').pop() }}
                    </a>
                  </div>
                </div>
              </div>

              <!-- Description Section -->
              <div class="detail-section full-width">
                <div class="section-title">
                  <q-icon name="description" size="18px" color="primary" class="q-mr-xs" />
                  Detalles de la Disputa
                </div>
                <p class="description-text">{{ item.descripcion }}</p>
              </div>
            </div>
          </div>
        </q-slide-transition>
      </div>
    </div>

    <!-- Resolver Dialog -->
    <q-dialog v-model="resolverDialog" persistent backdrop-filter="blur(8px)">
      <q-card class="dialog-card glass-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="gavel" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Resolver Disputa</h2>
          <p class="dialog-card__subtitle">Proceso de Resolución de Disputas</p>
        </div>

        <q-card-section class="q-px-lg q-pt-lg">
          <div class="info-bubble q-mb-lg">
            <div class="row items-center gap-xs q-mb-sm">
              <q-badge color="warning">
                ID: #{{ disputaActual?.idDisputa }}
              </q-badge>
              <q-badge color="info">
                Transacción: #{{ disputaActual?.idTransaccion }}
              </q-badge>
            </div>
            <div class="info-title text-white font-weight-bold q-mt-sm">
              {{ disputaActual?.motivo || 'Sin motivo especificado' }}
            </div>
            <p class="info-desc text-muted q-mt-sm">
              Reportado por: {{ disputaActual?.usuarioReportaNombre }}
            </p>
          </div>

          <q-form @submit="resolverDisputa" class="q-gutter-md">
            <div class="field-group">
              <label class="field-label">Decisión</label>
              <q-select
                v-model="decision"
                :options="decisionOptions"
                outlined
                dense
                dark
                placeholder="Seleccionar fallo"
                class="dialog-input"
                emit-value
                map-options
                :rules="[val => !!val || 'Selecciona una decisión']"
                hide-bottom-space
              >
                <template v-slot:option="scope">
                  <q-item v-bind="scope.itemProps">
                    <q-item-section avatar>
                      <q-icon
                        :name="scope.opt.icon"
                        :color="scope.opt.color"
                        size="20px"
                      />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label>{{ scope.opt.label }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
            </div>

            <div class="field-group">
              <label class="field-label">Observación</label>
              <q-input
                v-model="observacion"
                type="textarea"
                outlined
                dense
                dark
                placeholder="Detalla el motivo de tu decisión..."
                class="dialog-input dialog-textarea"
                maxlength="500"
                :rules="[val => !!val || 'Requerido']"
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
                type="submit"
                color="primary"
                label="Emitir Fallo"
                unelevated
                no-caps
                :loading="resolviendo"
                class="btn-submit"
              />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/authStore'
import disputaService from '@/services/disputaService'

const $q = useQuasar()
const authStore = useAuthStore()

const disputas = ref([])
const loading = ref(false)
const resolverDialog = ref(false)
const disputaActual = ref(null)
const decision = ref(null)
const observacion = ref('')
const resolviendo = ref(false)
const searchQuery = ref('')
const statusFilter = ref('todos')
const expandedCard = ref(null)

const tabs = [
  { key: 'todos', label: 'Todos' },
  { key: 'RECOMENDACION', label: 'Recomendaciones' },
  { key: 'BUG_REPORT', label: 'Bugs' }
]

const toggleExpand = id => {
  if (expandedCard.value === id) {
    expandedCard.value = null
  } else {
    expandedCard.value = id
  }
}

const filteredDisputas = computed(() => {
  return disputas.value.filter(d => {
    // 1. Estado Filter
    const matchesStatus = statusFilter.value === 'todos' || d.estado === statusFilter.value

    // 2. Search Query Filter
    const query = searchQuery.value?.toLowerCase() || ''
    const matchesSearch = !query ||
      d.idDisputa.toString().includes(query) ||
      d.motivo?.toLowerCase().includes(query) ||
      d.descripcion?.toLowerCase().includes(query) ||
      d.usuarioReportaNombre?.toLowerCase().includes(query) ||
      d.idTransaccion.toString().includes(query)

    return matchesStatus && matchesSearch
  })
})

const formatDate = dateStr => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('es-PE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const abrirResolver = disputa => {
  disputaActual.value = disputa
  decision.value = null
  observacion.value = ''
  resolverDialog.value = true
}

const resolverDisputa = async () => {
  if (!decision.value || !observacion.value) {
    $q.notify({
      type: 'negative',
      message: 'Completa todos los campos',
      position: 'top'
    })
    return
  }

  resolviendo.value = true
  try {
    await disputaService.resolver({
      idDisputa: disputaActual.value.idDisputa,
      decision: decision.value,
      observacion: observacion.value
    })
    $q.notify({
      type: 'positive',
      message: 'Disputa resuelta exitosamente',
      position: 'top'
    })
    resolverDialog.value = false
    await cargarDisputas()
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al resolver la disputa',
      position: 'top'
    })
  } finally {
    resolviendo.value = false
  }
}

const cargarDisputas = async () => {
  if (!authStore.isAdmin) return
  loading.value = true
  try {
    const data = await disputaService.listarPendientes()
    disputas.value = Array.isArray(data) ? data : []
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al cargar disputas',
      position: 'top'
    })
  } finally {
    loading.value = false
  }
}

const formatEstado = estado => {
  if (!estado) return ''
  const map = {
    PENDIENTE: 'Pendiente',
    PAGADO: 'Pagado',
    COMPLETADO: 'Completado',
    CANCELADO: 'Cancelado',
    CANCELADA: 'Cancelado',
    EN_DISPUTA: 'En Disputa'
  }
  return map[estado] || estado.replace(/_/g, ' ')
}

onMounted(cargarDisputas)
</script>

<style scoped>
.admin-disputas {
  padding: 32px 40px;
  max-width: 1400px;
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

.pending-badge {
  font-size: 0.85rem;
  font-weight: 600;
  padding: 8px 16px;
  background: rgba(245, 158, 11, 0.15);
  color: #f59e0b;
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

/* Disputas Feed */
.disputas-feed {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.disputa-card {
  border-radius: 16px;
  padding: 20px 24px;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.2, 0.8, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.disputa-card:hover {
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.03);
  transform: scale(1.005);
}

.disputa-card.card-resolved {
  border-left: 4px solid var(--color-positive);
  background: rgba(16, 185, 129, 0.02);
}

.disputa-card.expanded {
  border-color: rgba(124, 58, 237, 0.3);
  background: rgba(124, 58, 237, 0.02);
  box-shadow: 0 10px 30px -10px rgba(124, 58, 237, 0.1);
}

.dispute-id-gradient {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--color-primary) 0%, #3b82f6 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1.1rem;
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

.card-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 0.82rem;
  color: var(--color-text-muted);
}

.resolve-btn {
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

.dispute-details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
}

.detail-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.section-title {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text);
  display: flex;
  align-items: center;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
  font-size: 0.85rem;
}

.detail-label {
  color: var(--color-text-muted);
  font-weight: 500;
}

.detail-value {
  color: var(--color-text);
  font-weight: 600;
}

.no-evidence {
  display: flex;
  align-items: center;
  color: var(--color-warning);
  font-size: 0.85rem;
  padding: 12px;
  background: rgba(245, 158, 11, 0.05);
  border-radius: 8px;
  border: 1px solid rgba(245, 158, 11, 0.2);
}

.evidence-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.evidence-item {
  display: flex;
  align-items: center;
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
  font-size: 0.85rem;
}

.evidence-link {
  color: var(--color-primary);
  text-decoration: none;
  font-weight: 500;
}

.evidence-link:hover {
  text-decoration: underline;
}

.description-text {
  font-size: 0.9rem;
  line-height: 1.6;
  color: var(--color-text-secondary);
  white-space: pre-wrap;
  margin: 0;
  padding: 12px;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
  border-left: 3px solid var(--color-primary);
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
  padding: 28px 24px;
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
  margin: 0 0 4px;
}

.dialog-card__subtitle {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.7);
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
  margin-bottom: 16px;
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
  padding-top: 8px;
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

.gap-sm { gap: 8px; }
.gap-md { gap: 16px; }
.gap-xs { gap: 4px; }

@media (max-width: 768px) {
  .admin-disputas {
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

  .dispute-details-grid {
    grid-template-columns: 1fr;
  }
}
</style>