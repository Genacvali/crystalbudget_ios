import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import "./index.css";
import "./styles/ios-native.css";
import { initializeApp, isNative } from "./utils/capacitor";
import { SplashScreen } from '@capacitor/splash-screen';

// Инициализация iOS приложения
if (isNative) {
  // Немедленно скрыть splash screen
  SplashScreen.hide().catch(e => console.log('Splash hide error:', e));
}

// Рендер приложения
createRoot(document.getElementById("root")!).render(<App />);

// Инициализация в фоне
if (isNative) {
  initializeApp().catch(e => console.error('Init error:', e));
}

