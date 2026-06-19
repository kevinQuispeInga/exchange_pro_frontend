<template>
  <q-page class="disputas-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Abrir Disputa</h1>
        <p class="page-subtitle">Reporta un problema con una transacción</p>
      </div>
    </div>

    <div class="dispute-card">
      <div class="dispute-card__header">
        <div class="dispute-card__brand">
          <q-icon name="gavel" size="22px" color="white" />
        </div>
        <div>
          <h3 class="dispute-card__title font-display"
            >Formulario de Disputa</h3
          >
          <p class="dispute-card__desc"
            >La transacción será congelada hasta que un administrador la
            revise</p
          >
        </div>
      </div>

      <q-form @submit="abrirDisputa" class="dispute-card__body">
        <div class="field-group">
          <label class="field-label">ID de Transacción</label>
          <q-input
            v-model="idTransaccion"
            type="number"
            outlined
            dense
            placeholder="Ingresa el ID"
            class="dispute-input"
            :disable="!!transaccionIdPrefill"
            :rules="[val => !!val || 'Requerido']"
            hide-bottom-space
          >
            <template v-slot:prepend>
              <q-icon name="tag" size="18px" class="input-icon" />
            </template>
          </q-input>
        </div>

        <div class="field-group">
          <label class="field-label">Motivo</label>
          <q-input
            v-model="motivo"
            outlined
            dense
            placeholder="Ej: No recibí el pago"
            class="dispute-input"
            :rules="[val => !!val || 'Requerido']"
            hide-bottom-space
          >
            <template v-slot:prepend>
              <q-icon name="report_problem" size="18px" class="input-icon" />
            </template>
          </q-input>
        </div>

        <div class="field-group">
          <label class="field-label">Descripción detallada</label>
          <q-input
            v-model="descripcion"
            type="textarea"
            outlined
            dense
            placeholder="Describe qué ocurrió con la mayor cantidad de detalles posible..."
            class="dispute-input dispute-textarea"
            :rules="[val => !!val || 'Requerido']"
            hide-bottom-space
            :input-style="{ minHeight: '100px' }"
          />
        </div>

        <div class="dispute-warning">
          <q-icon name="info" size="18px" class="q-mr-sm" />
          <span
            >Al abrir una disputa, la transacción será congelada (EN_DISPUTA) y
            un administrador la revisará.</span
          >
        </div>

        <div class="form-actions">
          <q-btn
            label="Cancelar"
            flat
            no-caps
            class="btn-cancel"
            @click="$router.push('/transacciones')"
          />
          <q-btn
            type="submit"
            color="warning"
            label="Abrir Disputa"
            icon="gavel"
            unelevated
            no-caps
            class="btn-submit"
            :loading="saving"
          />
        </div>
      </q-form>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useRoute, useRouter } from 'vue-router'
import disputaService from '@/services/disputaService'

const $q = useQuasar()
const route = useRoute()
const router = useRouter()

const idTransaccion = ref(null)
const transaccionIdPrefill = ref(null)
const motivo = ref('')
const descripcion = ref('')
const saving = ref(false)

onMounted(() => {
  if (route.query.transaccionId) {
    transaccionIdPrefill.value = Number(route.query.transaccionId)
    idTransaccion.value = transaccionIdPrefill.value
  }
})

const abrirDisputa = async () => {
  if (!idTransaccion.value || !motivo.value || !descripcion.value) {
    $q.notify({
      type: 'negative',
      message: 'Todos los campos son obligatorios',
      position: 'top'
    })
    return
  }
  saving.value = true
  try {
    await disputaService.abrir({
      idTransaccion: Number(idTransaccion.value),
      motivo: motivo.value,
      descripcion: descripcion.value
    })
    $q.notify({
      type: 'positive',
      message: 'Disputa abierta. Transacción congelada.',
      position: 'top'
    })
    router.push('/transacciones')
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al abrir la disputa',
      position: 'top'
    })
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.disputas-page {
  padding: 28px 32px;
  max-width: 700px;
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
  .disputas-page {
    padding: 20px 16px;
  }
}

.dispute-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.dispute-card__header {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 20px 24px;
  background: linear-gradient(
    135deg,
    var(--color-primary) 0%,
    var(--color-primary-light) 100%
  );
  color: white;
}

.dispute-card__brand {
  width: 42px;
  height: 42px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.dispute-card__title {
  font-size: 1.1rem;
  font-weight: 600;
  margin: 0 0 2px;
  color: white;
}

.dispute-card__desc {
  font-family: var(--font-body);
  font-size: 0.8rem;
  opacity: 0.85;
  margin: 0;
  color: white;
}

.dispute-card__body {
  padding: 24px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 18px;
}

.field-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.dispute-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  min-height: 44px;
}

.dispute-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.input-icon {
  color: var(--color-text-muted);
}

.dispute-warning {
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
  margin-bottom: 20px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
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
