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
        <h1 class="auth-title font-display">Bienvenido de vuelta</h1>
        <p class="auth-subtitle">Ingresa a tu cuenta para continuar</p>
        <q-form @submit="onSubmit" class="auth-form">
          <div class="field-group">
            <label class="field-label">Correo electrónico</label>
            <q-input
              v-model="correo"
              type="email"
              outlined
              dense
              placeholder="tu@correo.com"
              class="auth-input"
              :rules="[val => !!val || 'Ingresa tu correo']"
              hide-bottom-space
            >
              <template v-slot:prepend>
                <q-icon name="email" size="18px" class="input-icon" />
              </template>
            </q-input>
          </div>
          <div class="field-group">
            <label class="field-label">Contraseña</label>
            <q-input
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              outlined
              dense
              placeholder="••••••••"
              class="auth-input"
              :rules="[val => !!val || 'Ingresa tu contraseña']"
              hide-bottom-space
            >
              <template v-slot:prepend>
                <q-icon name="lock" size="18px" class="input-icon" />
              </template>
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
          <q-btn
            label="Iniciar Sesión"
            type="submit"
            color="primary"
            unelevated
            no-caps
            class="auth-submit"
            :loading="loading"
            :disable="loading"
          />
          <div class="auth-footer-text">
            ¿No tienes cuenta?
            <router-link to="/register" class="auth-link"
              >Regístrate</router-link
            >
          </div>
        </q-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useQuasar } from 'quasar'
import { useAuthStore } from '@/stores/authStore'

const $router = useRouter()
const $q = useQuasar()
const authStore = useAuthStore()

const correo = ref('')
const password = ref('')
const showPassword = ref(false)
const loading = ref(false)

async function onSubmit() {
  loading.value = true
  try {
    await authStore.login(correo.value, password.value)
    $q.notify({ type: 'positive', message: 'Sesión iniciada', position: 'top' })
    $router.push('/')
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: error.response?.data?.error || 'Credenciales inválidas',
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
  right: -50px;
}

.shape--2 {
  width: 300px;
  height: 300px;
  background: var(--color-accent);
  bottom: -80px;
  left: -80px;
}

.shape--3 {
  width: 200px;
  height: 200px;
  background: var(--color-positive);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.auth-container {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 420px;
  padding: 20px;
}

.auth-card-wrapper {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-xl);
  padding: 40px 36px;
  box-shadow: var(--shadow-lg);
}

.auth-brand {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-bottom: 28px;
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
  margin: 0 0 28px;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
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
  border: 1px solid var(--color-border);
  min-height: 44px;
}

.auth-input :deep(.q-field__control:hover) {
  border-color: var(--color-primary-light);
}

.auth-input :deep(.q-field--focused .q-field__control) {
  border-color: var(--color-primary);
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
