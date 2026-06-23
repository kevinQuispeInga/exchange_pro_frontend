import api from '@/services/api'

const perfilService = {
  async obtener() {
    const { data } = await api.get('/api/Perfil')
    return data
  },
  async actualizar(datos) {
    const { data } = await api.put('/api/Perfil', datos)
    return data
  },
  async subirFoto(file) {
    const form = new FormData()
    form.append('foto', file)
    const { data } = await api.post('/api/Perfil/subir-foto', form)
    return data
  }
}

export default perfilService
