import { defineStore } from 'pinia'
import { LocalStorage } from 'quasar'
import authService from '@/services/authService'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: LocalStorage.getItem('authToken') || null,
    user: LocalStorage.getItem('currentUser') || null
  }),
  getters: {
    isAuthenticated: state => !!state.token,
    isAdmin: state => state.user?.rol === '2',
    userId: state => state.user?.idUsuario
  },
  actions: {
    async login(correo, password) {
      const response = await authService.login(correo, password)
      this.token = response.token
      const payload = JSON.parse(atob(response.token.split('.')[1]))
      this.user = {
        idUsuario: payload.IdUsuario,
        correo: payload.sub,
        rol: payload.Rol,
        nombres: payload.Nombres,
        apellidos: payload.Apellidos,
        nombreCompleto: payload.NombreCompleto
      }
      LocalStorage.set('authToken', this.token)
      LocalStorage.set('currentUser', this.user)
    },
    async registrar(datos) {
      return await authService.registrar(datos)
    },
    logout() {
      this.token = null
      this.user = null
      LocalStorage.remove('authToken')
      LocalStorage.remove('currentUser')
    }
  }
})
