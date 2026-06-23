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
              >{{ formatNumber(oferta.montoOfertado) }}
              {{ currencySymbol(null, oferta.monedaEntregaCode) }}</span
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
              >{{ formatNumber(oferta.montoMinimo) }}
              {{ currencySymbol(null, oferta.monedaEntregaCode) }}</span
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
    <q-dialog v-model="dialogoVisible" persistent @before-hide="cerrarDialogo">
      <q-card class="dialog-card">
        <!-- Step 1: Confirm operation -->
        <template v-if="!instrucciones">
          <div class="dialog-card__header">
            <div class="dialog-card__brand">
              <q-icon name="currency_exchange" size="24px" color="white" />
            </div>
            <h2 class="dialog-card__title font-display">Confirmar Operación</h2>
          </div>
          <q-card-section class="q-px-lg q-pt-lg">
            <div class="dialog-info">
              <div class="dialog-info__row">
                <span class="dialog-info__label">{{
                  ofertaSeleccionada?.tipoOperacion === 'COMPRA'
                    ? 'Comprador'
                    : 'Vendedor'
                }}</span>
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
                  {{ formatNumber(ofertaSeleccionada?.montoMinimo) }} –
                  {{ formatNumber(ofertaSeleccionada?.montoOfertado) }}
                  {{
                    currencySymbol(null, ofertaSeleccionada?.monedaEntregaCode)
                  }}
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
              <label class="field-label"
                >{{
                  ofertaSeleccionada?.tipoOperacion === 'COMPRA'
                    ? 'Monto a vender'
                    : 'Monto a recibir'
                }}
                ({{
                  currencySymbol(null, ofertaSeleccionada?.monedaEntregaCode)
                }})</label
              >
              <q-input
                v-model.number="montoInput"
                type="number"
                outlined
                dense
                dark
                placeholder="0.00"
                class="dialog-input"
                :rules="[
                  val => !!val || 'Requerido',
                  val => val > 0 || 'Debe ser > 0',
                  val =>
                    val >= (ofertaSeleccionada?.montoMinimo || 0) ||
                    `Mín ${formatNumber(ofertaSeleccionada?.montoMinimo)} ${currencySymbol(null, ofertaSeleccionada?.monedaEntregaCode)}`,
                  val =>
                    val <= (ofertaSeleccionada?.montoOfertado || 0) ||
                    `Máx ${formatNumber(ofertaSeleccionada?.montoOfertado)} ${currencySymbol(null, ofertaSeleccionada?.monedaEntregaCode)}`
                ]"
                hide-bottom-space
              />
              <div
                v-if="montoInput > 0 && ofertaSeleccionada?.tasaCambio"
                class="conversion-preview"
              >
                <template v-if="ofertaSeleccionada?.tipoOperacion === 'COMPRA'">
                  Recibirás
                  <strong
                    >{{
                      formatNumber(
                        calcularMontoRecibe(
                          montoInput,
                          ofertaSeleccionada?.tasaCambio
                        )
                      )
                    }}
                    {{
                      currencySymbol(null, ofertaSeleccionada?.monedaRecibeCode)
                    }}</strong
                  >
                </template>
                <template v-else>
                  Equivale a
                  <strong
                    >{{ formatNumber(montoOperacion) }}
                    {{
                      currencySymbol(null, ofertaSeleccionada?.monedaRecibeCode)
                    }}</strong
                  >
                </template>
              </div>
            </div>

            <div class="field-group q-mt-md">
              <label class="field-label">Método de pago</label>
              <q-select
                v-model="metodoPago"
                :options="opcionesMetodoPago"
                outlined
                dense
                dark
                placeholder="Seleccionar"
                class="dialog-input"
                emit-value
                :rules="[val => !!val || 'Selecciona un método']"
                hide-bottom-space
              >
                <template v-slot:option="scope">
                  <q-item v-bind="scope.itemProps">
                    <q-item-section avatar>
                      <q-icon :name="scope.opt.icon" size="32px" />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label>{{ scope.opt.label }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
                <template v-slot:selected-item="scope">
                  <div class="row items-center">
                    <q-icon
                      :name="getMetodoIcon(scope.opt)"
                      size="18px"
                      class="q-mr-sm"
                    />
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
        </template>

        <!-- Step 2: Payment instructions + upload -->
        <template v-else>
          <div class="dialog-card__header dialog-card__header--success">
            <div class="dialog-card__brand">
              <q-icon name="check_circle" size="24px" color="white" />
            </div>
            <h2 class="dialog-card__title font-display"
              >¡Transacción Iniciada!</h2
            >
          </div>
          <q-card-section class="q-px-lg q-py-lg">
            <p class="instruc-success-msg">
              La transacción se ha creado exitosamente. Realiza el pago a los
              siguientes datos y sube el comprobante:
            </p>
            <div class="instrucciones-body">
              <div class="instruc-card">
                <span class="instruc-label">Método de pago</span>
                <span class="instruc-value">{{
                  instrucciones.metodoSeleccionado
                }}</span>
              </div>
              <div class="instruc-card">
                <span class="instruc-label">Vas a recibir</span>
                <span class="instruc-amount font-mono">
                  {{ formatNumber(instrucciones.montoRecibe) }}
                  {{ currencySymbol(null, instrucciones.monedaRecibeCode) }}
                </span>
              </div>
              <div class="instruc-card instruc-card--amount">
                <span class="instruc-label">Monto exacto a depositar</span>
                <span class="instruc-amount font-mono">
                  {{ formatNumber(instrucciones.montoADepositar) }}
                  {{ currencySymbol(null, instrucciones.monedaEntregaCode) }}
                </span>
              </div>
              <div class="instruc-card">
                <span class="instruc-label">Tasa de cambio</span>
                <span class="instruc-value font-mono"
                  >1
                  {{ currencySymbol(null, instrucciones.monedaRecibeCode) }} ≈
                  {{ formatNumber(instrucciones.tasaCambio) }}
                  {{
                    currencySymbol(null, instrucciones.monedaEntregaCode)
                  }}</span
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

            <template v-if="metodoPago === 4">
              <div class="wallet-pay-section">
                <q-btn
                  color="primary"
                  label="Pagar con Wallet"
                  icon="account_balance_wallet"
                  unelevated
                  no-caps
                  class="wallet-pay-btn"
                  :loading="pagandoWallet"
                  @click="pagarConWallet"
                />
                <p class="wallet-pay-hint"
                  >El monto se descontará de tu saldo disponible en Wallet
                  Interna</p
                >
              </div>
            </template>
            <template v-else>
              <div class="oferta-upload-divider">
                <span class="oferta-upload-divider__line" />
                <span class="oferta-upload-divider__text"
                  >Subir comprobante</span
                >
                <span class="oferta-upload-divider__line" />
              </div>

              <div
                class="oferta-upload-zone"
                :class="{
                  'oferta-upload-zone--active': dragOver,
                  'oferta-upload-zone--has-file': selectedFile
                }"
                @dragover.prevent="dragOver = true"
                @dragleave.prevent="dragOver = false"
                @drop.prevent="onDrop"
                @click="triggerFilePicker"
              >
                <template v-if="!selectedFile">
                  <q-icon name="cloud_upload" size="36px" color="grey-5" />
                  <span class="oferta-upload-zone__text"
                    >Arrastra tu comprobante aquí o haz clic</span
                  >
                  <span class="oferta-upload-zone__hint"
                    >JPG, PNG, PDF — Máx 10 MB</span
                  >
                </template>
                <template v-else>
                  <img
                    v-if="filePreviewUrl"
                    :src="filePreviewUrl"
                    class="oferta-upload-preview"
                  />
                  <div v-else class="oferta-upload-pdf">
                    <q-icon
                      name="picture_as_pdf"
                      size="36px"
                      color="negative"
                    />
                    <span class="oferta-upload-pdf__name">{{
                      selectedFile.name
                    }}</span>
                  </div>
                </template>
              </div>
              <input
                ref="fileInput"
                type="file"
                accept="image/*,application/pdf"
                style="display: none"
                @change="onFileChange"
              />

              <div v-if="uploadSuccess" class="oferta-upload-success">
                <q-icon name="check_circle" size="20px" color="positive" />
                <span>Comprobante subido correctamente</span>
              </div>
            </template>
          </q-card-section>
          <q-card-actions align="right" class="q-px-lg q-pb-lg">
            <q-btn
              flat
              label="Cerrar"
              :disable="uploading"
              @click="confirmarCerrar"
              class="dialog-cancel"
            />
            <template v-if="metodoPago !== 4">
              <q-btn
                color="positive"
                :label="uploadSuccess ? 'Ir al detalle' : 'Subir Comprobante'"
                :icon="uploadSuccess ? 'arrow_forward' : 'check'"
                no-caps
                unelevated
                :loading="uploading"
                :disable="uploading || (!uploadSuccess && !selectedFile)"
                @click="uploadSuccess ? irAlDetalle() : confirmarSubida()"
              />
            </template>
          </q-card-actions>
        </template>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/authStore'
import { useOfertaStore } from '@/stores/ofertaStore'
import { useTransaccionStore } from '@/stores/transaccionStore'
import transaccionService from '@/services/transaccionService'
import EmptyState from '@/components/EmptyState.vue'
import { currencySymbol } from '@/utils/formatCurrency'

const router = useRouter()
const $q = useQuasar()
const authStore = useAuthStore()
const ofertaStore = useOfertaStore()
const transaccionStore = useTransaccionStore()

const loading = ref(false)
const dialogoVisible = ref(false)
const creando = ref(false)
const ofertaSeleccionada = ref(null)
const metodoPago = ref(null)
const montoInput = ref(null)
const instrucciones = ref(null)

const montoOperacion = computed(() => {
  if (!montoInput.value || !ofertaSeleccionada.value?.tasaCambio) return 0
  if (ofertaSeleccionada.value.tipoOperacion === 'COMPRA') {
    return montoInput.value
  }
  return convertirRecibeAEntrega(
    montoInput.value,
    ofertaSeleccionada.value.tasaCambio
  )
})
const transaccionId = ref(null)
const selectedFile = ref(null)
const filePreviewUrl = ref(null)
const dragOver = ref(false)
const uploading = ref(false)
const uploadSuccess = ref(false)
const fileInput = ref(null)
const pagandoWallet = ref(false)

const opcionesMetodoPago = [
  { label: 'Yape', value: 1, icon: 'img:/yape.png' },
  { label: 'Plin', value: 2, icon: 'img:/plin.png' },
  { label: 'Transferencia Bancaria', value: 3, icon: 'account_balance' },
  { label: 'Wallet Interna', value: 4, icon: 'account_balance_wallet' }
]

const ofertasVisibles = computed(() => {
  const uid = authStore.userId
  if (uid == null) return ofertaStore.ofertas
  return ofertaStore.ofertas.filter(o => Number(o.idUsuario) !== Number(uid))
})

function formatNumber(val) {
  if (val == null) return '0.00'
  return Number(val).toLocaleString('es-PE', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function calcularMontoRecibe(monto, tasa) {
  if (!monto || !tasa) return 0
  return monto * tasa
}

function convertirRecibeAEntrega(montoRecibe, tasa) {
  if (!montoRecibe || !tasa) return 0
  return montoRecibe / tasa
}

function calcularMontoRecibeFromCodes(monto, tasa) {
  if (monto == null) return 0
  if (!tasa) return monto
  return monto * tasa
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
  montoInput.value = null
  dialogoVisible.value = true
}

async function tomarOferta() {
  if (!metodoPago.value || !ofertaSeleccionada.value || !montoOperacion.value)
    return
  creando.value = true
  try {
    const data = await transaccionService.crear({
      idOferta: ofertaSeleccionada.value.idOferta,
      idMetodoPago: metodoPago.value,
      monto: montoOperacion.value
    })
    const tid = data.idTransaccion || data
    transaccionId.value = tid

    // Después de crear la transacción, siempre traemos las instrucciones de pago
    // y las mostramos en el mismo diálogo para que el usuario vea los datos (Yape/Plin/cuenta)
    // y pueda subir el comprobante inmediatamente.
    const inst = await transaccionService.getInstruccionesPago(tid)
    instrucciones.value = inst
    await transaccionStore.listarMisOperaciones()
    // dejamos el diálogo abierto (dialogoVisible === true) para mostrar el paso 2
  } catch (error) {
    const res = error.response
    let msg = 'Error al tomar la oferta'
    if (res?.data) {
      if (typeof res.data === 'string') msg = res.data
      else if (res.data.mensaje) msg = res.data.mensaje
      else if (res.data.message) msg = res.data.message
      else if (res.data.title) msg = res.data.title
    }
    instrucciones.value = null
    $q.notify({ type: 'negative', message: msg, position: 'top' })
  } finally {
    creando.value = false
  }
}

function irAlDetalle() {
  dialogoVisible.value = false
  instrucciones.value = null
  router.push(`/transacciones/${transaccionId.value}`)
}

function cerrarDialogo() {
  dialogoVisible.value = false
  instrucciones.value = null
  transaccionId.value = null
  resetUpload()
}

function resetUpload() {
  selectedFile.value = null
  filePreviewUrl.value = null
  uploadSuccess.value = false
}

function triggerFilePicker() {
  if (!selectedFile.value) {
    fileInput.value?.click()
  }
}

function onDrop(e) {
  dragOver.value = false
  const file = e.dataTransfer.files[0]
  if (file) processFile(file)
}

function onFileChange(e) {
  const file = e.target.files[0]
  if (file) processFile(file)
}

function processFile(file) {
  const maxSize = 10 * 1024 * 1024
  if (file.size > maxSize) {
    $q.notify({
      type: 'negative',
      message: 'El archivo no debe superar los 10 MB',
      position: 'top'
    })
    return
  }
  selectedFile.value = file
  if (file.type.startsWith('image/')) {
    const reader = new FileReader()
    reader.onload = e => {
      filePreviewUrl.value = e.target.result
    }
    reader.readAsDataURL(file)
  } else {
    filePreviewUrl.value = null
  }
}

async function confirmarSubida() {
  if (!selectedFile.value || !transaccionId.value) return
  uploading.value = true
  try {
    await transaccionService.marcarComoPagado(
      transaccionId.value,
      selectedFile.value
    )
    uploadSuccess.value = true
    selectedFile.value = null
    filePreviewUrl.value = null
    $q.notify({
      type: 'positive',
      message: 'Comprobante subido correctamente',
      position: 'top'
    })
    await transaccionStore.listarMisOperaciones()
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al subir comprobante',
      position: 'top'
    })
  } finally {
    uploading.value = false
  }
}

async function pagarConWallet() {
  if (!transaccionId.value) return
  pagandoWallet.value = true
  try {
    await transaccionService.pagarConWallet(transaccionId.value)
    $q.notify({
      type: 'positive',
      message: 'Pago realizado con Wallet Interna',
      position: 'top'
    })
    dialogoVisible.value = false
    instrucciones.value = null
    router.push(`/transacciones/${transaccionId.value}`)
  } catch (error) {
    const msg =
      error.response?.data?.mensaje ||
      error.response?.data ||
      'Error al pagar con wallet'
    $q.notify({ type: 'negative', message: msg, position: 'top' })
  } finally {
    pagandoWallet.value = false
  }
}

async function confirmarCerrar() {
  if (!uploadSuccess.value && transaccionId.value) {
    const ok = await new Promise(resolve => {
      $q.dialog({
        title: '¿Salir sin pagar?',
        message:
          'Si sales ahora, la transacción se cancelará y la oferta volverá a estar disponible.',
        cancel: { label: 'Seguir aquí', flat: true, color: 'primary' },
        ok: {
          label: 'Cancelar transacción',
          color: 'negative',
          unelevated: true
        },
        persistent: true
      })
        .onOk(() => resolve(true))
        .onCancel(() => resolve(false))
        .onDismiss(() => resolve(false))
    })
    if (!ok) return
    try {
      await transaccionService.cancelar(transaccionId.value)
    } catch (err) {
      const msg =
        err.response?.data?.mensaje || err.response?.data || 'Error al cancelar'
      $q.notify({ type: 'negative', message: msg, position: 'top' })
      return
    }
    $q.notify({
      type: 'positive',
      message: 'Transacción cancelada. La oferta está disponible nuevamente.',
      position: 'top'
    })
    cerrarDialogo()
    await ofertaStore.listarActivas()
  } else {
    cerrarDialogo()
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
  transition:
    transform var(--transition-base),
    box-shadow var(--transition-base);
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
  padding: 24px;
  text-align: center;
}

.dialog-card__header--success {
  background: var(--color-positive);
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
  min-height: 44px;
}

.dialog-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
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

.instruc-success-msg {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  margin: 0 0 16px;
  text-align: center;
  line-height: 1.5;
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

.oferta-upload-divider {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 16px 0;
}

.oferta-upload-divider__line {
  flex: 1;
  height: 1px;
  background: var(--color-border);
}

.oferta-upload-divider__text {
  font-family: var(--font-body);
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted);
  white-space: nowrap;
}

.oferta-upload-zone {
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-lg);
  padding: 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: var(--color-bg);
}

.oferta-upload-zone:hover {
  border-color: var(--color-primary);
  background: rgba(59, 130, 246, 0.03);
}

.oferta-upload-zone--active {
  border-color: var(--color-primary);
  background: rgba(59, 130, 246, 0.06);
}

.oferta-upload-zone--has-file {
  border-style: solid;
  border-color: var(--color-positive);
  cursor: default;
}

.oferta-upload-zone__text {
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text-secondary);
  text-align: center;
}

.oferta-upload-zone__hint {
  font-family: var(--font-body);
  font-size: 0.7rem;
  color: var(--color-text-muted);
}

.oferta-upload-preview {
  max-width: 100%;
  max-height: 120px;
  border-radius: var(--radius-sm);
  object-fit: contain;
}

.oferta-upload-pdf {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.oferta-upload-pdf__name {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text);
  text-align: center;
}

.oferta-upload-success {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 12px;
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-positive);
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

.wallet-pay-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 16px 0;
}

.wallet-pay-btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 10px 32px;
  min-width: 220px;
}

.wallet-pay-hint {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
  margin: 0;
  text-align: center;
}
</style>
