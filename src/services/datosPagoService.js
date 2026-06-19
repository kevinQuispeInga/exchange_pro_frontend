import api from '@/services/api'

const datosPagoService = {
  async crear(datos) {
    const { data } = await api.post('/api/DatosPago', datos)
    return data
  }
}

export default datosPagoService
