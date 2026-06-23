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
              >{{ formatNumber(oferta.montoOfertado) }} {{ oferta.monedaEntregaCode || '' }}</span
            >
          </div>
          <div class="oferta-card__row">
            <span class="row-label">Monto Mínimo</span>
            <span class="row-value font-mono"
              >{{ formatNumber(oferta.montoMinimo) }} {{ oferta.monedaEntregaCode || '' }}</span
            >
          </div>
          <div class="oferta-card__row">
            <span class="row-label">Tasa de Cambio</span>
            <span class="row-value font-mono text-accent">{{
              formatNumber(oferta.tasaCambio)
            }}</span>
          </div>
          <div class="oferta-card__row" v-if="oferta.monedaRecibeCode">
            <span class="row-label">Recibes</span>
            <span class="row-value font-mono">{{ oferta.monedaRecibeCode }}</span>
          </div>
        </div>

        <div class="oferta-card__actions">
          <q-btn
            v-if="oferta.estado === 'ACTIVA'"
            color="primary"
            label="Ver matches"
            icon="search"
            outline
            no-caps
            class="btn-matches"
            @click="verMatches(oferta)"
          />
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

    <q-dialog v-model="matchesDialog" persistent>
      <q-card class="dialog-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="search" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Matches encontrados</h2>
          <p class="dialog-card__subtitle">Ofertas que coinciden con la tuya</p>
        </div>
        <q-card-section class="q-px-lg q-py-lg">
          <div v-if="matchesCargando" class="flex flex-center q-pa-md">
            <q-spinner color="primary" size="2em" />
          </div>
          <div v-else-if="matches.length === 0" class="matches-empty">
            <q-icon name="search_off" size="48px" color="grey-6" />
            <p class="matches-empty-text">No se encontraron matches para esta oferta</p>
          </div>
          <div v-else class="matches-list">
            <div v-for="match in matches" :key="match.idOferta" class="match-card">
              <div class="match-card__header">
                <div class="match-card__user">
                  <q-avatar size="28px" color="primary" text-color="white" class="match-avatar">
                    {{ match.nombreUsuario?.charAt(0)?.toUpperCase() || '?' }}
                  </q-avatar>
                  <span class="match-username">{{ match.nombreUsuario }}</span>
                </div>
                <div class="match-reputation" v-if="match.reputacion != null">
                  <q-icon name="star" size="14px" color="warning" />
                  <span>{{ match.reputacion.toFixed(1) }}</span>
                </div>
              </div>
              <div class="match-card__body">
                <div class="match-stat">
                  <span class="match-stat-label">Tasa</span>
                  <span class="match-stat-value font-mono text-accent">{{ formatNumber(match.tasaCambio) }}</span>
                </div>
                <div class="match-stat">
                  <span class="match-stat-label">Monto</span>
                  <span class="match-stat-value font-mono">{{ formatNumber(match.montoOfertado) }} {{ match.monedaEntregaCode }}</span>
                </div>
                <div class="match-stat">
                  <span class="match-stat-label">Mínimo</span>
                  <span class="match-stat-value font-mono">{{ formatNumber(match.montoMinimo) }} {{ match.monedaEntregaCode }}</span>
                </div>
              </div>
              <div class="match-card__metodos" v-if="match.metodosPago?.length">
                <span class="match-metodos-label">Métodos:</span>
                <div class="match-metodos-list">
                  <q-chip v-for="mp in match.metodosPago" :key="mp" size="12px" dense outline color="primary" text-color="primary">
                    {{ mp }}
                  </q-chip>
                </div>
              </div>
              <q-btn
                color="positive"
                label="Tomar match"
                icon="shopping_cart"
                unelevated
                no-caps
                class="match-btn"
                @click="tomarMatch(match)"
              />
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right" class="q-px-lg q-pb-lg">
          <q-btn flat label="Cerrar" v-close-popup class="dialog-cancel" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useOfertaStore } from '@/stores/ofertaStore'
import EmptyState from '@/components/EmptyState.vue'
import ofertaService from '@/services/ofertaService'
import transaccionService from '@/services/transaccionService'

const router = useRouter()
const $q = useQuasar()
const ofertaStore = useOfertaStore()

const loading = ref(true)
const matchesDialog = ref(false)
const matches = ref([])
const matchesCargando = ref(false)
const ofertaMatchesRef = ref(null)

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

const verMatches = async oferta => {
  ofertaMatchesRef.value = oferta
  matchesCargando.value = true
  matchesDialog.value = true
  try {
    const data = await ofertaService.matches(oferta.idOferta)
    matches.value = data || []
  } catch {
    matches.value = []
    $q.notify({ type: 'negative', message: 'Error al buscar matches', position: 'top' })
  } finally {
    matchesCargando.value = false
  }
}

const tomarMatch = async match => {
  if (!ofertaMatchesRef.value) return
  const oferta = ofertaMatchesRef.value
  const montoMin = Math.max(oferta.montoMinimo || 0, match.montoMinimo || 0)
  const montoMax = Math.min(oferta.montoOfertado || 0, match.montoOfertado || 0)
  const monto = montoMax

  try {
    const data = await transaccionService.crear({
      idOferta: match.idOferta,
      idMetodoPago: 1,
      monto
    })
    const tid = data.idTransaccion || data
    $q.notify({ type: 'positive', message: 'Transacción iniciada con el match', position: 'top' })
    matchesDialog.value = false
    router.push(`/transacciones/${tid}`)
  } catch (error) {
    const msg = error.response?.data?.mensaje || error.response?.data || 'Error al tomar match'
    $q.notify({ type: 'negative', message: msg, position: 'top' })
  }
}

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

.oferta-card__actions {
  display: flex;
  gap: 8px;
}

.btn-matches {
  flex: 1;
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.8rem;
}

.btn-cancelar {
  flex: 1;
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.8rem;
}

.dialog-card {
  min-width: 420px;
  border-radius: var(--radius-xl);
  overflow: hidden;
}

.dialog-card__header {
  background: var(--color-primary);
  padding: 24px;
  text-align: center;
}

.dialog-card__brand {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 12px;
}

.dialog-card__title {
  font-size: 1.2rem;
  font-weight: 700;
  color: white;
  margin: 0 0 4px;
}

.dialog-card__subtitle {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.7);
  margin: 0;
}

.matches-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 32px;
}

.matches-empty-text {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin: 0;
  text-align: center;
}

.matches-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.match-card {
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 16px;
}

.match-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.match-card__user {
  display: flex;
  align-items: center;
  gap: 8px;
}

.match-avatar {
  font-weight: 600;
  font-size: 0.75rem;
}

.match-username {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
}

.match-reputation {
  display: flex;
  align-items: center;
  gap: 4px;
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-warning);
}

.match-card__body {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
}

.match-stat {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.match-stat-label {
  font-family: var(--font-body);
  font-size: 0.65rem;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--color-text-muted);
}

.match-stat-value {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--color-text);
}

.match-card__metodos {
  margin-bottom: 12px;
}

.match-metodos-label {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-secondary);
  display: block;
  margin-bottom: 6px;
}

.match-metodos-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.match-btn {
  width: 100%;
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.85rem;
}

.dialog-cancel {
  color: var(--color-text-secondary);
  font-weight: 500;
  border-radius: var(--radius-sm);
}
</style>