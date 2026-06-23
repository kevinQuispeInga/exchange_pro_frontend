import api from '@/services/api'

const calificacionService = {
  async crear(datos) {
    const { data } = await api.post('/api/Calificacion', datos)
    return data
  },
  async deUsuario(idUsuario) {
    const { data } = await api.get(`/api/Calificacion/usuario/${idUsuario}`)
    return data
  },
  async yaCalifico(idTransaccion) {
    const { data } = await api.get(`/api/Calificacion/ya-califico/${idTransaccion}`)
    return data
  }
}

export default calificacionService
