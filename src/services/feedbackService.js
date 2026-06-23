import api from '@/services/api'

const feedbackService = {
  async create(payload) {
    return await tryRequest(
      'post',
      [
        '/api/Feedback',
        '/api/Feedbacks',
        '/api/Admin/Feedback',
        '/api/Admin/Feedbacks'
      ],
      payload
    )
  },

  async getAll() {
    return await tryRequest('get', [
      '/api/Feedback',
      '/api/Feedbacks',
      '/api/Feedback/GetAll',
      '/api/Feedback/all',
      '/api/Admin/Feedback',
      '/api/Admin/Feedbacks',
      '/api/Admin/Feedback/GetAll',
      '/api/Admin/Feedback/all'
    ])
  },

  async respond(id, respuesta) {
    return await tryRequest(
      'put',
      [
        `/api/Feedback/${id}/responder`,
        `/api/Feedbacks/${id}/responder`,
        `/api/Admin/Feedback/${id}/responder`,
        `/api/Admin/Feedbacks/${id}/responder`
      ],
      { respuesta }
    )
  }
}

async function tryRequest(method, urls, payload = undefined) {
  let lastError = null

  for (const url of urls) {
    try {
      const response = await api.request({
        method,
        url,
        data: payload
      })
      return response.data
    } catch (err) {
      lastError = err

      // If any route works, return its data. Otherwise continue trying.
      // Only stop early for server errors that are not route-specific.
      const status = err.response?.status
      if (status && status >= 500) {
        throw err
      }
    }
  }

  throw lastError
}

export default feedbackService
