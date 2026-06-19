<template>
  <q-item
    clickable
    tag="a"
    :href="props.link"
    :class="{ 'nav-item--active': isActive }"
    class="nav-item"
  >
    <q-item-section avatar class="nav-item__icon">
      <q-icon :name="props.icon" size="20px" />
    </q-item-section>
    <q-item-section>
      <q-item-label class="nav-item__label">{{ props.title }}</q-item-label>
      <q-item-label v-if="props.caption" caption class="nav-item__caption">{{
        props.caption
      }}</q-item-label>
    </q-item-section>
    <q-item-section v-if="props.badge" side>
      <q-badge :label="props.badge" color="accent" rounded />
    </q-item-section>
  </q-item>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const props = defineProps({
  title: { type: String, required: true },
  caption: { type: String, default: '' },
  link: { type: String, default: '#' },
  icon: { type: String, default: '' },
  badge: { type: [String, Number], default: null }
})

const route = useRoute()

const isActive = computed(() => {
  const linkPath = props.link.replace('#', '')
  if (linkPath === '/') return route.path === '/'
  return route.path.startsWith(linkPath)
})
</script>

<style scoped>
.nav-item {
  border-radius: 8px;
  margin: 2px 8px;
  padding: 4px 8px;
  transition: background 0.2s ease, color 0.2s ease;
  position: relative;
}

.nav-item:hover {
  background: rgba(124, 58, 237, 0.06);
}

.nav-item--active {
  background: rgba(124, 58, 237, 0.12);
}

.nav-item--active::before {
  content: '';
  position: absolute;
  left: -8px;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 20px;
  background: var(--color-primary);
  border-radius: 0 3px 3px 0;
  box-shadow: 0 0 6px rgba(124, 58, 237, 0.4);
}

.nav-item--active .nav-item__icon :deep(.q-icon) {
  color: var(--color-primary-light);
}

.nav-item--active .nav-item__label {
  color: var(--color-primary-light);
  font-weight: 600;
}

.nav-item__icon :deep(.q-icon) {
  color: var(--color-text-secondary);
  transition: color 0.2s ease;
}

.nav-item__label {
  font-family: var(--font-body);
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--color-text);
  transition: color 0.2s ease;
}

.nav-item__caption {
  font-size: 0.75rem;
}
</style>
