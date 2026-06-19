import { defineStore } from 'pinia'
import walletService from '@/services/walletService'

export const useWalletStore = defineStore('wallet', {
  state: () => ({
    idWallet: null,
    saldos: [],
    loading: false,
    error: null
  }),
  actions: {
    async cargarSaldo() {
      this.loading = true
      this.error = null
      try {
        const data = await walletService.getSaldo()
        this.idWallet = data.idWallet
        this.saldos = data.saldos
      } catch (e) {
        this.error = e.response?.data?.mensaje || 'Error al cargar saldo'
        throw e
      } finally {
        this.loading = false
      }
    },
    async recargar(datos) {
      await walletService.recargar(datos)
      await this.cargarSaldo()
    }
  }
})
