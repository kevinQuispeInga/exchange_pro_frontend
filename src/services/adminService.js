import api from '@/services/api'

const adminService = {
  async getEstadisticas() {
    const { data } = await api.get('/api/Admin/estadisticas')
    return data
  },

  async chat(mensaje) {
    const { data } = await api.post('/api/Admin/chatbot', { mensaje })
    return data
  }
}

export default adminService
