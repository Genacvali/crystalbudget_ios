/**
 * Компонент для безопасной зоны на iOS (учитывает notch)
 * Автоматически добавляет отступы для iPhone с вырезом
 */

import { useEffect, useState } from 'react';
import { isIOS } from '@/utils/capacitor';

interface SafeAreaProps {
  children: React.ReactNode;
  top?: boolean;
  bottom?: boolean;
  left?: boolean;
  right?: boolean;
}

export function SafeArea({ 
  children, 
  top = true, 
  bottom = true, 
  left = true, 
  right = true 
}: SafeAreaProps) {
  const [insets, setInsets] = useState({
    top: 0,
    bottom: 0,
    left: 0,
    right: 0
  });

  useEffect(() => {
    if (!isIOS) return;

    // Получить safe area insets из CSS переменных
    const updateInsets = () => {
      const computedStyle = getComputedStyle(document.documentElement);
      
      const safeAreaTop = computedStyle.getPropertyValue('--sat') || 
                          computedStyle.getPropertyValue('env(safe-area-inset-top)') || '0px';
      const safeAreaBottom = computedStyle.getPropertyValue('--sab') || 
                              computedStyle.getPropertyValue('env(safe-area-inset-bottom)') || '0px';
      const safeAreaLeft = computedStyle.getPropertyValue('--sal') || 
                           computedStyle.getPropertyValue('env(safe-area-inset-left)') || '0px';
      const safeAreaRight = computedStyle.getPropertyValue('--sar') || 
                            computedStyle.getPropertyValue('env(safe-area-inset-right)') || '0px';

      setInsets({
        top: parseInt(safeAreaTop) || 0,
        bottom: parseInt(safeAreaBottom) || 0,
        left: parseInt(safeAreaLeft) || 0,
        right: parseInt(safeAreaRight) || 0,
      });
    };

    updateInsets();

    // Обновить при изменении ориентации
    window.addEventListener('resize', updateInsets);
    return () => window.removeEventListener('resize', updateInsets);
  }, []);

  // Не применять на веб или Android
  if (!isIOS) {
    return <>{children}</>;
  }

  return (
    <div 
      style={{
        paddingTop: top ? insets.top : undefined,
        paddingBottom: bottom ? insets.bottom : undefined,
        paddingLeft: left ? insets.left : undefined,
        paddingRight: right ? insets.right : undefined,
      }}
    >
      {children}
    </div>
  );
}

/**
 * Хук для получения safe area insets
 */
export function useSafeArea() {
  const [insets, setInsets] = useState({
    top: 0,
    bottom: 0,
    left: 0,
    right: 0
  });

  useEffect(() => {
    if (!isIOS) return;

    const updateInsets = () => {
      const computedStyle = getComputedStyle(document.documentElement);
      
      setInsets({
        top: parseInt(computedStyle.getPropertyValue('--sat') || '0'),
        bottom: parseInt(computedStyle.getPropertyValue('--sab') || '0'),
        left: parseInt(computedStyle.getPropertyValue('--sal') || '0'),
        right: parseInt(computedStyle.getPropertyValue('--sar') || '0'),
      });
    };

    updateInsets();
    window.addEventListener('resize', updateInsets);
    return () => window.removeEventListener('resize', updateInsets);
  }, []);

  return insets;
}



