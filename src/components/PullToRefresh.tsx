import { ReactNode, useRef, useState, useEffect } from 'react';
import { RefreshCw } from 'lucide-react';
import { vibrate } from '@/utils/capacitor';

interface PullToRefreshProps {
  children: ReactNode;
  onRefresh: () => Promise<void>;
  className?: string;
}

export function PullToRefresh({ children, onRefresh, className = '' }: PullToRefreshProps) {
  const [pullDistance, setPullDistance] = useState(0);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [canPull, setCanPull] = useState(false);
  const startY = useRef(0);
  const containerRef = useRef<HTMLDivElement>(null);

  const PULL_THRESHOLD = 80; // Расстояние для срабатывания обновления
  const MAX_PULL = 120; // Максимальное расстояние pull

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const handleScroll = () => {
      // Разрешаем pull только если скролл в самом верху
      setCanPull(container.scrollTop === 0);
    };

    container.addEventListener('scroll', handleScroll);
    return () => container.removeEventListener('scroll', handleScroll);
  }, []);

  const handleTouchStart = (e: React.TouchEvent) => {
    if (!canPull || isRefreshing) return;
    startY.current = e.touches[0].clientY;
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!canPull || isRefreshing) return;

    const diff = e.touches[0].clientY - startY.current;
    
    // Только если тянем вниз
    if (diff > 0) {
      const pull = Math.min(diff * 0.5, MAX_PULL); // Замедляем движение
      setPullDistance(pull);

      // Вибрация при достижении порога
      if (pull >= PULL_THRESHOLD && pullDistance < PULL_THRESHOLD) {
        vibrate('medium');
      }
    }
  };

  const handleTouchEnd = async () => {
    if (!canPull || isRefreshing) return;

    if (pullDistance >= PULL_THRESHOLD) {
      setIsRefreshing(true);
      await vibrate('heavy');
      
      try {
        await onRefresh();
      } finally {
        setIsRefreshing(false);
        setPullDistance(0);
      }
    } else {
      setPullDistance(0);
    }
  };

  const rotation = (pullDistance / MAX_PULL) * 360;

  return (
    <div className={`relative h-full overflow-hidden ${className}`}>
      {/* Индикатор обновления */}
      <div
        className="absolute top-0 left-0 right-0 flex items-center justify-center transition-all duration-300"
        style={{
          height: `${Math.max(pullDistance, 0)}px`,
          opacity: pullDistance > 0 ? 1 : 0,
        }}
      >
        <div
          className={`
            flex items-center justify-center w-10 h-10 rounded-full
            ${pullDistance >= PULL_THRESHOLD ? 'bg-primary' : 'bg-muted'}
            transition-colors duration-200
          `}
        >
          <RefreshCw
            className={`w-5 h-5 ${isRefreshing ? 'animate-spin' : ''} ${
              pullDistance >= PULL_THRESHOLD ? 'text-primary-foreground' : 'text-muted-foreground'
            }`}
            style={{
              transform: isRefreshing ? 'none' : `rotate(${rotation}deg)`,
              transition: isRefreshing ? 'none' : 'transform 0.1s',
            }}
          />
        </div>
      </div>

      {/* Контент */}
      <div
        ref={containerRef}
        className="h-full overflow-y-auto"
        style={{
          transform: `translateY(${pullDistance}px)`,
          transition: pullDistance === 0 ? 'transform 0.3s' : 'none',
        }}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        {children}
      </div>
    </div>
  );
}
