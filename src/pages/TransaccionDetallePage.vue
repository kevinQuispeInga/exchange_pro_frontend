<template>
  <q-page class="detalle-page">
    <div v-if="loading" class="flex flex-center q-pa-xl">
      <q-spinner color="primary" size="3em" />
    </div>

    <template v-else-if="transaccion">
      <q-btn
        flat
        dense
        icon="arrow_back"
        label="Volver"
        no-caps
        class="back-btn"
        @click="$router.push('/transacciones')"
      />

      <div class="detail-hero">
        <div class="detail-hero__left">
          <div class="detail-hero__brand">
            <q-icon name="currency_exchange" size="20px" color="white" />
          </div>
          <div>
            <h2 class="detail-hero__code font-mono">{{
              transaccion.codigo || 'Sin código'
            }}</h2>
            <p class="detail-hero__id"
              >Transacción #{{ transaccion.idTransaccion }}</p
            >
          </div>
        </div>
        <q-badge :color="estadoColor" rounded class="detail-hero__badge">
          {{ transaccion.estado }}
        </q-badge>
      </div>

      <div class="detail-grid">
        <div class="detail-card">
          <div class="detail-card__header">
            <q-icon name="info_outline" size="18px" />
            <h3 class="detail-card__title font-display">Información General</h3>
          </div>
          <div class="detail-card__body">
            <div class="detail-row">
              <span class="detail-label">Monto Operación</span>
              <span class="detail-value font-mono detail-value--large"
                >S/ {{ formatNumber(transaccion.montoOperacion) }}</span
              >
            </div>
            <div class="detail-row">
              <span class="detail-label">ID Oferta</span>
              <span class="detail-value font-mono"
                >#{{ transaccion.idOferta }}</span
              >
            </div>
            <div class="detail-row">
              <span class="detail-label">Fecha de Inicio</span>
              <span class="detail-value">{{
                formatDate(transaccion.fechaInicio)
              }}</span>
            </div>
          </div>
        </div>

        <div class="detail-card">
          <div class="detail-card__header">
            <q-icon name="people_outline" size="18px" />
            <h3 class="detail-card__title font-display">Participantes</h3>
          </div>
          <div class="detail-card__body">
            <div class="detail-row">
              <span class="detail-label">Comprador</span>
              <span class="detail-value">
                <q-badge
                  :color="esComprador ? 'positive' : 'grey'"
                  rounded
                  class="role-badge"
                >
                  {{
                    esComprador ? 'Eres tú' : `ID ${transaccion.compradorId}`
                  }}
                </q-badge>
              </span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Vendedor</span>
              <span class="detail-value">
                <q-badge
                  :color="esVendedor ? 'positive' : 'grey'"
                  rounded
                  class="role-badge"
                >
                  {{ esVendedor ? 'Eres tú' : `ID ${transaccion.vendedorId}` }}
                </q-badge>
              </span>
            </div>
          </div>
        </div>
      </div>

      <div class="detail-actions">
        <div class="detail-actions__label">Acciones disponibles</div>
        <div class="detail-actions__buttons">
          <q-btn
            v-if="esComprador && transaccion.estado === 'PENDIENTE'"
            color="primary"
            label="Ver Instrucciones"
            icon="info"
            no-caps
            unelevated
            class="action-btn"
            @click="verInstrucciones"
          />
          <q-btn
            v-if="esComprador && transaccion.estado === 'PENDIENTE'"
            color="positive"
            label="Subir Comprobante"
            icon="upload_file"
            no-caps
            unelevated
            class="action-btn"
            @click="subirComprobanteClick"
          />
          <q-btn
            v-if="esVendedor && transaccion.estado === 'PAGADO'"
            color="positive"
            label="Liberar Fondos"
            icon="check_circle"
            no-caps
            unelevated
            class="action-btn"
            @click="liberarFondos"
          />
          <q-btn
            v-if="transaccion.estado === 'PENDIENTE'"
            color="negative"
            label="Cancelar"
            icon="cancel"
            no-caps
            outline
            class="action-btn"
            @click="cancelarTransaccion"
          />
          <q-btn
            color="warning"
            label="Abrir Disputa"
            icon="gavel"
            no-caps
            outline
            class="action-btn"
            @click="abrirDisputa"
          />
        </div>
      </div>
    </template>

    <div v-else class="flex flex-center q-pa-xl">
      <div class="text-center">
        <q-icon name="search_off" size="64px" color="var(--color-danger)" />
        <h3
          class="font-display"
          style="color: var(--color-danger); margin: 12px 0 0"
          >Transacción no encontrada</h3
        >
      </div>
    </div>

    <q-dialog v-model="instruccionesDialog" persistent>
      <q-card class="dialog-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="payment" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Instrucciones de Pago</h2>
        </div>
        <q-card-section class="q-px-lg q-py-lg" v-if="instrucciones">
          <div class="instrucciones-body">
            <div class="instruc-card">
              <span class="instruc-label">Método seleccionado</span>
              <span class="instruc-value">{{
                instrucciones.metodoSeleccionado
              }}</span>
            </div>
            <div class="instruc-card instruc-card--amount">
              <span class="instruc-label">Monto a depositar</span>
              <span class="instruc-amount font-mono"
                >S/ {{ formatNumber(instrucciones.montoADepositar) }}</span
              >
            </div>
            <div class="instruc-card">
              <span class="instruc-label">Datos del vendedor</span>
              <div class="instruc-data">
                <div
                  v-if="instrucciones.datosDelVendedor?.yape"
                  class="data-row"
                >
                  <span class="data-label">Yape:</span>
                  <span class="data-value font-mono">{{
                    instrucciones.datosDelVendedor.yape
                  }}</span>
                </div>
                <div
                  v-if="instrucciones.datosDelVendedor?.plin"
                  class="data-row"
                >
                  <span class="data-label">Plin:</span>
                  <span class="data-value font-mono">{{
                    instrucciones.datosDelVendedor.plin
                  }}</span>
                </div>
                <div
                  v-if="instrucciones.datosDelVendedor?.numeroCuenta"
                  class="data-row"
                >
                  <span class="data-label">Cuenta:</span>
                  <span class="data-value font-mono">{{
                    instrucciones.datosDelVendedor.numeroCuenta
                  }}</span>
                </div>
                <div
                  v-if="instrucciones.datosDelVendedor?.cci"
                  class="data-row"
                >
                  <span class="data-label">CCI:</span>
                  <span class="data-value font-mono">{{
                    instrucciones.datosDelVendedor.cci
                  }}</span>
                </div>
              </div>
            </div>
            <div class="instruc-note">
              <q-icon name="info" size="18px" class="q-mr-sm" />
              {{ instrucciones.mensaje }}
            </div>
          </div>
        </q-card-section>
        <q-card-actions align="right" class="q-px-lg q-pb-lg">
          <q-btn flat label="Cerrar" v-close-popup class="btn-cancel" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useQuasar } from 'quasar'
import { useTransaccionStore } from '@/stores/transaccionStore'
import { useAuthStore } from '@/stores/authStore'
import transaccionService from '@/services/transaccionService'

const router = useRouter()
const route = useRoute()
const $q = useQuasar()
const transaccionStore = useTransaccionStore()
const authStore = useAuthStore()

const transaccion = ref(null)
const loading = ref(true)
const instruccionesDialog = ref(false)
const instrucciones = ref(null)

const id = computed(() => Number(route.params.id))
const esComprador = computed(
  () => transaccion.value?.compradorId === authStore.userId
)
const esVendedor = computed(
  () => transaccion.value?.vendedorId === authStore.userId
)
const estadoColor = computed(() => {
  const map = {
    PENDIENTE: 'warning',
    PAGADO: 'info',
    COMPLETADO: 'positive',
    CANCELADO: 'negative',
    EN_DISPUTA: 'accent'
  }
  return map[transaccion.value?.estado] || 'grey'
})

const formatNumber = val => {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

const formatDate = dateStr => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('es-PE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const cargarTransaccion = async () => {
  try {
    const data = await transaccionService.listarMisOperaciones()
    transaccion.value = data.find(t => t.idTransaccion === id.value) || null
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al cargar transacción',
      position: 'top'
    })
  } finally {
    loading.value = false
  }
}

const verInstrucciones = async () => {
  $q.loading.show()
  try {
    instrucciones.value = await transaccionService.getInstruccionesPago(
      transaccion.value.idTransaccion
    )
    instruccionesDialog.value = true
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al obtener instrucciones',
      position: 'top'
    })
  } finally {
    $q.loading.hide()
  }
}

const subirComprobanteClick = () => {
  const input = document.createElement('input')
  input.type = 'file'
  input.accept = 'image/*,application/pdf'
  input.onchange = async e => {
    const file = e.target.files[0]
    if (!file) return
    $q.loading.show()
    try {
      await transaccionService.marcarComoPagado(
        transaccion.value.idTransaccion,
        file
      )
      $q.notify({
        type: 'positive',
        message: 'Comprobante subido correctamente',
        position: 'top'
      })
      await cargarTransaccion()
    } catch {
      $q.notify({
        type: 'negative',
        message: 'Error al subir comprobante',
        position: 'top'
      })
    } finally {
      $q.loading.hide()
    }
  }
  input.click()
}

const liberarFondos = () => {
  $q.dialog({
    title: 'Liberar Fondos',
    message:
      '¿Confirmas que has recibido el pago? Los fondos retenidos serán liberados a tu wallet.',
    cancel: { label: 'Cancelar', flat: true, color: 'grey' },
    ok: { label: 'Sí, liberar', color: 'positive', unelevated: true },
    persistent: true
  }).onOk(async () => {
    $q.loading.show()
    try {
      await transaccionStore.liberarFondos(transaccion.value.idTransaccion)
      $q.notify({
        type: 'positive',
        message: 'Fondos liberados. Transacción completada.',
        position: 'top'
      })
      await cargarTransaccion()
    } catch {
      $q.notify({
        type: 'negative',
        message: 'Error al liberar fondos',
        position: 'top'
      })
    } finally {
      $q.loading.hide()
    }
  })
}

const cancelarTransaccion = () => {
  $q.dialog({
    title: 'Cancelar Transacción',
    message:
      '¿Estás seguro de cancelar esta transacción? La oferta volverá a estar activa.',
    cancel: { label: 'Volver', flat: true, color: 'grey' },
    ok: { label: 'Sí, cancelar', color: 'negative', unelevated: true },
    persistent: true
  }).onOk(async () => {
    $q.loading.show()
    try {
      await transaccionStore.cancelar(transaccion.value.idTransaccion)
      $q.notify({
        type: 'positive',
        message: 'Transacción cancelada',
        position: 'top'
      })
      await cargarTransaccion()
    } catch {
      $q.notify({
        type: 'negative',
        message: 'Error al cancelar',
        position: 'top'
      })
    } finally {
      $q.loading.hide()
    }
  })
}

const abrirDisputa = () => {
  router.push({
    path: '/disputas',
    query: { transaccionId: transaccion.value.idTransaccion }
  })
}

onMounted(cargarTransaccion)
</script>

<style scoped>
.detalle-page {
  padding: 28px 32px;
  max-width: 900px;
  margin: 0 auto;
}

.back-btn {
  color: var(--color-text-secondary);
  font-weight: 500;
  margin-bottom: 16px;
  border-radius: var(--radius-sm);
}

@media (max-width: 768px) {
  .detalle-page {
    padding: 20px 16px;
  }
}

.detail-hero {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(
    135deg,
    var(--color-primary) 0%,
    var(--color-primary-light) 100%
  );
  border-radius: var(--radius-lg);
  padding: 24px 28px;
  color: white;
  margin-bottom: 20px;
}

.detail-hero__left {
  display: flex;
  align-items: center;
  gap: 14px;
}

.detail-hero__brand {
  width: 42px;
  height: 42px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.detail-hero__code {
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0 0 2px;
  color: white;
}

.detail-hero__id {
  font-family: var(--font-body);
  font-size: 0.8rem;
  opacity: 0.8;
  margin: 0;
}

.detail-hero__badge {
  font-size: 0.85rem;
  font-weight: 600;
  padding: 6px 16px;
}

.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 20px;
}

@media (max-width: 768px) {
  .detail-grid {
    grid-template-columns: 1fr;
  }
}

.detail-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
}

.detail-card__header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-primary);
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--color-border-light);
}

.detail-card__title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.detail-card__body {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.detail-label {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}

.detail-value {
  font-family: var(--font-body);
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--color-text);
}

.detail-value--large {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--color-primary);
}

.role-badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 3px 10px;
}

.detail-actions {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
}

.detail-actions__label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted);
  margin-bottom: 12px;
}

.detail-actions__buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.action-btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.85rem;
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
  margin: 0;
}

.instrucciones-body {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.instruc-card {
  background: var(--color-bg);
  border-radius: var(--radius-md);
  padding: 14px 16px;
}

.instruc-card--amount {
  background: rgba(43, 122, 98, 0.06);
  border: 1px solid rgba(43, 122, 98, 0.15);
}

.instruc-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--color-text-secondary);
  display: block;
  margin-bottom: 4px;
}

.instruc-value {
  font-family: var(--font-body);
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--color-text);
}

.instruc-amount {
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--color-positive);
}

.instruc-data {
  margin-top: 8px;
}

.data-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
}

.data-label {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}

.data-value {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
}

.instruc-note {
  display: flex;
  align-items: flex-start;
  padding: 12px 16px;
  background: rgba(217, 119, 6, 0.06);
  border-left: 4px solid var(--color-warning);
  border-radius: var(--radius-sm);
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  line-height: 1.4;
}

.btn-cancel {
  color: var(--color-text-secondary);
  font-weight: 500;
  border-radius: var(--radius-sm);
}
</style>
