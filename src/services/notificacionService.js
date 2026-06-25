import api from '@/services/api'

const notificacionService = {
  async obtener() {
    const { data } = await api.get('/api/Notificaciones')
    return data
  },
  async contadorSinLeer() {
    const { data } = await api.get('/api/Notificaciones/unread-count')
    return data.unreadCount
  },
  async marcarComoLeido(id) {
    const { data } = await api.put(`/api/Notificaciones/${id}/leer`)
    return data
  }
}

export default notificacionService
