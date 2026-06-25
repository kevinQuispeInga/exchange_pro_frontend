<template>
  <div
    class="stat-card"
    :class="[`stat-card--${color}`, { 'stat-card--interactive': interactive }]"
    @click="$emit('click')"
  >
    <div class="stat-card__icon-wrapper">
      <q-icon :name="icon" size="22px" class="stat-card__icon" />
    </div>
    <div class="stat-card__body">
      <div class="stat-card__label">{{ label }}</div>
      <div class="stat-card__value font-display">
        <span v-if="prefix" class="stat-card__prefix">{{ prefix }}</span>
        {{ displayValue }}
        <span v-if="suffix" class="stat-card__suffix">{{ suffix }}</span>
      </div>
      <div v-if="subtext" class="stat-card__subtext">{{ subtext }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'

const props = defineProps({
  label: { type: String, required: true },
  value: { type: [Number, String], default: 0 },
  icon: { type: String, default: 'trending_up' },
  color: { type: String, default: 'primary' },
  prefix: { type: String, default: '' },
  suffix: { type: String, default: '' },
  subtext: { type: String, default: '' },
  animated: { type: Boolean, default: true },
  interactive: { type: Boolean, default: false },
  decimals: { type: Number, default: 0 }
})

defineEmits(['click'])

const displayValue = ref('0')

function animateValue(target) {
  if (!props.animated || typeof target !== 'number') {
    displayValue.value = formatValue(target)
    return
  }
  const numTarget = Number(target)
  if (isNaN(numTarget)) {
    displayValue.value = String(target)
    return
  }
  const duration = 800
  const start = performance.now()
  const startVal = 0

  function update(currentTime) {
    const elapsed = currentTime - start
    const progress = Math.min(elapsed / duration, 1)
    const eased = 1 - Math.pow(1 - progress, 3)
    const current = startVal + (numTarget - startVal) * eased
    displayValue.value = formatValue(current)
    if (progress < 1) {
      requestAnimationFrame(update)
    } else {
      displayValue.value = formatValue(numTarget)
    }
  }

  requestAnimationFrame(update)
}

function formatValue(val) {
  if (typeof val === 'number') {
    return val.toLocaleString('es-PE', {
      minimumFractionDigits: props.decimals,
      maximumFractionDigits: props.decimals
    })
  }
  return String(val)
}

watch(
  () => props.value,
  newVal => {
    animateValue(newVal)
  },
  { immediate: true }
)
</script>

<style scoped>
.stat-card {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 18px 20px;
  transition: transform var(--transition-base), box-shadow var(--transition-base);
}

.stat-card--interactive {
  cursor: pointer;
}

.stat-card--interactive:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
  border-color: var(--color-primary);
}

.stat-card__icon-wrapper {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-card--primary .stat-card__icon-wrapper {
  background: rgba(27, 58, 75, 0.1);
  color: var(--color-primary);
}

.stat-card--accent .stat-card__icon-wrapper {
  background: rgba(200, 121, 65, 0.1);
  color: var(--color-accent);
}

.stat-card--positive .stat-card__icon-wrapper {
  background: rgba(43, 122, 98, 0.1);
  color: var(--color-positive);
}

.stat-card--info .stat-card__icon-wrapper {
  background: rgba(37, 99, 235, 0.1);
  color: var(--color-info);
}

.stat-card--warning .stat-card__icon-wrapper {
  background: rgba(217, 119, 6, 0.1);
  color: var(--color-warning);
}

.stat-card__label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  margin-bottom: 2px;
}

.stat-card__value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: -0.02em;
  line-height: 1.2;
}

.stat-card__prefix,
.stat-card__suffix {
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text-secondary);
}

.stat-card__subtext {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
  margin-top: 2px;
}
</style>
