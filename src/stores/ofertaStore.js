import { defineStore } from 'pinia'
import ofertaService from '@/services/ofertaService'

export const useOfertaStore = defineStore('oferta', {
  state: () => ({
    ofertas: [],
    misOfertas: [],
    loading: false,
    error: null
  }),
  actions: {
    async listarActivas() {
      this.loading = true
      this.error = null
      try {
        this.ofertas = await ofertaService.listarActivas()
      } catch (e) {
        this.error = e.response?.data?.mensaje || 'Error al cargar ofertas'
        throw e
      } finally {
        this.loading = false
      }
    },
    async listarMisOfertas() {
      this.loading = true
      this.error = null
      try {
        this.misOfertas = await ofertaService.listarMisOfertas()
      } catch (e) {
        this.error = e.response?.data?.mensaje || 'Error al cargar mis ofertas'
        throw e
      } finally {
        this.loading = false
      }
    },
    async crear(datos) {
      await ofertaService.crear(datos)
      await this.listarActivas()
    },
    async cancelar(id) {
      await ofertaService.cancelar(id)
      await this.listarMisOfertas()
    }
  }
})
