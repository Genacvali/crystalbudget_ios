import { ReactNode, useRef, useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

interface SwipeToCloseProps {
  isOpen: boolean;
  onClose: () => void;
  children: ReactNode;
}

export function SwipeToClose({ isOpen, onClose, children }: SwipeToCloseProps) {
  const startX = useRef(0);
  const currentX = useRef(0);
  const isSwiping = useRef(false);
  const [isDragging, setIsDragging] = useState(false);
  const [swipeProgress, setSwipeProgress] = useState(0);

  useEffect(() => {
    if (!isOpen) return; // Только если меню открыто

    const handleTouchStart = (e: TouchEvent) => {
      startX.current = e.touches[0].clientX;
      isSwiping.current = true;
      setIsDragging(true);
      setSwipeProgress(0);
    };

    const handleTouchMove = (e: TouchEvent) => {
      if (!isSwiping.current) return;
      
      currentX.current = e.touches[0].clientX;
      const diff = startX.current - currentX.current; // Отрицательное значение для свайпа влево

      if (diff > 0) {
        e.preventDefault(); // Предотвращаем скролл
        
        const progress = Math.min(diff / 150, 1); // Максимум 150px для закрытия
        setSwipeProgress(progress);
        
        // Визуальная обратная связь
        if (progress > 0.3) {
          document.body.classList.add('swipe-close-hint');
        } else {
          document.body.classList.remove('swipe-close-hint');
        }
      }
    };

    const handleTouchEnd = () => {
      if (!isSwiping.current) return;
      
      const diff = startX.current - currentX.current;
      const progress = Math.min(diff / 150, 1);
      
      isSwiping.current = false;
      setIsDragging(false);
      setSwipeProgress(0);
      
      // Убираем визуальную обратную связь
      document.body.classList.remove('swipe-close-hint');
      
      // Если свайпнули больше чем на 80px влево, закрываем меню
      if (diff > 80) {
        onClose();
      }
      
      startX.current = 0;
      currentX.current = 0;
    };

    // Добавляем стили для визуальной обратной связи
    const style = document.createElement('style');
    style.textContent = `
      .swipe-close-hint {
        background: linear-gradient(270deg, rgba(239, 68, 68, 0.1) 0%, transparent 20%);
        transition: background 0.2s ease;
      }
      
      .swipe-close-hint::after {
        content: '';
        position: fixed;
        top: 0;
        right: 0;
        width: 4px;
        height: 100%;
        background: rgb(239, 68, 68);
        z-index: 9999;
        animation: swipeCloseGlow 0.5s ease-in-out;
      }
      
      @keyframes swipeCloseGlow {
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
      document.body.classList.remove('swipe-close-hint');
      document.head.removeChild(style);
    };
  }, [isOpen, onClose]);

  return (
    <div className={cn("relative", isDragging && "cursor-grabbing")}>
      {children}
    </div>
  );
}

