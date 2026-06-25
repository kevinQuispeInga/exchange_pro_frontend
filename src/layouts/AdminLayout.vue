<template>
  <q-layout view="lHh Lpr lFf" class="admin-layout" dark>
    <q-header class="admin-header">
      <q-toolbar class="admin-toolbar">
        <q-btn
          flat
          dense
          round
          icon="menu"
          class="admin-menu-btn"
          @click="toggleDrawer"
        />
        <q-space />
        <q-btn
          flat
          dense
          round
          icon="notifications"
          size="md"
          class="admin-notif-btn"
          @click="$router.push('/admin/notificaciones')"
        >
          <q-badge floating color="negative" rounded>{{ unreadCount }}</q-badge>
        </q-btn>
        <q-btn flat class="admin-user-btn" no-caps>
          <q-avatar
            size="30px"
            color="primary"
            text-color="white"
            class="admin-avatar"
          >
            <q-icon name="shield" size="16px" />
          </q-avatar>
          <span class="admin-user-name q-ml-sm">{{
            authStore.user?.nombres || authStore.user?.nombreCompleto || authStore.user?.correo?.split('@')[0] || 'Admin'
          }}</span>
        </q-btn>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="drawerOpen"
      show-if-above
      :width="240"
      class="admin-drawer"
    >
      <div class="drawer-header">
        <div class="drawer-logo">
          <div class="drawer-logo-icon">
            <q-icon name="currency_exchange" size="24px" color="white" />
          </div>
          <span class="drawer-brand font-display text-gradient"
            >Admin Panel</span
          >
        </div>
      </div>

      <q-scroll-area class="drawer-scroll">
        <q-list padding class="drawer-nav">
          <q-item
            v-for="item in navItems"
            :key="item.label"
            clickable
            :active="isActive(item.link)"
            active-class="nav-active"
            class="drawer-nav-item"
            @click="navigate(item.link)"
          >
            <q-item-section avatar class="nav-item-icon">
              <q-icon :name="item.icon" size="20px" />
            </q-item-section>
            <q-item-section>
              <q-item-label class="nav-item-label">{{
                item.label
              }}</q-item-label>
            </q-item-section>
          </q-item>
        </q-list>
      </q-scroll-area>

      <div class="drawer-footer">
        <TipoCambioBar />
        <div class="admin-profile">
          <q-avatar
            size="36px"
            color="primary"
            text-color="white"
            class="profile-avatar"
          >
            {{ authStore.user?.nombres?.charAt(0)?.toUpperCase() || authStore.user?.correo?.charAt(0)?.toUpperCase() || 'A' }}
          </q-avatar>
          <div class="profile-info">
            <div class="profile-name">{{
              authStore.user?.nombres || authStore.user?.nombreCompleto || authStore.user?.correo?.split('@')[0] || 'Admin'
            }}</div>
            <div class="profile-role">Administrador</div>
          </div>
        </div>
        <q-btn
          flat
          dense
          no-caps
          icon="logout"
          label="Cerrar Sesión"
          class="logout-btn"
          @click="cerrarSesion"
        />
      </div>
    </q-drawer>

    <q-page-container class="admin-content">
      <router-view v-slot="{ Component }">
        <transition name="page" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </q-page-container>
  </q-layout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import { useNotificacionStore } from '@/stores/notificacionStore'
import TipoCambioBar from '@/components/TipoCambioBar.vue'

const $router = useRouter()
const $route = useRoute()
const authStore = useAuthStore()
const notificacionStore = useNotificacionStore()

const unreadCount = computed(() => notificacionStore.unreadCount)

onMounted(() => {
  if (authStore.isAuthenticated) {
    notificacionStore.cargarUnreadCount()
  }
})

const drawerOpen = ref(false)

const navItems = computed(() => {
  const items = [
    { label: 'Dashboard', icon: 'dashboard', link: '/admin/dashboard' },
    { label: 'Disputas', icon: 'gavel', link: '/admin/disputas' },
    { label: 'Feedback', icon: 'feedback', link: '/admin/feedback' },
    { label: 'Reportes', icon: 'bar_chart', link: '/admin/reportes' }
  ]
  return items
})

function isActive(link) {
  return $route.path.startsWith(link)
}

function navigate(link) {
  $router.push(link)
  if (window.innerWidth < 1024) {
    drawerOpen.value = false
  }
}

function toggleDrawer() {
  drawerOpen.value = !drawerOpen.value
}

function cerrarSesion() {
  authStore.logout()
  drawerOpen.value = false
  $router.push('/login')
}
</script>

<style scoped>
.admin-layout {
  background: var(--color-bg);
  min-height: 100vh;
}

.admin-header {
  background: rgba(13, 18, 37, 0.8) !important;
  backdrop-filter: blur(16px) !important;
  border-bottom: 1px solid var(--color-border) !important;
  box-shadow: none !important;
}

.admin-toolbar {
  min-height: 56px;
  padding: 0 16px;
}

.admin-menu-btn {
  color: var(--color-text-secondary);
}

.admin-menu-btn:hover {
  color: var(--color-text);
}

.admin-notif-btn {
  color: var(--color-text-secondary);
  margin-right: 4px;
}

.admin-notif-btn:hover {
  color: var(--color-text);
}

.admin-user-btn {
  color: var(--color-text);
  border-radius: 8px;
  padding: 4px 8px;
}

.admin-user-btn:hover {
  background: rgba(124, 58, 237, 0.1);
}

.admin-avatar {
  background: rgba(124, 58, 237, 0.2) !important;
}

.admin-user-name {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 500;
}

.admin-drawer {
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
  font-size: 1rem;
  font-weight: 700;
}

.drawer-scroll {
  height: calc(100vh - 180px);
}

.drawer-nav {
  padding: 8px 0;
}

.drawer-nav-item {
  border-radius: 8px;
  margin: 2px 8px;
  padding: 8px 12px;
  transition:
    background var(--transition-fast),
    color var(--transition-fast);
  position: relative;
}

.drawer-nav-item:hover {
  background: rgba(124, 58, 237, 0.08);
}

.drawer-nav-item.nav-active {
  background: rgba(124, 58, 237, 0.12);
  border-left: 3px solid var(--color-primary);
  margin-left: 8px;
  padding-left: 9px;
}

.drawer-nav-item.nav-active .nav-item-icon :deep(.q-icon) {
  color: var(--color-primary-light);
}

.drawer-nav-item.nav-active .nav-item-label {
  color: var(--color-primary-light);
  font-weight: 600;
}

.nav-item-icon :deep(.q-icon) {
  color: var(--color-text-secondary);
  transition: color var(--transition-fast);
}

.nav-item-label {
  font-family: var(--font-body);
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--color-text);
  transition: color var(--transition-fast);
}

.drawer-footer {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 12px 16px;
  border-top: 1px solid var(--color-border);
  background: rgba(13, 18, 37, 0.9);
}

.admin-profile {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.profile-avatar {
  flex-shrink: 0;
}

.profile-info {
  flex: 1;
  min-width: 0;
}

.profile-name {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.profile-role {
  font-family: var(--font-body);
  font-size: 0.7rem;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.logout-btn {
  width: 100%;
  color: var(--color-negative);
  font-size: 0.8rem;
  font-weight: 500;
  border-radius: 6px;
  padding: 6px 12px;
  justify-content: flex-start;
}

.logout-btn:hover {
  background: rgba(244, 63, 94, 0.1);
}

.admin-content {
  min-height: 100vh;
  background: var(--color-bg);
}
</style>
