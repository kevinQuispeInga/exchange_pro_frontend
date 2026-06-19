<template>
  <div class="error-page">
    <div class="error-bg">
      <div class="error-bg__shape"></div>
    </div>
    <div class="error-content">
      <div class="error-code font-display">404</div>
      <h1 class="error-title font-display">Página no encontrada</h1>
      <p class="error-desc"
        >La página que buscas no existe o ha sido movida a otra dirección.</p
      >
      <div class="error-actions">
        <q-btn
          label="Volver al inicio"
          color="primary"
          unelevated
          no-caps
          icon="home"
          to="/"
          class="error-btn"
        />
        <q-btn
          label="Ir a ofertas"
          flat
          no-caps
          to="/ofertas"
          class="error-btn-secondary"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
.error-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg);
  position: relative;
  overflow: hidden;
}

.error-bg {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.error-bg__shape {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  background: var(--color-primary);
  opacity: 0.04;
  top: -100px;
  right: -100px;
}

.error-content {
  text-align: center;
  z-index: 1;
  padding: 24px;
  max-width: 480px;
}

.error-code {
  font-size: 8rem;
  font-weight: 800;
  line-height: 1;
  background: linear-gradient(
    135deg,
    var(--color-primary) 0%,
    var(--color-accent) 100%
  );
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 12px;
  letter-spacing: -0.04em;
}

.error-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--color-text);
  margin: 0 0 8px;
}

.error-desc {
  font-family: var(--font-body);
  font-size: 0.95rem;
  color: var(--color-text-secondary);
  margin: 0 0 28px;
  line-height: 1.5;
}

.error-actions {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.error-btn {
  border-radius: var(--radius-sm);
  font-weight: 600;
  padding: 8px 24px;
}

.error-btn-secondary {
  color: var(--color-text-secondary);
  font-weight: 500;
  border-radius: var(--radius-sm);
}
</style>
