import api from '@/services/api'

const tipoCambioService = {
  async obtener() {
    const { data } = await api.get('/api/TipoCambio')
    return data
  }
}

export default tipoCambioService