import api from '@/services/api'

const disputaService = {
  async abrir(datos) {
    const { data } = await api.post('/api/Disputa/abrir', datos)
    return data
  },
  async subirEvidencia(idDisputa, archivo) {
    const form = new FormData()
    form.append('archivo', archivo)
    const { data } = await api.post(`/api/Disputa/${idDisputa}/subir-evidencia`, form)
    return data
  },
  async listarPendientes() {
    const { data } = await api.get('/api/Disputa/pendientes')
    return data
  },
  async resolver(datos) {
    const { data } = await api.put('/api/Disputa/resolver', datos)
    return data
  }
}

export default disputaService
