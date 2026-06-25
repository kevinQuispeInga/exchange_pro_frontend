import { defineRouter } from '#q-app'
import {
  createMemoryHistory,
  createRouter,
  createWebHashHistory,
  createWebHistory
} from 'vue-router'

import routes from './routes.js'
// ¡Aquí está la ruta correcta con el @/ para que Vite no llore!
import { useAuthStore } from '@/stores/authStore'

export default defineRouter(() => {
  const createHistory = import.meta.env.QUASAR_SERVER
    ? createMemoryHistory
    : import.meta.env.QUASAR_VUE_ROUTER_MODE === 'history'
      ? createWebHistory
      : createWebHashHistory

  const Router = createRouter({
    scrollBehavior: () => ({ left: 0, top: 0 }),
    routes,
    history: createHistory(import.meta.env.QUASAR_VUE_ROUTER_BASE)
  })

  const protectedRoutes = [
    '/mis-ofertas',
    '/ofertas/crear',
    '/wallet',
    '/transacciones',
    '/datos-pago',
    '/disputas',
    '/perfil',
    '/notificaciones',
    '/admin/disputas',
    '/admin/reportes'
  ]

  Router.beforeEach(to => {
    const authStore = useAuthStore()
    const path = to.path

    if (
      protectedRoutes.some(prefix => path.startsWith(prefix)) &&
      !authStore.isAuthenticated
    ) {
      return '/login'
    }

    if (path === '/' && authStore.isAdmin) {
      return '/admin/dashboard'
    }

    if (path === '/login' && authStore.isAdmin) {
      return '/admin/dashboard'
    }

    if (path.startsWith('/admin') && !authStore.isAdmin) {
      return '/'
    }

    return true
  })

  return Router
})
