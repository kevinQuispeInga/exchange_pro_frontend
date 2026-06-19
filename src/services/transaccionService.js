import api from '@/services/api'

const transaccionService = {
  async crear(datos) {
    const { data } = await api.post('/api/Transaccion', datos)
    return data
  },
  async listarMisOperaciones() {
    const { data } = await api.get('/api/Transaccion/mis-operaciones')
    return data
  },
  async actualizarEstado(datos) {
    const { data } = await api.put('/api/Transaccion/estado', datos)
    return data
  },
  async liberarFondos(datos) {
    const { data } = await api.post('/api/Transaccion/liberar', datos)
    return data
  },
  async cancelar(id) {
    const { data } = await api.put(`/api/Transaccion/${id}/cancelar`)
    return data
  },
  async getInstruccionesPago(id) {
    const { data } = await api.get(`/api/Transaccion/${id}/instrucciones`)
    return data
  },
  async marcarComoPagado(id, comprobante) {
    const formData = new FormData()
    formData.append('comprobante', comprobante)
    const { data } = await api.put(`/api/Transaccion/${id}/pagar`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    return data
  }
}

export default transaccionService
