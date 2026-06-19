<template>
  <q-page class="ofertas-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Ofertas del Mercado</h1>
        <p class="page-subtitle">Encuentra la mejor tasa para tu operación</p>
      </div>
      <q-btn
        v-if="authStore.isAuthenticated"
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
      v-else-if="ofertasVisibles.length === 0"
      icon="storefront"
      title="No hay ofertas disponibles"
      description="Sé el primero en publicar una oferta en el mercado"
      action-label="Crear Oferta"
      action-icon="add"
      action-color="primary"
      @action="$router.push('/ofertas/crear')"
    />

    <div v-else class="ofertas-grid">
      <div
        v-for="oferta in ofertasVisibles"
        :key="oferta.idOferta"
        class="oferta-card"
      >
        <div class="oferta-card__header">
          <div class="oferta-card__user">
            <q-avatar
              size="32px"
              color="primary"
              text-color="white"
              class="oferta-card__avatar"
            >
              {{ oferta.nombreUsuario?.charAt(0)?.toUpperCase() || '?' }}
            </q-avatar>
            <div>
              <div class="oferta-card__username">{{
                oferta.nombreUsuario
              }}</div>
              <div class="oferta-card__id">ID #{{ oferta.idOferta }}</div>
            </div>
          </div>
          <q-badge
            :color="oferta.tipoOperacion === 'VENTA' ? 'positive' : 'info'"
            rounded
            class="oferta-card__type-badge"
          >
            <q-icon
              :name="
                oferta.tipoOperacion === 'VENTA'
                  ? 'trending_down'
                  : 'trending_up'
              "
              size="14px"
              class="q-mr-xs"
            />
            {{ oferta.tipoOperacion }}
          </q-badge>
        </div>

        <div class="oferta-card__body">
          <div class="oferta-card__stat">
            <span class="stat-label">Monto</span>
            <span class="stat-value font-mono"
              >S/ {{ formatNumber(oferta.montoOfertado) }}</span
            >
          </div>
          <div class="oferta-card__divider"></div>
          <div class="oferta-card__stat">
            <span class="stat-label">Tasa</span>
            <span class="stat-value font-mono text-accent">{{
              formatNumber(oferta.tasaCambio)
            }}</span>
          </div>
          <div class="oferta-card__divider"></div>
          <div class="oferta-card__stat">
            <span class="stat-label">Mínimo</span>
            <span class="stat-value font-mono"
              >S/ {{ formatNumber(oferta.montoMinimo) }}</span
            >
          </div>
        </div>

        <div class="oferta-card__actions">
          <q-btn
            v-if="authStore.isAuthenticated"
            color="primary"
            label="Tomar Oferta"
            icon="shopping_cart"
            no-caps
            unelevated
            class="oferta-card__btn"
            @click="abrirDialogo(oferta)"
          />
          <q-btn
            v-else
            color="primary"
            label="Inicia sesión para participar"
            outline
            no-caps
            class="oferta-card__btn"
            @click="$router.push('/login')"
          />
        </div>
      </div>
    </div>

    <!-- Tomar Oferta Dialog -->
    <q-dialog v-model="dialogoVisible" persistent>
      <q-card class="dialog-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="currency_exchange" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Confirmar Operación</h2>
        </div>
        <q-card-section class="q-px-lg q-pt-lg">
          <div class="dialog-info">
            <div class="dialog-info__row">
              <span class="dialog-info__label">Vendedor</span>
              <span class="dialog-info__value">{{
                ofertaSeleccionada?.nombreUsuario
              }}</span>
            </div>
            <div class="dialog-info__row">
              <span class="dialog-info__label">Tipo</span>
              <q-badge
                :color="
                  ofertaSeleccionada?.tipoOperacion === 'VENTA'
                    ? 'positive'
                    : 'info'
                "
                rounded
              >
                {{ ofertaSeleccionada?.tipoOperacion }}
              </q-badge>
            </div>
            <div class="dialog-info__row">
              <span class="dialog-info__label">Rango</span>
              <span class="dialog-info__value">
                S/ {{ formatNumber(ofertaSeleccionada?.montoMinimo) }} – S/
                {{ formatNumber(ofertaSeleccionada?.montoOfertado) }}
              </span>
            </div>
            <div class="dialog-info__row">
              <span class="dialog-info__label">Tasa</span>
              <span class="dialog-info__value font-mono text-accent">{{
                formatNumber(ofertaSeleccionada?.tasaCambio)
              }}</span>
            </div>
          </div>

          <div class="field-group q-mt-md">
            <label class="field-label">Monto a operar (S/)</label>
            <q-input
              v-model.number="montoOperacion"
              type="number"
              outlined
              dense
              placeholder="0.00"
              class="dialog-input"
              :rules="[
                val =>
                  val >= (ofertaSeleccionada?.montoMinimo || 0) ||
                  `Mín S/ ${formatNumber(ofertaSeleccionada?.montoMinimo)}`,
                val =>
                  val <= (ofertaSeleccionada?.montoOfertado || 0) ||
                  `Máx S/ ${formatNumber(ofertaSeleccionada?.montoOfertado)}`
              ]"
              hide-bottom-space
            />
          </div>

          <div class="field-group q-mt-md">
            <label class="field-label">Método de pago</label>
            <q-select
              v-model="metodoPago"
              :options="opcionesMetodoPago"
              outlined
              dense
              placeholder="Seleccionar"
              class="dialog-input"
              emit-value
              :rules="[val => !!val || 'Selecciona un método']"
              hide-bottom-space
            >
              <template v-slot:option="scope">
                <q-item v-bind="scope.itemProps">
                  <q-item-section avatar>
                    <q-icon :name="scope.opt.icon" size="20px" />
                  </q-item-section>
                  <q-item-section>
                    <q-item-label>{{ scope.opt.label }}</q-item-label>
                  </q-item-section>
                </q-item>
              </template>
              <template v-slot:selected-item="scope">
                <div class="row items-center">
                  <q-icon :name="getMetodoIcon(scope.opt)" size="18px" class="q-mr-sm" />
                  {{ getMetodoLabel(scope.opt) }}
                </div>
              </template>
            </q-select>
          </div>
        </q-card-section>

        <q-card-actions align="right" class="q-px-lg q-pb-lg">
          <q-btn flat label="Cancelar" v-close-popup class="dialog-cancel" />
          <q-btn
            color="primary"
            label="Confirmar Operación"
            unelevated
            no-caps
            :loading="creando"
            :disable="creando || !metodoPago || !montoOperacion"
            class="dialog-confirm"
            @click="tomarOferta"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/authStore'
import { useOfertaStore } from '@/stores/ofertaStore'
import { useTransaccionStore } from '@/stores/transaccionStore'
import EmptyState from '@/components/EmptyState.vue'

const $q = useQuasar()
const authStore = useAuthStore()
const ofertaStore = useOfertaStore()
const transaccionStore = useTransaccionStore()

const loading = ref(false)
const dialogoVisible = ref(false)
const creando = ref(false)
const ofertaSeleccionada = ref(null)
const metodoPago = ref(null)
const montoOperacion = ref(null)

const opcionesMetodoPago = [
  { label: 'Yape', value: 1, icon: 'qr_code' },
  { label: 'Plin', value: 2, icon: 'qr_code_scanner' },
  { label: 'Transferencia Bancaria', value: 3, icon: 'account_balance' }
]

const ofertasVisibles = computed(() => {
  if (!authStore.isAuthenticated) return ofertaStore.ofertas
  return ofertaStore.ofertas.filter(o => o.idUsuario !== authStore.userId)
})

function formatNumber(val) {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function getMetodoIcon(val) {
  const opt = opcionesMetodoPago.find(o => o.value === val)
  return opt?.icon || 'info'
}

function getMetodoLabel(val) {
  const opt = opcionesMetodoPago.find(o => o.value === val)
  return opt?.label || ''
}

function abrirDialogo(oferta) {
  ofertaSeleccionada.value = oferta
  metodoPago.value = null
  montoOperacion.value = null
  dialogoVisible.value = true
}

async function tomarOferta() {
  if (!metodoPago.value || !ofertaSeleccionada.value || !montoOperacion.value)
    return
  creando.value = true
  try {
    await transaccionStore.crear({
      idOferta: ofertaSeleccionada.value.idOferta,
      idMetodoPago: metodoPago.value,
      monto: montoOperacion.value
    })
    $q.notify({
      type: 'positive',
      message: 'Transacción iniciada exitosamente',
      position: 'top'
    })
    dialogoVisible.value = false
  } catch (error) {
    const res = error.response
    let msg = 'Error al tomar la oferta'
    if (res?.data) {
      if (typeof res.data === 'string') msg = res.data
      else if (res.data.mensaje) msg = res.data.mensaje
      else if (res.data.message) msg = res.data.message
      else if (res.data.title) msg = res.data.title
    }
    $q.notify({ type: 'negative', message: msg, position: 'top' })
  } finally {
    creando.value = false
  }
}

onMounted(async () => {
  loading.value = true
  try {
    await ofertaStore.listarActivas()
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al cargar ofertas',
      position: 'top'
    })
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.ofertas-page {
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
  .ofertas-page {
    padding: 20px 16px;
  }
  .page-header {
    flex-direction: column;
    gap: 12px;
  }
}

.ofertas-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
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
  transform: translateY(-3px);
  box-shadow: var(--shadow-md);
  border-color: var(--color-primary-light);
}

.oferta-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.oferta-card__user {
  display: flex;
  align-items: center;
  gap: 10px;
}

.oferta-card__avatar {
  font-weight: 600;
  font-size: 0.85rem;
}

.oferta-card__username {
  font-family: var(--font-body);
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text);
}

.oferta-card__id {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.oferta-card__type-badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 4px 10px;
}

.oferta-card__body {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.oferta-card__stat {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.stat-label {
  font-family: var(--font-body);
  font-size: 0.7rem;
  font-weight: 500;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.stat-value {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text);
}

.oferta-card__divider {
  width: 1px;
  height: 32px;
  background: var(--color-border);
}

.oferta-card__actions {
  display: flex;
  gap: 8px;
}

.oferta-card__btn {
  flex: 1;
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.85rem;
}

.dialog-card {
  min-width: 420px;
  border-radius: var(--radius-xl);
}

.dialog-card__header {
  background: var(--color-primary);
  padding: 28px 24px;
  text-align: center;
  border-radius: var(--radius-xl) var(--radius-xl) 0 0;
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
  margin: 0;
}

.dialog-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 16px;
  background: var(--color-bg);
  border-radius: var(--radius-md);
}

.dialog-info__row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dialog-info__label {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}

.dialog-info__value {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.dialog-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  min-height: 44px;
}

.dialog-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.dialog-cancel {
  color: var(--color-text-secondary);
  font-weight: 500;
}

.dialog-confirm {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
}
</style>
