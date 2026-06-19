<template>
  <q-page class="mis-ofertas-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Mis Ofertas</h1>
        <p class="page-subtitle"
          >Administra tus ofertas publicadas en el mercado</p
        >
      </div>
      <q-btn
        color="primary"
        label="Crear Oferta"
        icon="add"
        no-caps
        unelevated
        class="page-action"
        @click="$router.push('/ofertas/crear')"
      />
    </div>

    <div v-if="loading" class="flex flex-center q-pa-xl">
      <q-spinner color="primary" size="3em" />
    </div>

    <EmptyState
      v-else-if="ofertaStore.misOfertas.length === 0"
      icon="assignment"
      title="No tienes ofertas publicadas"
      description="Crea tu primera oferta y comienza a operar en el mercado P2P"
      action-label="Crear Oferta"
      action-icon="add"
      action-color="primary"
      @action="$router.push('/ofertas/crear')"
    />

    <div v-else class="ofertas-grid">
      <div
        v-for="oferta in ofertaStore.misOfertas"
        :key="oferta.idOferta"
        class="oferta-card"
      >
        <div class="oferta-card__top">
          <q-badge
            :color="oferta.tipoOperacion === 'COMPRA' ? 'info' : 'positive'"
            rounded
            class="badge-type"
          >
            {{ oferta.tipoOperacion }}
          </q-badge>
          <q-badge
            :color="estadoColor(oferta.estado)"
            rounded
            class="badge-estado"
          >
            {{ oferta.estado }}
          </q-badge>
        </div>

        <div class="oferta-card__body">
          <div class="oferta-card__row">
            <span class="row-label">Monto Ofertado</span>
            <span class="row-value font-mono"
              >S/ {{ formatNumber(oferta.montoOfertado) }}</span
            >
          </div>
          <div class="oferta-card__row">
            <span class="row-label">Monto Mínimo</span>
            <span class="row-value font-mono"
              >S/ {{ formatNumber(oferta.montoMinimo) }}</span
            >
          </div>
          <div class="oferta-card__row">
            <span class="row-label">Tasa de Cambio</span>
            <span class="row-value font-mono text-accent">{{
              formatNumber(oferta.tasaCambio)
            }}</span>
          </div>
        </div>

        <div class="oferta-card__actions">
          <q-btn
            v-if="oferta.estado === 'ACTIVA'"
            color="negative"
            label="Cancelar Oferta"
            icon="cancel"
            outline
            no-caps
            class="btn-cancelar"
            @click="confirmarCancelar(oferta.idOferta)"
          />
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useOfertaStore } from '@/stores/ofertaStore'
import EmptyState from '@/components/EmptyState.vue'

const $q = useQuasar()
const ofertaStore = useOfertaStore()

const loading = ref(true)

const estadoColor = estado => {
  const map = {
    ACTIVA: 'positive',
    CANCELADA: 'negative',
    COMPLETADA: 'info',
    PENDIENTE: 'warning'
  }
  return map[estado] || 'grey'
}

const formatNumber = val => {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

onMounted(async () => {
  try {
    await ofertaStore.listarMisOfertas()
  } finally {
    loading.value = false
  }
})

const confirmarCancelar = id => {
  $q.dialog({
    title: 'Cancelar Oferta',
    message:
      '¿Estás seguro de cancelar esta oferta? Los fondos retenidos serán liberados.',
    cancel: { label: 'Volver', flat: true, color: 'grey' },
    ok: { label: 'Sí, cancelar', color: 'negative', unelevated: true },
    persistent: true
  }).onOk(async () => {
    try {
      await ofertaStore.cancelar(id)
      $q.notify({
        type: 'positive',
        message: 'Oferta cancelada. Fondos liberados.',
        position: 'top'
      })
    } catch (error) {
      $q.notify({
        type: 'negative',
        message: error.response?.data?.mensaje || 'Error al cancelar',
        position: 'top'
      })
    }
  })
}
</script>

<style scoped>
.mis-ofertas-page {
  padding: 28px 32px;
  max-width: 1280px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: flex-start;
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

.page-action {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 20px;
}

@media (max-width: 768px) {
  .mis-ofertas-page {
    padding: 20px 16px;
  }
  .page-header {
    flex-direction: column;
    gap: 12px;
  }
}

.ofertas-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}

.oferta-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
  transition: transform var(--transition-base), box-shadow var(--transition-base);
}

.oferta-card:hover {
  box-shadow: var(--shadow-sm);
}

.oferta-card__top {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
}

.badge-type,
.badge-estado {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 3px 10px;
}

.oferta-card__body {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 16px;
}

.oferta-card__row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.row-label {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}

.row-value {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--color-text);
}

.btn-cancelar {
  width: 100%;
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.85rem;
}
</style>
