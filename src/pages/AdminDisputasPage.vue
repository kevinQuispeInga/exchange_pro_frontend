<template>
  <q-page class="admin-page">
    <div v-if="!authStore.isAdmin" class="access-denied">
      <div class="access-denied__icon">
        <q-icon name="lock" size="48px" color="white" />
      </div>
      <h2 class="access-denied__title font-display">Acceso Denegado</h2>
      <p class="access-denied__desc"
        >No tienes permisos de administrador para acceder a esta página.</p
      >
      <q-btn
        label="Volver al inicio"
        color="primary"
        unelevated
        no-caps
        to="/"
        class="access-denied__btn"
      />
    </div>

    <template v-else>
      <div class="page-header">
        <div>
          <h1 class="page-title font-display">Panel de Disputas</h1>
          <p class="page-subtitle"
            >Revisa y resuelve las disputas pendientes (VAR)</p
          >
        </div>
        <q-badge color="accent" rounded class="pending-badge">
          {{ disputas.length }} pendientes
        </q-badge>
      </div>

      <div class="table-wrapper">
        <q-table
          :rows="disputas"
          :columns="columns"
          row-key="idDisputa"
          flat
          :loading="loading"
          :bordered="false"
          hide-pagination
          class="custom-table"
        >
          <template v-slot:body-cell-fechaCreacion="props">
            <q-td :props="props">
              {{ formatDate(props.row.fechaCreacion) }}
            </q-td>
          </template>
          <template v-slot:body-cell-acciones="props">
            <q-td :props="props">
              <q-btn
                color="primary"
                label="Resolver"
                size="sm"
                unelevated
                no-caps
                class="table-action-btn"
                @click="abrirResolver(props.row)"
              />
            </q-td>
          </template>
          <template v-slot:no-data>
            <div class="empty-disputas">
              <div class="empty-disputas__icon">
                <q-icon name="check_circle" size="48px" color="positive" />
              </div>
              <h3 class="empty-disputas__title font-display"
                >No hay disputas pendientes</h3
              >
              <p class="empty-disputas__desc"
                >Todas las operaciones están en orden.</p
              >
            </div>
          </template>
        </q-table>
      </div>
    </template>

    <q-dialog v-model="resolverDialog" persistent>
      <q-card class="dialog-card">
        <div class="dialog-card__header">
          <div class="dialog-card__brand">
            <q-icon name="gavel" size="24px" color="white" />
          </div>
          <h2 class="dialog-card__title font-display">Resolver Disputa</h2>
          <p class="dialog-card__subtitle">Decisión del VAR</p>
        </div>

        <q-card-section class="q-px-lg q-pt-lg">
          <q-form @submit="resolverDisputa" class="q-gutter-md">
            <div class="field-group">
              <label class="field-label">Decisión</label>
              <q-select
                v-model="decision"
                :options="decisionOptions"
                outlined
                dense
                placeholder="Seleccionar fallo"
                class="dialog-input"
                emit-value
                map-options
                :rules="[val => !!val || 'Selecciona una decisión']"
                hide-bottom-space
              >
                <template v-slot:option="scope">
                  <q-item v-bind="scope.itemProps">
                    <q-item-section avatar>
                      <q-icon
                        :name="scope.opt.icon"
                        :color="scope.opt.color"
                        size="20px"
                      />
                    </q-item-section>
                    <q-item-section>
                      <q-item-label>{{ scope.opt.label }}</q-item-label>
                    </q-item-section>
                  </q-item>
                </template>
              </q-select>
            </div>

            <div class="field-group">
              <label class="field-label">Observación</label>
              <q-input
                v-model="observacion"
                type="textarea"
                outlined
                dense
                placeholder="Detalla el motivo de tu decisión..."
                class="dialog-input dialog-textarea"
                :rules="[val => !!val || 'Requerido']"
                hide-bottom-space
              />
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
                type="submit"
                color="primary"
                label="Emitir Fallo"
                unelevated
                no-caps
                :loading="resolviendo"
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
import { ref, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/authStore'
import disputaService from '@/services/disputaService'

const $q = useQuasar()
const authStore = useAuthStore()

const disputas = ref([])
const loading = ref(false)
const resolverDialog = ref(false)
const disputaActual = ref(null)
const decision = ref(null)
const observacion = ref('')
const resolviendo = ref(false)

const columns = [
  { name: 'id', label: 'ID', field: 'idDisputa', align: 'left' },
  {
    name: 'idTransaccion',
    label: 'Transacción',
    field: 'idTransaccion',
    align: 'left'
  },
  { name: 'motivo', label: 'Motivo', field: 'motivo', align: 'left' },
  {
    name: 'fechaCreacion',
    label: 'Fecha',
    field: 'fechaCreacion',
    align: 'left',
    sortable: true
  },
  { name: 'acciones', label: '', field: 'acciones', align: 'center' }
]

const decisionOptions = [
  {
    label: 'A favor del comprador',
    value: 'A_FAVOR_COMPRADOR',
    icon: 'person',
    color: 'positive'
  },
  {
    label: 'A favor del vendedor',
    value: 'A_FAVOR_VENDEDOR',
    icon: 'storefront',
    color: 'info'
  }
]

const formatDate = dateStr => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('es-PE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

const abrirResolver = disputa => {
  disputaActual.value = disputa
  decision.value = null
  observacion.value = ''
  resolverDialog.value = true
}

const resolverDisputa = async () => {
  if (!decision.value || !observacion.value) {
    $q.notify({
      type: 'negative',
      message: 'Completa todos los campos',
      position: 'top'
    })
    return
  }
  resolviendo.value = true
  try {
    await disputaService.resolver({
      idDisputa: disputaActual.value.idDisputa,
      decision: decision.value,
      observacion: observacion.value
    })
    $q.notify({
      type: 'positive',
      message: 'Disputa resuelta exitosamente',
      position: 'top'
    })
    resolverDialog.value = false
    await cargarDisputas()
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al resolver la disputa',
      position: 'top'
    })
  } finally {
    resolviendo.value = false
  }
}

const cargarDisputas = async () => {
  if (!authStore.isAdmin) return
  loading.value = true
  try {
    const data = await disputaService.listarPendientes()
    disputas.value = Array.isArray(data) ? data : []
  } catch {
    $q.notify({
      type: 'negative',
      message: 'Error al cargar disputas',
      position: 'top'
    })
  } finally {
    loading.value = false
  }
}

onMounted(cargarDisputas)
</script>

<style scoped>
.admin-page {
  padding: 28px 32px;
  max-width: 1200px;
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

.pending-badge {
  font-size: 0.8rem;
  font-weight: 600;
  padding: 6px 14px;
}

@media (max-width: 768px) {
  .admin-page {
    padding: 20px 16px;
  }
  .page-header {
    flex-direction: column;
    gap: 12px;
  }
}

.access-denied {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  min-height: 60vh;
  padding: 40px 24px;
}

.access-denied__icon {
  width: 80px;
  height: 80px;
  background: var(--color-danger);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
}

.access-denied__title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text);
  margin: 0 0 8px;
}

.access-denied__desc {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin: 0 0 24px;
}

.access-denied__btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
}

.table-wrapper {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.custom-table :deep(.q-table) {
  font-family: var(--font-body);
}

.custom-table :deep(th) {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding: 14px 16px !important;
  background: var(--color-bg);
  border-bottom: 1px solid var(--color-border);
}

.custom-table :deep(td) {
  padding: 14px 16px !important;
  border-bottom: 1px solid var(--color-border-light);
  font-size: 0.9rem;
}

.custom-table :deep(.q-table tbody tr:hover) {
  background: rgba(27, 58, 75, 0.03);
}

.table-action-btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.8rem;
}

.empty-disputas {
  text-align: center;
  padding: 48px 24px;
}

.empty-disputas__icon {
  margin-bottom: 16px;
}

.empty-disputas__title {
  font-size: 1.2rem;
  font-weight: 600;
  margin: 0 0 6px;
  color: var(--color-text);
}

.empty-disputas__desc {
  font-family: var(--font-body);
  color: var(--color-text-secondary);
  margin: 0;
}

.dialog-card {
  min-width: 420px;
  border-radius: var(--radius-xl);
  overflow: hidden;
}

.dialog-card__header {
  background: var(--color-primary);
  padding: 28px 24px;
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
