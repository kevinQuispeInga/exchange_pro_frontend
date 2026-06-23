<template>
  <div class="tipo-cambio-bar" v-if="rates.length">
    <div class="tc-tabs">
      <button
        v-for="m in rates"
        :key="m.codigo"
        class="tc-tab"
        :class="{ active: selected === m.codigo }"
        @click="selected = m.codigo"
      >
        {{ m.codigo }}
      </button>
    </div>
    <div class="tc-row">
      <span class="tc-label">{{ activeRate.codigo }}/PEN</span>
      <span class="tc-direction" :class="activeRate.direccion">
        {{ activeRate.direccion === 'sube' ? '▲' : activeRate.direccion === 'baja' ? '▼' : '–' }}
      </span>
    </div>
    <div class="tc-row">
      <span class="tc-price"><span class="tc-label-inline">C </span>S/{{ activeRate.compra }}</span>
      <span class="tc-sep">|</span>
      <span class="tc-price"><span class="tc-label-inline">V </span>S/{{ activeRate.venta }}</span>
    </div>
  </div>
  <div class="tipo-cambio-bar skeleton" v-else>
    <div class="tc-row">Cargando...</div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import tipoCambioService from '@/services/tipoCambioService'

const rates = ref([])
const selected = ref('USD')

const activeRate = computed(() => {
  return rates.value.find(m => m.codigo === selected.value) || rates.value[0] || { codigo: 'USD', compra: 0, venta: 0, direccion: 'estable' }
})

const fetch = async () => {
  try {
    const data = await tipoCambioService.obtener()
    rates.value = data.monedas || []
  } catch {
    rates.value = []
  }
}

onMounted(fetch)
</script>

<style scoped>
.tipo-cambio-bar {
  padding: 12px 16px;
  border-top: 1px solid var(--color-border);
  font-size: 0.78rem;
  line-height: 1.5;
}

.tc-row {
  display: flex;
  align-items: center;
  gap: 6px;
}

.tc-label {
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: 0.03em;
}

.tc-direction {
  font-weight: 700;
}

.tc-direction.sube { color: var(--color-positive); }
.tc-direction.baja { color: var(--color-negative); }
.tc-direction.estable { color: var(--color-text-muted); }

.tc-price {
  font-family: var(--font-mono);
  color: var(--color-text-secondary);
}

.tc-label-inline {
  font-family: var(--font-body);
  font-weight: 600;
  color: var(--color-text-muted);
  font-size: 0.7rem;
}

.tc-sep {
  color: var(--color-border);
}

.tc-tabs {
  display: flex;
  gap: 6px;
  margin-bottom: 6px;
}

.tc-tab {
  background: transparent;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  padding: 2px 8px;
  font-family: var(--font-mono);
  font-size: 0.7rem;
  font-weight: 600;
  color: var(--color-text-muted);
  cursor: pointer;
  transition: all 0.2s ease;
}

.tc-tab:hover {
  border-color: var(--color-primary);
  color: var(--color-text);
}

.tc-tab.active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: #fff;
}

.skeleton {
  color: var(--color-text-muted);
  font-size: 0.75rem;
}
</style>