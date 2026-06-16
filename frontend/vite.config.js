import { defineConfig } from 'vite'

export default defineConfig({
  server: {
    allowedHosts: true,
    proxy: {
      '/events': {
        target: 'http://sse:3001',
        changeOrigin: true,
      }
    }
  },
})
