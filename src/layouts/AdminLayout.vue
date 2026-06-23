<template>
  <q-layout view="lHh Lpr lFf" class="admin-layout" dark>
    <q-header class="admin-header">
      <q-toolbar class="admin-toolbar">
        <q-space />
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
            authStore.user?.nombres || authStore.user?.correo?.split('@')[0] || 'Admin'
          }}</span>
        </q-btn>
      </q-toolbar>
    </q-header>

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
import { useAuthStore } from '@/stores/authStore'

const authStore = useAuthStore()
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
