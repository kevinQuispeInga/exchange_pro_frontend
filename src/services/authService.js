import api from '@/services/api'

const authService = {
  async login(correo, password) {
    const { data } = await api.post('/api/Auth/login', { correo, password })
    return data
  },
  async registrar(datos) {
    const { data } = await api.post('/api/Auth/registrar', datos)
    return data
  },
  async solicitarReset(correo) {
    const { data } = await api.post('/api/Auth/solicitar-reset', { correo })
    return data
  },
  async restablecerPassword(resetToken, nuevaPassword, confirmarPassword) {
    const { data } = await api.post('/api/Auth/restablecer-password', {
      resetToken,
      nuevaPassword,
      confirmarPassword
    })
    return data
  }
}

export default authService
