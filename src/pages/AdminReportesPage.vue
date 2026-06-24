<template>
  <q-page class="admin-reportes-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Reportes</h1>
        <p class="page-subtitle">Genera y exporta reportes del sistema</p>
      </div>
    </div>

    <div class="filtros-card">
      <div class="filtros-grid">
        <div class="filtro-group">
          <label class="filtro-label">Tipo de Reporte</label>
          <q-select
            v-model="filtros.tipo"
            :options="opcionesTipo"
            outlined
            dense
            dark
            placeholder="Seleccionar tipo"
            class="filtro-input"
            emit-value
            map-options
          />
        </div>
        <div class="filtro-group">
          <label class="filtro-label">Moneda</label>
          <q-select
            v-model="filtros.idMoneda"
            :options="opcionesMoneda"
            outlined
            dense
            dark
            placeholder="Todas"
            class="filtro-input"
            clearable
            emit-value
            map-options
          />
        </div>
        <div class="filtro-group">
          <label class="filtro-label">Estado</label>
          <q-select
            v-model="filtros.estado"
            :options="opcionesEstado"
            outlined
            dense
            dark
            placeholder="Todos"
            class="filtro-input"
            clearable
            emit-value
            map-options
          />
        </div>
        <div class="filtro-group">
          <label class="filtro-label">Desde</label>
          <q-input
            v-model="filtros.fechaDesde"
            type="date"
            outlined
            dense
            dark
            class="filtro-input"
          />
        </div>
        <div class="filtro-group">
          <label class="filtro-label">Hasta</label>
          <q-input
            v-model="filtros.fechaHasta"
            type="date"
            outlined
            dense
            dark
            class="filtro-input"
          />
        </div>
      </div>
      <div class="filtros-actions">
        <q-btn
          color="primary"
          label="Generar Reporte"
          icon="play_arrow"
          unelevated
          no-caps
          :loading="generando"
          @click="generarReporte"
        />
      </div>
    </div>

    <div v-if="resultados.length > 0" class="resultados-card">
      <div class="resultados-header">
        <h3 class="resultados-title font-display">Resultados</h3>
        <q-btn
          color="accent"
          label="Exportar"
          icon="file_download"
          outline
          no-caps
          :loading="exportando"
          @click="exportarReporte"
        />
      </div>
      <q-table
        :rows="resultados"
        :columns="columnas"
        row-key="id"
        dark
        flat
        dense
        class="resultados-table"
        :pagination="{ rowsPerPage: 20 }"
        hide-bottom
      />
    </div>

    <div
      v-if="!generando && resultados.length === 0 && !sinResultados"
      class="empty-state"
    >
      <q-icon name="bar_chart" size="48px" color="grey-6" />
      <p class="empty-text">Selecciona los filtros y genera un reporte</p>
    </div>

    <div v-if="sinResultados && resultados.length === 0" class="empty-state">
      <q-icon name="search_off" size="48px" color="grey-6" />
      <p class="empty-text"
        >No se encontraron resultados para los filtros seleccionados</p
      >
    </div>
  </q-page>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useQuasar } from 'quasar'
import ExcelJS from 'exceljs'
import reporteService from '@/services/reporteService'

const $q = useQuasar()

const generando = ref(false)
const exportando = ref(false)
const resultados = ref([])
const sinResultados = ref(false)

const opcionesTipo = [
  { label: 'Usuarios', value: 'usuarios' },
  { label: 'Ofertas', value: 'ofertas' },
  { label: 'Transacciones', value: 'transacciones' },
  { label: 'Recargas', value: 'recargas' },
  { label: 'Retiros', value: 'retiros' },
  { label: 'Disputas', value: 'disputas' }
]

const opcionesMoneda = [
  { label: 'PEN (Sol Peruano)', value: 1 },
  { label: 'USD (Dólar Americano)', value: 2 },
  { label: 'EUR (Euro)', value: 3 },
  { label: 'JPY (Yen Japonés)', value: 4 },
  { label: 'GBP (Libra Esterlina)', value: 5 }
]

const opcionesEstado = [
  { label: 'Activo', value: 'ACTIVO' },
  { label: 'Inactivo', value: 'INACTIVO' },
  { label: 'Pendiente', value: 'PENDIENTE' },
  { label: 'Completado', value: 'COMPLETADO' }
]

const filtros = reactive({
  tipo: null,
  idMoneda: null,
  estado: null,
  fechaDesde: '',
  fechaHasta: ''
})

const normalizeResults = response => {
  if (Array.isArray(response)) return response
  if (!response || typeof response !== 'object') return []

  const keys = [
    'data',
    'resultados',
    'items',
    'rows',
    'lista',
    'datos',
    'results',
    'value'
  ]

  for (const key of keys) {
    if (Array.isArray(response[key])) return response[key]
  }

  for (const key of Object.keys(response)) {
    const nested = normalizeResults(response[key])
    if (nested.length > 0) return nested
  }

  return []
}

const columnas = computed(() => {
  if (!Array.isArray(resultados.value) || resultados.value.length === 0)
    return []
  const keys = Object.keys(resultados.value[0])
  return keys.map(k => ({
    name: k,
    label: getReadableLabel(k),
    field: k,
    sortable: true,
    align: 'left'
  }))
})

const generarReporte = async () => {
  if (!filtros.tipo) {
    $q.notify({
      type: 'negative',
      message: 'Selecciona un tipo de reporte',
      position: 'top'
    })
    return
  }
  generando.value = true
  sinResultados.value = false
  try {
    const response = await reporteService.generar({ ...filtros })
    console.log('Reporte generar response:', response)
    resultados.value = normalizeResults(response)
    console.log('Reporte normalizado:', resultados.value)
    if (resultados.value.length === 0) {
      sinResultados.value = true
    }
  } catch (error) {
    console.error('Error generando reporte:', error)
    $q.notify({
      type: 'negative',
      message: 'Error al generar reporte',
      position: 'top'
    })
  } finally {
    generando.value = false
  }
}

const columnLabels = {
  idUsuario: 'ID Usuario',
  nombreCompleto: 'Nombre Completo',
  correo: 'Correo',
  telefono: 'Teléfono',
  documentoIdentidad: 'Documento de Identidad',
  estado: 'Estado',
  reputacion: 'Reputación',
  fechaRegistro: 'Fecha de Registro',
  idOferta: 'ID Oferta',
  titulo: 'Título',
  descripcion: 'Descripción',
  precio: 'Precio',
  moneda: 'Moneda',
  cantidad: 'Cantidad',
  idTransaccion: 'ID Transacción',
  monto: 'Monto',
  fecha: 'Fecha',
  tipo: 'Tipo',
  idDisputa: 'ID Disputa',
  razon: 'Razón',
  mensajeError: 'Mensaje de Error',
  idRetiro: 'ID Retiro',
  metodoPago: 'Método de Pago',
  idRecarga: 'ID Recarga',
  calificacion: 'Calificación'
}

const getReadableLabel = key => {
  return columnLabels[key] || key.replace(/([A-Z])/g, ' $1').trim()
}

const jsonToXlsx = async (jsonData, tipo) => {
  const workbook = new ExcelJS.Workbook()

  let wsData = []
  if (jsonData.datos && Array.isArray(jsonData.datos)) {
    wsData = jsonData.datos
  } else if (Array.isArray(jsonData)) {
    wsData = jsonData
  }

  if (wsData.length === 0) return

  // Hoja principal de datos
  const worksheet = workbook.addWorksheet(tipo || 'Reporte')
  const headers = Object.keys(wsData[0])
  const readableHeaders = headers.map(h => getReadableLabel(h))

  // Agregar encabezados con títulos legibles
  const headerRow = worksheet.addRow(readableHeaders)

  // Estilo de encabezado
  headerRow.eachCell((cell, colNumber) => {
    cell.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF4472C4' }
    }
    cell.font = {
      bold: true,
      color: { argb: 'FFFFFFFF' },
      size: 12
    }
    cell.alignment = {
      horizontal: 'center',
      vertical: 'center',
      wrapText: true
    }
    cell.border = {
      left: { style: 'thin', color: { argb: 'FF000000' } },
      right: { style: 'thin', color: { argb: 'FF000000' } },
      top: { style: 'thin', color: { argb: 'FF000000' } },
      bottom: { style: 'thin', color: { argb: 'FF000000' } }
    }
  })

  // Agregar datos con estilos alternados
  wsData.forEach((row, rowIndex) => {
    const dataRow = worksheet.addRow(headers.map(h => row[h]))
    const isEvenRow = rowIndex % 2 === 0

    dataRow.eachCell((cell, colNumber) => {
      cell.alignment = {
        horizontal: 'left',
        vertical: 'center',
        wrapText: true
      }
      cell.border = {
        left: { style: 'thin', color: { argb: 'FFE0E0E0' } },
        right: { style: 'thin', color: { argb: 'FFE0E0E0' } },
        top: { style: 'thin', color: { argb: 'FFE0E0E0' } },
        bottom: { style: 'thin', color: { argb: 'FFE0E0E0' } }
      }

      // Alternancia de colores
      if (!isEvenRow) {
        cell.fill = {
          type: 'pattern',
          pattern: 'solid',
          fgColor: { argb: 'FFF2F2F2' }
        }
      }

      // Formato de fechas
      const value = row[headers[colNumber - 1]]
      if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(value)) {
        cell.numFmt = 'yyyy-mm-dd hh:mm:ss'
      }
    })
  })

  // Ajustar ancho de columnas basado en títulos legibles
  worksheet.columns = readableHeaders.map((label, idx) => {
    const header = headers[idx]
    const maxLength = Math.max(
      label.length,
      ...wsData.map(row => String(row[header] || '').length)
    )
    return {
      header: label,
      key: header,
      width: Math.min(maxLength + 3, 40)
    }
  })

  // Congelar primera fila
  worksheet.views = [{ state: 'frozen', ySplit: 1 }]

  // Hoja de resumen si existe
  if (jsonData.resumen && Array.isArray(jsonData.resumen)) {
    const summarySheet = workbook.addWorksheet('Resumen')
    const summaryHeaders = Object.keys(jsonData.resumen[0])
    const readableSummaryHeaders = summaryHeaders.map(h => getReadableLabel(h))
    const summaryRow = summarySheet.addRow(readableSummaryHeaders)

    summaryRow.eachCell(cell => {
      cell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FF4472C4' }
      }
      cell.font = {
        bold: true,
        color: { argb: 'FFFFFFFF' },
        size: 12
      }
      cell.alignment = { horizontal: 'center', vertical: 'center' }
      cell.border = {
        left: { style: 'thin', color: { argb: 'FF000000' } },
        right: { style: 'thin', color: { argb: 'FF000000' } },
        top: { style: 'thin', color: { argb: 'FF000000' } },
        bottom: { style: 'thin', color: { argb: 'FF000000' } }
      }
    })

    jsonData.resumen.forEach((row, idx) => {
      const sRow = summarySheet.addRow(summaryHeaders.map(h => row[h]))
      if (idx % 2 === 1) {
        sRow.eachCell(cell => {
          cell.fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'FFF2F2F2' }
          }
        })
      }
    })

    summarySheet.columns = readableSummaryHeaders.map((label, idx) => ({
      header: label,
      key: summaryHeaders[idx],
      width: Math.max(label.length + 2, 20)
    }))
  }

  return workbook
}

const exportarReporte = async () => {
  if (resultados.value.length === 0) return
  exportando.value = true
  try {
    const response = await reporteService.exportar({ ...filtros })
    const blob = response.data

    if (!blob || blob.size === 0) {
      throw new Error('Archivo vacío')
    }

    const type = blob.type || ''

    // Si es JSON, convertir a XLSX
    if (
      type.includes('json') ||
      type.includes('text') ||
      type.includes('javascript')
    ) {
      const text = await blob.text()
      const jsonData = JSON.parse(text)
      console.log('JSON recibido, convirtiendo a XLSX:', jsonData)

      const workbook = await jsonToXlsx(jsonData, filtros.tipo)
      const buffer = await workbook.xlsx.writeBuffer()
      const xlsxBlob = new Blob([buffer], {
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      })
      const filename = `reporte-${filtros.tipo || 'general'}-${new Date().toISOString().split('T')[0]}.xlsx`

      const url = window.URL.createObjectURL(xlsxBlob)
      const link = document.createElement('a')
      link.href = url
      link.setAttribute('download', filename)
      document.body.appendChild(link)
      link.click()
      link.remove()
      window.URL.revokeObjectURL(url)

      $q.notify({
        type: 'positive',
        message: 'Reporte exportado',
        position: 'top'
      })
      return
    }

    // Si es un blob binario (XLSX real)
    const filename =
      parseFilename(response.headers['content-disposition']) ||
      `reporte-${filtros.tipo || 'general'}.xlsx`

    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', filename)
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
    $q.notify({
      type: 'positive',
      message: 'Reporte exportado',
      position: 'top'
    })
  } catch (error) {
    console.error('Error exportando reporte:', error)
    $q.notify({
      type: 'negative',
      message: error?.message || 'Error al exportar reporte, revisa la consola',
      position: 'top'
    })
  } finally {
    exportando.value = false
  }
}
</script>

<style scoped>
.admin-reportes-page {
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
  .admin-reportes-page {
    padding: 20px 16px;
  }
}

.filtros-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 24px;
  margin-bottom: 20px;
}

.filtros-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
}

.filtro-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filtro-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.filtro-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  min-height: 42px;
}

.filtro-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.filtros-actions {
  display: flex;
  justify-content: flex-end;
}

.resultados-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.resultados-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 18px 20px;
  border-bottom: 1px solid var(--color-border-light);
}

.resultados-title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.resultados-table :deep(.q-table) {
  background: transparent;
}

.resultados-table :deep(.q-table__card) {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.resultados-table :deep(thead tr) {
  background: linear-gradient(135deg, #4472c4 0%, #3f5fa3 100%);
}

.resultados-table :deep(th) {
  font-family: var(--font-display);
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: none;
  letter-spacing: 0.02em;
  color: #ffffff;
  background: linear-gradient(135deg, #4472c4 0%, #3f5fa3 100%);
  border: none;
  padding: 14px 12px;
  border-right: 1px solid rgba(255, 255, 255, 0.1);
}

.resultados-table :deep(th:last-child) {
  border-right: none;
}

.resultados-table :deep(tbody tr) {
  transition: background-color 0.2s ease;
}

.resultados-table :deep(tbody tr:nth-child(even)) {
  background-color: #f8f9fa;
}

.resultados-table :deep(tbody tr:hover) {
  background-color: #e8ecf5;
}

.resultados-table :deep(td) {
  font-family: var(--font-body);
  font-size: 0.85rem;
  color: var(--color-text);
  padding: 12px;
  border: 1px solid var(--color-border-light);
  border-bottom: 1px solid #e0e0e0;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  padding: 60px 24px;
  text-align: center;
}

.empty-text {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin: 0;
}
</style>
