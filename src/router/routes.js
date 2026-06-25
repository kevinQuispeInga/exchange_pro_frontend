const routes = [
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      { path: '', component: () => import('@/pages/IndexPage.vue') },
      { path: 'ofertas', component: () => import('@/pages/OfertasPage.vue') },
      {
        path: 'ofertas/crear',
        component: () => import('@/pages/CrearOfertaPage.vue')
      },
      {
        path: 'mis-ofertas',
        component: () => import('@/pages/MisOfertasPage.vue')
      },
      { path: 'wallet', component: () => import('@/pages/WalletPage.vue') },
      {
        path: 'transacciones',
        component: () => import('@/pages/TransaccionesPage.vue')
      },
      {
        path: 'transacciones/:id',
        component: () => import('@/pages/TransaccionDetallePage.vue')
      },
      {
        path: 'datos-pago',
        component: () => import('@/pages/DatosPagoPage.vue')
      },
      { path: 'disputas', component: () => import('@/pages/DisputasPage.vue') },
      {
        path: 'feedback',
        component: () => import('@/pages/UserFeedbackPage.vue')
      },
      { path: 'perfil', component: () => import('@/pages/PerfilPage.vue') },
      {
        path: 'notificaciones',
        component: () => import('@/pages/NotificacionesPage.vue')
      }
    ]
  },
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    children: [
      {
        path: 'dashboard',
        component: () => import('@/pages/AdminDashboardPage.vue')
      },
      {
        path: 'disputas',
        component: () => import('@/pages/AdminDisputasPage.vue')
      },
      {
        path: 'feedback',
        component: () => import('@/pages/AdminFeedbackPage.vue')
      },
      {
        path: 'reportes',
        component: () => import('@/pages/AdminReportesPage.vue')
      },
      {
        path: 'notificaciones',
        component: () => import('@/pages/NotificacionesPage.vue')
      }
    ]
  },
  {
    path: '/login',
    component: () => import('@/pages/LoginPage.vue')
  },
  {
    path: '/register',
    component: () => import('@/pages/RegisterPage.vue')
  },
  {
    path: '/forgot-password',
    component: () => import('@/pages/ForgotPasswordPage.vue')
  },
  {
    path: '/reset-password',
    component: () => import('@/pages/ResetPasswordPage.vue')
  },
  {
    path: '/:catchAll(.*)*',
    component: () => import('@/pages/ErrorNotFound.vue')
  }
]

export default routes
