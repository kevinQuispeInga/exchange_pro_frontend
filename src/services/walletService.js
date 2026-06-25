import api from '@/services/api'

const walletService = {
  async getSaldo() {
    const { data } = await api.get('/api/Wallet/saldo')
    return data
  },
  async recargar(datos) {
    const { data } = await api.post('/api/Wallet/recargar', datos)
    return data
  }
}

export default walletService
