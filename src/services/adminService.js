import api from '@/services/api'

const adminService = {
  async getEstadisticas() {
    const { data } = await api.get('/api/Admin/estadisticas')
    return data
  },

  async getHistorial(metrica, anio, mes, semana) {
    let url = `/api/Admin/historial?metrica=${metrica}`
    if (anio !== undefined && anio !== null) url += `&anio=${anio}`
    if (mes !== undefined && mes !== null) url += `&mes=${mes}`
    if (semana !== undefined && semana !== null) url += `&semana=${semana}`
    const { data } = await api.get(url)
    return data
  },

  async chat(mensaje) {
    const { data } = await api.post('/api/Admin/chatbot', { mensaje })
    return data
  }
}

export default adminService
