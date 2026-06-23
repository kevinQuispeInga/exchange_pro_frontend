<template>
  <div class="market-rhythm" ref="containerRef">
    <div class="market-rhythm__bg">
      <svg
        class="market-rhythm__wave"
        :width="width"
        :height="height"
        :viewBox="`0 0 ${width} ${height}`"
        preserveAspectRatio="none"
      >
        <defs>
          <linearGradient id="waveGrad" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="rgba(27, 58, 75, 0.08)" />
            <stop offset="50%" stop-color="rgba(200, 121, 65, 0.12)" />
            <stop offset="100%" stop-color="rgba(27, 58, 75, 0.08)" />
          </linearGradient>
          <linearGradient id="waveGrad2" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="rgba(27, 58, 75, 0.04)" />
            <stop offset="50%" stop-color="rgba(200, 121, 65, 0.08)" />
            <stop offset="100%" stop-color="rgba(27, 58, 75, 0.04)" />
          </linearGradient>
        </defs>
        <path
          :d="wavePath1"
          fill="url(#waveGrad)"
          class="market-rhythm__path market-rhythm__path--1"
        />
        <path
          :d="wavePath2"
          fill="url(#waveGrad2)"
          class="market-rhythm__path market-rhythm__path--2"
        />
      </svg>
    </div>
    <div class="market-rhythm__particles">
      <span
        v-for="p in particles"
        :key="p.id"
        class="market-rhythm__particle"
        :style="p.style"
      >
        {{ p.symbol }}
      </span>
    </div>
    <div class="market-rhythm__content">
      <div class="market-rhythm__rate">
        <div class="market-rhythm__tabs">
          <button
            v-for="m in rates"
            :key="m.codigo"
            class="tab-btn"
            :class="{ active: selected === m.codigo }"
            @click="selected = m.codigo"
          >
            {{ m.codigo }}
          </button>
        </div>
        <div class="market-rhythm__prices">
          <span class="market-rhythm__value font-mono" ref="rateRef">
            {{ activeRate.mid.toFixed(4) }}
          </span>
          <span
            class="market-rhythm__direction"
            :class="activeRate.direccion"
          >
            <q-icon
              :name="activeRate.direccion === 'sube' ? 'arrow_upward' : activeRate.direccion === 'baja' ? 'arrow_downward' : 'remove'"
              size="16px"
            />
          </span>
        </div>
        <div class="market-rhythm__spread">
          <span class="spread-item"><strong>COMPRA</strong> <span class="font-mono">{{ activeRate.compra.toFixed(4) }}</span></span>
          <span class="spread-sep">|</span>
          <span class="spread-item"><strong>VENTA</strong> <span class="font-mono">{{ activeRate.venta.toFixed(4) }}</span></span>
        </div>
      </div>
      <div class="market-rhythm__stats">
        <div class="market-rhythm__stat">
          <span class="stat-label">Ofertas Activas</span>
          <span class="stat-value font-mono">{{ activeOffers }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import tipoCambioService from '@/services/tipoCambioService'

const props = defineProps({
  activeOffers: { type: Number, default: 0 }
})

const containerRef = ref(null)
const rateRef = ref(null)
const width = ref(800)
const height = ref(200)
const rates = ref([])
const selected = ref('USD')
let resizeObserver = null

const activeRate = computed(() => {
  return rates.value.find(m => m.codigo === selected.value) || { codigo: 'USD', mid: 0, compra: 0, venta: 0, direccion: 'estable' }
})

const fetchRate = async () => {
  try {
    const data = await tipoCambioService.obtener()
    rates.value = data.monedas || []
  } catch {
    // silent
  }
}

const particles = computed(() => {
  const symbols = ['S/', '$', 'S/', '$', 'S/', '$']
  return Array.from({ length: 12 }, (_, i) => {
    const symbol = symbols[i % symbols.length]
    const x = 5 + ((i * 8.3) % 100)
    const y = 20 + ((i * 17 + 5) % 60)
    const delay = (i * 0.7) % 3
    const duration = 4 + (i % 3) * 2
    const size = 12 + (i % 4) * 4
    const opacity = 0.08 + (i % 3) * 0.06
    return {
      id: i,
      symbol,
      style: {
        left: `${x}%`,
        top: `${y}%`,
        animationDelay: `${delay}s`,
        animationDuration: `${duration}s`,
        fontSize: `${size}px`,
        opacity
      }
    }
  })
})

const wavePath1 = computed(() => {
  const w = width.value
  const h = height.value
  const points = 40
  const segments = []
  for (let i = 0; i <= points; i++) {
    const x = (i / points) * w
    const phase = (i / points) * Math.PI * 4
    const y = h * 0.5 + Math.sin(phase) * 20 + Math.sin(phase * 0.5 + 1) * 12
    segments.push(`${i === 0 ? 'M' : 'L'}${x.toFixed(0)},${y.toFixed(0)}`)
  }
  return segments.join(' ') + ` L${w},${h} L0,${h} Z`
})

const wavePath2 = computed(() => {
  const w = width.value
  const h = height.value
  const points = 30
  const segments = []
  for (let i = 0; i <= points; i++) {
    const x = (i / points) * w
    const phase = (i / points) * Math.PI * 3 + 1.5
    const y = h * 0.55 + Math.sin(phase) * 15 + Math.sin(phase * 0.7) * 8
    segments.push(`${i === 0 ? 'M' : 'L'}${x.toFixed(0)},${y.toFixed(0)}`)
  }
  return segments.join(' ') + ` L${w},${h} L0,${h} Z`
})

function updateDimensions() {
  if (containerRef.value) {
    width.value = containerRef.value.offsetWidth
    height.value = containerRef.value.offsetHeight
  }
}

onMounted(() => {
  updateDimensions()
  resizeObserver = new ResizeObserver(updateDimensions)
  if (containerRef.value) {
    resizeObserver.observe(containerRef.value)
  }
  fetchRate()
})

onBeforeUnmount(() => {
  if (resizeObserver) resizeObserver.disconnect()
})
</script>

<style scoped>
.market-rhythm {
  position: relative;
  width: 100%;
  height: 180px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.market-rhythm__bg {
  position: absolute;
  inset: 0;
}

.market-rhythm__wave {
  width: 100%;
  height: 100%;
}

.market-rhythm__path--1 {
  animation: wave-drift 6s ease-in-out infinite;
}

.market-rhythm__path--2 {
  animation: wave-drift 8s ease-in-out infinite reverse;
}

@keyframes wave-drift {
  0%,
  100% {
    transform: translateX(0);
  }
  50% {
    transform: translateX(10px);
  }
}

.market-rhythm__particles {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.market-rhythm__particle {
  position: absolute;
  font-family: var(--font-mono);
  font-weight: 600;
  color: var(--color-primary);
  animation: particle-float 4s ease-in-out infinite;
  will-change: transform;
}

@keyframes particle-float {
  0%,
  100% {
    transform: translateY(0px) rotate(0deg);
    opacity: 0.6;
  }
  25% {
    transform: translateY(-8px) rotate(5deg);
  }
  50% {
    transform: translateY(-4px) rotate(-3deg);
  }
  75% {
    transform: translateY(-10px) rotate(2deg);
  }
}

.market-rhythm__content {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 32px;
  z-index: 1;
}

.market-rhythm__rate {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.market-rhythm__tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 10px;
}

.tab-btn {
  background: transparent;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: 4px 14px;
  font-family: var(--font-mono);
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--color-text-muted);
  cursor: pointer;
  transition: all 0.2s ease;
}

.tab-btn:hover {
  border-color: var(--color-primary);
  color: var(--color-text);
}

.tab-btn.active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: #fff;
}

.market-rhythm__label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.market-rhythm__value {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: -0.02em;
  line-height: 1;
}

.market-rhythm__prices {
  display: flex;
  align-items: center;
  gap: 8px;
}

.market-rhythm__direction {
  display: inline-flex;
  align-items: center;
}

.market-rhythm__direction.sube {
  color: var(--color-positive);
}

.market-rhythm__direction.baja {
  color: var(--color-negative);
}

.market-rhythm__direction.estable {
  color: var(--color-text-muted);
}

.market-rhythm__spread {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 4px;
}

.spread-item {
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}

.spread-sep {
  color: var(--color-border);
}

.market-rhythm__stats {
  display: flex;
  flex-direction: column;
  gap: 16px;
  text-align: right;
}

.market-rhythm__stat {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.stat-label {
  font-family: var(--font-body);
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.stat-value {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--color-text);
}
</style>