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
import { BiometricAuth, BiometryType, BiometryError } from '@aparajita/capacitor-biometric-auth';
import { Share, ShareOptions } from '@capacitor/share';

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

// ============================================
// БИОМЕТРИЧЕСКАЯ АУТЕНТИФИКАЦИЯ
// ============================================

/**
 * Проверка доступности биометрии на устройстве
 */
export async function isBiometricAvailable(): Promise<{
  available: boolean;
  type: 'faceId' | 'touchId' | 'none';
}> {
  if (!isNative) {
    return { available: false, type: 'none' };
  }

  try {
    const result = await BiometricAuth.checkBiometry();
    console.log('[Biometric] Check result:', result);
    
    if (!result.isAvailable) {
      return { available: false, type: 'none' };
    }

    // Определяем тип биометрии
    let type: 'faceId' | 'touchId' | 'none' = 'none';
    if (result.biometryType === BiometryType.faceId) {
      type = 'faceId';
    } else if (result.biometryType === BiometryType.touchId || 
               result.biometryType === BiometryType.fingerprint) {
      type = 'touchId';
    }

    return {
      available: true,
      type
    };
  } catch (error) {
    console.error('[Biometric] Availability check error:', error);
    return { available: false, type: 'none' };
  }
}

/**
 * Аутентификация через Face ID / Touch ID
 */
export async function authenticateWithBiometric(reason: string = 'Войдите в приложение'): Promise<{
  success: boolean;
  error?: string;
}> {
  if (!isNative) {
    console.warn('[Biometric] Not available on web');
    return { success: false, error: 'Not available on web' };
  }

  try {
    // Проверяем доступность
    const { available } = await isBiometricAvailable();
    if (!available) {
      return { success: false, error: 'Биометрия недоступна' };
    }

    // Запрашиваем аутентификацию
    await BiometricAuth.authenticate({
      reason,
      cancelTitle: 'Отмена',
      allowDeviceCredential: true, // Разрешить использовать пароль устройства
      iosFallbackTitle: 'Использовать пароль',
      androidTitle: 'Вход',
      androidSubtitle: reason,
      androidConfirmationRequired: false,
    });

    console.log('[Biometric] Authentication success');
    await notificationHaptic(); // Haptic при успехе
    return { success: true };

  } catch (error: any) {
    console.error('[Biometric] Authentication error:', error);
    
    // Обработка разных типов ошибок
    let errorMessage = 'Ошибка аутентификации';
    
    if (error.code === BiometryError.userCancel) {
      errorMessage = 'Отменено пользователем';
    } else if (error.code === BiometryError.authenticationFailed) {
      errorMessage = 'Не удалось распознать';
    } else if (error.code === BiometryError.biometryLockout) {
      errorMessage = 'Слишком много попыток';
    } else if (error.code === BiometryError.biometryNotAvailable) {
      errorMessage = 'Биометрия недоступна';
    }

    return { success: false, error: errorMessage };
  }
}

// ============================================
// SHARE ФУНКЦИОНАЛ
// ============================================

/**
 * Поделиться текстом или данными
 */
export async function shareContent(options: {
  title?: string;
  text?: string;
  url?: string;
  dialogTitle?: string;
}): Promise<boolean> {
  if (!isNative) {
    // Fallback для веба - можно использовать Web Share API
    if (navigator.share) {
      try {
        await navigator.share({
          title: options.title,
          text: options.text,
          url: options.url,
        });
        return true;
      } catch (error) {
        console.error('[Share] Web share error:', error);
        return false;
      }
    }
    console.warn('[Share] Not available on this platform');
    return false;
  }

  try {
    const shareOptions: ShareOptions = {
      title: options.title,
      text: options.text,
      url: options.url,
      dialogTitle: options.dialogTitle || 'Поделиться',
    };

    await Share.share(shareOptions);
    await selectionHaptic(); // Haptic при открытии share sheet
    console.log('[Share] Content shared successfully');
    return true;
  } catch (error) {
    console.error('[Share] Share error:', error);
    return false;
  }
}

/**
 * Экспорт данных в CSV и шаринг
 */
export async function shareDataAsCSV(
  data: any[],
  filename: string = 'export.csv',
  title: string = 'Экспорт данных'
): Promise<boolean> {
  try {
    // Конвертируем данные в CSV
    const csvContent = convertToCSV(data);
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);

    // Создаем временную ссылку для скачивания
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);

    console.log('[Share] CSV exported successfully');
    await notificationHaptic();
    return true;
  } catch (error) {
    console.error('[Share] CSV export error:', error);
    return false;
  }
}

/**
 * Вспомогательная функция для конвертации в CSV
 */
function convertToCSV(data: any[]): string {
  if (!data || data.length === 0) return '';

  const headers = Object.keys(data[0]);
  const csvRows = [
    headers.join(','), // Заголовки
    ...data.map(row => 
      headers.map(header => {
        const value = row[header];
        // Экранируем запятые и кавычки
        if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
          return `"${value.replace(/"/g, '""')}"`;
        }
        return value;
      }).join(',')
    )
  ];

  return csvRows.join('\n');
}



