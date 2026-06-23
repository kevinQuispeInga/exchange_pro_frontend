<template>
  <q-layout view="lHh Lpr lFf" class="main-layout" dark>
    <q-header class="main-header">
      <q-toolbar class="main-toolbar">
        <q-toolbar-title class="main-title">
          <span class="logo-mark font-display text-gradient">ExchangePro</span>
        </q-toolbar-title>
        <div v-if="authStore.isAuthenticated" class="user-section">
          <q-btn flat class="user-btn" no-caps>
            <div class="user-info row items-center no-wrap">
              <q-avatar size="32px" class="user-avatar">
                <q-icon name="person" size="18px" />
              </q-avatar>
              <span class="user-name q-ml-sm">{{
                authStore.user?.nombres || authStore.user?.correo?.split('@')[0] || 'User'
              }}</span>
            </div>
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
import { useAuthStore } from '@/stores/authStore'

const authStore = useAuthStore()
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
}
</style>
