<template>
  <div class="auth-page">
    <div class="auth-bg">
      <div class="auth-bg__shapes">
        <div class="shape shape--1"></div>
        <div class="shape shape--2"></div>
        <div class="shape shape--3"></div>
      </div>
    </div>
    <div class="auth-container">
      <div class="auth-card-wrapper animate-scale-in">
        <div class="auth-brand">
          <div class="auth-brand__icon">
            <q-icon name="currency_exchange" size="32px" color="white" />
          </div>
          <span class="auth-brand__name font-display">ExchangePro</span>
        </div>
        <h1 class="auth-title font-display">Crear tu cuenta</h1>
        <p class="auth-subtitle">Únete a la plataforma de intercambio P2P</p>
        <q-form @submit="onSubmit" class="auth-form">
          <div class="row q-col-gutter-sm">
            <div class="col-12">
              <div class="field-group">
                <label class="field-label">Nombre completo</label>
                <q-input
                  v-model="form.nombreCompleto"
                  outlined
                  dense
                  dark
                  placeholder="Ej: Juan Pérez"
                  class="auth-input"
                  maxlength="100"
                  :rules="[val => !!val || 'Requerido']"
                  hide-bottom-space
                >
                  <template v-slot:prepend
                    ><q-icon name="person" size="18px" class="input-icon"
                  /></template>
                </q-input>
              </div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Correo electrónico</label>
                <q-input
                  v-model="form.correo"
                  type="email"
                  outlined
                  dense
                  dark
                  placeholder="tu@correo.com"
                  class="auth-input"
                  :rules="[
                    val => !!val || 'Requerido',
                    val => /.+@.+\..+/.test(val) || 'Inválido'
                  ]"
                  hide-bottom-space
                >
                  <template v-slot:prepend
                    ><q-icon name="email" size="18px" class="input-icon"
                  /></template>
                </q-input>
              </div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Teléfono</label>
                <q-input
                  v-model="form.telefono"
                  type="tel"
                  outlined
                  dense
                  dark
                  placeholder="999888777"
                  class="auth-input"
                  maxlength="9"
                  :rules="[
                    val => !!val || 'Requerido',
                    val => /^\d{9}$/.test(val) || 'Debe tener 9 dígitos'
                  ]"
                  hide-bottom-space
                >
                  <template v-slot:prepend
                    ><q-icon name="phone" size="18px" class="input-icon"
                  /></template>
                </q-input>
              </div>
            </div>
            <div class="col-12">
              <div class="field-group">
                <label class="field-label">Documento de identidad</label>
                <q-input
                  v-model="form.documentoIdentidad"
                  outlined
                  dense
                  dark
                  placeholder="DNI o CE"
                  class="auth-input"
                  maxlength="8"
                  :rules="[
                    val => !!val || 'Requerido',
                    val => /^\d{8}$/.test(val) || 'Debe tener 8 dígitos'
                  ]"
                  hide-bottom-space
                >
                  <template v-slot:prepend
                    ><q-icon name="badge" size="18px" class="input-icon"
                  /></template>
                </q-input>
              </div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Contraseña</label>
                <q-input
                  v-model="form.password"
                  :type="showPassword ? 'text' : 'password'"
                  outlined
                  dense
                  dark
                  placeholder="••••••••"
                  class="auth-input"
                  maxlength="50"
                  :rules="[
                    val => !!val || 'Requerido',
                    val => val.length >= 6 || 'Mín 6 car.'
                  ]"
                  hide-bottom-space
                >
                  <template v-slot:prepend
                    ><q-icon name="lock" size="18px" class="input-icon"
                  /></template>
                  <template v-slot:append>
                    <q-icon
                      :name="showPassword ? 'visibility_off' : 'visibility'"
                      size="18px"
                      class="cursor-pointer input-icon"
                      @click="showPassword = !showPassword"
                    />
                  </template>
                </q-input>
              </div>
            </div>
            <div class="col-12 col-sm-6">
              <div class="field-group">
                <label class="field-label">Confirmar contraseña</label>
                <q-input
                  v-model="form.confirmarPassword"
                  :type="showConfirmPassword ? 'text' : 'password'"
                  outlined
                  dense
                  dark
                  placeholder="••••••••"
                  class="auth-input"
                  maxlength="50"
                  :rules="[
                    val => !!val || 'Requerido',
                    val => val === form.password || 'No coinciden'
                  ]"
                  hide-bottom-space
                >
                  <template v-slot:prepend
                    ><q-icon name="lock" size="18px" class="input-icon"
                  /></template>
                  <template v-slot:append>
                    <q-icon
                      :name="
                        showConfirmPassword ? 'visibility_off' : 'visibility'
                      "
                      size="18px"
                      class="cursor-pointer input-icon"
                      @click="showConfirmPassword = !showConfirmPassword"
                    />
                  </template>
                </q-input>
              </div>
            </div>
          </div>
          <q-btn
            label="Crear Cuenta"
            type="submit"
            color="primary"
            unelevated
            no-caps
            class="auth-submit q-mt-sm"
            :loading="loading"
            :disable="loading"
          />
          <div class="auth-footer-text">
            ¿Ya tienes cuenta?
            <router-link to="/login" class="auth-link"
              >Inicia sesión</router-link
            >
          </div>
        </q-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/authStore'

const $router = useRouter()
const $q = useQuasar()
const authStore = useAuthStore()

const form = reactive({
  nombreCompleto: '',
  correo: '',
  telefono: '',
  documentoIdentidad: '',
  password: '',
  confirmarPassword: ''
})

const showPassword = ref(false)
const showConfirmPassword = ref(false)
const loading = ref(false)

async function onSubmit() {
  loading.value = true
  try {
    await authStore.registrar({ ...form })
    $q.notify({
      type: 'positive',
      message: 'Cuenta creada exitosamente',
      position: 'top'
    })
    $router.push('/login')
  } catch (error) {
    $q.notify({
      type: 'negative',
      message:
        error.response?.data?.error ||
        error.response?.data?.mensaje ||
        'Error al crear cuenta',
      position: 'top'
    })
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg);
  position: relative;
  overflow: hidden;
}

.auth-bg {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.auth-bg__shapes {
  position: absolute;
  width: 100%;
  height: 100%;
}

.shape {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.15;
}

.shape--1 {
  width: 400px;
  height: 400px;
  background: var(--color-primary);
  top: -100px;
  left: -50px;
}

.shape--2 {
  width: 300px;
  height: 300px;
  background: var(--color-accent);
  bottom: -80px;
  right: -80px;
}

.shape--3 {
  width: 200px;
  height: 200px;
  background: var(--color-positive);
  top: 20%;
  right: 30%;
}

.auth-container {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 520px;
  padding: 20px;
}

.auth-card-wrapper {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-xl);
  padding: 36px;
  box-shadow: var(--shadow-lg);
}

.auth-brand {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-bottom: 24px;
}

.auth-brand__icon {
  width: 40px;
  height: 40px;
  background: var(--color-primary);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.auth-brand__name {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--color-primary);
}

.auth-title {
  font-size: 1.5rem;
  font-weight: 700;
  text-align: center;
  margin: 0 0 4px;
  color: var(--color-text);
}

.auth-subtitle {
  font-family: var(--font-body);
  font-size: 0.9rem;
  text-align: center;
  color: var(--color-text-secondary);
  margin: 0 0 24px;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.field-label {
  font-family: var(--font-body);
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text);
}

.auth-input :deep(.q-field__control) {
  border-radius: var(--radius-sm);
  min-height: 42px;
}

.auth-input :deep(.q-field__control:hover) {
  border-color: var(--color-primary-light) !important;
}

.auth-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary) !important;
  box-shadow: 0 0 0 3px rgba(27, 58, 75, 0.08);
}

.auth-input :deep(.q-field__native) {
  font-family: var(--font-body);
  font-size: 0.9rem;
  padding: 0 0 0 4px;
}

.input-icon {
  color: var(--color-text-muted);
}

.auth-submit {
  border-radius: var(--radius-sm);
  font-weight: 600;
  font-size: 0.95rem;
  padding: 12px;
  min-height: 44px;
}

.auth-footer-text {
  font-family: var(--font-body);
  font-size: 0.85rem;
  text-align: center;
  color: var(--color-text-secondary);
}

.auth-link {
  color: var(--color-primary);
  font-weight: 600;
  text-decoration: none;
}

.auth-link:hover {
  text-decoration: underline;
}
</style>
