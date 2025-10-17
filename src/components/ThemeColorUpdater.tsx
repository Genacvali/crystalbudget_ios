import { useEffect } from 'react';
import { useTheme } from 'next-themes';
import { StatusBar, Style } from '@capacitor/status-bar';
import { isNative } from '@/utils/capacitor';

/**
 * Компонент для синхронизации темы приложения с iOS status bar
 */
export function ThemeColorUpdater() {
  const { theme, resolvedTheme } = useTheme();

  useEffect(() => {
    if (!isNative) return;

    const updateStatusBar = async () => {
      const isDark = resolvedTheme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);
      
      try {
        await StatusBar.setStyle({
          style: isDark ? Style.Dark : Style.Light
        });
      } catch (error) {
        console.error('[ThemeColorUpdater] Failed to update status bar:', error);
      }
    };

    updateStatusBar();
  }, [theme, resolvedTheme]);

  return null;
}

