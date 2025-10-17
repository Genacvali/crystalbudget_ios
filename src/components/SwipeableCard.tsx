import { ReactNode, useRef, useState } from 'react';
import { vibrate } from '@/utils/capacitor';
import { Trash2, Edit } from 'lucide-react';

interface SwipeableCardProps {
  children: ReactNode;
  onDelete?: () => void;
  onEdit?: () => void;
  className?: string;
}

export function SwipeableCard({ children, onDelete, onEdit, className = '' }: SwipeableCardProps) {
  const [translateX, setTranslateX] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const startX = useRef(0);
  const currentX = useRef(0);

  const handleTouchStart = (e: React.TouchEvent) => {
    startX.current = e.touches[0].clientX;
    currentX.current = translateX;
    setIsDragging(true);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!isDragging) return;

    const diff = e.touches[0].clientX - startX.current;
    const newTranslate = currentX.current + diff;

    // Ограничиваем свайп влево (от -100 до 0)
    if (newTranslate <= 0 && newTranslate >= -100) {
      setTranslateX(newTranslate);
    }
  };

  const handleTouchEnd = async () => {
    setIsDragging(false);

    // Если свайп больше 50px, показываем кнопки действий
    if (translateX < -50) {
      setTranslateX(-100);
      await vibrate('light');
    } else {
      setTranslateX(0);
    }
  };

  const handleDelete = async () => {
    await vibrate('heavy');
    setTranslateX(0);
    onDelete?.();
  };

  const handleEdit = async () => {
    await vibrate('medium');
    setTranslateX(0);
    onEdit?.();
  };

  return (
    <div className="relative overflow-hidden">
      {/* Кнопки действий (скрыты под карточкой) */}
      <div className="absolute right-0 top-0 bottom-0 flex items-center">
        {onEdit && (
          <button
            onClick={handleEdit}
            className="h-full px-6 bg-blue-500 text-white flex items-center justify-center transition-all"
            style={{
              transform: `translateX(${Math.max(0, 100 + translateX)}px)`,
            }}
          >
            <Edit className="w-5 h-5" />
          </button>
        )}
        {onDelete && (
          <button
            onClick={handleDelete}
            className="h-full px-6 bg-red-500 text-white flex items-center justify-center transition-all"
            style={{
              transform: `translateX(${Math.max(0, 100 + translateX)}px)`,
            }}
          >
            <Trash2 className="w-5 h-5" />
          </button>
        )}
      </div>

      {/* Карточка */}
      <div
        className={`${className} transition-transform ${isDragging ? 'duration-0' : 'duration-300'}`}
        style={{
          transform: `translateX(${translateX}px)`,
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

