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
      launchShowDuration: 2000,
      backgroundColor: "#0f172a",
      launchAutoHide: true,
      iosLaunchShowDuration: 2000,
      showSpinner: false,
      spinnerColor: "#ffffff"
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



