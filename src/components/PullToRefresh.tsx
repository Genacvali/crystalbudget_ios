import { useEffect, useRef, ReactNode, useState } from "react";
import { Loader2, ArrowDown } from "lucide-react";

interface PullToRefreshProps {
  onRefresh: () => Promise<void>;
  children: ReactNode;
}

export function PullToRefresh({ onRefresh, children }: PullToRefreshProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const startY = useRef<number>(0);
  const currentY = useRef<number>(0);
  const isPulling = useRef<boolean>(false);
  const isRefreshing = useRef<boolean>(false);
  const refreshIndicatorRef = useRef<HTMLDivElement>(null);
  const [pullProgress, setPullProgress] = useState(0);
  const [isReadyToRefresh, setIsReadyToRefresh] = useState(false);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const handleTouchStart = (e: TouchEvent) => {
      // Только если прокрутка в самом верху
      if (window.scrollY === 0) {
        startY.current = e.touches[0].clientY;
        isPulling.current = true;
      }
    };

    const handleTouchMove = (e: TouchEvent) => {
      if (!isPulling.current || isRefreshing.current) return;

      currentY.current = e.touches[0].clientY;
      const diff = currentY.current - startY.current;

      // Только если тянем вниз и находимся в верху страницы
      if (diff > 0 && window.scrollY === 0) {
        e.preventDefault();

        const pullDistance = Math.min(diff * 0.6, 100); // Увеличил максимум до 100px
        const progress = Math.min(pullDistance / 100, 1);
        
        setPullProgress(progress);
        setIsReadyToRefresh(progress > 0.7); // Готов к обновлению при 70%

        if (refreshIndicatorRef.current) {
          refreshIndicatorRef.current.style.height = `${pullDistance}px`;
          refreshIndicatorRef.current.style.opacity = `${Math.min(progress * 2, 1)}`;

          // Плавное вращение стрелки
          const rotation = progress * 180;
          const icon = refreshIndicatorRef.current.querySelector('svg');
          if (icon) {
            icon.style.transform = `rotate(${rotation}deg) scale(${0.8 + progress * 0.2})`;
          }
        }
      }
    };

    const handleTouchEnd = async () => {
      if (!isPulling.current || isRefreshing.current) return;

      const diff = currentY.current - startY.current;
      isPulling.current = false;

      // Если потянули достаточно далеко (больше 70px)
      if (diff > 70 && window.scrollY === 0) {
        isRefreshing.current = true;
        setIsReadyToRefresh(false);

        if (refreshIndicatorRef.current) {
          // Плавная анимация к состоянию загрузки
          refreshIndicatorRef.current.style.height = '80px';
          refreshIndicatorRef.current.classList.add('refreshing');
        }

        try {
          await onRefresh();
        } catch (error) {
          console.error('Refresh failed:', error);
        } finally {
          isRefreshing.current = false;

          if (refreshIndicatorRef.current) {
            refreshIndicatorRef.current.classList.remove('refreshing');
            // Плавное скрытие
            refreshIndicatorRef.current.style.height = '0px';
            refreshIndicatorRef.current.style.opacity = '0';
          }
        }
      } else {
        // Плавная анимация возврата
        if (refreshIndicatorRef.current) {
          refreshIndicatorRef.current.style.height = '0px';
          refreshIndicatorRef.current.style.opacity = '0';
        }
      }

      setPullProgress(0);
      setIsReadyToRefresh(false);
      startY.current = 0;
      currentY.current = 0;
    };

    container.addEventListener('touchstart', handleTouchStart, { passive: false });
    container.addEventListener('touchmove', handleTouchMove, { passive: false });
    container.addEventListener('touchend', handleTouchEnd);

    return () => {
      container.removeEventListener('touchstart', handleTouchStart);
      container.removeEventListener('touchmove', handleTouchMove);
      container.removeEventListener('touchend', handleTouchEnd);
    };
  }, [onRefresh]);

  return (
    <div ref={containerRef} className="relative">
      <div
        ref={refreshIndicatorRef}
        className={`fixed top-0 left-0 right-0 z-50 flex items-center justify-center bg-background/90 backdrop-blur-md overflow-hidden transition-all duration-300 ease-out ${
          isReadyToRefresh ? 'bg-primary/10' : ''
        }`}
        style={{ height: 0, opacity: 0 }}
      >
        <div className="flex flex-col items-center gap-2">
          {isRefreshing.current ? (
            <Loader2 className="h-6 w-6 text-primary animate-spin" />
          ) : (
            <ArrowDown 
              className={`h-6 w-6 text-primary transition-all duration-200 ${
                isReadyToRefresh ? 'text-primary' : 'text-muted-foreground'
              }`} 
            />
          )}
          <span className={`text-xs transition-colors duration-200 ${
            isReadyToRefresh ? 'text-primary' : 'text-muted-foreground'
          }`}>
            {isReadyToRefresh ? 'Отпустите для обновления' : 'Потяните для обновления'}
          </span>
        </div>
      </div>
      <style>{`
        .refreshing {
          animation: pulse 1.5s ease-in-out infinite;
        }
        @keyframes pulse {
          0%, 100% { opacity: 0.8; }
          50% { opacity: 1; }
        }
      `}</style>
      {children}
    </div>
  );
}
