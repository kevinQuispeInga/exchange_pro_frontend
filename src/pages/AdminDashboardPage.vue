<template>
  <q-page class="admin-dashboard">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Dashboard</h1>
        <p class="page-subtitle">Panel de control administrativo</p>
      </div>
      <q-btn flat dense icon="refresh" class="refresh-btn" @click="fetchEstadisticas" :loading="loading" />
    </div>

    <div class="ticker-bar glass-card">
      <div class="ticker-container">
        <div class="ticker-track">
          <span class="ticker-content">{{ tickerText }}</span>
          <span class="ticker-content">{{ tickerText }}</span>
        </div>
      </div>
    </div>

    <div class="stats-grid row q-col-gutter-md q-mb-lg">
      <div class="col-12 col-md-6" v-if="loading">
        <div class="stat-card stat-hero glass-card shimmer">
          <div class="stat-card-inner">
            <div class="stat-icon-placeholder"></div>
            <div class="stat-body-placeholder">
              <div class="stat-value-placeholder"></div>
              <div class="stat-label-placeholder"></div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-12 col-md-6" v-else>
        <div class="stat-card stat-hero glass-card glow stat-enter" style="--delay: 0s">
          <div class="stat-card-inner">
            <div class="stat-icon-wrapper" style="background: rgba(124, 58, 237, 0.15)">
              <q-icon name="people" color="primary" size="28px" />
            </div>
            <div class="stat-body">
              <div class="stat-value text-gradient">{{ stats.usuarios ?? '—' }}</div>
              <div class="stat-label">Usuarios Registrados</div>
            </div>
          </div>
        </div>
      </div>

      <div class="col-12 col-sm-6 col-md-2" v-for="(s, i) in smallStats" :key="s.label">
        <div v-if="loading" class="stat-card glass-card shimmer">
          <div class="stat-card-inner">
            <div class="stat-icon-placeholder"></div>
            <div class="stat-body-placeholder">
              <div class="stat-value-placeholder"></div>
              <div class="stat-label-placeholder"></div>
            </div>
          </div>
        </div>
        <div v-else class="stat-card glass-card stat-enter" :style="{ '--delay': `${(i + 1) * 0.1}s` }">
          <div class="stat-icon-wrapper" :style="{ background: s.bg }">
            <q-icon :name="s.icon" :color="s.color" size="22px" />
          </div>
          <div class="stat-body">
            <div class="stat-value mono" :style="{ color: s.valueColor }">{{ s.value }}</div>
            <div class="stat-label">{{ s.label }}</div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="error" class="error-state glass-card">
      <q-icon name="cloud_off" size="32px" color="negative" />
      <span>No se pudieron cargar las estadísticas</span>
      <q-btn flat dense label="Reintentar" color="primary" no-caps @click="fetchEstadisticas" />
    </div>

    <div class="activity-section glass-card">
      <h3 class="activity-title font-display">Actividad Reciente</h3>
      <div class="activity-list">
        <div class="activity-item" v-for="(item, i) in activityFeed" :key="i">
          <div class="activity-dot" :style="{ background: item.color }"></div>
          <div class="activity-content">
            <span class="activity-text">{{ item.text }}</span>
            <span class="activity-time">{{ item.time }}</span>
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '@/services/api'

const loading = ref(true)
const error = ref(false)
const stats = ref({})

const smallStats = computed(() => [
  {
    label: 'Ofertas Activas',
    value: stats.value.ofertas ?? '—',
    icon: 'sell',
    color: 'accent',
    valueColor: 'var(--color-accent)',
    bg: 'rgba(34, 211, 238, 0.12)'
  },
  {
    label: 'Transacciones Completadas',
    value: stats.value.transacciones ?? '—',
    icon: 'swap_horiz',
    color: 'positive',
    valueColor: 'var(--color-positive)',
    bg: 'rgba(16, 185, 129, 0.12)'
  },
  {
    label: 'Disputas Pendientes',
    value: stats.value.disputas ?? '—',
    icon: 'gavel',
    color: 'negative',
    valueColor: 'var(--color-negative)',
    bg: 'rgba(244, 63, 94, 0.12)'
  }
])

const tickerText = computed(() => {
  const s = stats.value
  return [
    'PLATFORM STATUS: OPERATIONAL',
    `ACTIVE USERS: ${s.usuarios ?? '...'}`,
    `OFFERS: ${s.ofertas ?? '...'}`,
    `COMPLETED TX: ${s.transacciones ?? '...'}`,
    `PENDING DISPUTES: ${s.disputas ?? '...'}`
  ].join('  •  ') + '  •  '
})

const activityFeed = [
  { text: 'Nuevo usuario registrado', time: 'hace 2 min', color: 'var(--color-primary)' },
  { text: 'Transacción #1284 completada', time: 'hace 8 min', color: 'var(--color-positive)' },
  { text: 'Disputa #42 resuelta', time: 'hace 15 min', color: 'var(--color-positive)' },
  { text: 'Nueva oferta creada: USDT/PEN', time: 'hace 22 min', color: 'var(--color-accent)' },
  { text: 'Feedback recibido de usuario', time: 'hace 35 min', color: 'var(--color-warning)' },
  { text: 'Retiro procesado: S/ 2,500', time: 'hace 1 h', color: 'var(--color-accent)' }
]

const fetchEstadisticas = async () => {
  loading.value = true
  error.value = false
  try {
    const res = await api.get('/api/Admin/estadisticas')
    stats.value = {
      usuarios: res.data.usuarios ?? res.data.totalUsuarios ?? res.data.Usuarios ?? res.data.usuariosRegistrados ?? '—',
      ofertas: res.data.ofertas ?? res.data.totalOfertas ?? res.data.Ofertas ?? res.data.ofertasActivas ?? '—',
      transacciones: res.data.transacciones ?? res.data.totalTransacciones ?? res.data.Transacciones ?? res.data.transaccionesCompletadas ?? '—',
      disputas: res.data.disputas ?? res.data.pendientes ?? res.data.Disputas ?? res.data.disputasPendientes ?? '—'
    }
  } catch (err) {
    console.error('Error loading stats:', err)
    error.value = true
  } finally {
    loading.value = false
  }
}

onMounted(fetchEstadisticas)
</script>

<style scoped>
.admin-dashboard {
  padding: 28px 32px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
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

.refresh-btn {
  color: var(--color-text-muted);
  border-radius: var(--radius-sm);
}

/* Ticker */
.ticker-bar {
  overflow: hidden;
  padding: 10px 0;
  margin-bottom: 24px;
}

.ticker-container {
  overflow: hidden;
  white-space: nowrap;
}

.ticker-track {
  display: inline-block;
  white-space: nowrap;
  animation: ticker-scroll 40s linear infinite;
}

.ticker-content {
  display: inline-block;
  font-family: var(--font-mono);
  font-size: 0.78rem;
  color: var(--color-text-secondary);
  letter-spacing: 0.03em;
}

@keyframes ticker-scroll {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}

/* Stats */
.stats-grid {
  margin-top: 8px;
}

.stat-card {
  padding: 20px;
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
  position: relative;
  overflow: hidden;
}

.stat-card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1px;
  background: linear-gradient(135deg, transparent 40%, transparent 60%);
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  transition: background 0.4s ease;
  pointer-events: none;
}

.stat-card:hover::before {
  background: linear-gradient(135deg, var(--color-primary), var(--color-accent), transparent 70%);
}

.stat-card-inner {
  display: flex;
  align-items: center;
  gap: 14px;
}

.stat-hero {
  min-height: 100px;
}

.stat-hero .stat-card-inner {
  gap: 18px;
}

.stat-icon-wrapper {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-hero .stat-icon-wrapper {
  width: 52px;
  height: 52px;
  border-radius: 14px;
}

.stat-body {
  display: flex;
  flex-direction: column;
  gap: 3px;
  min-width: 0;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  line-height: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.stat-hero .stat-value {
  font-size: 2rem;
}

.stat-value.mono {
  font-family: var(--font-mono);
}

.stat-label {
  font-family: var(--font-body);
  font-size: 0.78rem;
  color: var(--color-text-muted);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Entrance animation */
.stat-enter {
  animation: stat-fade-in 0.5s ease both;
  animation-delay: var(--delay, 0s);
}

@keyframes stat-fade-in {
  from {
    opacity: 0;
    transform: translateY(16px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Shimmer placeholders */
.shimmer .stat-icon-placeholder {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  flex-shrink: 0;
}

.shimmer .stat-body-placeholder {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.shimmer .stat-value-placeholder {
  height: 24px;
  width: 80px;
}

.shimmer .stat-label-placeholder {
  height: 14px;
  width: 120px;
}

/* Error state */
.error-state {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  color: var(--color-text-secondary);
  font-size: 0.9rem;
}

/* Activity feed */
.activity-section {
  padding: 20px;
}

.activity-title {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-text);
  margin: 0 0 16px;
}

.activity-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid var(--color-border);
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-top: 6px;
  flex-shrink: 0;
  box-shadow: 0 0 6px currentColor;
}

.activity-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex: 1;
  min-width: 0;
}

.activity-text {
  font-family: var(--font-body);
  font-size: 0.88rem;
  color: var(--color-text);
}

.activity-time {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

@media (max-width: 768px) {
  .admin-dashboard {
    padding: 20px 16px;
  }

  .stat-hero .stat-value {
    font-size: 1.6rem;
  }
}
</style>
