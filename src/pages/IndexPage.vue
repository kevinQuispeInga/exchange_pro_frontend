<template>
  <q-page class="dashboard">
    <div class="dashboard__header">
      <div>
        <h1 class="dashboard__greeting font-display">
          {{
            authStore.isAuthenticated
              ? `Hola, ${authStore.user?.nombres || authStore.user?.correo?.split('@')[0] || 'Usuario'}`
              : 'Bienvenido a ExchangePro'
          }}
        </h1>
        <p class="dashboard__subtitle">
          {{
            authStore.isAuthenticated
              ? 'Gestiona tus intercambios P2P desde un solo lugar'
              : 'La plataforma segura de intercambio de divisas entre personas'
          }}
        </p>
      </div>
      <div v-if="!authStore.isAuthenticated" class="dashboard__cta">
        <q-btn
          label="Comenzar"
          icon="arrow_forward"
          color="primary"
          no-caps
          unelevated
          to="/register"
          class="cta-btn"
        />
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { useAuthStore } from '@/stores/authStore'

const authStore = useAuthStore()
</script>

<style scoped>
.dashboard {
  padding: 28px 32px;
  max-width: 1280px;
  margin: 0 auto;
}

.dashboard__header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 24px;
}

.dashboard__greeting {
  font-size: 1.6rem;
  font-weight: 700;
  color: var(--color-text);
  margin: 0 0 4px;
}

.dashboard__subtitle {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin: 0;
}

.cta-btn {
  border-radius: var(--radius-sm);
  padding: 8px 24px;
  font-weight: 600;
}

.dashboard__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 768px) {
  .dashboard {
    padding: 20px 16px;
  }
  .dashboard__grid {
    grid-template-columns: 1fr;
  }
  .dashboard__header {
    flex-direction: column;
    gap: 12px;
  }
  .dashboard__greeting {
    font-size: 1.3rem;
  }
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.section-title {
  font-size: 1.15rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.section-link {
  font-weight: 500;
  font-size: 0.85rem;
}

.dashboard__section {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
}

.section-empty {
  padding: 32px 0;
  text-align: center;
  color: var(--color-text-muted);
  font-family: var(--font-body);
  font-size: 0.9rem;
}

.oferta-row,
.activity-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid var(--color-border-light);
  cursor: pointer;
  transition: background var(--transition-fast);
}

.activity-row {
  cursor: pointer;
}

.activity-row:hover {
  background: rgba(27, 58, 75, 0.03);
  margin: 0 -8px;
  padding: 10px 8px;
  border-radius: 6px;
}

.oferta-row:last-child,
.activity-row:last-child {
  border-bottom: none;
}

.oferta-row__user {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
}

.oferta-row__name {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.oferta-row__type {
  flex-shrink: 0;
}

.badge-sm {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 2px 8px;
}

.oferta-row__rate,
.oferta-row__amount {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
  text-align: right;
  min-width: 70px;
}

.activity-row__code {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-primary);
  flex: 1;
}

.activity-row__amount {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
  min-width: 80px;
  text-align: right;
}
</style>
