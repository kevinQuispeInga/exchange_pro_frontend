<template>
  <div class="empty-state">
    <div class="empty-state__icon-wrapper">
      <q-icon :name="icon" size="48px" class="empty-state__icon" />
    </div>
    <h3 class="empty-state__title font-display">{{ title }}</h3>
    <p v-if="description" class="empty-state__description">{{ description }}</p>
    <div v-if="$slots.default || actionLabel" class="empty-state__action">
      <slot>
        <q-btn
          v-if="actionLabel"
          :label="actionLabel"
          :color="actionColor"
          :to="actionTo"
          :icon="actionIcon"
          no-caps
          unelevated
          class="empty-state__btn"
          @click="$emit('action')"
        />
      </slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  icon: { type: String, default: 'inbox' },
  title: { type: String, required: true },
  description: { type: String, default: '' },
  actionLabel: { type: String, default: '' },
  actionTo: { type: [String, Object], default: null },
  actionIcon: { type: String, default: '' },
  actionColor: { type: String, default: 'primary' }
})

defineEmits(['action'])
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  padding: 60px 24px;
  min-height: 300px;
}

.empty-state__icon-wrapper {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(27, 58, 75, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
}

.empty-state__icon {
  color: var(--color-text-muted);
}

.empty-state__title {
  font-size: 1.3rem;
  font-weight: 600;
  color: var(--color-text);
  margin: 0 0 8px;
}

.empty-state__description {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin: 0 0 24px;
  max-width: 380px;
  line-height: 1.5;
}

.empty-state__btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
}
</style>
