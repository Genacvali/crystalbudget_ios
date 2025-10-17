import { Dialog, DialogContent } from "@/components/ui/dialog";

interface TelegramGuideProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConnectNow: () => void;
}

export function TelegramGuide({ open, onOpenChange, onConnectNow }: TelegramGuideProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <div className="p-4">
          <h3 className="text-lg font-semibold mb-2">Telegram Бот</h3>
          <p className="text-sm text-muted-foreground mb-4">Подключите Telegram бот для быстрого добавления расходов</p>
          <button
            onClick={() => {
              onConnectNow();
              onOpenChange(false);
              localStorage.setItem("telegram_guide_shown", "true");
            }}
            className="w-full py-2 bg-primary text-primary-foreground rounded-lg mb-2"
          >
            Подключить
          </button>
          <button
            onClick={() => {
              onOpenChange(false);
              localStorage.setItem("telegram_guide_shown", "true");
            }}
            className="w-full py-2 bg-secondary text-secondary-foreground rounded-lg"
          >
            Позже
          </button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

