<template>
  <q-page class="admin-dashboard">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Dashboard</h1>
        <p class="page-subtitle">Panel de control administrativo</p>
      </div>
      <div class="header-controls">
        <!-- Selector Global de Fecha (Filtro Inteligente Customizado) -->
        <div class="date-filter-group">
          <!-- Año -->
          <div class="filter-select-wrap">
            <label class="filter-label">Año</label>
            <div class="custom-dropdown">
              <div class="dropdown-trigger" @click.stop="isOpenAnio = !isOpenAnio; isOpenMes = false; isOpenSemana = false">
                <span>{{ filterAnio }}</span>
                <q-icon name="arrow_drop_down" class="dropdown-arrow" :class="{ rotated: isOpenAnio }" size="16px" />
              </div>
              <transition name="dropdown-fade">
                <div v-if="isOpenAnio" class="dropdown-menu glass-card">
                  <div 
                    v-for="y in yearOptions" 
                    :key="y" 
                    class="dropdown-option"
                    :class="{ active: filterAnio === y }"
                    @click="filterAnio = y; isOpenAnio = false"
                  >
                    {{ y }}
                  </div>
                </div>
              </transition>
            </div>
          </div>
          
          <!-- Mes -->
          <div class="filter-select-wrap">
            <label class="filter-label">Mes</label>
            <div class="custom-dropdown">
              <div class="dropdown-trigger" @click.stop="isOpenMes = !isOpenMes; isOpenAnio = false; isOpenSemana = false">
                <span>{{ currentMonthLabel }}</span>
                <q-icon name="arrow_drop_down" class="dropdown-arrow" :class="{ rotated: isOpenMes }" size="16px" />
              </div>
              <transition name="dropdown-fade">
                <div v-if="isOpenMes" class="dropdown-menu glass-card">
                  <div 
                    class="dropdown-option"
                    :class="{ active: filterMes === null }"
                    @click="filterMes = null; isOpenMes = false"
                  >
                    Todos los meses
                  </div>
                  <div 
                    v-for="m in monthOptions" 
                    :key="m.value" 
                    class="dropdown-option"
                    :class="{ active: filterMes === m.value }"
                    @click="filterMes = m.value; isOpenMes = false"
                  >
                    {{ m.label }}
                  </div>
                </div>
              </transition>
            </div>
          </div>
          
          <!-- Semana -->
          <div class="filter-select-wrap">
            <label class="filter-label">Semana</label>
            <div class="custom-dropdown" :class="{ disabled: filterMes === null }">
              <div 
                class="dropdown-trigger" 
                @click.stop="filterMes !== null && (isOpenSemana = !isOpenSemana); isOpenAnio = false; isOpenMes = false"
              >
                <span>{{ currentSemanaLabel }}</span>
                <q-icon name="arrow_drop_down" class="dropdown-arrow" :class="{ rotated: isOpenSemana }" size="16px" />
              </div>
              <transition name="dropdown-fade">
                <div v-if="isOpenSemana && filterMes !== null" class="dropdown-menu glass-card">
                  <div 
                    class="dropdown-option"
                    :class="{ active: filterSemana === null }"
                    @click="filterSemana = null; isOpenSemana = false"
                  >
                    Todas las semanas
                  </div>
                  <div 
                    v-for="s in [1, 2, 3, 4, 5]" 
                    :key="s" 
                    class="dropdown-option"
                    :class="{ active: filterSemana === s }"
                    @click="filterSemana = s; isOpenSemana = false"
                  >
                    {{ getSemanaLabel(s) }}
                  </div>
                </div>
              </transition>
            </div>
          </div>
        </div>
        <q-btn
          flat
          dense
          icon="refresh"
          class="refresh-btn"
          @click="handleRefresh"
          :loading="loading"
        />
      </div>
    </div>

    <div class="ticker-bar glass-card">
      <div class="ticker-container">
        <div class="ticker-track">
          <span class="ticker-content">{{ tickerText }}</span>
          <span class="ticker-content">{{ tickerText }}</span>
        </div>
      </div>
    </div>

    <div class="stats-grid q-mb-lg">
      <div class="stat-card-wrapper" v-if="loading">
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
      <div class="stat-card-wrapper" v-else>
        <div class="stat-card glass-card glow stat-enter" style="--delay: 0s">
          <div class="stat-card-inner spaced">
            <div class="stat-body">
              <div class="stat-value text-gradient">{{
                periodStats.usuarios
              }}</div>
              <div class="stat-label">Nuevos Usuarios</div>
            </div>
            <div
              class="stat-icon-wrapper"
              style="background: rgba(124, 58, 237, 0.15)"
            >
              <q-icon name="people" color="primary" size="28px" />
            </div>
          </div>
        </div>
      </div>

      <div
        class="stat-card-wrapper"
        v-for="(s, i) in smallStats"
        :key="s.label"
      >
        <div v-if="loading" class="stat-card glass-card shimmer">
          <div class="stat-card-inner">
            <div class="stat-icon-placeholder"></div>
            <div class="stat-body-placeholder">
              <div class="stat-value-placeholder"></div>
              <div class="stat-label-placeholder"></div>
            </div>
          </div>
        </div>
        <div
          v-else
          class="stat-card glass-card stat-enter"
          :style="{ '--delay': `${(i + 1) * 0.1}s` }"
        >
          <div class="stat-card-inner spaced">
            <div class="stat-body">
              <div class="stat-value mono" :style="{ color: s.valueColor }">{{
                s.value
              }}</div>
              <div class="stat-label">{{ s.label }}</div>
            </div>
            <div class="stat-icon-wrapper" :style="{ background: s.bg }">
              <q-icon :name="s.icon" :color="s.color" size="22px" />
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="error" class="error-state glass-card">
      <q-icon name="cloud_off" size="32px" color="negative" />
      <span>No se pudieron cargar las estadísticas</span>
      <q-btn
        flat
        dense
        label="Reintentar"
        color="primary"
        no-caps
        @click="fetchEstadisticas"
      />
    </div>

    <!-- Sección de Gráficos Analíticos -->
    <div class="charts-grid q-mb-lg" v-if="!loading && !error">
      <!-- Card 1: Tendencia Histórica (Line Chart Interactivo) -->
      <div class="chart-card glass-card">
        <div class="chart-header-row">
          <div class="chart-header-title-wrap">
            <h4 class="chart-title font-display">Tendencia Histórica</h4>
            <p class="chart-subtitle">Evolución en tiempo real de métricas clave</p>
          </div>
          <div class="chart-selectors">
            <!-- Selector de Métricas -->
            <div class="metric-selector">
              <button 
                v-for="m in metricOptions" 
                :key="m.value" 
                class="metric-pill"
                :class="{ active: selectedMetric === m.value }"
                @click="selectedMetric = m.value"
              >
                {{ m.label }}
              </button>
            </div>
          </div>
        </div>
        <div class="chart-container">
          <svg viewBox="0 0 500 200" class="line-chart-svg">
            <defs>
              <linearGradient id="chart-grad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" :stop-color="metricColor" stop-opacity="0.4"/>
                <stop offset="100%" :stop-color="metricColor" stop-opacity="0.0"/>
              </linearGradient>
            </defs>
            
            <line x1="40" y1="20" x2="480" y2="20" stroke="rgba(255,255,255,0.05)" />
            <line x1="40" y1="70" x2="480" y2="70" stroke="rgba(255,255,255,0.05)" />
            <line x1="40" y1="120" x2="480" y2="120" stroke="rgba(255,255,255,0.05)" />
            <line x1="40" y1="170" x2="480" y2="170" stroke="rgba(255,255,255,0.1)" />

            <text x="30" y="24" fill="rgba(255,255,255,0.4)" font-size="10" text-anchor="end" class="font-mono">{{ Math.round(maxTrxVal) }}</text>
            <text x="30" y="74" fill="rgba(255,255,255,0.4)" font-size="10" text-anchor="end" class="font-mono">{{ Math.round(maxTrxVal * 0.6) }}</text>
            <text x="30" y="124" fill="rgba(255,255,255,0.4)" font-size="10" text-anchor="end" class="font-mono">{{ Math.round(maxTrxVal * 0.3) }}</text>
            <text x="30" y="174" fill="rgba(255,255,255,0.4)" font-size="10" text-anchor="end" class="font-mono">0</text>

            <!-- Nombres de los Ejes -->
            <text x="40" y="12" fill="rgba(255,255,255,0.35)" font-size="8" font-weight="700" letter-spacing="0.05em" text-anchor="start">↑ CANTIDAD</text>

            <path :d="areaPath" fill="url(#chart-grad)" />
            <path :d="linePath" fill="none" :stroke="metricColor" stroke-width="3" stroke-linecap="round" />
            <circle v-for="(pt, idx) in chartPoints" :key="idx" :cx="pt.x" :cy="pt.y" r="5" :fill="metricColor" stroke="var(--color-bg)" stroke-width="2" />

            <!-- Zonas de Hover transparentes para facilitar la interacción táctil y de mouse -->
            <circle 
              v-for="(pt, idx) in chartPoints" 
              :key="'hover-' + idx" 
              :cx="pt.x" 
              :cy="pt.y" 
              r="15" 
              fill="transparent" 
              style="cursor: pointer"
              @mouseover="activePointIndex = idx"
              @mouseleave="activePointIndex = null"
              @click="activePointIndex = idx"
            />

            <!-- Burbuja emergente (Tooltip) con el valor y concepto del punto -->
            <g v-if="activePointIndex !== null" style="pointer-events: none">
              <rect 
                :x="chartPoints[activePointIndex].x - 55" 
                :y="chartPoints[activePointIndex].y - 32" 
                width="110" 
                height="20" 
                rx="5" 
                fill="rgba(15, 23, 42, 0.95)" 
                :stroke="metricColor" 
                stroke-width="1.5"
              />
              <text 
                :x="chartPoints[activePointIndex].x" 
                :y="chartPoints[activePointIndex].y - 18" 
                fill="white" 
                font-size="9" 
                font-weight="700" 
                text-anchor="middle"
              >
                {{ getTooltipText(chartPoints[activePointIndex]) }}
              </text>
            </g>

            <text v-for="(label, idx) in chartLabels" :key="idx" :x="getXCoordinate(idx, chartLabels.length)" y="185" fill="rgba(255,255,255,0.4)" font-size="10" text-anchor="middle" class="font-mono">
              {{ label }}
            </text>
          </svg>
        </div>
      </div>

      <!-- Card 2: Resumen del Sistema (Donut Chart Interactivo) -->
      <div class="chart-card glass-card">
        <div class="chart-header-row">
          <h4 class="chart-title font-display">Resumen del Sistema</h4>
          <div class="metric-selector">
            <button 
              v-for="d in donutOptions" 
              :key="d.value" 
              class="metric-pill"
              :class="{ active: selectedDonutMetric === d.value }"
              @click="selectedDonutMetric = d.value"
            >
              {{ d.label }}
            </button>
          </div>
        </div>
        <div class="chart-container donut-layout">
          <div class="donut-svg-wrap">
            <svg viewBox="0 0 100 100" class="donut-chart-svg">
              <circle cx="50" cy="50" r="40" fill="none" stroke="rgba(255,255,255,0.05)" stroke-width="12" />
              
              <!-- Segmento 1 -->
              <circle cx="50" cy="50" r="40" fill="none" :stroke="donutColor1" :stroke-width="hoveredSegment === 1 ? 16 : 12" 
                :stroke-dasharray="`${dashActive} 251.3`" stroke-dashoffset="0"
                style="transition: stroke-width 0.2s ease, stroke 0.2s ease; cursor: pointer;"
                @mouseover="hoveredSegment = 1"
                @mouseleave="hoveredSegment = null"
              />
              
              <!-- Segmento 2 -->
              <circle cx="50" cy="50" r="40" fill="none" :stroke="donutColor2" :stroke-width="hoveredSegment === 2 ? 16 : 12" 
                :stroke-dasharray="`${dashCompleted} 251.3`" :stroke-dashoffset="`-${dashActive}`"
                style="transition: stroke-width 0.2s ease, stroke 0.2s ease; cursor: pointer;"
                @mouseover="hoveredSegment = 2"
                @mouseleave="hoveredSegment = null"
              />
            </svg>
            <div class="donut-center">
              <span class="donut-center-val">{{ donutCenterValue }}</span>
              <span class="donut-center-label">{{ donutCenterLabel }}</span>
            </div>
          </div>
          
          <div class="donut-legend">
            <div class="legend-item" @mouseover="hoveredSegment = 1" @mouseleave="hoveredSegment = null" style="cursor: pointer;">
              <span class="legend-dot" :style="{ background: donutColor1 }"></span>
              <div class="legend-info">
                <span class="legend-name">{{ donutLabel1 }}</span>
                <span class="legend-val">{{ donutValue1 }} ({{ Math.round((donutValue1 / totalActiveItems) * 100) }}%)</span>
              </div>
            </div>
            <div class="legend-item" @mouseover="hoveredSegment = 2" @mouseleave="hoveredSegment = null" style="cursor: pointer;">
              <span class="legend-dot" :style="{ background: donutColor2 }"></span>
              <div class="legend-info">
                <span class="legend-name">{{ donutLabel2 }}</span>
                <span class="legend-val">{{ donutValue2 }} ({{ Math.round((donutValue2 / totalActiveItems) * 100) }}%)</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Tarjetas analíticas de KPIs inferiores para llenar el espacio vacío -->
        <div class="donut-kpis">
          <div class="kpi-box glass-card">
            <span class="kpi-label">{{ selectedDonutMetric === 'operaciones' ? 'Éxito Transacciones' : 'Reclamos Resueltos' }}</span>
            <span class="kpi-value text-primary">{{ selectedDonutMetric === 'operaciones' ? conversionRateText : '88.5%' }}</span>
          </div>
          <div class="kpi-box glass-card">
            <span class="kpi-label">{{ selectedDonutMetric === 'operaciones' ? 'Monedas Activas' : 'Prioridad' }}</span>
            <span class="kpi-value">{{ selectedDonutMetric === 'operaciones' ? 'Soles y Dólares' : 'Alta' }}</span>
          </div>
          <div class="kpi-box glass-card">
            <span class="kpi-label">{{ selectedDonutMetric === 'operaciones' ? 'Estado Sistema' : 'Tiempo Espera' }}</span>
            <span class="kpi-value text-positive">{{ selectedDonutMetric === 'operaciones' ? 'Funcionando bien' : '< 15 min' }}</span>
          </div>
        </div>
      </div>
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
import { ref, onMounted, onUnmounted, computed, watch } from 'vue'
import adminService from '@/services/adminService'

const loading = ref(true)
const error = ref(false)
const stats = ref({})

const allHistoricalData = ref({
  usuarios: [],
  ofertas: [],
  transacciones: [],
  disputas: [],
  feedback: []
})

const getSum = (arr) => {
  if (!arr || arr.length === 0) return 0
  return arr.reduce((sum, val) => sum + val, 0)
}

const periodStats = computed(() => {
  const data = allHistoricalData.value
  return {
    usuarios: getSum(data.usuarios),
    ofertas: getSum(data.ofertas),
    transacciones: getSum(data.transacciones),
    disputas: getSum(data.disputas),
    feedback: getSum(data.feedback)
  }
})

const smallStats = computed(() => [
  {
    label: 'Ofertas Activas',
    value: periodStats.value.ofertas,
    icon: 'sell',
    color: 'accent',
    valueColor: 'var(--color-accent)',
    bg: 'rgba(34, 211, 238, 0.12)'
  },
  {
    label: 'Transacciones Completadas',
    value: periodStats.value.transacciones,
    icon: 'swap_horiz',
    color: 'positive',
    valueColor: 'var(--color-positive)',
    bg: 'rgba(16, 185, 129, 0.12)'
  },
  {
    label: 'Disputas Pendientes',
    value: periodStats.value.disputas,
    icon: 'gavel',
    color: 'negative',
    valueColor: 'var(--color-negative)',
    bg: 'rgba(244, 63, 94, 0.12)'
  }
])

const tickerText = computed(() => {
  const s = periodStats.value
  return (
    [
      'ESTADO DE LA PLATAFORMA: OPERATIVO',
      `USUARIOS ACTIVOS: ${s.usuarios}`,
      `OFERTAS: ${s.ofertas}`,
      `TRANSACCIONES COMPLETADAS: ${s.transacciones}`,
      `DISPUTAS PENDIENTES: ${s.disputas}`
    ].join('  •  ') + '  •  '
  )
})

const activityFeed = [
  {
    text: 'Nuevo usuario registrado',
    time: 'hace 2 min',
    color: 'var(--color-primary)'
  },
  {
    text: 'Transacción #1284 completada',
    time: 'hace 8 min',
    color: 'var(--color-positive)'
  },
  {
    text: 'Disputa #42 resuelta',
    time: 'hace 15 min',
    color: 'var(--color-positive)'
  },
  {
    text: 'Nueva oferta creada en el mercado',
    time: 'hace 22 min',
    color: 'var(--color-accent)'
  },
  {
    text: 'Feedback recibido de usuario',
    time: 'hace 35 min',
    color: 'var(--color-warning)'
  },
  {
    text: 'Retiro procesado: S/ 2,500',
    time: 'hace 1 h',
    color: 'var(--color-accent)'
  }
]

const fetchEstadisticas = async () => {
  loading.value = true
  error.value = false
  try {
    const data = await adminService.getEstadisticas()
    stats.value = data
  } catch (err) {
    console.error('Error loading stats:', err.response?.data ?? err)
    error.value = true
  } finally {
    loading.value = false
  }
}

const selectedMetric = ref('transacciones')
const activePointIndex = ref(null)
const loadingChart = ref(false)

const metricOptions = [
  { value: 'usuarios', label: 'Nuevos Usuarios' },
  { value: 'ofertas', label: 'Nuevas Ofertas' },
  { value: 'transacciones', label: 'Transacciones' },
  { value: 'disputas', label: 'Reclamos' },
  { value: 'feedback', label: 'Sugerencias' }
]

const metricColor = computed(() => {
  const map = {
    usuarios: 'var(--color-primary)',
    ofertas: 'var(--color-accent)',
    transacciones: 'var(--color-positive)',
    disputas: 'var(--color-negative)',
    feedback: 'var(--color-warning)'
  }
  return map[selectedMetric.value] || 'var(--color-primary)'
})

const chartValues = computed(() => {
  return allHistoricalData.value[selectedMetric.value] || []
})

const maxTrxVal = computed(() => {
  const values = chartValues.value
  if (!values || values.length === 0) return 10
  return Math.max(...values) * 1.5 || 10
})

// Configuración de Filtros de Fecha (Año, Mes, Semana)
const filterAnio = ref(new Date().getFullYear())
const filterMes = ref(new Date().getMonth() + 1)
const filterSemana = ref(null)

const isOpenAnio = ref(false)
const isOpenMes = ref(false)
const isOpenSemana = ref(false)

const yearOptions = [2026, 2025, 2024]

const monthOptions = [
  { value: 1, label: 'Enero' },
  { value: 2, label: 'Febrero' },
  { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' },
  { value: 5, label: 'Mayo' },
  { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' },
  { value: 8, label: 'Agosto' },
  { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' },
  { value: 11, label: 'Noviembre' },
  { value: 12, label: 'Diciembre' }
]

const currentMonthLabel = computed(() => {
  if (filterMes.value === null) return 'Todos los meses'
  const opt = monthOptions.find(m => m.value === filterMes.value)
  return opt ? opt.label : ''
})

const getSemanaLabel = (s) => {
  const labels = {
    1: 'Semana 1 (Días 1-7)',
    2: 'Semana 2 (Días 8-14)',
    3: 'Semana 3 (Días 15-21)',
    4: 'Semana 4 (Días 22-28)',
    5: 'Semana 5 (Días 29+)'
  }
  return labels[s] || ''
}

const currentSemanaLabel = computed(() => {
  if (filterMes.value === null) return 'Todas las semanas'
  if (filterSemana.value === null) return 'Todas las semanas'
  return getSemanaLabel(filterSemana.value)
})

const closeAllDropdowns = (e) => {
  if (!e.target.closest('.custom-dropdown')) {
    isOpenAnio.value = false
    isOpenMes.value = false
    isOpenSemana.value = false
  }
}

const chartLabels = computed(() => {
  if (filterMes.value === null) {
    return ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic']
  } else if (filterSemana.value === null) {
    const maxDays = new Date(filterAnio.value, filterMes.value, 0).getDate()
    const weeks = ['Semana 1', 'Semana 2', 'Semana 3', 'Semana 4']
    if (maxDays >= 29) weeks.push('Semana 5')
    return weeks
  } else {
    const targetSemana = filterSemana.value
    const maxDays = new Date(filterAnio.value, filterMes.value, 0).getDate()
    
    const startDay = (targetSemana - 1) * 7 + 1
    const endDay = Math.min(startDay + 6, maxDays)
    
    const days = []
    for (let d = startDay; d <= endDay; d++) {
      days.push(`Día ${d}`)
    }
    return days
  }
})

const getXCoordinate = (idx, totalPoints) => {
  const total = totalPoints ?? 7
  if (total <= 1) return 40
  return 40 + idx * ((480 - 40) / (total - 1))
}

const fetchAllHistorial = async () => {
  loadingChart.value = true
  try {
    const metrics = ['usuarios', 'ofertas', 'transacciones', 'disputas', 'feedback']
    const promises = metrics.map(m => 
      adminService.getHistorial(m, filterAnio.value, filterMes.value, filterSemana.value)
    )
    const results = await Promise.all(promises)
    
    allHistoricalData.value = {
      usuarios: results[0] || [],
      ofertas: results[1] || [],
      transacciones: results[2] || [],
      disputas: results[3] || [],
      feedback: results[4] || []
    }
  } catch (err) {
    console.error('Error al cargar historial global:', err)
  } finally {
    loadingChart.value = false
  }
}

watch([filterAnio, filterMes, filterSemana], () => {
  if (filterMes.value === null && filterSemana.value !== null) {
    filterSemana.value = null
    return
  }
  fetchAllHistorial()
})

const chartPoints = computed(() => {
  const values = chartValues.value
  if (!values || values.length === 0) return []
  
  const max = maxTrxVal.value
  return values.map((v, idx) => {
    const x = getXCoordinate(idx, values.length)
    const y = 170 - (v / max) * (170 - 20)
    return { x, y, value: v }
  })
})

const linePath = computed(() => {
  const pts = chartPoints.value
  if (pts.length === 0) return ''
  return pts.reduce((path, pt, idx) => {
    return idx === 0 ? `M ${pt.x} ${pt.y}` : `${path} L ${pt.x} ${pt.y}`
  }, '')
})

const areaPath = computed(() => {
  const pts = chartPoints.value
  if (pts.length === 0) return ''
  const line = linePath.value
  const first = pts[0]
  const last = pts[pts.length - 1]
  return `${line} L ${last.x} 170 L ${first.x} 170 Z`
})

const getTooltipText = (pt) => {
  if (!pt) return ''
  const val = pt.value
  const metric = selectedMetric.value
  
  const labels = {
    usuarios: val === 1 ? 'nuevo usuario' : 'nuevos usuarios',
    ofertas: val === 1 ? 'nueva oferta' : 'nuevas ofertas',
    transacciones: val === 1 ? 'transacción' : 'transacciones',
    disputas: val === 1 ? 'reclamo' : 'reclamos',
    feedback: val === 1 ? 'sugerencia' : 'sugerencias'
  }
  
  return `${val} ${labels[metric] || ''}`
}

const selectedDonutMetric = ref('operaciones')
const hoveredSegment = ref(null)

const donutOptions = [
  { value: 'operaciones', label: 'Mercado P2P' },
  { value: 'soporte', label: 'Soporte y Ayuda' }
]

const donutColor1 = computed(() => 'var(--color-primary)')
const donutColor2 = computed(() => selectedDonutMetric.value === 'operaciones' ? 'var(--color-positive)' : 'var(--color-warning)')

const donutLabel1 = computed(() => selectedDonutMetric.value === 'operaciones' ? 'Ofertas Publicadas' : 'Reclamos Pendientes')
const donutLabel2 = computed(() => selectedDonutMetric.value === 'operaciones' ? 'Transacciones Completadas' : 'Sugerencias Recibidas')

const donutValue1 = computed(() => {
  const o = periodStats.value.ofertas
  const d = periodStats.value.disputas
  return selectedDonutMetric.value === 'operaciones' ? o : d
})

const donutValue2 = computed(() => {
  const t = periodStats.value.transacciones
  const f = periodStats.value.feedback
  return selectedDonutMetric.value === 'operaciones' ? t : f
})

const totalActiveItems = computed(() => donutValue1.value + donutValue2.value || 1)
const dashActive = computed(() => (donutValue1.value / totalActiveItems.value) * 251.3)
const dashCompleted = computed(() => (donutValue2.value / totalActiveItems.value) * 251.3)

const donutCenterValue = computed(() => {
  if (hoveredSegment.value === 1) return donutValue1.value
  if (hoveredSegment.value === 2) return donutValue2.value
  return totalActiveItems.value
})

const donutCenterLabel = computed(() => {
  if (hoveredSegment.value === 1) return selectedDonutMetric.value === 'operaciones' ? 'Ofertas' : 'Reclamos'
  if (hoveredSegment.value === 2) return selectedDonutMetric.value === 'operaciones' ? 'Transacciones' : 'Sugerencias'
  return 'Total'
})

const conversionRateText = computed(() => {
  const o = periodStats.value.ofertas
  const t = periodStats.value.transacciones
  const total = o + t || 1
  return `${Math.round((t / total) * 100)}%`
})

const handleRefresh = async () => {
  await fetchEstadisticas()
  await fetchAllHistorial()
}

onMounted(async () => {
  window.addEventListener('click', closeAllDropdowns)
  await fetchEstadisticas()
  await fetchAllHistorial()
})

onUnmounted(() => {
  window.removeEventListener('click', closeAllDropdowns)
})
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
  0% {
    transform: translateX(0);
  }
  100% {
    transform: translateX(-50%);
  }
}

/* Stats */
.stats-grid {
  margin-top: 8px;
  display: grid;
  grid-template-columns: repeat(4, minmax(250px, 1fr));
  gap: 18px;
}

@media (max-width: 959px) {
  .stats-grid {
    grid-template-columns: repeat(2, minmax(240px, 1fr));
  }
}

@media (max-width: 599px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
}

.stat-card-wrapper {
  width: 100%;
}

.stat-card {
  padding: 24px;
  transition:
    border-color 0.3s ease,
    box-shadow 0.3s ease;
  position: relative;
  overflow: hidden;
  width: 100%;
  min-width: 0;
  box-sizing: border-box;
  min-height: 170px;
  background: rgba(13, 16, 33, 0.88);
  border: 1px solid rgba(124, 58, 237, 0.25);
  border-radius: 24px;
  backdrop-filter: blur(20px);
}

.stat-card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  padding: 1px;
  background: linear-gradient(
    135deg,
    rgba(124, 58, 237, 0.35),
    rgba(16, 185, 129, 0.15)
  );
  -webkit-mask:
    linear-gradient(#fff 0 0) content-box,
    linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  transition: background 0.4s ease;
  pointer-events: none;
}

.stat-card:hover::before {
  background: linear-gradient(
    135deg,
    var(--color-primary),
    var(--color-accent),
    transparent 70%
  );
}

.stat-card-inner {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 14px;
}

.stat-card-inner.spaced {
  gap: 18px;
}

.stat-hero {
  min-height: 90px;
}

.stat-hero .stat-card-inner {
  gap: 18px;
}

.stat-icon-wrapper {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: absolute;
  top: 22px;
  right: 22px;
  flex-shrink: 0;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.12);
}

.stat-hero .stat-icon-wrapper {
  width: 52px;
  height: 52px;
  border-radius: 14px;
}

.stat-body {
  display: flex;
  flex-direction: column;
  gap: 6px;
  min-width: 0;
  padding-right: 80px;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  line-height: 1.05;
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
  font-size: 0.92rem;
  color: var(--color-text-muted);
  white-space: normal;
  overflow: visible;
  text-overflow: unset;
  font-weight: 600;
  line-height: 1.4;
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

/* Estilos de los Gráficos Analíticos */
.charts-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 1024px) {
  .charts-grid {
    grid-template-columns: 1fr;
  }
}

.chart-card {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.chart-header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.chart-header-title-wrap {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.chart-subtitle {
  font-family: var(--font-body);
  font-size: 0.72rem;
  color: var(--color-text-secondary);
  margin: 0;
}

.chart-selectors {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: center;
}

.period-selector {
  border-color: rgba(255, 255, 255, 0.08);
}

.metric-selector {
  display: flex;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: 2px;
}

.metric-pill {
  background: transparent;
  border: none;
  color: var(--color-text-secondary);
  font-family: var(--font-body);
  font-size: 0.72rem;
  font-weight: 600;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.metric-pill:hover {
  color: var(--color-text);
}

.metric-pill.active {
  background: var(--color-primary);
  color: white;
}

.chart-title {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--color-text);
  margin: 0;
}

.chart-container {
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.line-chart-svg {
  width: 100%;
  height: auto;
  overflow: visible;
}

.donut-layout {
  display: flex;
  align-items: center;
  justify-content: space-around;
  flex-wrap: wrap;
  gap: 24px;
  padding: 10px 0;
}

.donut-svg-wrap {
  position: relative;
  width: 130px;
  height: 130px;
}

.donut-chart-svg {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
  transform-origin: center;
}

.donut-center {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.donut-center-val {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text);
  line-height: 1;
}

.donut-center-label {
  font-size: 0.68rem;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-top: 2px;
}

.donut-legend {
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
  min-width: 180px;
}

.legend-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-top: 4px;
  flex-shrink: 0;
}

.legend-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.legend-name {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text-secondary);
}

.legend-val {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--color-text);
  font-family: var(--font-mono);
}

/* KPIs para rellenar el espacio del Donut Chart */
.donut-kpis {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 12px;
  width: 100%;
  margin-top: 16px;
  border-top: 1px solid var(--color-border-light);
  padding-top: 16px;
}

@media (max-width: 480px) {
  .donut-kpis {
    grid-template-columns: 1fr;
  }
}

.kpi-box {
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  background: rgba(255, 255, 255, 0.015);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm);
  text-align: center;
}

.kpi-label {
  font-size: 0.65rem;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-weight: 600;
}

.kpi-value {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--color-text);
}

/* Selector Global en Cabecera */
.header-controls {
  display: flex;
  align-items: center;
  gap: 20px;
}

.date-filter-group {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 16px;
}

.filter-select-wrap {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.filter-label {
  font-size: 0.65rem;
  text-transform: uppercase;
  color: var(--color-text-secondary);
  font-weight: 700;
  letter-spacing: 0.05em;
  margin-left: 2px;
}

/* Custom Dropdown Styling */
.custom-dropdown {
  position: relative;
  min-width: 120px;
}

.custom-dropdown.disabled {
  opacity: 0.4;
}

.dropdown-trigger {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-sm);
  color: var(--color-text);
  padding: 6px 12px;
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  height: 34px;
  user-select: none;
  transition: all 0.2s ease;
}

.custom-dropdown:not(.disabled) .dropdown-trigger:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(255, 255, 255, 0.2);
}

.custom-dropdown.disabled .dropdown-trigger {
  cursor: not-allowed;
}

.dropdown-arrow {
  transition: transform 0.2s ease;
  color: var(--color-text-secondary);
}

.dropdown-arrow.rotated {
  transform: rotate(180deg);
  color: var(--color-primary);
}

.dropdown-menu {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  width: 100%;
  min-width: 170px;
  background: rgba(15, 23, 42, 0.95);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  padding: 6px 0;
  z-index: 100;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.5);
  max-height: 250px;
  overflow-y: auto;
}

/* Scrollbar styling for dropdown menu */
.dropdown-menu::-webkit-scrollbar {
  width: 4px;
}

.dropdown-menu::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
}

.dropdown-option {
  padding: 8px 14px;
  font-size: 0.82rem;
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all 0.15s ease;
}

.dropdown-option:hover {
  background: rgba(124, 58, 237, 0.1);
  color: var(--color-text);
}

.dropdown-option.active {
  background: var(--color-primary);
  color: white;
  font-weight: 600;
}

/* Transition animation */
.dropdown-fade-enter-active,
.dropdown-fade-leave-active {
  transition: all 0.15s ease;
}

.dropdown-fade-enter-from,
.dropdown-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  .header-controls {
    width: 100%;
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
  }
  .date-filter-group {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    align-items: center;
    gap: 12px;
  }
}
</style>
