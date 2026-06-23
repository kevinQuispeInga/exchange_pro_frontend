<template>
  <q-page class="crear-oferta-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Crear Oferta</h1>
        <p class="page-subtitle">Publica una nueva oferta en el mercado P2P</p>
      </div>
    </div>

    <div v-if="loadingWallet" class="flex flex-center q-pa-xl">
      <q-spinner color="primary" size="3em" />
    </div>

    <template v-else>
      <div class="wallet-summary">
        <div class="wallet-summary__icon">
          <q-icon name="account_balance_wallet" size="24px" color="white" />
        </div>
        <div class="wallet-summary__content">
          <span class="wallet-summary__label">Tu saldo disponible</span>
          <div class="wallet-summary__balances">
            <span
              v-for="saldo in walletStore.saldos"
              :key="saldo.idMoneda"
              class="balance-chip font-mono"
            >
              {{ monedaLabel(saldo.idMoneda) }}: {{ currencySymbol(saldo.idMoneda) }}
              {{ formatNumber(saldo.saldoDisponible) }}
            </span>
            <span v-if="walletStore.saldos.length === 0" class="text-muted"
              >Sin saldo. Recarga primero</span
            >
          </div>
        </div>
      </div>

      <div class="form-card">
        <div class="form-card__header">
          <q-icon
            name="add_circle_outline"
            size="22px"
            class="form-card__header-icon"
          />
          <h2 class="form-card__title font-display">Detalles de la Oferta</h2>
        </div>

        <q-form @submit="crearOferta" class="form-card__body">
          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Tipo de Operación</label>
                <q-select
                  v-model="form.tipoOperacion"
                  :options="['COMPRA', 'VENTA']"
                  outlined
                  dense
                  dark
                  placeholder="Seleccionar"
                  class="form-input"
                  popup-content-class="select-popup-dark"
                  :rules="[val => !!val || 'Requerido']"
                  hide-bottom-space
                />
              </div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Tasa de Cambio</label>
                <q-select
                  v-model="form.tasaCambio"
                  :options="tasaOptions"
                  outlined
                  dense
                  dark
                  placeholder="Seleccionar"
                  class="form-input"
                  emit-value
                  map-options
                  popup-content-class="select-popup-dark"
                  :rules="[val => !!val || 'Requerido']"
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">{{
                  form.tipoOperacion === 'COMPRA'
                    ? 'Moneda a Comprar'
                    : 'Moneda a Vender'
                }}</label>
                <q-select
                  v-model="form.monedaEntrega"
                  :options="opcionesMoneda"
                  outlined
                  dense
                  dark
                  placeholder="Seleccionar"
                  class="form-input"
                  emit-value
                  map-options
                  popup-content-class="select-popup-dark"
                  :rules="[val => !!val || 'Requerido']"
                  hide-bottom-space
                />
              </div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">{{
                  form.tipoOperacion === 'COMPRA'
                    ? 'Moneda a Pagar'
                    : 'Moneda a Recibir'
                }}</label>
                <q-select
                  v-model="form.monedaRecibe"
                  :options="opcionesMoneda"
                  outlined
                  dense
                  dark
                  placeholder="Seleccionar"
                  class="form-input"
                  emit-value
                  map-options
                  popup-content-class="select-popup-dark"
                  :rules="[val => !!val || 'Requerido']"
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <div class="row q-col-gutter-md">
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Monto a Ofertado ({{ monedaLabel(form.monedaEntrega) }})</label>
                <q-input
                  v-model.number="form.montoOfertado"
                  type="number"
                  outlined
                  dense
                  dark
                  placeholder="0.00"
                  class="form-input"
                  name="montoOfertado"
                  autocomplete="off"
                  :rules="[
                    val => !!val || 'Requerido',
                    val => val > 0 || 'Debe ser > 0'
                  ]"
                  hide-bottom-space
                />
                <div
                  v-if="form.montoOfertado > 0 && form.tasaCambio"
                  class="conversion-preview"
                >
                  <span v-if="form.tipoOperacion === 'COMPRA'">
                      Pagarás ≈ <strong>{{ formatNumber(calcularMontoRecibe(form.montoOfertado, form.tasaCambio)) }} {{ monedaLabel(form.monedaRecibe) }}</strong>
                    </span>
                    <span v-else>
                      Recibirás ≈ <strong>{{ formatNumber(calcularMontoRecibe(form.montoOfertado, form.tasaCambio)) }} {{ monedaLabel(form.monedaRecibe) }}</strong>
                  </span>
                </div>
              </div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Monto Mínimo ({{ monedaLabel(form.monedaEntrega) }})</label>
                <q-input
                  v-model.number="form.montoMinimo"
                  type="number"
                  outlined
                  dense
                  dark
                  placeholder="0.00"
                  class="form-input"
                  :rules="[
                    val => !!val || 'Requerido',
                    val => val > 0 || 'Debe ser > 0',
                    val => val <= form.montoOfertado || 'No > al ofertado'
                  ]"
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <div class="form-card__actions">
            <q-btn
              label="Cancelar"
              flat
              no-caps
              class="btn-cancel"
              @click="$router.push('/mis-ofertas')"
            />
            <q-btn
              label="Publicar Oferta"
              type="submit"
              color="primary"
              unelevated
              no-caps
              :loading="loading"
              :disable="loading"
              class="btn-submit"
            />
          </div>
        </q-form>
      </div>
    </template>
  </q-page>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useQuasar } from 'quasar'
import { useRouter } from 'vue-router'
import { useOfertaStore } from '@/stores/ofertaStore'
import { useWalletStore } from '@/stores/walletStore'
import { currencySymbol } from '@/utils/formatCurrency'

const $q = useQuasar()
const router = useRouter()
const ofertaStore = useOfertaStore()
const walletStore = useWalletStore()

const loading = ref(false)
const loadingWallet = ref(true)

const opcionesMoneda = [
  { label: 'PEN (Soles)', value: 1 },
  { label: 'USD (Dólares)', value: 2 },
  { label: 'EUR (Euros)', value: 3 },
  { label: 'JPY (Yenes)', value: 4 },
  { label: 'GBP (Libras)', value: 5 }
]

const tasaOptions = [
  { label: '3.70', value: 3.7 },
  { label: '3.75', value: 3.75 },
  { label: '3.80', value: 3.8 },
  { label: '3.85', value: 3.85 },
  { label: '3.90', value: 3.9 },
  { label: '3.95', value: 3.95 },
  { label: '4.00', value: 4.0 }
]

const monedaLabel = id => {
  const m = opcionesMoneda.find(o => o.value === id)
  return m ? m.label.split(' ')[0] : id
}

const formatNumber = val => {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

const calcularMontoRecibe = (monto, tasa) => {
  if (!monto || !tasa) return 0
  return monto * tasa
}

const form = ref({
  tipoOperacion: null,
  monedaEntrega: null,
  monedaRecibe: null,
  montoOfertado: null,
  montoMinimo: null,
  tasaCambio: null
})

onMounted(async () => {
  try {
    await walletStore.cargarSaldo()
  } finally {
    loadingWallet.value = false
  }
})

const crearOferta = async () => {
  if (form.value.monedaEntrega === form.value.monedaRecibe) {
    $q.notify({
      type: 'negative',
      message: 'Las monedas deben ser diferentes',
      position: 'top'
    })
    return
  }
  loading.value = true
  try {
    await ofertaStore.crear({ ...form.value })
    $q.notify({
      type: 'positive',
      message: 'Oferta publicada exitosamente',
      position: 'top'
    })
    router.push('/mis-ofertas')
  } catch (error) {
    const res = error.response
    let msg = 'Error al publicar la oferta'
    if (res?.data) {
      if (typeof res.data === 'string') msg = res.data
      else if (res.data.mensaje) msg = res.data.mensaje
      else if (res.data.title) msg = res.data.title
      else if (res.data.errors) {
        const first = Object.values(res.data.errors)[0]
        msg = Array.isArray(first) ? first[0] : first
      }
    }
    $q.notify({ type: 'negative', message: msg, position: 'top' })
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.crear-oferta-page {
  padding: 28px 32px;
  max-width: 800px;
  margin: 0 auto;
}

.page-header {
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

@media (max-width: 768px) {
  .crear-oferta-page {
    padding: 20px 16px;
  }
}

.wallet-summary {
  display: flex;
  align-items: center;
  gap: 14px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 16px 20px;
  margin-bottom: 20px;
}

.wallet-summary__icon {
  width: 44px;
  height: 44px;
  background: var(--color-primary);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.wallet-summary__label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  display: block;
  margin-bottom: 4px;
}

.wallet-summary__balances {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.balance-chip {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text);
  padding: 2px 10px;
  background: var(--color-bg);
  border-radius: 6px;
}

.text-muted {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

.form-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.form-card__header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 20px 24px;
  border-bottom: 1px solid var(--color-border-light);
}

.form-card__header-icon {
  color: var(--color-primary);
}

.form-card__title {
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.form-card__body {
  padding: 24px;
}

.form-card__actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 24px;
  border-top: 1px solid var(--color-border-light);
  margin-top: 24px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 16px;
}

.field-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.form-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  min-height: 44px;
}

.form-input :deep(.q-field__native),
.form-input :deep(.q-field__input) {
  color: #ffffff !important;
}

.form-input :deep(.q-field__native span),
.form-input :deep(.q-field__input span) {
  color: #ffffff !important;
}

.form-input :deep(.q-select .q-field__native span) {
  color: #ffffff !important;
}

.form-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 2px rgba(124, 58, 237, 0.2);
}

.form-input :deep(input),
.form-input :deep(select),
.form-input :deep(textarea) {
  outline: none !important;
}

.btn-cancel {
  color: var(--color-text-secondary);
  font-weight: 500;
  border-radius: var(--radius-sm);
}

.btn-submit {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
}

.select-popup-dark .q-item {
  color: #e2e8f0 !important;
  background: #161f3a !important;
}

.select-popup-dark .q-item--active {
  color: #ffffff !important;
  background: rgba(124, 58, 237, 0.25) !important;
}

.select-popup-dark .q-item:hover {
  background: rgba(124, 58, 237, 0.15) !important;
}

.conversion-preview {
  margin-top: 8px;
  padding: 8px 12px;
  background: rgba(43, 122, 98, 0.06);
  border: 1px solid rgba(43, 122, 98, 0.15);
  border-radius: var(--radius-sm);
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text-secondary);
}

.conversion-preview strong {
  color: var(--color-positive);
  font-family: var(--font-mono);
  font-size: 0.85rem;
}
</style>
