import { ReactNode, useRef, useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

interface ActionSheetProps {
  isOpen: boolean;
  onOpenChange: (open: boolean) => void;
  children: ReactNode;
}

export function ActionSheet({ isOpen, onOpenChange, children }: ActionSheetProps) {
  const startX = useRef(0);
  const currentX = useRef(0);
  const isSwiping = useRef(false);
  const [isDragging, setIsDragging] = useState(false);
  const [swipeProgress, setSwipeProgress] = useState(0);

  useEffect(() => {
    const handleTouchStart = (e: TouchEvent) => {
      if (isOpen) return; // Только если меню закрыто
      
      // Свайп от левого края экрана (первые 20px)
      if (e.touches[0].clientX < 20) {
        startX.current = e.touches[0].clientX;
        isSwiping.current = true;
        setIsDragging(true);
        setSwipeProgress(0);
      }
    };

    const handleTouchMove = (e: TouchEvent) => {
      if (!isSwiping.current || isOpen) return;
      
      currentX.current = e.touches[0].clientX;
      const diff = currentX.current - startX.current;

      if (diff > 0) {
        e.preventDefault(); // Предотвращаем скролл
        
        const progress = Math.min(diff / 100, 1); // Максимум 100px для открытия
        setSwipeProgress(progress);
        
        // Визуальная обратная связь - добавляем класс к body
        if (progress > 0.3) {
          document.body.classList.add('swipe-hint');
        } else {
          document.body.classList.remove('swipe-hint');
        }
      }
    };

    const handleTouchEnd = () => {
      if (!isSwiping.current || isOpen) return;
      
      const diff = currentX.current - startX.current;
      const progress = Math.min(diff / 100, 1);
      
      isSwiping.current = false;
      setIsDragging(false);
      setSwipeProgress(0);
      
      // Убираем визуальную обратную связь
      document.body.classList.remove('swipe-hint');
      
      // Если свайпнули больше чем на 50px вправо, открываем меню
      if (diff > 50) {
        onOpenChange(true);
      }
      
      startX.current = 0;
      currentX.current = 0;
    };

    // Добавляем стили для визуальной обратной связи
    const style = document.createElement('style');
    style.textContent = `
      .swipe-hint {
        background: linear-gradient(90deg, rgba(59, 130, 246, 0.1) 0%, transparent 20%);
        transition: background 0.2s ease;
      }
      
      .swipe-hint::before {
        content: '';
        position: fixed;
        top: 0;
        left: 0;
        width: 4px;
        height: 100%;
        background: rgb(59, 130, 246);
        z-index: 9999;
        animation: swipeGlow 0.5s ease-in-out;
      }
      
      @keyframes swipeGlow {
        0% { opacity: 0; transform: scaleY(0); }
        50% { opacity: 1; transform: scaleY(1); }
        100% { opacity: 0.7; transform: scaleY(1); }
      }
    `;
    document.head.appendChild(style);

    window.addEventListener('touchstart', handleTouchStart, { passive: false });
    window.addEventListener('touchmove', handleTouchMove, { passive: false });
    window.addEventListener('touchend', handleTouchEnd);

    return () => {
      window.removeEventListener('touchstart', handleTouchStart);
      window.removeEventListener('touchmove', handleTouchMove);
      window.removeEventListener('touchend', handleTouchEnd);
      document.body.classList.remove('swipe-hint');
      document.head.removeChild(style);
    };
  }, [isOpen, onOpenChange]);

  return (
    <div className={cn("relative", isDragging && "cursor-grabbing")}>
      {children}
    </div>
  );
}

