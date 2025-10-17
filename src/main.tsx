import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import "./index.css";
import "./styles/ios-native.css";
import { initializeApp } from "./utils/capacitor";

// Инициализация iOS приложения
initializeApp().then(() => {
  createRoot(document.getElementById("root")!).render(<App />);
});

