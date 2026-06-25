import { LocalStorage } from 'quasar'
import axios from 'axios'

const api = axios.create()

api.interceptors.request.use(config => {
  const token = LocalStorage.getItem('authToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      LocalStorage.remove('authToken')
      LocalStorage.remove('currentUser')
      window.location.hash = '#/login'
    }
    return Promise.reject(error)
  }
)

export default api
