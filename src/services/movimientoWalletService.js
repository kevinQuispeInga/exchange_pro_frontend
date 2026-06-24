import api from '@/services/api'

const movimientoWalletService = {
  async obtener(monedaId) {
    const params = monedaId ? { IdMoneda: monedaId } : {}
    const { data } = await api.get('/api/MovimientoWallet', { params })
    return data
  }
}

export default movimientoWalletService