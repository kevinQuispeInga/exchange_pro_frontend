import api from '@/services/api'

const authService = {
  async login(correo, password) {
    const { data } = await api.post('/api/Auth/login', { correo, password })
    return data
  },
  async registrar(datos) {
    const { data } = await api.post('/api/Auth/registrar', datos)
    return data
  }
}

export default authService
