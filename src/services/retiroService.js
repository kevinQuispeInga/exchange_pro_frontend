import api from '@/services/api'

const retiroService = {
  async solicitar(datos) {
    const { data } = await api.post('/api/Retiro/solicitar', datos)
    return data
  },
  async misRetiros() {
    const { data } = await api.get('/api/Retiro/mis-retiros')
    return data
  }
}

export default retiroService
