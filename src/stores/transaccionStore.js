import { defineStore } from 'pinia'
import transaccionService from '@/services/transaccionService'

export const useTransaccionStore = defineStore('transaccion', {
  state: () => ({
    transacciones: [],
    loading: false,
    error: null
  }),
  actions: {
    async listarMisOperaciones() {
      this.loading = true
      this.error = null
      try {
        this.transacciones = await transaccionService.listarMisOperaciones()
      } catch (e) {
        this.error =
          e.response?.data?.message || 'Error al cargar transacciones'
        throw e
      } finally {
        this.loading = false
      }
    },
    async crear(datos) {
      await transaccionService.crear(datos)
      await this.listarMisOperaciones()
    },
    async actualizarEstado(datos) {
      await transaccionService.actualizarEstado(datos)
      await this.listarMisOperaciones()
    },
    async liberarFondos(idTransaccion) {
      await transaccionService.liberarFondos({ idTransaccion })
      await this.listarMisOperaciones()
    },
    async cancelar(id) {
      await transaccionService.cancelar(id)
      await this.listarMisOperaciones()
    }
  }
})
