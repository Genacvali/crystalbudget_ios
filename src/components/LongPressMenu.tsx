import { ReactNode, useState, useRef, useEffect } from 'react';
import {
  ContextMenu,
  ContextMenuContent,
  ContextMenuItem,
  ContextMenuTrigger,
  ContextMenuSeparator,
} from '@/components/ui/context-menu';
import { vibrate } from '@/utils/capacitor';
import { cn } from '@/lib/utils';

export interface LongPressMenuItem {
  label: string;
  icon?: ReactNode;
  onClick: () => void;
  variant?: 'default' | 'destructive';
  disabled?: boolean;
  separator?: boolean;
}

interface LongPressMenuProps {
  children: ReactNode;
  items: LongPressMenuItem[];
  className?: string;
}

export function LongPressMenu({ children, items, className }: LongPressMenuProps) {
  const [isOpen, setIsOpen] = useState(false);
  const longPressTimer = useRef<NodeJS.Timeout>();
  const triggerRef = useRef<HTMLDivElement>(null);

  const handleTouchStart = (e: React.TouchEvent) => {
    // Запускаем таймер на 500мс для long press
    longPressTimer.current = setTimeout(async () => {
      await vibrate('medium'); // Haptic при активации
      setIsOpen(true);
    }, 500);
  };

  const handleTouchEnd = () => {
    // Отменяем таймер если палец убрали раньше
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
    }
  };

  const handleTouchMove = () => {
    // Отменяем если палец двигается
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
    }
  };

  useEffect(() => {
    return () => {
      if (longPressTimer.current) {
        clearTimeout(longPressTimer.current);
      }
    };
  }, []);

  const handleItemClick = async (item: LongPressMenuItem) => {
    if (item.disabled) return;
    
    await vibrate('light');
    setIsOpen(false);
    item.onClick();
  };

  return (
    <ContextMenu open={isOpen} onOpenChange={setIsOpen}>
      <ContextMenuTrigger asChild>
        <div
          ref={triggerRef}
          className={cn('touch-none select-none', className)}
          onTouchStart={handleTouchStart}
          onTouchEnd={handleTouchEnd}
          onTouchMove={handleTouchMove}
          onContextMenu={(e) => {
            e.preventDefault();
            vibrate('medium');
            setIsOpen(true);
          }}
        >
          {children}
        </div>
      </ContextMenuTrigger>
      <ContextMenuContent className="w-56 ios-card">
        {items.map((item, index) => (
          <div key={index}>
            {item.separator && index > 0 && <ContextMenuSeparator />}
            <ContextMenuItem
              disabled={item.disabled}
              onClick={() => handleItemClick(item)}
              className={cn(
                'flex items-center gap-3 py-3 cursor-pointer',
                item.variant === 'destructive' && 'text-red-600 dark:text-red-400 focus:text-red-600',
                item.disabled && 'opacity-50 cursor-not-allowed'
              )}
            >
              {item.icon && <span className="text-lg">{item.icon}</span>}
              <span>{item.label}</span>
            </ContextMenuItem>
          </div>
        ))}
      </ContextMenuContent>
    </ContextMenu>
  );
}

// Hook для программного управления context menu
export function useLongPressMenu() {
  const [isOpen, setIsOpen] = useState(false);

  const show = async () => {
    await vibrate('medium');
    setIsOpen(true);
  };

  const hide = () => {
    setIsOpen(false);
  };

  return {
    isOpen,
    show,
    hide,
  };
}

