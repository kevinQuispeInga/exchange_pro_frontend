<template>
  <q-layout view="lHh Lpr lFf" class="main-layout" dark>
    <q-header class="main-header">
      <q-toolbar class="main-toolbar">
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
          class="menu-btn"
          @click="toggleLeftDrawer"
        />
        <q-toolbar-title class="main-title">
          <span class="logo-mark font-display text-gradient">ExchangePro</span>
        </q-toolbar-title>
        <div v-if="authStore.isAuthenticated" class="user-section">
          <q-btn
            flat
            dense
            round
            icon="notifications_none"
            size="md"
            class="notif-btn"
            @click="$router.push('/notificaciones')"
          >
            <q-badge floating color="negative" rounded>{{
              unreadCount
            }}</q-badge>
          </q-btn>
          <q-btn flat class="user-btn" no-caps>
            <div class="user-info row items-center no-wrap">
              <q-avatar size="32px" class="user-avatar">
                <q-icon name="person" size="18px" />
              </q-avatar>
              <span class="user-name q-ml-sm">{{
                authStore.user?.nombres || authStore.user?.nombreCompleto || authStore.user?.correo?.split('@')[0] || 'User'
              }}</span>
              <q-icon name="arrow_drop_down" size="20px" class="q-ml-xs" />
            </div>
            <q-menu class="user-menu" anchor="bottom right" self="top right">
              <q-list style="min-width: 180px">
                <q-item clickable v-close-popup @click="irAPerfil">
                  <q-item-section avatar
                    ><q-icon name="person" size="20px"
                  /></q-item-section>
                  <q-item-section
                    ><q-item-label>Mi Perfil</q-item-label></q-item-section
                  >
                </q-item>
                <q-item clickable v-close-popup @click="irAWallet">
                  <q-item-section avatar
                    ><q-icon name="account_balance_wallet" size="20px"
                  /></q-item-section>
                  <q-item-section
                    ><q-item-label>Mi Wallet</q-item-label></q-item-section
                  >
                </q-item>
                <q-separator />
                <q-item
                  clickable
                  v-close-popup
                  @click="cerrarSesion"
                  class="text-negative"
                >
                  <q-item-section avatar>
                    <q-icon name="logout" size="20px" color="negative" />
                  </q-item-section>
                  <q-item-section
                    ><q-item-label>Cerrar Sesión</q-item-label></q-item-section
                  >
                </q-item>
              </q-list>
            </q-menu>
          </q-btn>
        </div>
        <div v-else class="user-section">
          <q-btn flat label="Ingresar" to="/login" no-caps class="login-btn" />
          <q-btn
            outline
            label="Registrarse"
            to="/register"
            no-caps
            class="register-btn"
          />
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      :width="240"
      class="main-drawer"
    >
      <div class="drawer-header">
        <div class="drawer-logo">
          <div class="drawer-logo-icon">
            <q-icon name="currency_exchange" size="24px" color="white" />
          </div>
          <span class="drawer-brand font-display text-gradient"
            >ExchangePro</span
          >
        </div>
      </div>
      <q-scroll-area class="drawer-scroll">
        <q-list padding class="nav-list">
          <div class="nav-section-label">General</div>
          <EssentialLink
            v-for="link in mainLinks"
            :key="link.title"
            v-bind="link"
          />
          <template v-if="authStore.isAuthenticated">
            <div class="nav-section-label">Operaciones</div>
            <EssentialLink
              v-for="link in operLinks"
              :key="link.title"
              v-bind="link"
            />
            <div class="nav-section-label">Finanzas</div>
            <EssentialLink
              v-for="link in financeLinks"
              :key="link.title"
              v-bind="link"
            />
          </template>
          <template v-if="authStore.isAuthenticated">
            <div class="nav-section-label">Soporte</div>
            <EssentialLink
              v-for="link in supportLinks"
              :key="link.title"
              v-bind="link"
            />
          </template>
          <template v-if="authStore.isAdmin">
            <div class="nav-section-label">Administración</div>
            <EssentialLink
              v-for="link in adminLinks"
              :key="link.title"
              v-bind="link"
            />
          </template>
        </q-list>
      </q-scroll-area>
      <div class="drawer-footer">
        <TipoCambioBar />
        <div class="footer-version">ExchangePro v1.0</div>
      </div>
    </q-drawer>

    <q-page-container class="page-container">
      <router-view v-slot="{ Component }">
        <transition name="page" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import EssentialLink from '@/components/EssentialLink.vue'
import TipoCambioBar from '@/components/TipoCambioBar.vue'
import { useAuthStore } from '@/stores/authStore'
import { useNotificacionStore } from '@/stores/notificacionStore'
import notificacionService from '@/services/notificacionService'

const $router = useRouter()
const $q = useQuasar()
const authStore = useAuthStore()
const notificacionStore = useNotificacionStore()

const unreadCount = computed(() => notificacionStore.unreadCount)
const notificationInterval = ref(null)

const iniciarSondeo = () => {
  if (notificationInterval.value) return // ya está corriendo
  
  notificacionStore.cargarUnreadCount()

  // Configurar sondeo (polling) de notificaciones cada 5 segundos
  notificationInterval.value = setInterval(async () => {
    if (!authStore.isAuthenticated) {
      detenerSondeo()
      return
    }
    
    const oldCount = notificacionStore.unreadCount
    await notificacionStore.cargarUnreadCount()
    const newCount = notificacionStore.unreadCount

    if (newCount > oldCount) {
      try {
        const list = await notificacionService.obtener()
        const ultima = list[0]
        if (ultima && !ultima.leido) {
          $q.notify({
            type: 'info',
            message: `${ultima.titulo}: ${ultima.mensaje}`,
            position: 'top-right',
            timeout: 5000,
            icon: 'notifications_active',
            actions: [
              {
                label: 'Ver',
                color: 'white',
                handler: () => {
                  $router.push('/notificaciones')
                }
              }
            ]
          })
        }
      } catch (e) {
        $q.notify({
          type: 'info',
          message: 'Tienes nuevas notificaciones sin leer.',
          position: 'top-right',
          timeout: 5000,
          icon: 'notifications_active',
          actions: [
            {
              label: 'Ver',
              color: 'white',
              handler: () => {
                $router.push('/notificaciones')
              }
            }
          ]
        })
      }
    }
  }, 5000)
}

const detenerSondeo = () => {
  if (notificationInterval.value) {
    clearInterval(notificationInterval.value)
    notificationInterval.value = null
  }
}

// Observar el estado de autenticación para iniciar/detener el sondeo de forma dinámica
watch(() => authStore.isAuthenticated, (authenticated) => {
  if (authenticated) {
    iniciarSondeo()
  } else {
    detenerSondeo()
  }
}, { immediate: true })

onBeforeUnmount(() => {
  detenerSondeo()
})

const leftDrawerOpen = ref(false)

function toggleLeftDrawer() {
  leftDrawerOpen.value = !leftDrawerOpen.value
}

function cerrarSesion() {
  if (notificationInterval.value) {
    clearInterval(notificationInterval.value)
  }
  authStore.logout()
  leftDrawerOpen.value = false
  $router.push('/login')
}

function irAPerfil() {
  $router.push('/perfil')
}

function irAWallet() {
  $router.push('/wallet')
}

const mainLinks = computed(() => [
  { title: 'Inicio', icon: 'home', link: '#/' },
  {
    title: 'Ofertas',
    icon: 'storefront',
    link: '#/ofertas',
    badge: authStore.isAuthenticated ? 'Live' : null
  }
])

const operLinks = computed(() => [
  { title: 'Mis Ofertas', icon: 'assignment', link: '#/mis-ofertas' },
  {
    title: 'Crear Oferta',
    icon: 'add_circle_outline',
    link: '#/ofertas/crear'
  },
  { title: 'Transacciones', icon: 'swap_horiz', link: '#/transacciones' }
])

const financeLinks = computed(() => [
  { title: 'Mi Perfil', icon: 'person', link: '#/perfil' },
  { title: 'Mi Wallet', icon: 'account_balance_wallet', link: '#/wallet' },
  { title: 'Datos de Pago', icon: 'credit_card', link: '#/datos-pago' },
  { title: 'Disputas', icon: 'gavel', link: '#/disputas' }
])

const supportLinks = computed(() => [
  { title: 'Enviar Feedback', icon: 'feedback', link: '#/feedback' }
])

const adminLinks = computed(() => [
  {
    title: 'Panel Admin',
    icon: 'admin_panel_settings',
    link: '#/admin/dashboard'
  }
])
</script>

<style scoped>
.main-layout {
  background: var(--color-bg);
}

.main-header {
  background: rgba(13, 18, 37, 0.8) !important;
  backdrop-filter: blur(16px) !important;
  border-bottom: 1px solid var(--color-border) !important;
  box-shadow: none !important;
}

.main-toolbar {
  min-height: 56px;
  padding: 0 12px;
}

.menu-btn {
  color: var(--color-text-secondary);
  margin-right: 4px;
}

.menu-btn:hover {
  color: var(--color-text);
}

.main-title {
  font-size: 1.1rem;
  letter-spacing: -0.01em;
}

.logo-mark {
  font-weight: 700;
  font-size: 1.2rem;
}

.user-section {
  display: flex;
  align-items: center;
  gap: 8px;
}

.notif-btn {
  color: var(--color-text-secondary);
  position: relative;
}

.notif-btn::after {
  content: '';
  position: absolute;
  top: 6px;
  right: 6px;
  width: 6px;
  height: 6px;
  background: var(--color-negative);
  border-radius: 50%;
  animation: notif-pulse 2s infinite;
}

@keyframes notif-pulse {
  0%,
  100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(1.3);
  }
}

.notif-btn:hover {
  color: var(--color-text);
}

.user-btn {
  color: var(--color-text);
  border-radius: 8px;
  padding: 4px 8px;
}

.user-btn:hover {
  background: rgba(124, 58, 237, 0.1);
}

.user-avatar {
  background: rgba(124, 58, 237, 0.2) !important;
  color: white;
}

.user-name {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 500;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.login-btn {
  color: var(--color-text-secondary);
  font-weight: 500;
  font-size: 0.85rem;
}

.login-btn:hover {
  color: var(--color-text);
}

.register-btn {
  color: var(--color-text);
  border-color: var(--color-border);
  font-weight: 500;
  font-size: 0.85rem;
}

.register-btn:hover {
  border-color: var(--color-primary);
  color: var(--color-primary-light);
}

.main-drawer {
  background: rgba(13, 18, 37, 0.85) !important;
  backdrop-filter: blur(20px) !important;
  border-right: 1px solid var(--color-border) !important;
}

.drawer-header {
  padding: 20px 16px 16px;
  border-bottom: 1px solid var(--color-border);
}

.drawer-logo {
  display: flex;
  align-items: center;
  gap: 10px;
}

.drawer-logo-icon {
  width: 36px;
  height: 36px;
  background: linear-gradient(
    135deg,
    var(--color-primary),
    var(--color-accent)
  );
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.drawer-brand {
  font-size: 1.1rem;
  font-weight: 700;
}

.drawer-scroll {
  height: calc(100vh - 140px);
}

.nav-list {
  padding: 8px 0;
}

.nav-section-label {
  font-family: var(--font-body);
  font-size: 0.65rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--color-text-muted);
  padding: 16px 16px 6px;
}

.drawer-footer {
  padding: 12px 16px;
  border-top: 1px solid var(--color-border);
  text-align: center;
}

.footer-version {
  font-size: 0.7rem;
  color: var(--color-text-muted);
}

.page-container {
  min-height: 100vh;
  background: var(--color-bg);
  padding-bottom: 88px;
}
</style>
