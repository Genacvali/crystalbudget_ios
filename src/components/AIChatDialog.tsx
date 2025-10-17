import { Dialog, DialogContent } from "@/components/ui/dialog";

interface AIChatDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function AIChatDialog({ open, onOpenChange }: AIChatDialogProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <div className="p-4">
          <h3 className="text-lg font-semibold mb-2">AI Чат</h3>
          <p className="text-sm text-muted-foreground">Функция в разработке</p>
        </div>
      </DialogContent>
    </Dialog>
  );
}

