<template>
  <q-page class="perfil-page">
    <div class="page-header">
      <div>
        <h1 class="page-title font-display">Mi Perfil</h1>
        <p class="page-subtitle">Administra tu información personal</p>
      </div>
    </div>

    <div v-if="loading" class="flex flex-center q-pa-xl">
      <q-spinner color="primary" size="3em" />
    </div>

    <template v-else>
      <div class="profile-hero">
        <div class="profile-avatar-wrap" @click="triggerFotoPicker">
          <q-avatar size="80px" class="profile-avatar">
            <img v-if="fotoUrl" :src="fotoUrl" />
            <q-icon v-else name="person" size="36px" />
          </q-avatar>
          <div class="profile-avatar-overlay">
            <q-icon name="camera_alt" size="20px" color="white" />
          </div>
        </div>
        <input
          ref="fotoInput"
          type="file"
          accept="image/*"
          style="display: none"
          @change="onFotoChange"
        />
        <div class="profile-hero__info">
          <h2 class="profile-hero__name font-display">{{ perfil.nombres || perfil.nombreCompleto || '—' }}</h2>
          <div class="profile-hero__reputation" v-if="perfil.reputacion != null">
            <div class="stars-row">
              <q-icon
                v-for="i in 5"
                :key="i"
                :name="i <= Math.round(perfil.reputacion) ? 'star' : 'star_border'"
                :color="i <= Math.round(perfil.reputacion) ? 'warning' : 'grey-6'"
                size="18px"
              />
              <span class="reputation-text">{{ perfil.reputacion.toFixed(1) }}</span>
            </div>
            <span class="reputation-count">{{ perfil.totalCalificaciones }} calificaciones</span>
          </div>
        </div>
      </div>

      <q-form @submit="guardarPerfil" class="form-grid">
        <div class="form-card">
          <div class="form-card__header">
            <q-icon name="person_outline" size="18px" />
            <h3 class="form-card__title font-display">Información Personal</h3>
          </div>
          <div class="form-card__body">
            <div class="field-row">
              <div class="field-group flex-1">
                <label class="field-label">Nombres</label>
                <q-input
                  v-model="perfil.nombres"
                  outlined
                  dense
                  dark
                  placeholder="Tus nombres"
                  class="form-input"
                  :rules="[val => !!val || 'Los nombres son requeridos']"
                  hide-bottom-space
                />
              </div>
              <div class="field-group flex-1">
                <label class="field-label">Apellidos</label>
                <q-input
                  v-model="perfil.apellidos"
                  outlined
                  dense
                  dark
                  placeholder="Tus apellidos"
                  class="form-input"
                  :rules="[val => !!val || 'Los apellidos son requeridos']"
                  hide-bottom-space
                />
              </div>
            </div>
            <div class="field-group">
              <label class="field-label">Correo Electrónico</label>
              <q-input
                :model-value="perfil.correo"
                outlined
                dense
                dark
                readonly
                class="form-input form-input--readonly"
                hide-bottom-space
              >
                <template v-slot:prepend>
                  <q-icon name="email" size="18px" class="input-icon" />
                </template>
              </q-input>
            </div>
            <div class="field-group">
              <label class="field-label">Documento de Identidad</label>
              <q-input
                :model-value="perfil.documentoIdentidad"
                outlined
                dense
                dark
                readonly
                class="form-input form-input--readonly"
                hide-bottom-space
              >
                <template v-slot:prepend>
                  <q-icon name="badge" size="18px" class="input-icon" />
                </template>
              </q-input>
            </div>
            <div class="field-group">
              <label class="field-label">Teléfono</label>
              <q-input
                v-model="perfil.telefono"
                type="tel"
                outlined
                dense
                dark
                placeholder="999888777"
                class="form-input"
                maxlength="9"
                hide-bottom-space
              />
            </div>
          </div>
        </div>

        <div class="form-footer">
          <q-btn
            label="Cancelar"
            flat
            no-caps
            class="btn-cancel"
            @click="$router.push('/')"
          />
          <q-btn
            type="submit"
            color="primary"
            label="Guardar Cambios"
            icon="save"
            unelevated
            no-caps
            class="btn-submit"
            :loading="saving"
          />
        </div>
      </q-form>
    </template>
  </q-page>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useQuasar } from 'quasar'
import perfilService from '@/services/perfilService'
import { useAuthStore } from '@/stores/authStore'

const API_BASE_URL = 'http://localhost:5238'
const $q = useQuasar()
const authStore = useAuthStore()

const loading = ref(true)
const saving = ref(false)
const fotoInput = ref(null)
const fotoUrl = ref(null)

const perfil = reactive({
  nombres: '',
  apellidos: '',
  nombreCompleto: '',
  correo: '',
  documentoIdentidad: '',
  telefono: '',
  reputacion: null,
  totalCalificaciones: 0,
  rutaFoto: null
})

function triggerFotoPicker() {
  fotoInput.value?.click()
}

function onFotoChange(e) {
  const file = e.target.files[0]
  if (!file) return
  const reader = new FileReader()
  reader.onload = async () => {
    fotoUrl.value = reader.result
    try {
      const resp = await perfilService.subirFoto(file)
      perfil.rutaFoto = resp.ruta
      $q.notify({ type: 'positive', message: 'Foto actualizada', position: 'top' })
    } catch {
      $q.notify({ type: 'negative', message: 'Error al subir foto', position: 'top' })
    }
  }
  reader.readAsDataURL(file)
}

onMounted(async () => {
  try {
    const data = await perfilService.obtener()
    if (data) {
      perfil.nombres = data.nombres || ''
      perfil.apellidos = data.apellidos || ''
      perfil.nombreCompleto = data.nombreCompleto || ''
      perfil.correo = data.correo || ''
      perfil.documentoIdentidad = data.documentoIdentidad || ''
      perfil.telefono = data.telefono || ''
      perfil.reputacion = data.reputacion
      perfil.totalCalificaciones = data.totalCalificaciones || 0
      perfil.rutaFoto = data.fotoPerfil || data.rutaFoto || ''
      if (perfil.rutaFoto) {
        fotoUrl.value = `${API_BASE_URL}${perfil.rutaFoto}`
      }
    }
  } catch {
    $q.notify({ type: 'negative', message: 'Error al cargar perfil', position: 'top' })
  } finally {
    loading.value = false
  }
})

const guardarPerfil = async () => {
  saving.value = true
  try {
    await perfilService.actualizar({
      nombres: perfil.nombres,
      apellidos: perfil.apellidos,
      telefono: perfil.telefono
    })
    authStore.user.nombres = perfil.nombres
    authStore.user.apellidos = perfil.apellidos
    authStore.user.nombreCompleto = `${perfil.nombres} ${perfil.apellidos}`
    $q.notify({ type: 'positive', message: 'Perfil actualizado exitosamente', position: 'top' })
  } catch {
    $q.notify({ type: 'negative', message: 'Error al guardar perfil', position: 'top' })
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.perfil-page {
  padding: 28px 32px;
  max-width: 800px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0 0 4px;
  color: var(--color-text);
}

.page-subtitle {
  font-family: var(--font-body);
  font-size: 0.9rem;
  color: var(--color-text-secondary);
  margin: 0;
}

@media (max-width: 768px) {
  .perfil-page {
    padding: 20px 16px;
  }
}

.profile-hero {
  display: flex;
  align-items: center;
  gap: 24px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: 28px 32px;
  margin-bottom: 24px;
}

.profile-avatar-wrap {
  position: relative;
  cursor: pointer;
  flex-shrink: 0;
}

.profile-avatar {
  width: 80px;
  height: 80px;
  background: rgba(124, 58, 237, 0.2) !important;
  color: white;
  font-size: 2rem;
}

.profile-avatar img {
  object-fit: cover;
}

.profile-avatar-overlay {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.profile-avatar-wrap:hover .profile-avatar-overlay {
  opacity: 1;
}

.profile-hero__info {
  flex: 1;
}

.profile-hero__name {
  font-size: 1.3rem;
  font-weight: 700;
  margin: 0 0 6px;
  color: var(--color-text);
}

.stars-row {
  display: flex;
  align-items: center;
  gap: 2px;
}

.reputation-text {
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-warning);
  margin-left: 6px;
}

.reputation-count {
  font-family: var(--font-body);
  font-size: 0.75rem;
  color: var(--color-text-muted);
  display: block;
  margin-top: 2px;
}

.form-grid {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.form-card__header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-primary);
  padding: 18px 20px;
  border-bottom: 1px solid var(--color-border-light);
}

.form-card__title {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  color: var(--color-text);
}

.form-card__body {
  padding: 16px 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-row {
  display: flex;
  gap: 16px;
}

.flex-1 {
  flex: 1;
}

.field-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.form-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  min-height: 42px;
}

.form-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.form-input--readonly :deep(.q-field__control) {
  background: rgba(0, 0, 0, 0.15);
}

.input-icon {
  color: var(--color-text-muted);
}

.form-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 8px;
}

.btn-cancel {
  color: var(--color-text-secondary);
  font-weight: 500;
  border-radius: var(--radius-sm);
}

.btn-submit {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
}
</style>
