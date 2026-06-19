<template>
  <q-page class="transacciones-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Mis Transacciones</h1>
        <p class="page-subtitle">Historial de todas tus operaciones</p>
      </div>
    </div>

    <div v-if="loading" class="flex flex-center q-pa-xl">
      <q-spinner color="primary" size="3em" />
    </div>

    <EmptyState
      v-else-if="transaccionStore.transacciones.length === 0"
      icon="swap_horiz"
      title="No tienes transacciones"
      description="Participa en una oferta para comenzar a operar"
      action-label="Ver Ofertas"
      action-icon="storefront"
      action-color="primary"
      @action="$router.push('/ofertas')"
    />

    <div v-else class="table-wrapper">
      <q-card flat class="table-card">
        <q-table
          :rows="transaccionStore.transacciones"
          :columns="columns"
          row-key="idTransaccion"
          flat
          :bordered="false"
          hide-pagination
          @row-click="onRowClick"
          class="custom-table"
        >
          <template v-slot:body-cell-montoOperacion="props">
            <q-td :props="props">
              <span class="table-amount font-mono"
                >S/ {{ formatNumber(props.row.montoOperacion) }}</span
              >
            </q-td>
          </template>
          <template v-slot:body-cell-estado="props">
            <q-td :props="props">
              <q-badge
                :color="estadoColor(props.row.estado)"
                rounded
                class="table-badge"
              >
                {{ props.row.estado }}
              </q-badge>
            </q-td>
          </template>
          <template v-slot:body-cell-fechaInicio="props">
            <q-td :props="props" class="table-date">
              {{ formatDate(props.row.fechaInicio) }}
            </q-td>
          </template>
          <template v-slot:body-cell-codigo="props">
            <q-td :props="props">
              <span class="table-code font-mono">{{ props.row.codigo }}</span>
            </q-td>
          </template>
        </q-table>
      </q-card>
    </div>
  </q-page>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useTransaccionStore } from '@/stores/transaccionStore'
import EmptyState from '@/components/EmptyState.vue'

const router = useRouter()
const transaccionStore = useTransaccionStore()

const loading = ref(true)

const columns = [
  {
    name: 'codigo',
    label: 'Código',
    field: 'codigo',
    align: 'left',
    sortable: true
  },
  { name: 'idOferta', label: 'Oferta', field: 'idOferta', align: 'left' },
  {
    name: 'montoOperacion',
    label: 'Monto',
    field: 'montoOperacion',
    align: 'left'
  },
  {
    name: 'estado',
    label: 'Estado',
    field: 'estado',
    align: 'left',
    sortable: true
  },
  {
    name: 'fechaInicio',
    label: 'Fecha',
    field: 'fechaInicio',
    align: 'left',
    sortable: true
  }
]

const estadoColor = estado => {
  const map = {
    PENDIENTE: 'warning',
    PAGADO: 'info',
    COMPLETADO: 'positive',
    CANCELADO: 'negative',
    EN_DISPUTA: 'accent'
  }
  return map[estado] || 'grey'
}

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

const onRowClick = (evt, row) => {
  router.push(`/transacciones/${row.idTransaccion}`)
}

onMounted(async () => {
  try {
    await transaccionStore.listarMisOperaciones()
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.transacciones-page {
  padding: 28px 32px;
  max-width: 1200px;
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
  .transacciones-page {
    padding: 20px 16px;
  }
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
  cursor: pointer;
  font-size: 0.9rem;
}

.custom-table :deep(.q-table__card) {
  border-radius: 0;
}

.custom-table :deep(.q-table tbody tr:hover) {
  background: rgba(27, 58, 75, 0.03);
}

.table-code {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-primary);
}

.table-amount {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text);
}

.table-badge {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 3px 10px;
}

.table-date {
  font-size: 0.85rem;
  color: var(--color-text-secondary);
}
</style>
