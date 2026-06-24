<template>
  <q-page class="datos-pago-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Datos de Pago</h1>
        <p class="page-subtitle"
          >Configura cómo recibirás los pagos de tus ventas</p
        >
      </div>
    </div>

    <q-form @submit="guardarDatosPago" class="form-grid">
      <div class="method-card">
        <div class="method-card__header">
          <div class="method-card__icon method-card__icon--yape">
            <q-icon name="img:/yape.png" size="34px" />
          </div>
          <div>
            <h3 class="method-card__title">Yape</h3>
            <p class="method-card__desc">Recibe pagos al instante</p>
          </div>
        </div>
        <div class="method-card__body">
          <q-input
            v-model="yape"
            label="Número de Yape"
            type="tel"
            outlined
            dense
            dark
            placeholder="987654321"
            class="method-input"
            maxlength="9"
            :rules="[
              val => !val || /^\d{9}$/.test(val) || 'Debe tener 9 dígitos'
            ]"
            hide-bottom-space
          />
        </div>
      </div>

      <div class="method-card">
        <div class="method-card__header">
          <div class="method-card__icon method-card__icon--plin">
            <q-icon name="img:/plin.png" size="34px" />
          </div>
          <div>
            <h3 class="method-card__title">Plin</h3>
            <p class="method-card__desc">Transferencias rápidas</p>
          </div>
        </div>
        <div class="method-card__body">
          <q-input
            v-model="plin"
            label="Número de Plin"
            type="tel"
            outlined
            dense
            dark
            placeholder="987654321"
            class="method-input"
            maxlength="9"
            :rules="[
              val => !val || /^\d{9}$/.test(val) || 'Debe tener 9 dígitos'
            ]"
            hide-bottom-space
          />
        </div>
      </div>

      <div class="method-card method-card--wide">
        <div class="method-card__header">
          <div class="method-card__icon method-card__icon--bank">
            <q-icon name="account_balance" size="22px" />
          </div>
          <div>
            <h3 class="method-card__title">Transferencia Bancaria</h3>
            <p class="method-card__desc">Depósito en cuenta bancaria</p>
          </div>
        </div>
        <div class="method-card__body bank-body">
          <q-select
            v-model="bancoId"
            :options="bancoOptions"
            label="Banco"
            outlined
            dense
            dark
            placeholder="Seleccionar"
            class="method-input"
            emit-value
            map-options
            :rules="[val => !!val || 'Selecciona un banco']"
            hide-bottom-space
          />
          <q-input
            v-model="numeroCuenta"
            label="Número de Cuenta"
            outlined
            dense
            dark
            placeholder="000-0000000-0-00"
            class="method-input"
            maxlength="14"
            :rules="[
              val => !val || /^\d{14}$/.test(val) || 'Debe tener 14 dígitos'
            ]"
            hide-bottom-space
          />
          <q-input
            v-model="cci"
            label="CCI"
            outlined
            dense
            dark
            placeholder="000-000-0000000-00-00"
            class="method-input"
            maxlength="20"
            :rules="[
              val => !val || /^\d{20}$/.test(val) || 'Debe tener 20 dígitos'
            ]"
            hide-bottom-space
          />
        </div>
      </div>

      <div class="form-footer">
        <q-btn
          label="Cancelar"
          flat
          no-caps
          class="btn-cancel"
          @click="$router.push('/transacciones')"
        />
        <q-btn
          type="submit"
          color="primary"
          label="Guardar Datos de Pago"
          icon="save"
          unelevated
          no-caps
          class="btn-submit"
          :loading="saving"
        />
      </div>
    </q-form>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useRouter } from 'vue-router'
import datosPagoService from '@/services/datosPagoService'

const $q = useQuasar()
const router = useRouter()

const yape = ref('')
const plin = ref('')
const bancoId = ref(null)
const numeroCuenta = ref('')
const cci = ref('')
const saving = ref(false)

const bancoOptions = [
  { label: 'BCP', value: 1 },
  { label: 'Interbank', value: 2 },
  { label: 'BBVA', value: 3 },
  { label: 'Scotiabank', value: 4 }
]

onMounted(async () => {
  try {
    const data = await datosPagoService.obtener()
    if (data.yape) yape.value = data.yape
    if (data.plin) plin.value = data.plin
    if (data.idBanco) bancoId.value = data.idBanco
    if (data.numeroCuenta) numeroCuenta.value = data.numeroCuenta
    if (data.cci) cci.value = data.cci
  } catch {
    // No hay datos guardados aún
  }
})

const guardarDatosPago = async () => {
  const tieneYape = !!yape.value
  const tienePlin = !!plin.value
  const tieneBanco = !!bancoId.value && !!numeroCuenta.value

  if (!tieneYape && !tienePlin && !tieneBanco) {
    $q.notify({
      type: 'negative',
      message: 'Debes proporcionar al menos Yape, Plin o datos bancarios',
      position: 'top'
    })
    return
  }

  saving.value = true
  const datos = {}
  if (tieneYape) datos.yape = yape.value
  if (tienePlin) datos.plin = plin.value
  if (tieneBanco) {
    datos.idBanco = bancoId.value
    datos.numeroCuenta = numeroCuenta.value
    datos.cci = cci.value
  }

  try {
    await datosPagoService.crear(datos)
    $q.notify({
      type: 'positive',
      message: 'Datos de pago guardados exitosamente',
      position: 'top'
    })
    router.push('/transacciones')
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al guardar datos de pago',
      position: 'top'
    })
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.datos-pago-page {
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
  .datos-pago-page {
    padding: 20px 16px;
  }
}

.form-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.method-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
  transition: transform var(--transition-base), box-shadow var(--transition-base);
}

.method-card:hover {
  border-color: var(--color-primary-light);
  box-shadow: var(--shadow-sm);
}

.method-card__header {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 20px;
  border-bottom: 1px solid var(--color-border-light);
}

.method-card__icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.method-card__icon--yape {
  background: transparent;
  color: var(--color-accent);
}

.method-card__icon--plin {
  background: transparent;
  color: var(--color-positive);
}

.method-card__icon--bank {
  background: rgba(37, 99, 235, 0.1);
  color: var(--color-info);
}

.method-card__title {
  font-family: var(--font-display);
  font-size: 1rem;
  font-weight: 600;
  margin: 0 0 2px;
  color: var(--color-text);
}

.method-card__desc {
  font-family: var(--font-body);
  font-size: 0.8rem;
  color: var(--color-text-muted);
  margin: 0;
}

.method-card__body {
  padding: 16px 20px;
}

.method-card--wide {
  grid-column: 1 / -1;
}

.bank-body {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.method-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  min-height: 42px;
}

.method-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.form-footer {
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