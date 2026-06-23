import api from '@/services/api'

const datosPagoService = {
  async obtener() {
    const { data } = await api.get('/api/DatosPago')
    return data
  },
  async obtenerPorUsuario(idUsuario) {
    const { data } = await api.get(`/api/DatosPago/${idUsuario}`)
    return data
  },
  async crear(datos) {
    const { data } = await api.post('/api/DatosPago', datos)
    return data
  }
}

export default datosPagoService
