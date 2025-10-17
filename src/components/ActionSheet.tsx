import { ReactNode, useState } from 'react';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@/components/ui/sheet';
import { cn } from '@/lib/utils';
import { vibrate, selectionHaptic } from '@/utils/capacitor';
import { X } from 'lucide-react';

export interface ActionSheetAction {
  label: string;
  icon?: ReactNode;
  onClick: () => void;
  variant?: 'default' | 'destructive';
  disabled?: boolean;
}

interface ActionSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title?: string;
  description?: string;
  actions: ActionSheetAction[];
  cancelLabel?: string;
}

export function ActionSheet({
  open,
  onOpenChange,
  title,
  description,
  actions,
  cancelLabel = 'Отмена',
}: ActionSheetProps) {
  const handleAction = async (action: ActionSheetAction) => {
    if (action.disabled) return;
    
    await selectionHaptic();
    onOpenChange(false);
    
    // Небольшая задержка для анимации закрытия
    setTimeout(() => {
      action.onClick();
    }, 150);
  };

  const handleCancel = async () => {
    await vibrate('light');
    onOpenChange(false);
  };

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent 
        side="bottom" 
        className={cn(
          "ios-sheet rounded-t-3xl border-none p-0",
          "max-h-[80vh] overflow-hidden"
        )}
      >
        {/* Handle indicator */}
        <div className="flex justify-center py-3">
          <div className="w-10 h-1 rounded-full bg-gray-300 dark:bg-gray-600" />
        </div>

        <div className="px-4 pb-safe">
          {/* Header */}
          {(title || description) && (
            <SheetHeader className="text-center mb-2">
              {title && (
                <SheetTitle className="text-sm font-semibold text-gray-500 dark:text-gray-400">
                  {title}
                </SheetTitle>
              )}
              {description && (
                <SheetDescription className="text-xs text-gray-400 dark:text-gray-500">
                  {description}
                </SheetDescription>
              )}
            </SheetHeader>
          )}

          {/* Actions */}
          <div className="space-y-2 mb-4">
            {actions.map((action, index) => (
              <button
                key={index}
                onClick={() => handleAction(action)}
                disabled={action.disabled}
                className={cn(
                  "w-full flex items-center justify-center gap-3 py-4 px-4",
                  "rounded-xl font-medium text-base transition-all",
                  "active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed",
                  action.variant === 'destructive'
                    ? 'bg-red-50 text-red-600 hover:bg-red-100 dark:bg-red-900/20 dark:text-red-400 dark:hover:bg-red-900/30'
                    : 'bg-blue-50 text-blue-600 hover:bg-blue-100 dark:bg-blue-900/20 dark:text-blue-400 dark:hover:bg-blue-900/30'
                )}
              >
                {action.icon && <span className="text-xl">{action.icon}</span>}
                {action.label}
              </button>
            ))}
          </div>

          {/* Cancel button */}
          <button
            onClick={handleCancel}
            className={cn(
              "w-full py-4 rounded-xl font-semibold text-base",
              "bg-gray-100 text-gray-900 hover:bg-gray-200",
              "dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700",
              "transition-all active:scale-95"
            )}
          >
            {cancelLabel}
          </button>
        </div>
      </SheetContent>
    </Sheet>
  );
}

// Упрощенный хук для использования Action Sheet
export function useActionSheet() {
  const [isOpen, setIsOpen] = useState(false);
  const [config, setConfig] = useState<Omit<ActionSheetProps, 'open' | 'onOpenChange'> | null>(null);

  const show = (options: Omit<ActionSheetProps, 'open' | 'onOpenChange'>) => {
    setConfig(options);
    setIsOpen(true);
  };

  const hide = () => {
    setIsOpen(false);
  };

  const ActionSheetComponent = config ? (
    <ActionSheet
      {...config}
      open={isOpen}
      onOpenChange={setIsOpen}
    />
  ) : null;

  return {
    show,
    hide,
    isOpen,
    ActionSheet: ActionSheetComponent,
  };
}

