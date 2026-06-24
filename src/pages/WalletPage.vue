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
        <div class="wallet-hero__left">
          <div class="wallet-hero__icon">
            <q-icon name="account_balance_wallet" size="32px" color="white" />
          </div>
          <div class="wallet-hero__info">
            <span class="wallet-hero__id font-mono">Wallet #{{ walletStore.idWallet || '—' }}</span>
            <span class="wallet-hero__label">Saldo total disponible</span>
            <span class="wallet-hero__balance font-display">{{ formatCurrency(totalDisponible, null) }}</span>
          </div>
        </div>
        <div class="wallet-hero__actions">
          <q-btn color="white" label="Recargar" icon="add" unelevated no-caps class="hero-btn hero-btn--primary" text-color="primary" @click="abrirRecarga" />
          <q-btn color="white" label="Retirar" icon="remove" unelevated no-caps class="hero-btn hero-btn--secondary" text-color="negative" @click="abrirRetiro" />
        </div>
      </div>

      <div v-if="walletStore.saldos.length === 0" class="flex flex-center q-pa-lg">
        <EmptyState icon="account_balance_wallet" title="Sin saldos registrados" description="Recarga tu wallet para empezar a operar" action-label="Recargar ahora" action-icon="add_circle" action-color="primary" @action="dialogoRecarga = true" />
      </div>

      <div v-else class="saldo-cards">
        <div v-for="saldo in walletStore.saldos" :key="saldo.idMoneda" class="saldo-card" :class="`saldo-card--${currencyClass(saldo.idMoneda)}`">
          <div class="saldo-card__top">
            <div class="saldo-card__currency">
              <div class="saldo-card__icon">
                <q-icon name="attach_money" size="18px" />
              </div>
              <span class="saldo-card__name">{{ currencyName(saldo.idMoneda) }}</span>
            </div>
            <span class="saldo-card__code">{{ currencyCode(saldo.idMoneda) }}</span>
          </div>
          <div class="saldo-card__balance">
            <span class="saldo-card__label">Disponible</span>
            <span class="saldo-card__amount font-mono">{{ formatCurrency(saldo.saldoDisponible, saldo.idMoneda) }}</span>
          </div>
          <div class="saldo-card__footer">
            <div class="saldo-card__held">
              <span>Retenido</span>
              <span class="font-mono">{{ formatCurrency(saldo.saldoRetenido, saldo.idMoneda) }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="movements-section">
        <div class="movements-header">
          <h3 class="movements-title font-display">Movimientos</h3>
          <div class="movements-filters">
            <q-btn v-for="m in filterOptions" :key="m.value" flat dense no-caps :label="m.label" :class="{ 'filter--active': monedaFiltro === m.value }" class="filter-btn" @click="cambiarFiltroMoneda(m.value)" />
          </div>
        </div>

        <div v-if="movimientosCargando" class="flex flex-center q-pa-md">
          <q-spinner color="primary" size="2em" />
        </div>

        <div v-else-if="movimientos.length === 0" class="movements-empty">
          <q-icon name="receipt_long" size="40px" color="grey-6" />
          <span>No hay movimientos registrados</span>
        </div>

        <div v-else class="movements-table">
          <div class="movements-table__header">
            <span>Tipo</span>
            <span>Moneda</span>
            <span>Monto</span>
            <span>Estado</span>
            <span>Fecha</span>
          </div>
          <div v-for="mov in movimientos" :key="mov.idMovimiento" class="movements-row">
            <div class="movements-row__type">
              <div class="type-badge" :class="`type-badge--${typeClass(mov.tipoOperacion)}`">
                <q-icon :name="typeIcon(mov.tipoOperacion)" size="14px" />
              </div>
              <span>{{ typeLabel(mov.tipoOperacion) }}</span>
            </div>
            <div class="movements-row__currency">
              <span class="currency-dot" :class="`dot--${currencyClass(mov.monedaCodigo ? currencyIdByCode(mov.monedaCodigo) : 0)}`"></span>
              <span class="font-mono">{{ mov.monedaCodigo || '—' }}</span>
            </div>
            <div class="movements-row__amount" :class="amountClass(mov.tipoOperacion)">
              {{ sign(mov.tipoOperacion) }}{{ formatNumber(mov.monto) }}
            </div>
            <div class="movements-row__status">
              <span class="status-badge" :class="mov.resultado === 'EXITOSO' ? 'status--ok' : 'status--fail'">{{ mov.resultado || '—' }}</span>
            </div>
            <div class="movements-row__date font-mono">{{ formatDate(mov.fechaMovimiento) }}</div>
          </div>
        </div>
      </div>
    </template>

    <q-dialog v-model="dialogoRecarga" persistent>
      <q-card class="action-dialog">
        <div class="action-dialog__header action-dialog__header--deposit">
          <div class="action-dialog__brand">
            <q-icon name="account_balance" size="28px" color="white" />
          </div>
          <div class="action-dialog__titles">
            <h2 class="action-dialog__title font-display">Recargar Saldo</h2>
            <p class="action-dialog__subtitle">Elige un método y deposita en la cuenta de ExchangePro</p>
          </div>
          <q-btn icon="close" flat round dense color="white" v-close-popup class="action-dialog__close" />
        </div>

        <q-card-section class="action-dialog__body">
          <q-form @submit="recargarSaldo" class="action-form">
            <div class="action-form__summary">
              <div class="summary-label">Wallet</div>
              <div class="summary-value font-mono">#{{ walletStore.idWallet || '—' }}</div>
            </div>

            <div class="action-form__field">
              <label class="field-label">Moneda</label>
              <q-select v-model="recarga.idMoneda" :options="monedaOptions" outlined dense dark placeholder="Seleccionar moneda" class="dialog-input" emit-value map-options :rules="[val => !!val || 'Selecciona una moneda']" hide-bottom-space>
                <template v-slot:option="{ opt, selected, toggleOption }">
                  <q-item :active="selected" clickable @click="toggleOption(opt)" dense>
                    <q-item-section avatar>
                      <span class="currency-option-dot" :class="`dot--${currencyClass(opt.value)}`"></span>
                    </q-item-section>
                    <q-item-section>
                      <q-item-label>{{ opt.label }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
            </div>

            <div class="action-form__field">
              <label class="field-label">Monto a recargar</label>
              <q-input v-model.number="recarga.monto" type="number" outlined dense dark placeholder="0.00" class="dialog-input" :rules="[val => val > 0 || 'Debe ser mayor a 0']" hide-bottom-space>
                <template v-slot:prepend>
                  <span class="input-currency">{{ currencySymbol(recarga.idMoneda) }}</span>
                </template>
              </q-input>
            </div>

            <div class="action-form__field">
              <label class="field-label">Deposita a una de estas cuentas</label>
              <div class="app-accounts">
                <div
                  v-for="cta in appAccounts"
                  :key="cta.key"
                  class="account-option"
                  :class="{ 'account-option--selected': recarga.metodoPago === cta.key }"
                  @click="recarga.metodoPago = cta.key"
                >
                  <div class="account-option__radio">
                    <div v-if="recarga.metodoPago === cta.key" class="account-option__dot"></div>
                  </div>
                  <div class="account-option__info">
                    <div class="account-option__method">{{ cta.method }}</div>
                    <div class="account-option__detail font-mono">{{ cta.detail }}</div>
                    <div v-if="cta.extra" class="account-option__extra font-mono">{{ cta.extra }}</div>
                  </div>
                  <q-btn flat round dense icon="content_copy" size="sm" class="account-option__copy" @click.stop="copiar(cta.detail)" />
                </div>
              </div>
            </div>

            <div class="action-form__field">
              <label class="field-label">N° de operación / referencia</label>
              <q-input v-model="recarga.numeroReferencia" outlined dense dark placeholder="Ej: 123456" class="dialog-input" maxlength="15" inputmode="numeric" :rules="[val => !!val || 'Ingresa la referencia', val => /^\d+$/.test(val) || 'Solo números']" hide-bottom-space />
            </div>

            <div class="action-form__footer">
              <q-btn label="Cancelar" flat no-caps class="btn-cancel" v-close-popup />
              <q-btn label="Confirmar Recarga" type="submit" color="primary" unelevated no-caps :loading="recargando" :disable="recargando || !recarga.metodoPago" class="btn-primary" icon="add_circle" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>

    <q-dialog v-model="dialogoRetiro" persistent>
      <q-card class="action-dialog">
        <div class="action-dialog__header action-dialog__header--withdraw">
          <div class="action-dialog__brand">
            <q-icon name="output" size="28px" color="white" />
          </div>
          <div class="action-dialog__titles">
            <h2 class="action-dialog__title font-display">Retirar Saldo</h2>
            <p class="action-dialog__subtitle">Transfiere a una de tus cuentas registradas</p>
          </div>
          <q-btn icon="close" flat round dense color="white" v-close-popup class="action-dialog__close" />
        </div>

        <q-card-section class="action-dialog__body">
          <q-form @submit="retirarSaldo" class="action-form">
            <div class="action-form__summary">
              <div class="summary-label">Wallet</div>
              <div class="summary-value font-mono">#{{ walletStore.idWallet || '—' }}</div>
            </div>

            <div class="action-form__field">
              <label class="field-label">Moneda</label>
              <q-select v-model="retiro.idMoneda" :options="monedaOptions" outlined dense dark placeholder="Seleccionar moneda" class="dialog-input" emit-value map-options :rules="[val => !!val || 'Selecciona una moneda']" hide-bottom-space>
                <template v-slot:option="{ opt, selected, toggleOption }">
                  <q-item :active="selected" clickable @click="toggleOption(opt)" dense>
                    <q-item-section avatar>
                      <span class="currency-option-dot" :class="`dot--${currencyClass(opt.value)}`"></span>
                    </q-item-section>
                    <q-item-section>
                      <q-item-label>{{ opt.label }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
            </div>

            <div class="action-form__field">
              <label class="field-label">Monto a retirar</label>
              <q-input v-model.number="retiro.monto" type="number" outlined dense dark placeholder="0.00" class="dialog-input" :rules="[val => val > 0 || 'Debe ser mayor a 0']" hide-bottom-space>
                <template v-slot:prepend>
                  <span class="input-currency">{{ currencySymbol(retiro.idMoneda) }}</span>
                </template>
              </q-input>
              <div v-if="retiro.idMoneda && retiro.monto && retiroSaldo" class="field-hint field-hint--warn">
                <span v-if="retiro.monto > retiroSaldo.saldoDisponible" class="text-negative">Saldo insuficiente — disponible: {{ formatCurrency(retiroSaldo.saldoDisponible, retiro.idMoneda) }}</span>
              </div>
            </div>

            <div v-if="loadingMetodos" class="flex flex-center q-pa-sm">
              <q-spinner color="primary" size="1.5em" />
              <span class="q-ml-sm text-muted">Cargando tus métodos de pago...</span>
            </div>

            <div v-else-if="metodosPagoUsuario.length === 0" class="action-form__field">
              <div class="no-methods">
                <q-icon name="info" size="20px" />
                <span>No tienes métodos de pago registrados. <router-link to="/datos-pago" class="link-primary">Registra uno aquí</router-link></span>
              </div>
            </div>

            <div v-else class="action-form__field">
              <label class="field-label">Retirar a</label>
              <div class="app-accounts">
                <div
                  v-for="met in metodosPagoUsuario"
                  :key="met.key"
                  class="account-option"
                  :class="{ 'account-option--selected': retiro.metodoRetiro === met.key }"
                  @click="seleccionarMetodoRetiro(met)"
                >
                  <div class="account-option__radio">
                    <div v-if="retiro.metodoRetiro === met.key" class="account-option__dot"></div>
                  </div>
                  <div class="account-option__info">
                    <div class="account-option__method">{{ met.method }}</div>
                    <div class="account-option__detail font-mono">{{ met.detail }}</div>
                    <div v-if="met.extra" class="account-option__extra font-mono">{{ met.extra }}</div>
                  </div>
                </div>
              </div>
            </div>

            <div class="action-form__footer">
              <q-btn label="Cancelar" flat no-caps class="btn-cancel" v-close-popup />
              <q-btn label="Solicitar Retiro" type="submit" color="negative" unelevated no-caps :loading="retirando" :disable="retirando || !retiro.metodoRetiro" class="btn-primary" icon="output" />
            </div>
          </q-form>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useWalletStore } from '@/stores/walletStore'
import { useAuthStore } from '@/stores/authStore'
import walletService from '@/services/walletService'
import retiroService from '@/services/retiroService'
import movimientoWalletService from '@/services/movimientoWalletService'
import datosPagoService from '@/services/datosPagoService'
import EmptyState from '@/components/EmptyState.vue'
import { formatNumber, formatCurrency, currencySymbol } from '@/utils/formatCurrency'

const $q = useQuasar()
const walletStore = useWalletStore()
const authStore = useAuthStore()

const loading = ref(true)
const recargando = ref(false)
const retirando = ref(false)
const dialogoRecarga = ref(false)
const dialogoRetiro = ref(false)
const loadingMetodos = ref(false)
const metodosPagoUsuario = ref([])

const monedas = [
  { label: 'Soles (PEN)', value: 1, code: 'PEN' },
  { label: 'Dólares (USD)', value: 2, code: 'USD' },
  { label: 'Euros (EUR)', value: 3, code: 'EUR' },
  { label: 'Yenes (JPY)', value: 4, code: 'JPY' },
  { label: 'Libras (GBP)', value: 5, code: 'GBP' }
]

const monedaOptions = monedas.map(m => ({ label: `${m.code} — ${m.label.split('(')[0].trim()}`, value: m.value }))

const appAccounts = [
  { key: 'YAPE', method: 'Yape', detail: '999 888 777', extra: 'ExchangePro' },
  { key: 'PLIN', method: 'Plin', detail: '999 888 777', extra: 'ExchangePro' },
  { key: 'BCP', method: 'BCP — Cuenta Corriente', detail: '193-1234567-0-00', extra: 'CCI: 002-193-1234567000-00' },
  { key: 'INTERBANK', method: 'Interbank — Cuenta Corriente', detail: '898-1234567890', extra: 'CCI: 003-898-1234567890-00' }
]

const filterOptions = [
  { label: 'Todas', value: null },
  ...monedas.map(m => ({ label: m.code, value: m.value }))
]

const totalDisponible = computed(() =>
  walletStore.saldos.reduce((sum, s) => sum + (s.saldoDisponible || 0), 0)
)

const recargaSaldo = computed(() =>
  walletStore.saldos.find(s => s.idMoneda === recarga.value?.idMoneda)
)

const retiroSaldo = computed(() =>
  walletStore.saldos.find(s => s.idMoneda === retiro.value?.idMoneda)
)

const currencyName = id => {
  const m = monedas.find(o => o.value === id)
  return m ? m.label.split(' ')[0] : '—'
}

const currencyCode = id => {
  const m = monedas.find(o => o.value === id)
  return m ? m.code : '—'
}

const currencyClass = id => {
  const map = { 1: 'pen', 2: 'usd', 3: 'eur', 4: 'jpy', 5: 'gbp' }
  return map[id] || 'other'
}

const currencyIdByCode = code => {
  const m = monedas.find(o => o.code === code)
  return m ? m.value : 0
}

const typeLabel = tipo => {
  const labels = { RECARGA: 'Recarga', RETIRO: 'Retiro', COMPRA_VENTA: 'Compra/Venta', PAGO_WALLET: 'Pago Wallet' }
  return labels[tipo] || tipo
}

const typeIcon = tipo => {
  const icons = { RECARGA: 'arrow_downward', RETIRO: 'arrow_upward', COMPRA_VENTA: 'swap_horiz', PAGO_WALLET: 'payment' }
  return icons[tipo] || 'circle'
}

const typeClass = tipo => {
  const map = { RECARGA: 'in', RETIRO: 'out', COMPRA_VENTA: 'swap', PAGO_WALLET: 'pay' }
  return map[tipo] || 'other'
}

const amountClass = tipo => tipo === 'RECARGA' ? 'amount--positive' : 'amount--negative'

const sign = tipo => tipo === 'RECARGA' ? '+' : '−'

const formatDate = dateStr => {
  if (!dateStr) return '—'
  return new Date(dateStr).toLocaleDateString('es-PE', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
}

const recarga = ref({ monto: null, idMoneda: null, metodoPago: null, numeroReferencia: null })
const retiro = ref({ monto: null, idMoneda: null, metodoRetiro: null, metodoLabel: null, cuentaDestino: null, titular: null })

const movimientos = ref([])
const movimientosCargando = ref(false)
const monedaFiltro = ref(null)

const cargarMovimientos = async monedaId => {
  movimientosCargando.value = true
  try {
    const data = await movimientoWalletService.obtener(monedaId)
    movimientos.value = data || []
  } catch {
    movimientos.value = []
  } finally {
    movimientosCargando.value = false
  }
}

const cambiarFiltroMoneda = monedaId => {
  monedaFiltro.value = monedaId
  cargarMovimientos(monedaId)
}

const abrirRecarga = () => {
  recarga.value = { monto: null, idMoneda: null, metodoPago: null, numeroReferencia: null }
  dialogoRecarga.value = true
}

const abrirRetiro = async () => {
  retiro.value = { monto: null, idMoneda: null, metodoRetiro: null, cuentaDestino: null, titular: null }
  metodosPagoUsuario.value = []
  loadingMetodos.value = true
  dialogoRetiro.value = true
  try {
    const data = await datosPagoService.obtenerPorUsuario(authStore.user?.idUsuario)
    const metodos = []
    if (data && data.length > 0) {
      const d = data[0]
      if (d.yape) metodos.push({ key: 'YAPE_' + d.idDatoPago, method: 'Yape', detail: d.yape, extra: authStore.user?.nombres || '' })
      if (d.plin) metodos.push({ key: 'PLIN_' + d.idDatoPago, method: 'Plin', detail: d.plin, extra: authStore.user?.nombres || '' })
      if (d.numeroCuenta) metodos.push({ key: 'CTA_' + d.idDatoPago, method: 'Cuenta Bancaria', detail: d.numeroCuenta, extra: d.cci ? 'CCI: ' + d.cci : '' })
    }
    metodosPagoUsuario.value = metodos
  } catch {
    metodosPagoUsuario.value = []
  } finally {
    loadingMetodos.value = false
  }
}

const seleccionarMetodoRetiro = met => {
  retiro.value.metodoRetiro = met.key
  retiro.value.cuentaDestino = met.detail
  retiro.value.titular = met.extra
  retiro.value.metodoLabel = met.method
}

const copiar = texto => {
  navigator.clipboard.writeText(texto).then(() => {
    $q.notify({ type: 'positive', message: 'Copiado: ' + texto, position: 'top' })
  })
}

watch(dialogoRecarga, val => {
  if (!val) recarga.value = { monto: null, idMoneda: null, metodoPago: null, numeroReferencia: null }
})

watch(dialogoRetiro, val => {
  if (!val) {
    retiro.value = { monto: null, idMoneda: null, metodoRetiro: null, cuentaDestino: null, titular: null }
    metodosPagoUsuario.value = []
  }
})

onMounted(async () => {
  try {
    await walletStore.cargarSaldo()
    await cargarMovimientos()
  } finally {
    loading.value = false
  }
})

const recargarSaldo = async () => {
  recargando.value = true
  try {
    await walletStore.recargar({ ...recarga.value })
    $q.notify({ type: 'positive', message: 'Saldo recargado exitosamente', position: 'top' })
    dialogoRecarga.value = false
    recarga.value = { monto: null, idMoneda: null, metodoPago: null, numeroReferencia: null }
    await walletStore.cargarSaldo()
    await cargarMovimientos(monedaFiltro.value)
  } catch (error) {
    $q.notify({ type: 'negative', message: error.response?.data?.mensaje || 'Error al recargar', position: 'top' })
  } finally {
    recargando.value = false
  }
}

const retirarSaldo = async () => {
  retirando.value = true
  try {
    await retiroService.solicitar({
      idMoneda: retiro.value.idMoneda,
      monto: retiro.value.monto,
      metodoRetiro: retiro.value.metodoLabel || retiro.value.metodoRetiro?.split('_')[0] || 'TRANSFERENCIA',
      cuentaDestino: retiro.value.cuentaDestino,
      titular: retiro.value.titular
    })
    $q.notify({ type: 'positive', message: 'Solicitud de retiro enviada exitosamente', position: 'top' })
    dialogoRetiro.value = false
    retiro.value = { monto: null, idMoneda: null, metodoRetiro: null, cuentaDestino: null, titular: null }
    metodosPagoUsuario.value = []
    await walletStore.cargarSaldo()
    await cargarMovimientos(monedaFiltro.value)
  } catch (error) {
    $q.notify({ type: 'negative', message: error.response?.data?.mensaje || 'Error al solicitar retiro', position: 'top' })
  } finally {
    retirando.value = false
  }
}
</script>

<style scoped>
.wallet-page {
  padding: 28px 32px;
  max-width: 960px;
  margin: 0 auto;
}

.page-header { margin-bottom: 24px; }
.page-title { font-size: 1.5rem; font-weight: 700; margin: 0 0 4px; color: var(--color-text); }
.page-subtitle { font-family: var(--font-body); font-size: 0.9rem; color: var(--color-text-secondary); margin: 0; }

@media (max-width: 768px) {
  .wallet-page { padding: 20px 16px; }
}

/* Hero */
.wallet-hero {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-light) 100%);
  border-radius: var(--radius-lg);
  padding: 28px 32px;
  margin-bottom: 24px;
  color: white;
}

.wallet-hero__left {
  display: flex;
  align-items: center;
  gap: 20px;
  flex: 1;
}

.wallet-hero__icon {
  width: 56px;
  height: 56px;
  background: rgba(255,255,255,0.15);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.wallet-hero__info { flex: 1; display: flex; flex-direction: column; gap: 2px; }
.wallet-hero__id { font-size: 0.75rem; font-weight: 500; opacity: 0.8; }
.wallet-hero__label { font-family: var(--font-body); font-size: 0.8rem; opacity: 0.85; }
.wallet-hero__balance { font-size: 2rem; font-weight: 700; line-height: 1.2; }

.wallet-hero__actions { display: flex; gap: 8px; flex-shrink: 0; }

.hero-btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 20px;
}

/* Saldo cards */
.saldo-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 16px;
  margin-bottom: 28px;
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

.saldo-card__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.saldo-card__currency {
  display: flex;
  align-items: center;
  gap: 10px;
}

.saldo-card__icon {
  width: 34px;
  height: 34px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.saldo-card--pen .saldo-card__icon { background: rgba(43,122,98,0.1); color: var(--color-positive); }
.saldo-card--usd .saldo-card__icon { background: rgba(37,99,235,0.1); color: var(--color-info); }
.saldo-card--eur .saldo-card__icon { background: rgba(99,37,235,0.1); color: #7c3aed; }
.saldo-card--jpy .saldo-card__icon { background: rgba(235,183,37,0.1); color: #eab308; }
.saldo-card--gbp .saldo-card__icon { background: rgba(235,37,75,0.1); color: #e11d48; }

.saldo-card__name { font-family: var(--font-body); font-size: 0.95rem; font-weight: 600; color: var(--color-text); }
.saldo-card__code { font-family: var(--font-mono); font-size: 0.75rem; font-weight: 600; color: var(--color-text-muted); background: var(--color-bg); padding: 2px 8px; border-radius: 4px; }

.saldo-card__balance { margin-bottom: 12px; }
.saldo-card__label { font-family: var(--font-body); font-size: 0.72rem; color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.04em; display: block; margin-bottom: 4px; }
.saldo-card__amount { font-size: 1.5rem; font-weight: 700; color: var(--color-text); letter-spacing: -0.02em; }

.saldo-card__footer { border-top: 1px solid var(--color-border-light); padding-top: 12px; }
.saldo-card__held { display: flex; justify-content: space-between; align-items: center; font-family: var(--font-body); font-size: 0.8rem; color: var(--color-text-secondary); }

/* Movements */
.movements-section { margin-top: 8px; }
.movements-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; flex-wrap: wrap; gap: 12px; }
.movements-title { font-size: 1.1rem; font-weight: 700; margin: 0; color: var(--color-text); }

.movements-filters { display: flex; gap: 4px; }
.filter-btn { color: var(--color-text-secondary); font-size: 0.78rem; font-weight: 500; border-radius: var(--radius-sm); padding: 4px 12px; }
.filter--active { background: rgba(124,58,237,0.12); color: var(--color-primary-light); }

.movements-empty {
  display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 40px;
  color: var(--color-text-muted); font-family: var(--font-body); font-size: 0.85rem;
  background: var(--color-surface); border: 1px solid var(--color-border); border-radius: var(--radius-lg);
}

.movements-table {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.movements-table__header {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr 1fr 0.8fr 1.2fr;
  gap: 8px;
  padding: 12px 18px;
  background: var(--color-bg);
  border-bottom: 1px solid var(--color-border);
  font-family: var(--font-body);
  font-size: 0.7rem;
  font-weight: 600;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.movements-row {
  display: grid;
  grid-template-columns: 1.2fr 0.8fr 1fr 0.8fr 1.2fr;
  gap: 8px;
  align-items: center;
  padding: 14px 18px;
  border-bottom: 1px solid var(--color-border-light);
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text);
  transition: background var(--transition-base);
}

.movements-row:last-child { border-bottom: none; }
.movements-row:hover { background: var(--color-bg); }

.movements-row__type { display: flex; align-items: center; gap: 10px; }

.type-badge {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.type-badge--in { background: rgba(43,122,98,0.1); color: var(--color-positive); }
.type-badge--out { background: rgba(244,63,94,0.1); color: var(--color-negative); }
.type-badge--swap { background: rgba(37,99,235,0.1); color: var(--color-info); }
.type-badge--pay { background: rgba(124,58,237,0.1); color: #7c3aed; }

.movements-row__currency { display: flex; align-items: center; gap: 8px; }

.currency-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.dot--pen { background: var(--color-positive); }
.dot--usd { background: var(--color-info); }
.dot--eur { background: #7c3aed; }
.dot--jpy { background: #eab308; }
.dot--gbp { background: #e11d48; }

.movements-row__amount { font-family: var(--font-mono); font-weight: 700; }
.amount--positive { color: var(--color-positive); }
.amount--negative { color: var(--color-negative); }

.status-badge {
  font-size: 0.72rem;
  font-weight: 600;
  padding: 2px 10px;
  border-radius: 20px;
}

.status--ok { background: rgba(43,122,98,0.1); color: var(--color-positive); }
.status--fail { background: rgba(244,63,94,0.1); color: var(--color-negative); }

.movements-row__date { font-size: 0.78rem; color: var(--color-text-muted); }

/* Action Dialogs */
.action-dialog {
  width: 100%;
  max-width: 480px;
  border-radius: var(--radius-xl);
  margin: 40px auto;
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 80px);
}

.action-dialog__header {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 24px 28px;
  position: relative;
}

.action-dialog__header--deposit { background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-light) 100%); }
.action-dialog__header--withdraw { background: linear-gradient(135deg, #dc2626 0%, #f87171 100%); }

.action-dialog__brand {
  width: 44px;
  height: 44px;
  background: rgba(255,255,255,0.15);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.action-dialog__titles { flex: 1; }
.action-dialog__title { font-size: 1.1rem; font-weight: 700; color: white; margin: 0 0 2px; }
.action-dialog__subtitle { font-family: var(--font-body); font-size: 0.8rem; color: rgba(255,255,255,0.7); margin: 0; }

.action-dialog__close {
  position: absolute;
  top: 12px;
  right: 12px;
}

.action-dialog__body {
  padding: 24px 28px;
  overflow-y: auto;
  flex: 1;
}

.action-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.action-form__summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: 12px 16px;
}

.summary-label { font-family: var(--font-body); font-size: 0.78rem; color: var(--color-text-muted); }
.summary-value { font-size: 0.9rem; font-weight: 600; color: var(--color-text); }

.action-form__field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.field-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.dialog-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  min-height: 46px;
}

.dialog-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 0 3px rgba(27,58,75,0.08);
}

.field-hint {
  margin-top: 2px;
  font-size: 0.78rem;
  color: var(--color-text-muted);
}

.field-hint--warn strong { color: var(--color-negative); }
.field-hint strong { color: var(--color-positive); }

.input-currency {
  font-family: var(--font-mono);
  font-weight: 700;
  font-size: 1rem;
  color: var(--color-text-secondary);
  padding-right: 4px;
}

.currency-option-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
}

.action-form__footer {
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

.btn-primary {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
}

/* App Accounts */
.app-accounts {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.account-option {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: border-color var(--transition-base), background var(--transition-base);
}

.account-option:hover {
  border-color: var(--color-primary-light);
}

.account-option--selected {
  border-color: var(--color-primary);
  background: rgba(124, 58, 237, 0.06);
}

.account-option__radio {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  border: 2px solid var(--color-text-muted);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: border-color var(--transition-base);
}

.account-option--selected .account-option__radio {
  border-color: var(--color-primary);
}

.account-option__dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--color-primary);
}

.account-option__info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.account-option__method {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
}

.account-option__detail {
  font-size: 0.82rem;
  color: var(--color-text);
  letter-spacing: 0.01em;
}

.account-option__extra {
  font-size: 0.72rem;
  color: var(--color-text-muted);
}

.account-option__copy {
  color: var(--color-text-muted);
  flex-shrink: 0;
}

.account-option__copy:hover {
  color: var(--color-primary);
}

.no-methods {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 14px;
  background: rgba(244, 63, 94, 0.06);
  border: 1px solid rgba(244, 63, 94, 0.15);
  border-radius: var(--radius-sm);
  font-family: var(--font-body);
  font-size: 0.82rem;
  color: var(--color-text-secondary);
}

.link-primary {
  color: var(--color-primary);
  text-decoration: none;
  font-weight: 600;
}

.link-primary:hover {
  text-decoration: underline;
}
</style>