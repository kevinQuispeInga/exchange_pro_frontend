<template>
  <q-page class="feedback-page">
    <div class="page-header">
      <h1 class="page-title font-display">Enviar Feedback</h1>
      <p class="page-subtitle">Ayúdanos a mejorar ExchangePro</p>
    </div>

    <template v-if="!submitted">
      <div class="form-card glass-card">
        <div class="form-section">
          <label class="section-label">Tipo de Feedback</label>
          <div class="tipo-options">
            <div
              class="tipo-card"
              :class="{ active: tipo === 'RECOMENDACION' }"
              @click="tipo = 'RECOMENDACION'"
            >
              <q-icon name="lightbulb" size="32px" :color="tipo === 'RECOMENDACION' ? 'primary' : 'grey'" />
              <span class="tipo-label">Recomendación</span>
            </div>
            <div
              class="tipo-card"
              :class="{ active: tipo === 'REPORTE_BUG' }"
              @click="tipo = 'REPORTE_BUG'"
            >
              <q-icon name="bug_report" size="32px" :color="tipo === 'REPORTE_BUG' ? 'negative' : 'grey'" />
              <span class="tipo-label">Reportar Bug</span>
            </div>
          </div>
        </div>

        <div class="form-section">
          <label class="section-label">Título</label>
          <q-input
            v-model="titulo"
            placeholder="Breve resumen de tu feedback"
            dark
            outlined
            :rules="[val => !!val || 'El título es requerido']"
          />
        </div>

        <div class="form-section">
          <label class="section-label">Descripción</label>
          <q-input
            v-model="descripcion"
            type="textarea"
            placeholder="Describe tu sugerencia o el bug encontrado..."
            dark
            outlined
            rows="5"
            :rules="[val => !!val || 'La descripción es requerida']"
          />
        </div>

        <q-btn
          label="Enviar Feedback"
          color="primary"
          :loading="loading"
          :disable="loading"
          unelevated
          size="lg"
          class="submit-btn"
          @click="submitFeedback"
        />
      </div>
    </template>

    <template v-else>
      <div class="success-card glass-card">
        <div class="success-icon">
          <q-icon name="check_circle" size="64px" color="positive" />
        </div>
        <h2 class="success-title">¡Gracias por tu feedback!</h2>
        <p class="success-desc">Tu opinión es muy valiosa para nosotros y nos ayuda a mejorar.</p>
        <q-btn
          label="Enviar otro"
          color="primary"
          outline
          unelevated
          @click="resetForm"
        />
      </div>
    </template>
  </q-page>
</template>

<script setup>
import { ref } from 'vue'
import { useQuasar } from 'quasar'
import api from '@/services/api'

const $q = useQuasar()

const tipo = ref('RECOMENDACION')
const titulo = ref('')
const descripcion = ref('')
const loading = ref(false)
const submitted = ref(false)

async function submitFeedback() {
  if (!titulo.value || !descripcion.value) {
    $q.notify({ type: 'warning', message: 'Completa todos los campos', position: 'top' })
    return
  }
  loading.value = true
  try {
    await api.post('/api/Feedback', {
      tipo: tipo.value,
      titulo: titulo.value,
      descripcion: descripcion.value
    })
    submitted.value = true
    $q.notify({ type: 'positive', message: 'Feedback enviado correctamente', position: 'top' })
  } catch (err) {
    $q.notify({ type: 'negative', message: err.response?.data?.message || 'Error al enviar feedback', position: 'top' })
  } finally {
    loading.value = false
  }
}

function resetForm() {
  tipo.value = 'RECOMENDACION'
  titulo.value = ''
  descripcion.value = ''
  submitted.value = false
}
</script>

<style scoped>
.feedback-page {
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

.form-card {
  padding: 32px;
}

.form-section {
  margin-bottom: 24px;
}

.section-label {
  display: block;
  font-family: var(--font-body);
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 10px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.tipo-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.tipo-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 24px 16px;
  border: 2px solid rgba(255, 255, 255, 0.08);
  border-radius: 16px;
  cursor: pointer;
  transition: border-color 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
  background: rgba(255, 255, 255, 0.02);
}

.tipo-card:hover {
  border-color: rgba(255, 255, 255, 0.15);
  background: rgba(255, 255, 255, 0.04);
}

.tipo-card.active {
  border-color: var(--color-primary);
  background: rgba(124, 58, 237, 0.08);
}

.tipo-card.active:has(.q-icon[color="negative"]) {
  border-color: var(--color-negative);
  background: rgba(244, 63, 94, 0.08);
}

.tipo-label {
  font-family: var(--font-body);
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--color-text);
}

.submit-btn {
  width: 100%;
  margin-top: 8px;
}

.success-card {
  padding: 48px 32px;
  text-align: center;
}

.success-icon {
  margin-bottom: 16px;
}

.success-title {
  font-family: var(--font-display);
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--color-text);
  margin: 0 0 8px;
}

.success-desc {
  font-family: var(--font-body);
  color: var(--color-text-secondary);
  margin: 0 0 24px;
  font-size: 0.95rem;
}

@media (max-width: 600px) {
  .feedback-page {
    padding: 20px 16px;
  }

  .form-card,
  .success-card {
    padding: 24px 16px;
  }

  .tipo-options {
    gap: 12px;
  }

  .tipo-card {
    padding: 20px 12px;
  }

  .submit-btn {
    width: 100%;
  }
}
</style>
