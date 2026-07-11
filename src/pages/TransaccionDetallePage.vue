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
          {{ formatEstado(transaccion.estado) }}
        </q-badge>
      </div>

      <div class="timeline-section">
        <div class="timeline">
          <div
            v-for="(step, i) in timelineSteps"
            :key="i"
            class="timeline__step"
            :class="{
              'timeline__step--done': step.status === 'done',
              'timeline__step--active': step.status === 'active',
              'timeline__step--pending': step.status === 'pending'
            }"
          >
            <div class="timeline__connector" v-if="i > 0" />
            <div class="timeline__node">
              <q-icon :name="step.icon" size="20px" />
            </div>
            <div class="timeline__content">
              <span class="timeline__title">{{ step.label }}</span>
              <span class="timeline__desc">{{ step.desc }}</span>
              <span v-if="step.date" class="timeline__date">{{
                formatDate(step.date)
              }}</span>
            </div>
          </div>
          <div
            v-if="transaccion.estado === 'CANCELADO'"
            class="timeline__step timeline__step--cancelled"
          >
            <div class="timeline__connector" />
            <div class="timeline__node">
              <q-icon name="cancel" size="20px" />
            </div>
            <div class="timeline__content">
              <span class="timeline__title">Transacción Cancelada</span>
              <span class="timeline__desc"
                >La operación fue cancelada por el usuario</span
              >
            </div>
          </div>
          <div
            v-if="transaccion.estado === 'EN_DISPUTA'"
            class="timeline__step timeline__step--dispute"
          >
            <div class="timeline__connector" />
            <div class="timeline__node">
              <q-icon name="gavel" size="20px" />
            </div>
            <div class="timeline__content">
              <span class="timeline__title">En Disputa</span>
              <span class="timeline__desc"
                >La transacción está siendo revisada por un administrador</span
              >
            </div>
          </div>
        </div>
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
                >{{ formatNumber(transaccion.montoOperacion) }}
                {{ transaccion.monedaEntregaCode || '' }}</span
              >
            </div>
            <div class="detail-row" v-if="transaccion.totalPagar">
              <span class="detail-label">Total a Pagar</span>
              <span class="detail-value font-mono detail-value--large"
                >{{ formatNumber(transaccion.totalPagar) }}
                {{ transaccion.monedaRecibeCode || '' }}</span
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
                    esComprador
                      ? 'Tú'
                      : transaccion.compradorNombre ||
                        `ID ${transaccion.compradorId}`
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
                  {{
                    esVendedor
                      ? 'Tú'
                      : transaccion.vendedorNombre ||
                        `ID ${transaccion.vendedorId}`
                  }}
                </q-badge>
              </span>
            </div>
          </div>
        </div>
      </div>

      <div
        v-if="esComprador && transaccion.estado === 'PENDIENTE'"
        class="pay-steps-card"
      >
        <div class="pay-steps-card__header">
          <q-icon name="payments" size="18px" />
          <h3 class="pay-steps-card__title font-display"
            >Pasos para completar el pago</h3
          >
        </div>
        <div class="pay-steps-card__body">
          <div class="pay-step">
            <div class="pay-step__num">1</div>
            <div class="pay-step__content">
              <span class="pay-step__title">Realiza el pago</span>
              <span class="pay-step__desc"
                >Transfiere {{ formatNumber(transaccion.montoOperacion) }}
                {{ transaccion.monedaEntregaCode || '' }} a los datos que viste
                al crear la transacción (Yape, Plin o cuenta bancaria del
                vendedor).</span
              >
            </div>
          </div>
          <div class="pay-step-arrow">
            <q-icon name="keyboard_arrow_down" size="24px" color="grey-5" />
          </div>
          <div class="pay-step">
            <div class="pay-step__num">2</div>
            <div class="pay-step__content">
              <span class="pay-step__title">Sube el comprobante</span>
              <span class="pay-step__desc"
                >Toma una foto o captura de pantalla del comprobante y súbela
                para que el vendedor confirme el pago.</span
              >
            </div>
          </div>
        </div>
      </div>

      <div
        v-if="esVendedor && transaccion.estado === 'PAGADO'"
        class="pay-steps-card"
      >
        <div class="pay-steps-card__header">
          <q-icon name="verified" size="18px" />
          <h3 class="pay-steps-card__title font-display"
            >Pasos para liberar los fondos</h3
          >
        </div>
        <div class="pay-steps-card__body">
          <div class="pay-step">
            <div class="pay-step__num">1</div>
            <div class="pay-step__content">
              <span class="pay-step__title">Verifica el comprobante</span>
              <span class="pay-step__desc"
                >Revisa el comprobante que el comprador subió. Asegúrate de que
                el monto y los datos coincidan con tu cuenta.</span
              >
            </div>
          </div>
          <div class="pay-step-arrow">
            <q-icon name="keyboard_arrow_down" size="24px" color="grey-5" />
          </div>
          <div class="pay-step">
            <div class="pay-step__num">2</div>
            <div class="pay-step__content">
              <span class="pay-step__title">Libera los fondos</span>
              <span class="pay-step__desc"
                >Confirma que recibiste el pago para liberar los fondos
                retenidos a tu wallet. Una vez liberado no hay marcha
                atrás.</span
              >
            </div>
          </div>
        </div>
      </div>

      <div v-if="transaccion.rutaComprobante" class="comprobante-card">
        <div class="comprobante-card__header">
          <q-icon name="receipt_long" size="18px" />
          <h3 class="comprobante-card__title font-display"
            >Comprobante de Pago</h3
          >
        </div>
        <div class="comprobante-card__body">
          <div class="comprobante-preview" @click="previewComprobante = true">
            <img
              v-if="esImagen"
              :src="comprobanteUrl"
              alt="Comprobante"
              class="comprobante-thumb"
            />
            <div v-else class="comprobante-pdf-icon">
              <q-icon name="picture_as_pdf" size="48px" color="negative" />
              <span class="comprobante-pdf-label">Ver PDF</span>
            </div>
            <div class="comprobante-overlay">
              <q-icon name="zoom_in" size="28px" color="white" />
            </div>
          </div>
          <div class="comprobante-actions">
            <q-btn
              flat
              dense
              icon="open_in_new"
              label="Abrir en nueva pestaña"
              no-caps
              color="primary"
              @click="abrirComprobante"
            />
            <q-btn
              v-if="esVendedor && transaccion.estado === 'PAGADO'"
              color="positive"
              label="Liberar Fondos"
              icon="check_circle"
              no-caps
              unelevated
              class="action-btn comprobante-liberar"
              @click="liberarFondos"
            />
          </div>
        </div>
      </div>

      <div
        v-if="
          esComprador &&
          transaccion.estado === 'PAGADO' &&
          transaccion.tipoOperacion === 'COMPRA'
        "
        class="waiting-card"
      >
        <div class="waiting-card__header">
          <q-icon name="hourglass_top" size="18px" />
          <h3 class="waiting-card__title font-display">Esperando liberación</h3>
        </div>
        <div class="waiting-card__body">
          <p class="waiting-card__desc">
            El vendedor liberará los fondos en breve. Recibirás
            <strong
              >{{ formatNumber(transaccion.montoOperacion) }}
              {{ transaccion.monedaEntregaCode }}</strong
            >
            en tu billetera una vez que confirme la operación.
          </p>
        </div>
      </div>

      <div v-if="transaccion.estado === 'COMPLETADO'" class="rating-card">
        <div class="rating-card__header">
          <q-icon name="star_rate" size="18px" />
          <h3 class="rating-card__title font-display">Calificar Transacción</h3>
        </div>
        <div class="rating-card__body">
          <div v-if="calificacionExistente" class="rating-existing">
            <div class="stars-row">
              <q-icon
                v-for="i in 5"
                :key="i"
                :name="
                  i <= calificacionExistente.puntuacion ? 'star' : 'star_border'
                "
                color="warning"
                size="22px"
              />
            </div>
            <p v-if="calificacionExistente.comentario" class="rating-comment">{{
              calificacionExistente.comentario
            }}</p>
            <p class="rating-submitted">Ya calificaste esta transacción</p>
          </div>
          <div v-else class="rating-form">
            <p class="rating-prompt">¿Cómo calificas esta transacción?</p>
            <div class="stars-input">
              <q-icon
                v-for="i in 5"
                :key="i"
                :name="i <= nuevaPuntuacion ? 'star' : 'star_border'"
                color="warning"
                size="32px"
                class="star-clickable"
                :class="{ 'star-hover': i <= hoverPuntuacion }"
                @mouseenter="hoverPuntuacion = i"
                @mouseleave="hoverPuntuacion = 0"
                @click="nuevaPuntuacion = i"
              />
            </div>
            <q-input
              v-model="comentarioCalificacion"
              outlined
              dense
              dark
              placeholder="Escribe un comentario (opcional)"
              class="rating-input"
              maxlength="500"
              hide-bottom-space
            />
            <q-btn
              color="primary"
              label="Enviar Calificación"
              icon="send"
              unelevated
              no-caps
              :loading="enviandoCalificacion"
              :disable="!nuevaPuntuacion"
              class="rating-submit"
              @click="enviarCalificacion"
            />
          </div>
        </div>
      </div>

      <div class="detail-actions">
        <div class="detail-actions__label">Acciones disponibles</div>
        <div class="detail-actions__buttons">
          <q-btn
            v-if="esComprador && transaccion.estado === 'PENDIENTE'"
            color="positive"
            label="Subir Comprobante"
            icon="upload_file"
            no-caps
            unelevated
            class="action-btn"
            @click="uploadDialog = true"
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
            v-if="transaccion.estado !== 'EN_DISPUTA' && transaccion.estado !== 'COMPLETADO' && transaccion.estado !== 'CANCELADO'"
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
            <div class="instruc-card">
              <span class="instruc-label">Vas a recibir</span>
              <span class="instruc-amount font-mono"
                >{{ formatNumber(instrucciones.montoRecibe) }}
                {{ instrucciones.monedaRecibeCode }}</span
              >
            </div>
            <div class="instruc-card instruc-card--amount">
              <span class="instruc-label">Monto exacto a depositar</span>
              <span class="instruc-amount font-mono"
                >{{ formatNumber(instrucciones.montoADepositar) }}
                {{ instrucciones.monedaEntregaCode }}</span
              >
            </div>
            <div class="instruc-card">
              <span class="instruc-label">Tasa de cambio</span>
              <span class="instruc-value font-mono"
                >                1 {{ instrucciones.monedaEntregaCode }} =
                {{ formatNumber(instrucciones.tasaCambio, 3) }}
                {{ instrucciones.monedaRecibeCode }}</span
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
        <q-card-actions align="between" class="q-px-lg q-pb-lg">
          <q-btn flat label="Cerrar" v-close-popup class="btn-cancel" />
          <q-btn
            color="positive"
            label="Ya realicé el pago — Subir comprobante"
            icon="upload_file"
            no-caps
            unelevated
            @click="instruccionesDialog = false; uploadDialog = true"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="uploadDialog" persistent>
      <q-card class="dialog-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="upload_file" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Subir Comprobante</h2>
        </div>
        <q-card-section class="q-px-lg q-py-lg">
          <p class="upload-hint">
            Selecciona una imagen o PDF del comprobante de pago que realizaste.
          </p>
          <div
            class="upload-zone"
            :class="{
              'upload-zone--active': dragOver,
              'upload-zone--has-file': selectedFile
            }"
            @dragover.prevent="dragOver = true"
            @dragleave.prevent="dragOver = false"
            @drop.prevent="onDrop"
            @click="triggerFilePicker"
          >
            <template v-if="!selectedFile">
              <q-icon name="cloud_upload" size="48px" color="grey-5" />
              <span class="upload-zone__text"
                >Arrastra el archivo aquí o haz clic para seleccionar</span
              >
              <span class="upload-zone__hint">JPG, PNG, PDF — Máx 10 MB</span>
            </template>
            <template v-else>
              <img
                v-if="filePreviewUrl && filePreviewUrl.startsWith('data:image')"
                :src="filePreviewUrl"
                class="upload-preview"
              />
              <div
                v-else-if="selectedFile.type === 'application/pdf'"
                class="upload-pdf-icon"
              >
                <q-icon name="picture_as_pdf" size="48px" color="negative" />
                <span class="upload-pdf-name">{{ selectedFile.name }}</span>
              </div>
              <div v-else class="upload-file-info">
                <q-icon name="description" size="32px" color="primary" />
                <span class="upload-file-name">{{ selectedFile.name }}</span>
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
        </q-card-section>
        <q-card-actions align="right" class="q-px-lg q-pb-lg">
          <q-btn
            flat
            label="Cancelar"
            v-close-popup
            class="btn-cancel"
            @click="resetUpload"
          />
          <q-btn
            color="positive"
            label="Subir Comprobante"
            icon="check"
            no-caps
            unelevated
            :disable="!selectedFile"
            :loading="uploading"
            @click="confirmarSubida"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="previewComprobante" maximized>
      <q-card class="preview-card">
        <q-bar class="preview-bar">
          <span class="preview-bar__title">Comprobante de Pago</span>
          <q-space />
          <q-btn dense flat icon="close" v-close-popup />
        </q-bar>
        <q-card-section class="preview-body flex flex-center">
          <img
            v-if="esImagen"
            :src="comprobanteUrl"
            class="preview-image"
            alt="Comprobante"
          />
          <div v-else class="preview-pdf">
            <q-icon name="picture_as_pdf" size="80px" color="negative" />
            <p class="preview-pdf__text">
              No se puede previsualizar este archivo.
            </p>
            <q-btn
              color="primary"
              label="Abrir PDF"
              icon="open_in_new"
              no-caps
              unelevated
              @click="abrirComprobante"
            />
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useQuasar } from 'quasar'
import { useTransaccionStore } from '@/stores/transaccionStore'
import { useAuthStore } from '@/stores/authStore'
import transaccionService from '@/services/transaccionService'
import calificacionService from '@/services/calificacionService'
import api from '@/services/api'

const router = useRouter()
const route = useRoute()
const $q = useQuasar()
const transaccionStore = useTransaccionStore()
const authStore = useAuthStore()

const transaccion = ref(null)
const loading = ref(true)
const instruccionesDialog = ref(false)
const instrucciones = ref(null)
const uploadDialog = ref(false)
const selectedFile = ref(null)
const filePreviewUrl = ref(null)
const dragOver = ref(false)
const uploading = ref(false)
const fileInput = ref(null)
const previewComprobante = ref(false)

const nuevaPuntuacion = ref(0)
const hoverPuntuacion = ref(0)
const comentarioCalificacion = ref('')
const enviandoCalificacion = ref(false)
const calificacionExistente = ref(null)

const API_BASE = api.defaults.baseURL

const id = computed(() => Number(route.params.id))
const esComprador = computed(
  () => Number(transaccion.value?.compradorId) === Number(authStore.userId)
)
const esVendedor = computed(
  () => Number(transaccion.value?.vendedorId) === Number(authStore.userId)
)

const comprobanteUrl = computed(() => {
  if (!transaccion.value?.rutaComprobante) return null
  return `${API_BASE}${transaccion.value.rutaComprobante}`
})

const esImagen = computed(() => {
  const ruta = transaccion.value?.rutaComprobante || ''
  const ext = ruta.split('.').pop()?.toLowerCase()
  return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].includes(ext)
})

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

const timelineSteps = computed(() => {
  const estado = transaccion.value?.estado
  const pasos = [
    {
      label: 'Transacción Creada',
      desc: 'La transacción se ha registrado en el sistema',
      icon: 'check_circle',
      date: transaccion.value?.fechaInicio,
      status: 'done'
    },
    {
      label: 'Pago Realizado',
      desc:
        estado === 'COMPLETADO'
          ? 'El comprador realizó el pago'
          : estado === 'PAGADO'
            ? 'Comprobante recibido, esperando confirmación'
            : 'El comprador debe realizar el pago',
      icon:
        estado === 'COMPLETADO' || estado === 'PAGADO'
          ? 'check_circle'
          : 'hourglass_empty',
      status:
        estado === 'COMPLETADO' || estado === 'PAGADO'
          ? 'done'
          : estado === 'PENDIENTE'
            ? 'active'
            : 'pending'
    },
    {
      label: 'Fondos Liberados',
      desc:
        estado === 'COMPLETADO'
          ? 'Los fondos han sido transferidos al vendedor'
          : estado === 'PAGADO'
            ? 'El vendedor debe liberar los fondos'
            : 'Pendiente de pago',
      icon:
        estado === 'COMPLETADO'
          ? 'check_circle'
          : estado === 'PAGADO'
            ? 'hourglass_empty'
            : 'lock',
      status:
        estado === 'COMPLETADO'
          ? 'done'
          : estado === 'PAGADO'
            ? 'active'
            : 'pending'
    }
  ]
  return pasos
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

function calcularMontoRecibeFromCodes(
  monto,
  tasa,
  monedaEntregaCode,
  monedaRecibeCode
) {
  if (monto == null) return 0
  if (!tasa) return monto
  if (!monedaEntregaCode || !monedaRecibeCode) return monto
  const e = String(monedaEntregaCode).toUpperCase()
  const r = String(monedaRecibeCode).toUpperCase()
  if (e === r) return monto
  if (e === 'PEN' && r === 'USD') return monto / tasa
  if (e === 'USD' && r === 'PEN') return monto * tasa
  return monto
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
    if (instrucciones.value && transaccion.value?.tasaCambio) {
      instrucciones.value.montoRecibe =
        transaccion.value.montoOperacion * transaccion.value.tasaCambio
    }
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

const triggerFilePicker = () => {
  if (!selectedFile.value) {
    fileInput.value?.click()
  }
}

const onDrop = e => {
  dragOver.value = false
  const file = e.dataTransfer.files[0]
  if (file) processFile(file)
}

const onFileChange = e => {
  const file = e.target.files[0]
  if (file) processFile(file)
}

const processFile = file => {
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

const resetUpload = () => {
  selectedFile.value = null
  filePreviewUrl.value = null
}

const confirmarSubida = async () => {
  if (!selectedFile.value) return
  uploading.value = true
  try {
    await transaccionService.marcarComoPagado(
      transaccion.value.idTransaccion,
      selectedFile.value
    )
    $q.notify({
      type: 'positive',
      message: 'Comprobante subido correctamente',
      position: 'top'
    })
    uploadDialog.value = false
    resetUpload()
    await cargarTransaccion()
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

const liberarFondos = () => {
  $q.dialog({
    title: 'Liberar Fondos',
    message: `¿Confirmas que el comprador realizó el pago de ${formatNumber(transaccion.value.montoOperacion)} ${transaccion.value.monedaEntregaCode || ''} correctamente?`,
    html: true,
    cancel: { label: 'Revisar de nuevo', flat: true, color: 'grey' },
    ok: { label: 'Sí, liberar fondos', color: 'positive', unelevated: true },
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
    } catch (error) {
      const res = error.response
      let msg = 'Error al liberar fondos'
      if (res?.data) {
        if (typeof res.data === 'string') msg = res.data
        else if (res.data.mensaje) msg = res.data.mensaje
        else if (res.data.message) msg = res.data.message
        else if (res.data.title) msg = res.data.title
      }
      $q.notify({
        type: 'negative',
        message: msg,
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

const abrirComprobante = () => {
  if (comprobanteUrl.value) {
    window.open(comprobanteUrl.value, '_blank')
  }
}

watch(
  () => transaccion.value?.estado,
  async estado => {
    if (estado === 'COMPLETADO') {
      try {
        const resp = await calificacionService.yaCalifico(id.value)
        if (resp?.yaCalifico) {
          calificacionExistente.value = resp
        }
      } catch {
        // not rated yet
      }
    }
  }
)

const enviarCalificacion = async () => {
  if (!nuevaPuntuacion.value) return
  enviandoCalificacion.value = true
  try {
    const data = await calificacionService.crear({
      idTransaccion: id.value,
      puntuacion: nuevaPuntuacion.value,
      comentario: comentarioCalificacion.value || ''
    })
    calificacionExistente.value = data
    $q.notify({
      type: 'positive',
      message: 'Calificación enviada exitosamente',
      position: 'top'
    })
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al enviar calificación',
      position: 'top'
    })
  } finally {
    enviandoCalificacion.value = false
  }
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

.timeline-section {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 24px 28px;
  margin-bottom: 20px;
}

.timeline {
  display: flex;
  gap: 0;
  position: relative;
}

.timeline__step {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  padding: 0 8px;
}

.timeline__connector {
  position: absolute;
  top: 20px;
  left: calc(-50% + 20px);
  right: calc(50% + 20px);
  height: 3px;
  background: var(--color-border);
  border-radius: 2px;
}

.timeline__step--done .timeline__conneter {
  background: var(--color-positive);
}

.timeline__step--active .timeline__connector {
  background: linear-gradient(
    90deg,
    var(--color-positive) 0%,
    var(--color-border) 100%
  );
}

.timeline__step--done + .timeline__step--done .timeline__connector,
.timeline__step--done + .timeline__step--active .timeline__connector {
  background: var(--color-positive);
}

.timeline__step--done:first-of-type + .timeline__step .timeline__connector {
  background: var(--color-positive);
}

.timeline__node {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg);
  border: 2px solid var(--color-border);
  z-index: 1;
  transition: all 0.3s ease;
}

.timeline__step--done .timeline__node {
  background: var(--color-positive);
  border-color: var(--color-positive);
  color: white;
}

.timeline__step--active .timeline__node {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: white;
  box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.2);
}

.timeline__step--cancelled .timeline__node {
  background: var(--color-negative);
  border-color: var(--color-negative);
  color: white;
}

.timeline__step--dispute .timeline__node {
  background: var(--color-warning);
  border-color: var(--color-warning);
  color: white;
}

.timeline__content {
  text-align: center;
  margin-top: 10px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.timeline__title {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.timeline__step--pending .timeline__title {
  color: var(--color-text-muted);
}

.timeline__desc {
  font-family: var(--font-body);
  font-size: 0.7rem;
  color: var(--color-text-secondary);
  line-height: 1.3;
}

.timeline__step--pending .timeline__desc {
  color: var(--color-text-muted);
}

.timeline__date {
  font-family: var(--font-body);
  font-size: 0.65rem;
  color: var(--color-text-muted);
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

.pay-steps-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
  margin-bottom: 20px;
}

.pay-steps-card__header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-primary);
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--color-border-light);
}

.pay-steps-card__title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.pay-steps-card__body {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.pay-step {
  display: flex;
  gap: 14px;
  align-items: flex-start;
}

.pay-step__num {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-primary);
  color: white;
  font-family: var(--font-mono);
  font-size: 0.85rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.pay-step__content {
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding-top: 4px;
}

.pay-step__title {
  font-family: var(--font-body);
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text);
}

.pay-step__desc {
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text-secondary);
  line-height: 1.4;
}

.pay-step-arrow {
  display: flex;
  justify-content: center;
  padding: 4px 0 4px 16px;
}

.comprobante-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
  margin-bottom: 20px;
}

.comprobante-card__header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-primary);
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--color-border-light);
}

.comprobante-card__title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.comprobante-card__body {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
}

.comprobante-preview {
  position: relative;
  width: 200px;
  height: 140px;
  border-radius: var(--radius-md);
  overflow: hidden;
  cursor: pointer;
  border: 1px solid var(--color-border);
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg);
}

.comprobante-thumb {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.comprobante-pdf-icon {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.comprobante-pdf-label {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-secondary);
}

.comprobante-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.comprobante-preview:hover .comprobante-overlay {
  opacity: 1;
}

.comprobante-actions {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 10px;
}

.comprobante-liberar {
  margin-left: auto;
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

.rating-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 20px;
  margin-bottom: 20px;
}

.rating-card__header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-warning);
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--color-border-light);
}

.rating-card__title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.rating-card__body {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.rating-existing {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 12px 0;
}

.stars-row {
  display: flex;
  gap: 2px;
}

.rating-comment {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  font-style: italic;
  text-align: center;
  margin: 0;
}

.rating-submitted {
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text-muted);
  margin: 0;
}

.rating-form {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14px;
}

.rating-prompt {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text);
  margin: 0;
  font-weight: 500;
}

.stars-input {
  display: flex;
  gap: 4px;
}

.star-clickable {
  cursor: pointer;
  transition: transform 0.15s ease;
}

.star-clickable:hover {
  transform: scale(1.2);
}

.rating-input {
  width: 100%;
  max-width: 400px;
}

.rating-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  min-height: 42px;
}

.rating-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.rating-submit {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
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

.upload-hint {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  margin: 0 0 16px;
  text-align: center;
}

.upload-zone {
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-lg);
  padding: 32px 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: var(--color-bg);
}

.upload-zone:hover {
  border-color: var(--color-primary);
  background: rgba(59, 130, 246, 0.03);
}

.upload-zone--active {
  border-color: var(--color-primary);
  background: rgba(59, 130, 246, 0.06);
}

.upload-zone--has-file {
  border-style: solid;
  border-color: var(--color-positive);
  cursor: default;
}

.upload-zone__text {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  text-align: center;
}

.upload-zone__hint {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
}

.upload-preview {
  max-width: 100%;
  max-height: 160px;
  border-radius: var(--radius-sm);
  object-fit: contain;
}

.upload-pdf-icon {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
}

.upload-pdf-name {
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text);
  text-align: center;
}

.upload-file-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
}

.upload-file-name {
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text);
  text-align: center;
}

.preview-card {
  background: var(--color-bg);
  border-radius: 0;
  max-height: 100vh;
  display: flex;
  flex-direction: column;
}

.preview-bar {
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  padding: 8px 16px;
}

.preview-bar__title {
  font-family: var(--font-body);
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text);
}

.preview-body {
  flex: 1;
  overflow: auto;
  padding: 24px;
}

.preview-image {
  max-width: 100%;
  max-height: 90vh;
  object-fit: contain;
  border-radius: var(--radius-md);
}

.preview-pdf {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 48px;
}

.preview-pdf__text {
  font-family: var(--font-body);
  font-size: 1rem;
  color: var(--color-text-secondary);
  margin: 0;
}

.waiting-card {
  background: var(--color-surface);
  border: 1px solid var(--color-warning);
  border-radius: var(--radius-lg);
  padding: 20px;
  margin-bottom: 20px;
}

.waiting-card__header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-warning);
  margin-bottom: 12px;
}

.waiting-card__title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.waiting-card__desc {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text-secondary);
  line-height: 1.5;
  margin: 0;
}
</style>
