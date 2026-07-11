<template>
  <q-page class="transacciones-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Mis Transacciones</h1>
        <p class="page-subtitle">Historial de todas tus operaciones</p>
      </div>
    </div>

    <div v-if="loading" class="skeleton-grid">
      <div v-for="n in 4" :key="n" class="skeleton-card" />
    </div>

    <template v-else-if="transaccionStore.transacciones.length">
      <div class="stats-row">
        <div class="stat-item">
          <span class="stat-value">{{ transaccionStore.transacciones.length }}</span>
          <span class="stat-label">Total</span>
        </div>
        <div class="stat-item">
          <span class="stat-value stat-value--warning">{{ pendientes }}</span>
          <span class="stat-label">Pendientes</span>
        </div>
        <div class="stat-item">
          <span class="stat-value stat-value--positive">{{ completadas }}</span>
          <span class="stat-label">Completadas</span>
        </div>
        <div class="stat-item">
          <span class="stat-value stat-value--accent">{{ enDisputa }}</span>
          <span class="stat-label">En Disputa</span>
        </div>
      </div>

      <div class="filter-row">
        <button
          v-for="f in filters"
          :key="f.key"
          class="filter-pill"
          :class="{ active: activeFilter === f.key }"
          @click="activeFilter = f.key"
        >
          {{ f.label }}
        </button>
      </div>

      <TransitionGroup name="list" tag="div" class="cards-grid">
        <article
          v-for="t in filtered"
          :key="t.idTransaccion"
          class="trx-card glass-card card-hover"
          @click="$router.push(`/transacciones/${t.idTransaccion}`)"
        >
          <div class="trx-card__top">
            <div class="trx-card__code-wrap">
              <span class="trx-card__code font-mono">{{ t.codigo }}</span>
              <span class="trx-card__id">#{{ t.idTransaccion }}</span>
            </div>
            <q-badge :color="estadoColor(t.estado)" rounded class="trx-card__badge">
              {{ formatEstado(t.estado) }}
            </q-badge>
          </div>

          <div class="trx-card__body">
            <div class="trx-card__main">
              <span class="trx-card__amount font-mono">
                {{ formatNumber(t.montoOperacion) }} {{ t.monedaEntregaCode || '' }}
              </span>
              <span class="trx-card__meta">
                Oferta #{{ t.idOferta }}
              </span>
            </div>
            <div class="trx-card__aside">
              <q-icon name="calendar_today" size="14px" class="trx-card__icon" />
              <span class="trx-card__date">{{ formatDate(t.fechaInicio) }}</span>
            </div>
          </div>

          <div class="trx-card__footer">
            <span class="trx-card__action">
              Ver detalle
              <q-icon name="chevron_right" size="16px" />
            </span>
          </div>
        </article>
      </TransitionGroup>
    </template>

    <EmptyState
      v-else
      icon="swap_horiz"
      title="No tienes transacciones"
      description="Participa en una oferta para comenzar a operar"
      action-label="Ver Ofertas"
      action-icon="storefront"
      action-color="primary"
      @action="$router.push('/ofertas')"
    />
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useTransaccionStore } from '@/stores/transaccionStore'
import EmptyState from '@/components/EmptyState.vue'

const router = useRouter()
const transaccionStore = useTransaccionStore()

const loading = ref(true)
const activeFilter = ref('todas')

const filters = [
  { key: 'todas', label: 'Todas' },
  { key: 'PENDIENTE', label: 'Pendientes' },
  { key: 'PAGADO', label: 'Pagadas' },
  { key: 'COMPLETADO', label: 'Completadas' },
  { key: 'EN_DISPUTA', label: 'Disputa' },
  { key: 'CANCELADO', label: 'Canceladas' }
]

const filtered = computed(() =>
  activeFilter.value === 'todas'
    ? transaccionStore.transacciones
    : transaccionStore.transacciones.filter(t => t.estado === activeFilter.value)
)

const pendientes = computed(() =>
  transaccionStore.transacciones.filter(t => t.estado === 'PENDIENTE').length
)
const completadas = computed(() =>
  transaccionStore.transacciones.filter(t => t.estado === 'COMPLETADO').length
)
const enDisputa = computed(() =>
  transaccionStore.transacciones.filter(t => t.estado === 'EN_DISPUTA').length
)

const estadoColor = estado => {
  const map = {
    PENDIENTE: 'warning',
    PAGADO: 'info',
    COMPLETADO: 'positive',
    CANCELADO: 'negative',
    CANCELADA: 'negative',
    EN_DISPUTA: 'accent'
  }
  return map[estado] || 'grey'
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

const formatNumber = val => {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

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

onMounted(async () => {
  try {
    await transaccionStore.listarMisOperaciones()
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.transacciones-page {
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

@media (max-width: 768px) {
  .transacciones-page {
    padding: 20px 16px;
  }
}

.skeleton-grid {
  display: grid;
  gap: 16px;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
}

.skeleton-card {
  height: 160px;
  background: rgba(255, 255, 255, 0.04);
  border-radius: var(--radius-lg);
  animation: shimmer 1.5s ease-in-out infinite;
  background-image: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0.04) 25%,
    rgba(255, 255, 255, 0.08) 50%,
    rgba(255, 255, 255, 0.04) 75%
  );
  background-size: 200% 100%;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

.stats-row {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

.stat-item {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 16px 24px;
  flex: 1;
  min-width: 120px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.stat-value {
  font-family: var(--font-mono);
  font-size: 1.6rem;
  font-weight: 700;
  color: var(--color-text);
  font-variant-numeric: tabular-nums;
}

.stat-value--warning { color: var(--color-warning); }
.stat-value--positive { color: var(--color-positive); }
.stat-value--accent { color: var(--color-accent); }

.stat-label {
  font-size: 0.7rem;
  font-weight: 600;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.filter-row {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.filter-pill {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid var(--color-border);
  border-radius: 999px;
  padding: 6px 18px;
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: background 0.2s, color 0.2s, border-color 0.2s;
}

.filter-pill:hover {
  background: rgba(124, 58, 237, 0.1);
  border-color: rgba(124, 58, 237, 0.3);
  color: var(--color-text);
}

.filter-pill.active {
  background: rgba(124, 58, 237, 0.2);
  border-color: var(--color-primary);
  color: #ffffff;
}

.cards-grid {
  display: grid;
  gap: 16px;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
}

.trx-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.trx-card__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.trx-card__code-wrap {
  display: flex;
  align-items: center;
  gap: 8px;
}

.trx-card__code {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--color-primary-light);
}

.trx-card__id {
  font-size: 0.7rem;
  color: var(--color-text-muted);
}

.trx-card__badge {
  font-size: 0.65rem;
  font-weight: 600;
  padding: 3px 10px;
}

.trx-card__body {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
}

.trx-card__main {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.trx-card__amount {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--color-text);
  font-variant-numeric: tabular-nums;
}

.trx-card__meta {
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.trx-card__aside {
  display: flex;
  align-items: center;
  gap: 4px;
}

.trx-card__icon {
  color: var(--color-text-muted);
  opacity: 0.6;
}

.trx-card__date {
  font-family: var(--font-mono);
  font-size: 0.7rem;
  color: var(--color-text-muted);
  font-variant-numeric: tabular-nums;
}

.trx-card__footer {
  border-top: 1px solid var(--color-border-light);
  padding-top: 12px;
}

.trx-card__action {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--color-primary);
  display: flex;
  align-items: center;
  gap: 2px;
}

.list-enter-active,
.list-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.list-enter-from {
  opacity: 0;
  transform: translateY(12px);
}

.list-leave-to {
  opacity: 0;
  transform: translateY(-12px);
}

.list-move {
  transition: transform 0.3s ease;
}
</style>
