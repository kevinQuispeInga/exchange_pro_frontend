import api from '@/services/api'

const ofertaService = {
  async listarActivas() {
    const { data } = await api.get('/api/Oferta')
    return data
  },
  async listarMisOfertas() {
    const { data } = await api.get('/api/Oferta/mis-ofertas')
    return data
  },
  async crear(datos) {
    const { data } = await api.post('/api/Oferta', datos)
    return data
  },
  async cancelar(id) {
    const { data } = await api.put(`/api/Oferta/${id}/cancelar`)
    return data
  },
  async matches(id) {
    const { data } = await api.get(`/api/Oferta/${id}/matches`)
    return data
  }
}

export default ofertaService