import api from '@/services/api'

const feedbackService = {
  async create(payload) {
    const { data } = await api.post('/api/Feedback', payload)
    return data
  },

  async getAll() {
    const { data } = await api.get('/api/Feedback')
    return data
  },

  async respond(id, respuesta) {
    const { data } = await api.put(`/api/Feedback/${id}/responder`, { respuesta })
    return data
  }
}

export default feedbackService
