import api from '@/services/api'

const reporteService = {
  async generar(datos) {
    const { data } = await api.post('/api/Reporte/generar', datos)
    return data
  },
  async exportar(datos) {
    const response = await api.post('/api/Reporte/exportar', datos, {
      responseType: 'blob'
    })
    return response
  },
  async historial() {
    const { data } = await api.get('/api/Reporte/historial')
    return data
  }
}

export default reporteService
