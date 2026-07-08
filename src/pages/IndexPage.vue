<template>
  <q-page class="dashboard">
    <div class="dashboard__header">
      <div>
        <h1 class="dashboard__greeting font-display">
          {{
            authStore.isAuthenticated
              ? `Hola, ${authStore.user?.nombres || authStore.user?.nombreCompleto || authStore.user?.correo?.split('@')[0] || 'Usuario'}`
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

    <MarketRhythm
      :active-offers="ofertaStore.ofertas.length"
      class="q-mb-lg"
    />

    <div v-if="authStore.isAuthenticated" class="row q-col-gutter-md q-mb-lg">
      <div class="col-12 col-sm-6 col-md-3" v-for="(stat, i) in stats" :key="i">
        <StatCard
          v-bind="stat"
          :value="stat.computedValue"
          interactive
          @click="navigate(stat.route)"
        />
      </div>
    </div>

    <div class="dashboard__grid">
      <div class="dashboard__section">
        <div class="section-header">
          <h2 class="section-title font-display">Últimas Ofertas</h2>
          <q-btn
            flat
            label="Ver todas"
            no-caps
            color="primary"
            to="/ofertas"
            class="section-link"
          />
        </div>
        <div v-if="ofertaStore.ofertas.length === 0" class="section-empty">
          <p>Cargando ofertas...</p>
        </div>
        <div v-else class="ofertas-list">
          <div
            v-for="oferta in ofertaStore.ofertas.slice(0, 4)"
            :key="oferta.idOferta"
            class="oferta-row"
          >
            <div class="oferta-row__user">
              <q-avatar size="28px" color="primary" text-color="white">
                {{ oferta.nombreUsuario?.charAt(0) || '?' }}
              </q-avatar>
              <span class="oferta-row__name">{{ oferta.nombreUsuario }}</span>
            </div>
            <div class="oferta-row__type">
              <q-badge
                :color="oferta.tipoOperacion === 'VENTA' ? 'positive' : 'info'"
                rounded
                class="badge-sm"
              >
                {{ oferta.tipoOperacion }}
              </q-badge>
            </div>
            <div class="oferta-row__rate font-mono">{{
              Number(oferta.tasaCambio).toFixed(2)
            }}</div>
            <div class="oferta-row__amount font-mono"
              >{{ Number(oferta.montoOfertado).toLocaleString('es-PE') }} {{ oferta.monedaEntregaCode || '' }}</div
            >
          </div>
        </div>
      </div>

      <div class="dashboard__section">
        <div class="section-header">
          <h2 class="section-title font-display">Actividad Reciente</h2>
          <q-btn
            flat
            label="Ver todo"
            no-caps
            color="primary"
            to="/transacciones"
            class="section-link"
          />
        </div>
        <div v-if="!authStore.isAuthenticated" class="section-empty">
          <p>Inicia sesión para ver tu actividad</p>
        </div>
        <div
          v-else-if="transaccionStore.transacciones.length === 0"
          class="section-empty"
        >
          <p>Aún no tienes transacciones</p>
        </div>
        <div v-else class="activity-list">
          <div
            v-for="trx in transaccionStore.transacciones.slice(0, 4)"
            :key="trx.idTransaccion"
            class="activity-row"
            @click="$router.push(`/transacciones/${trx.idTransaccion}`)"
          >
            <div class="activity-row__code">{{ getTrxTypeLabel(trx) }}</div>
            <q-badge :color="estadoColor(trx.estado)" rounded class="badge-sm">
              {{ formatEstado(trx.estado) }}
            </q-badge>
            <div class="activity-row__amount font-mono"
              >{{ Number(trx.montoOperacion).toLocaleString('es-PE') }} {{ trx.monedaEntregaCode || '' }}</div
            >
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import tipoCambioService from '@/services/tipoCambioService'
import { useAuthStore } from '@/stores/authStore'
import { useOfertaStore } from '@/stores/ofertaStore'
import { useTransaccionStore } from '@/stores/transaccionStore'
import { useWalletStore } from '@/stores/walletStore'
import StatCard from '@/components/StatCard.vue'
import MarketRhythm from '@/components/MarketRhythm.vue'

const $router = useRouter()
const authStore = useAuthStore()
const ofertaStore = useOfertaStore()
const transaccionStore = useTransaccionStore()
const walletStore = useWalletStore()

const tasasCambio = ref([])

const convertToPen = (monto, idMoneda) => {
  if (!monto) return 0
  if (idMoneda === 1) return monto // PEN ya es Soles

  const codigos = {
    1: 'PEN',
    2: 'USD',
    3: 'EUR',
    4: 'JPY',
    5: 'GBP'
  }
  const code = codigos[idMoneda]
  const tasa = tasasCambio.value.find(t => t.codigo === code)
  if (tasa && tasa.mid) {
    return monto * tasa.mid
  }

  // Fallbacks de tasas de cambio locales por si falla la API
  const fallbacks = {
    2: 3.75,  // USD
    3: 4.08,  // EUR
    4: 0.024, // JPY
    5: 4.80   // GBP
  }
  return monto * (fallbacks[idMoneda] || 1)
}

const stats = computed(() => [
  {
    label: 'Saldo Wallet',
    icon: 'account_balance_wallet',
    color: 'primary',
    prefix: 'S/',
    computedValue: walletStore.saldos.reduce(
      (sum, s) => sum + convertToPen(s.saldoDisponible, s.idMoneda),
      0
    ),
    decimals: 2,
    subtext: `${walletStore.saldos.length} monedas`,
    route: '/wallet'
  },
  {
    label: 'Ofertas Activas',
    icon: 'storefront',
    color: 'accent',
    computedValue: ofertaStore.ofertas.length,
    subtext: 'En el mercado',
    route: '/ofertas'
  },
  {
    label: 'Mis Transacciones',
    icon: 'swap_horiz',
    color: 'info',
    computedValue: transaccionStore.transacciones.length,
    subtext: 'Total de operaciones',
    route: '/transacciones'
  },
  {
    label: 'Mi Rol',
    icon: 'verified_user',
    color: 'positive',
    computedValue: authStore.isAdmin ? 'Administrador' : 'Usuario',
    animated: false,
    route: '/transacciones'
  }
])

function navigate(route) {
  $router.push(route)
}

function estadoColor(estado) {
  const map = {
    PENDIENTE: 'warning',
    PAGADO: 'info',
    COMPLETADO: 'positive',
    CANCELADO: 'negative',
    EN_DISPUTA: 'accent'
  }
  return map[estado] || 'grey'
}

const formatEstado = estado => {
  if (!estado) return ''
  const map = {
    PENDIENTE: 'Pendiente',
    PAGADO: 'Pagado',
    COMPLETADO: 'Completado',
    CANCELADO: 'Cancelado',
    CANCELADA: 'Cancelado',
    EN_DISPUTA: 'En Disputa'
  }
  return map[estado] || estado.replace(/_/g, ' ')
}

const getTrxTypeLabel = (trx) => {
  const isComprador = trx.compradorId === authStore.user?.idUsuario
  const moneda = trx.monedaEntregaCode || 'divisas'
  return isComprador ? `Compra de ${moneda}` : `Venta de ${moneda}`
}

onMounted(async () => {
  try {
    await ofertaStore.listarActivas()
  } catch (_) {}
  if (authStore.isAuthenticated) {
    try {
      await walletStore.cargarSaldo()
    } catch (_) {}
    try {
      await transaccionStore.listarMisOperaciones()
    } catch (_) {}
    try {
      const data = await tipoCambioService.obtener()
      tasasCambio.value = data.monedas || []
    } catch (_) {}
  }
})
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
