<template>
  <q-page class="wallet-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Mi Wallet</h1>
        <p class="page-subtitle">Administra tus saldos digitales</p>
      </div>
    </div>

    <div v-if="loading" class="flex flex-center q-pa-xl">
      <q-spinner color="primary" size="3em" />
    </div>

    <template v-else>
      <div class="wallet-hero">
        <div class="wallet-hero__icon">
          <q-icon name="account_balance_wallet" size="36px" color="white" />
        </div>
        <div class="wallet-hero__info">
          <span class="wallet-hero__id font-mono"
            >Wallet #{{ walletStore.idWallet || '—' }}</span
          >
          <span class="wallet-hero__label">Saldo total disponible</span>
          <span class="wallet-hero__balance font-display"
            >S/ {{ formatNumber(totalDisponible) }}</span
          >
        </div>
        <q-btn
          color="white"
          label="Recargar"
          icon="add"
          unelevated
          no-caps
          class="wallet-hero__btn"
          text-color="primary"
          @click="dialogoRecarga = true"
        />
      </div>

      <div
        v-if="walletStore.saldos.length === 0"
        class="flex flex-center q-pa-lg"
      >
        <EmptyState
          icon="account_balance_wallet"
          title="Sin saldos registrados"
          description="Recarga tu wallet para empezar a operar"
          action-label="Recargar ahora"
          action-icon="add_circle"
          action-color="primary"
          @action="dialogoRecarga = true"
        />
      </div>

      <div v-else class="saldos-grid">
        <div
          v-for="saldo in walletStore.saldos"
          :key="saldo.idMoneda"
          class="saldo-card"
          :class="`saldo-card--${monedaClass(saldo.idMoneda)}`"
        >
          <div class="saldo-card__header">
            <div class="saldo-card__currency">
              <div class="saldo-card__icon">
                <q-icon
                  :name="
                    monedaClass(saldo.idMoneda) === 'pen'
                      ? 'monetization_on'
                      : 'attach_money'
                  "
                  size="20px"
                />
              </div>
              <span class="saldo-card__name">{{
                monedaLabel(saldo.idMoneda)
              }}</span>
            </div>
            <q-icon name="more_horiz" size="20px" class="saldo-card__menu" />
          </div>
          <div class="saldo-card__balance">
            <span class="saldo-card__label">Disponible</span>
            <span class="saldo-card__amount font-mono"
              >S/ {{ formatNumber(saldo.saldoDisponible) }}</span
            >
          </div>
          <div class="saldo-card__footer">
            <div class="saldo-card__retenido">
              <span class="retenido-label">Retenido</span>
              <span class="retenido-amount font-mono"
                >S/ {{ formatNumber(saldo.saldoRetenido) }}</span
              >
            </div>
          </div>
        </div>
      </div>
    </template>

    <q-dialog v-model="dialogoRecarga" persistent>
      <q-card class="dialog-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="add_circle" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Recargar Saldo</h2>
          <p class="dialog-card__subtitle">Añade fondos a tu wallet digital</p>
        </div>
        <q-card-section class="q-px-lg q-pt-lg">
          <q-form @submit="recargarSaldo" class="q-gutter-md">
            <div class="field-group">
              <label class="field-label">Moneda</label>
              <q-select
                v-model="recarga.idMoneda"
                :options="opcionesMoneda"
                outlined
                dense
                placeholder="Seleccionar moneda"
                class="dialog-input"
                emit-value
                map-options
                :rules="[val => !!val || 'Selecciona una moneda']"
                hide-bottom-space
              />
            </div>
            <div class="field-group">
              <label class="field-label">Monto a recargar (S/)</label>
              <q-input
                v-model.number="recarga.monto"
                type="number"
                outlined
                dense
                placeholder="0.00"
                class="dialog-input"
                :rules="[val => val > 0 || 'Debe ser mayor a 0']"
                hide-bottom-space
              >
                <template v-slot:prepend>
                  <q-icon
                    name="monetization_on"
                    size="18px"
                    class="input-icon"
                  />
                </template>
              </q-input>
            </div>
            <div class="dialog-actions">
              <q-btn
                label="Cancelar"
                flat
                no-caps
                class="btn-cancel"
                v-close-popup
              />
              <q-btn
                label="Recargar"
                type="submit"
                color="primary"
                unelevated
                no-caps
                :loading="recargando"
                :disable="recargando"
                class="btn-submit"
              />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useWalletStore } from '@/stores/walletStore'
import EmptyState from '@/components/EmptyState.vue'

const $q = useQuasar()
const walletStore = useWalletStore()

const loading = ref(true)
const recargando = ref(false)
const dialogoRecarga = ref(false)

const opcionesMoneda = [
  { label: 'PEN (Sol Peruano)', value: 1 },
  { label: 'USD (Dólar Americano)', value: 2 }
]

const totalDisponible = computed(() =>
  walletStore.saldos.reduce((sum, s) => sum + (s.saldoDisponible || 0), 0)
)

const monedaLabel = id => {
  const m = opcionesMoneda.find(o => o.value === id)
  return m ? m.label.split(' ')[0] : id
}

const monedaClass = id => (id === 1 ? 'pen' : 'usd')

const formatNumber = val => {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

const recarga = ref({ monto: null, idMoneda: null })

onMounted(async () => {
  try {
    await walletStore.cargarSaldo()
  } finally {
    loading.value = false
  }
})

const recargarSaldo = async () => {
  recargando.value = true
  try {
    await walletStore.recargar({ ...recarga.value })
    $q.notify({
      type: 'positive',
      message: 'Saldo recargado exitosamente',
      position: 'top'
    })
    dialogoRecarga.value = false
    recarga.value = { monto: null, idMoneda: null }
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: error.response?.data?.mensaje || 'Error al recargar',
      position: 'top'
    })
  } finally {
    recargando.value = false
  }
}
</script>

<style scoped>
.wallet-page {
  padding: 28px 32px;
  max-width: 900px;
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
  .wallet-page {
    padding: 20px 16px;
  }
}

.wallet-hero {
  display: flex;
  align-items: center;
  gap: 20px;
  background: linear-gradient(
    135deg,
    var(--color-primary) 0%,
    var(--color-primary-light) 100%
  );
  border-radius: var(--radius-lg);
  padding: 28px 32px;
  margin-bottom: 24px;
  color: white;
}

.wallet-hero__icon {
  width: 60px;
  height: 60px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.wallet-hero__info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.wallet-hero__id {
  font-size: 0.75rem;
  font-weight: 500;
  opacity: 0.8;
}

.wallet-hero__label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 400;
  opacity: 0.85;
}

.wallet-hero__balance {
  font-size: 2rem;
  font-weight: 700;
  line-height: 1.2;
}

.wallet-hero__btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 20px;
}

.saldos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.saldo-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
  transition: transform var(--transition-base), box-shadow var(--transition-base);
}

.saldo-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.saldo-card__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.saldo-card__currency {
  display: flex;
  align-items: center;
  gap: 10px;
}

.saldo-card__icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.saldo-card--pen .saldo-card__icon {
  background: rgba(43, 122, 98, 0.1);
  color: var(--color-positive);
}

.saldo-card--usd .saldo-card__icon {
  background: rgba(37, 99, 235, 0.1);
  color: var(--color-info);
}

.saldo-card__name {
  font-family: var(--font-body);
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text);
}

.saldo-card__menu {
  color: var(--color-text-muted);
  cursor: pointer;
}

.saldo-card__balance {
  margin-bottom: 12px;
}

.saldo-card__label {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  display: block;
  margin-bottom: 4px;
}

.saldo-card__amount {
  font-size: 1.6rem;
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: -0.02em;
}

.saldo-card__footer {
  border-top: 1px solid var(--color-border-light);
  padding-top: 12px;
}

.saldo-card__retenido {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.retenido-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text-secondary);
}

.retenido-amount {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-warning);
}

.dialog-card {
  min-width: 400px;
  border-radius: var(--radius-xl);
  overflow: hidden;
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
  margin: 0 0 4px;
}

.dialog-card__subtitle {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.7);
  margin: 0;
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

.dialog-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  min-height: 44px;
}

.dialog-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.input-icon {
  color: var(--color-text-muted);
}

.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 8px;
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
</style>
