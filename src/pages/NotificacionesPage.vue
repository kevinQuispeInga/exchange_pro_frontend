<template>
  <q-page class="notificaciones-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Notificaciones</h1>
        <p class="page-subtitle">Tus avisos recientes</p>
      </div>
    </div>

    <q-card flat bordered class="notificaciones-card">
      <q-card-section>
        <div class="notificaciones-list">
          <div
            v-for="notificacion in notificaciones"
            :key="notificacion.idNotificacion"
            class="notificacion-item"
            :class="{ unread: !notificacion.leido }"
            @click="marcar(notificacion)"
          >
            <div class="notificacion-left">
              <div class="notificacion-title">{{ notificacion.titulo }}</div>
              <div class="notificacion-message">{{ notificacion.mensaje }}</div>
            </div>
            <div class="notificacion-right">
              <div class="notificacion-date">{{
                formatFecha(notificacion.fecha)
              }}</div>
              <q-badge
                v-if="!notificacion.leido"
                color="primary"
                label="Nuevo"
                class="notificacion-badge"
              />
            </div>
          </div>
          <div v-if="notificaciones.length === 0" class="empty-state">
            <q-icon name="notifications_off" size="48px" color="grey-6" />
            <p class="empty-text">No hay notificaciones nuevas.</p>
          </div>
        </div>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import { useNotificacionStore } from '@/stores/notificacionStore'

const $q = useQuasar()
const notificacionStore = useNotificacionStore()

const notificaciones = computed(() => notificacionStore.notificaciones)

const cargarNotificaciones = async () => {
  try {
    await notificacionStore.cargarNotificaciones()
  } catch (error) {
    console.error('Error cargando notificaciones:', error)
    $q.notify({
      type: 'negative',
      message: 'Error al cargar notificaciones',
      position: 'top'
    })
  }
}

const marcar = async notificacion => {
  if (notificacion.leido) return
  try {
    await notificacionStore.marcarComoLeido(notificacion.idNotificacion)
  } catch (error) {
    console.error('Error marcando notificación como leída:', error)
    $q.notify({
      type: 'negative',
      message: 'No se pudo marcar como leída',
      position: 'top'
    })
  }
}

const formatFecha = fecha => {
  if (!fecha) return ''
  return new Date(fecha).toLocaleString('es-PE', {
    year: 'numeric',
    month: 'short',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(cargarNotificaciones)
</script>

<style scoped>
.notificaciones-page {
  padding: 24px 32px;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 1.6rem;
  font-weight: 700;
  margin: 0 0 4px;
}

.page-subtitle {
  color: var(--color-text-secondary);
  margin: 0;
}

.notificaciones-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
}

.notificaciones-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.notificacion-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 18px 16px;
  border-radius: 12px;
  cursor: pointer;
  transition: background 0.2s ease;
  background: var(--color-surface);
}

.notificacion-item.unread {
  background: rgba(68, 114, 196, 0.08);
}

.notificacion-item:hover {
  background: rgba(68, 114, 196, 0.12);
}

.notificacion-title {
  font-weight: 700;
  margin-bottom: 6px;
}

.notificacion-message {
  color: var(--color-text-secondary);
}

.notificacion-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 6px;
}

.notificacion-date {
  font-size: 0.8rem;
  color: var(--color-text-secondary);
}

.notificacion-badge {
  text-transform: uppercase;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 0;
  gap: 12px;
  color: var(--color-text-secondary);
}

.empty-text {
  margin: 0;
}
</style>
