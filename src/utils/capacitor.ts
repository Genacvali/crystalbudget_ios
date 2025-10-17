/**
 * Утилиты для работы с Capacitor и нативными функциями iOS/Android
 */

import { Capacitor } from '@capacitor/core';
import { StatusBar, Style } from '@capacitor/status-bar';
import { SplashScreen } from '@capacitor/splash-screen';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';
import { Haptics, ImpactStyle, NotificationType } from '@capacitor/haptics';
import { App } from '@capacitor/app';
import { 
  PushNotifications, 
  Token,
  PushNotificationSchema, 
  ActionPerformed 
} from '@capacitor/push-notifications';

// Определение платформы
export const isNative = Capacitor.isNativePlatform();
export const isIOS = Capacitor.getPlatform() === 'ios';
export const isAndroid = Capacitor.getPlatform() === 'android';
export const isWeb = Capacitor.getPlatform() === 'web';
export const platform = Capacitor.getPlatform();

console.log(`[Capacitor] Platform: ${platform}, Native: ${isNative}`);

/**
 * Инициализация приложения при запуске
 * Вызывать в main.tsx перед рендером React
 */
export async function initializeApp() {
  if (!isNative) {
    console.log('[Capacitor] Running on web, skipping native initialization');
    return;
  }

  try {
    console.log('[Capacitor] Initializing native app...');
    
    // Скрыть splash screen
    await SplashScreen.hide();
    console.log('[Capacitor] Splash screen hidden');
    
    // Настроить status bar
    if (isIOS) {
      // На iOS можно менять только стиль
      await StatusBar.setStyle({ style: Style.Dark });
      console.log('[Capacitor] iOS status bar configured');
    } else if (isAndroid) {
      // На Android можно менять и стиль и цвет
      await StatusBar.setStyle({ style: Style.Dark });
      await StatusBar.setBackgroundColor({ color: '#0f172a' });
      console.log('[Capacitor] Android status bar configured');
    }

    // Обработка выхода из приложения (back button на Android)
    if (isAndroid) {
      App.addListener('backButton', ({ canGoBack }) => {
        console.log('[Capacitor] Back button pressed, canGoBack:', canGoBack);
        if (!canGoBack) {
          App.exitApp();
        } else {
          window.history.back();
        }
      });
    }

    // Обработка перехода в background/foreground
    App.addListener('appStateChange', ({ isActive }) => {
      console.log('[Capacitor] App state changed, isActive:', isActive);
    });

    // Инициализация push notifications
    await initPushNotifications();

    console.log('[Capacitor] App initialized successfully');
  } catch (error) {
    console.error('[Capacitor] App initialization error:', error);
  }
}

/**
 * Тактильная отдача (вибрация)
 * Работает на iOS и Android
 */
export async function vibrate(style: 'light' | 'medium' | 'heavy' = 'medium') {
  if (!isNative) return;
  
  try {
    const impactStyle = {
      light: ImpactStyle.Light,
      medium: ImpactStyle.Medium,
      heavy: ImpactStyle.Heavy
    }[style];
    
    await Haptics.impact({ style: impactStyle });
  } catch (error) {
    console.error('[Capacitor] Haptics error:', error);
  }
}

/**
 * Сделать фото камерой для сканирования чеков
 */
export async function takePhoto(): Promise<string | null> {
  if (!isNative) {
    console.warn('[Capacitor] Camera not available on web');
    return null;
  }

  try {
    const image = await Camera.getPhoto({
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Camera,
      // iOS специфичные настройки
      presentationStyle: isIOS ? 'fullscreen' : 'popover',
      saveToGallery: false,
      // Текст для iOS разрешений
      promptLabelHeader: 'Сканировать чек',
      promptLabelPhoto: 'Выбрать из галереи',
      promptLabelPicture: 'Сделать фото'
    });
    
    if (!image.base64String) {
      throw new Error('No image data returned');
    }
    
    return `data:image/jpeg;base64,${image.base64String}`;
  } catch (error) {
    console.error('[Capacitor] Camera error:', error);
    return null;
  }
}

/**
 * Выбрать фото из галереи
 */
export async function pickPhoto(): Promise<string | null> {
  if (!isNative) {
    console.warn('[Capacitor] Photo picker not available on web');
    return null;
  }

  try {
    const image = await Camera.getPhoto({
      quality: 90,
      allowEditing: false,
      resultType: CameraResultType.Base64,
      source: CameraSource.Photos,
      presentationStyle: isIOS ? 'popover' : 'fullscreen',
      // Текст для iOS разрешений
      promptLabelHeader: 'Выбрать чек',
      promptLabelPhoto: 'Из галереи',
    });
    
    if (!image.base64String) {
      throw new Error('No image data returned');
    }
    
    return `data:image/jpeg;base64,${image.base64String}`;
  } catch (error) {
    console.error('[Capacitor] Photo picker error:', error);
    return null;
  }
}

/**
 * Проверить разрешение на камеру
 */
export async function checkCameraPermission(): Promise<boolean> {
  if (!isNative) return false;

  try {
    const permission = await Camera.checkPermissions();
    return permission.camera === 'granted';
  } catch (error) {
    console.error('[Capacitor] Permission check error:', error);
    return false;
  }
}

/**
 * Запросить разрешение на камеру
 */
export async function requestCameraPermission(): Promise<boolean> {
  if (!isNative) return false;

  try {
    const permission = await Camera.requestPermissions({ permissions: ['camera', 'photos'] });
    return permission.camera === 'granted';
  } catch (error) {
    console.error('[Capacitor] Permission request error:', error);
    return false;
  }
}

/**
 * Получить информацию о платформе для отладки
 */
export function getPlatformInfo() {
  return {
    platform,
    isNative,
    isIOS,
    isAndroid,
    isWeb,
    capacitorVersion: Capacitor.getPlatform(),
  };
}

/**
 * Инициализация Push Notifications
 */
export async function initPushNotifications() {
  if (!isNative) {
    console.log('[Push] Push notifications not available on web');
    return null;
  }

  try {
    console.log('[Push] Initializing push notifications...');

    // Запрос разрешений
    const permission = await PushNotifications.requestPermissions();
    
    if (permission.receive === 'granted') {
      console.log('[Push] Permission granted');
      
      // Регистрация для push notifications
      await PushNotifications.register();

      // Обработчик успешной регистрации
      PushNotifications.addListener('registration', (token: Token) => {
        console.log('[Push] Registration success, token:', token.value);
        // Здесь можно отправить токен на сервер
        return token.value;
      });

      // Обработчик ошибки регистрации
      PushNotifications.addListener('registrationError', (error: any) => {
        console.error('[Push] Registration error:', error);
      });

      // Обработчик получения push notification
      PushNotifications.addListener(
        'pushNotificationReceived',
        (notification: PushNotificationSchema) => {
          console.log('[Push] Notification received:', notification);
          // Haptic feedback при получении уведомления
          vibrate('medium');
        }
      );

      // Обработчик клика по notification
      PushNotifications.addListener(
        'pushNotificationActionPerformed',
        (action: ActionPerformed) => {
          console.log('[Push] Notification action performed:', action);
          // Haptic feedback при клике
          vibrate('light');
        }
      );

      return true;
    } else {
      console.log('[Push] Permission denied');
      return false;
    }
  } catch (error) {
    console.error('[Push] Initialization error:', error);
    return false;
  }
}

/**
 * Получить Push Notification token
 */
export async function getPushToken(): Promise<string | null> {
  if (!isNative) return null;

  try {
    // Токен будет получен через listener 'registration'
    await PushNotifications.register();
    return null; // Токен придет через listener
  } catch (error) {
    console.error('[Push] Get token error:', error);
    return null;
  }
}

/**
 * Установить badge на иконке приложения (iOS)
 */
export async function setBadgeCount(count: number) {
  if (!isNative || !isIOS) return;

  try {
    await PushNotifications.removeAllDeliveredNotifications();
    // На iOS badge устанавливается через push notification payload
    console.log('[Push] Badge count request:', count);
  } catch (error) {
    console.error('[Push] Set badge error:', error);
  }
}

/**
 * Очистить все уведомления
 */
export async function clearAllNotifications() {
  if (!isNative) return;

  try {
    await PushNotifications.removeAllDeliveredNotifications();
    console.log('[Push] All notifications cleared');
  } catch (error) {
    console.error('[Push] Clear notifications error:', error);
  }
}

/**
 * Notification haptic feedback
 */
export async function notificationHaptic() {
  if (!isNative) return;

  try {
    await Haptics.notification({ type: NotificationType.Success });
  } catch (error) {
    console.error('[Haptics] Notification haptic error:', error);
  }
}

/**
 * Selection haptic feedback (легкая вибрация)
 */
export async function selectionHaptic() {
  if (!isNative) return;

  try {
    await Haptics.selectionStart();
    setTimeout(() => Haptics.selectionEnd(), 100);
  } catch (error) {
    console.error('[Haptics] Selection haptic error:', error);
  }
}



