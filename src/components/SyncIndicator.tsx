import { useState, useEffect } from 'react';
import { Cloud, CloudOff, RefreshCw, Check } from 'lucide-react';
import { getStorageStats, getLastSyncTime } from '@/utils/localStorage';

export function SyncIndicator() {
  const [stats, setStats] = useState({ pendingSync: 0, totalItems: 0 });
  const [lastSync, setLastSync] = useState<string | null>(null);
  const [isSyncing, setIsSyncing] = useState(false);

  useEffect(() => {
    loadStats();
    const interval = setInterval(loadStats, 30000); // Обновлять каждые 30 сек
    return () => clearInterval(interval);
  }, []);

  const loadStats = async () => {
    const storageStats = await getStorageStats();
    const syncTime = await getLastSyncTime();
    setStats(storageStats);
    setLastSync(syncTime);
  };

  const getTimeSinceSync = () => {
    if (!lastSync) return 'Никогда';
    
    const now = new Date();
    const syncDate = new Date(lastSync);
    const diffMs = now.getTime() - syncDate.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Только что';
    if (diffMins < 60) return `${diffMins} мин назад`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours} ч назад`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays} д назад`;
  };

  const getStatusIcon = () => {
    if (isSyncing) {
      return <RefreshCw className="w-4 h-4 animate-spin" />;
    }
    if (stats.pendingSync > 0) {
      return <CloudOff className="w-4 h-4 text-orange-500" />;
    }
    return <Check className="w-4 h-4 text-green-500" />;
  };

  const getStatusText = () => {
    if (isSyncing) return 'Синхронизация...';
    if (stats.pendingSync > 0) return `${stats.pendingSync} не синхронизировано`;
    return 'Синхронизировано';
  };

  return (
    <div className="flex items-center gap-2 text-sm text-muted-foreground ios-transition">
      {getStatusIcon()}
      <div className="flex flex-col">
        <span className="text-xs">{getStatusText()}</span>
        <span className="text-[10px] opacity-60">{getTimeSinceSync()}</span>
      </div>
      <div className="text-xs opacity-50">
        {stats.totalItems} записей
      </div>
    </div>
  );
}

