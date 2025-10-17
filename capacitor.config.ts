import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'net.crystalbudget.app',
  appName: 'CrystalBudget',
  webDir: 'dist',
  
  // iOS настройки
  server: {
    iosScheme: 'https',
  },
  
  ios: {
    contentInset: 'always',
    scrollEnabled: true,
    limitsNavigationsToAppBoundDomains: false,
  },
  
  // Плагины
  plugins: {
    SplashScreen: {
      launchShowDuration: 0,
      launchAutoHide: true,
      backgroundColor: "#000000",
      showSpinner: false
    },
    
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#0f172a'
    },
    
    Keyboard: {
      resize: 'body',
      style: 'dark',
      resizeOnFullScreen: true
    },
    
    Camera: {
      presentationStyle: 'fullscreen'
    }
  }
};

export default config;



