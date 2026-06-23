import { defineStore } from 'pinia'
import notificacionService from '@/services/notificacionService'

export const useNotificacionStore = defineStore('notificacion', {
  state: () => ({
    unreadCount: 0,
    notificaciones: []
  }),
  actions: {
    async cargarUnreadCount() {
      try {
        this.unreadCount = await notificacionService.contadorSinLeer()
      } catch (error) {
        this.unreadCount = 0
        console.error(
          'Error cargando contador de notificaciones no leídas:',
          error
        )
      }
    },
    async cargarNotificaciones() {
      try {
        this.notificaciones = await notificacionService.obtener()
      } catch (error) {
        console.error('Error cargando notificaciones:', error)
        throw error
      }
    },
    async marcarComoLeido(id) {
      try {
        await notificacionService.marcarComoLeido(id)
        const index = this.notificaciones.findIndex(
          item => item.idNotificacion === id
        )
        if (index !== -1) {
          this.notificaciones[index].leido = true
        }
        await this.cargarUnreadCount()
      } catch (error) {
        console.error('Error marcando notificación como leída:', error)
        throw error
      }
    }
  }
})
