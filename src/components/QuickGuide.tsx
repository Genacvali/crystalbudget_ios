import { Dialog, DialogContent } from "@/components/ui/dialog";

interface QuickGuideProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onComplete: () => void;
  userId: string;
}

export function QuickGuide({ open, onOpenChange, onComplete, userId }: QuickGuideProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <div className="p-4">
          <h3 className="text-lg font-semibold mb-2">Быстрый старт</h3>
          <p className="text-sm text-muted-foreground mb-4">Добро пожаловать в CrystalBudget!</p>
          <button
            onClick={() => {
              onComplete();
              onOpenChange(false);
            }}
            className="w-full py-2 bg-primary text-primary-foreground rounded-lg"
          >
            Начать
          </button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

