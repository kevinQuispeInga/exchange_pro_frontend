import { defineConfig } from '#q-app'

export default defineConfig((/* ctx */) => {
  return {
    boot: [],

    css: ['app.scss'],

    extras: ['roboto-font', 'material-icons'],

    build: {
      vueRouterMode: 'hash',
      extendViteConf (viteConf) {
        if (!viteConf.server) viteConf.server = {}
        viteConf.server.allowedHosts = true
      }
    },

    devServer: {
      open: true,
      port: 9000,
      proxy: {
        '/api': {
          target: 'http://localhost:5238',
          changeOrigin: true
        }
      }
    },

    framework: {
      config: {
        notify: {
          position: 'top-right',
          timeout: 3500,
          textColor: 'white',
          actions: [{ icon: 'close', color: 'white' }]
        },
        loading: {
          messageColor: 'white',
          spinnerColor: 'secondary'
        }
      },
      plugins: ['Notify', 'Dialog', 'Loading', 'LocalStorage', 'SessionStorage']
    },

    animations: [],

    ssr: {
      prodPort: 3000,
      middlewares: ['render'],
      pwa: false
    },

    pwa: {
      workboxMode: 'GenerateSW'
    },

    cordova: {},

    capacitor: {
      hideSplashscreen: true
    },

    electron: {
      preloadScripts: ['electron-preload'],
      inspectPort: 5858,
      bundler: 'packager',
      packager: {},
      builder: {
        appId: 'exchange-pro-frontend'
      }
    },

    bex: {
      extraScripts: []
    }
  }
})
