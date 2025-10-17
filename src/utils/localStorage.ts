/**
 * Offline-First Local Storage
 * Все транзакции и категории хранятся локально на устройстве
 * Supabase используется только для:
 * - Аутентификация
 * - Настройки пользователя
 * - Резервное копирование (опционально)
 */

import { Preferences } from '@capacitor/preferences';
import { isNative } from './capacitor';

// Ключи для хранения данных
const STORAGE_KEYS = {
  TRANSACTIONS: 'local_transactions',
  CATEGORIES: 'local_categories',
  INCOMES: 'local_incomes',
  INCOME_SOURCES: 'local_income_sources',
  LAST_SYNC: 'last_sync_timestamp',
  PENDING_SYNC: 'pending_sync_items',
} as const;

/**
 * Получить данные из локального хранилища
 */
async function getItem<T>(key: string): Promise<T | null> {
  try {
    if (isNative) {
      const { value } = await Preferences.get({ key });
      return value ? JSON.parse(value) : null;
    } else {
      const value = localStorage.getItem(key);
      return value ? JSON.parse(value) : null;
    }
  } catch (error) {
    console.error(`[LocalStorage] Error getting ${key}:`, error);
    return null;
  }
}

/**
 * Сохранить данные в локальное хранилище
 */
async function setItem<T>(key: string, value: T): Promise<void> {
  try {
    const stringValue = JSON.stringify(value);
    
    if (isNative) {
      await Preferences.set({ key, value: stringValue });
    } else {
      localStorage.setItem(key, stringValue);
    }
  } catch (error) {
    console.error(`[LocalStorage] Error setting ${key}:`, error);
  }
}

/**
 * Удалить данные из локального хранилища
 */
async function removeItem(key: string): Promise<void> {
  try {
    if (isNative) {
      await Preferences.remove({ key });
    } else {
      localStorage.removeItem(key);
    }
  } catch (error) {
    console.error(`[LocalStorage] Error removing ${key}:`, error);
  }
}

/**
 * Очистить все данные
 */
async function clear(): Promise<void> {
  try {
    if (isNative) {
      await Preferences.clear();
    } else {
      localStorage.clear();
    }
  } catch (error) {
    console.error('[LocalStorage] Error clearing:', error);
  }
}

// === ТРАНЗАКЦИИ ===

export interface LocalTransaction {
  id: string;
  user_id: string;
  amount: number;
  description: string;
  category_id: string;
  date: string;
  created_at: string;
  updated_at: string;
  synced: boolean; // Флаг синхронизации с сервером
}

export async function getTransactions(): Promise<LocalTransaction[]> {
  const transactions = await getItem<LocalTransaction[]>(STORAGE_KEYS.TRANSACTIONS);
  return transactions || [];
}

export async function saveTransaction(transaction: LocalTransaction): Promise<void> {
  const transactions = await getTransactions();
  const existingIndex = transactions.findIndex(t => t.id === transaction.id);
  
  if (existingIndex >= 0) {
    transactions[existingIndex] = { ...transaction, updated_at: new Date().toISOString() };
  } else {
    transactions.push({ ...transaction, created_at: new Date().toISOString() });
  }
  
  await setItem(STORAGE_KEYS.TRANSACTIONS, transactions);
  console.log('[LocalStorage] Transaction saved:', transaction.id);
}

export async function deleteTransaction(id: string): Promise<void> {
  const transactions = await getTransactions();
  const filtered = transactions.filter(t => t.id !== id);
  await setItem(STORAGE_KEYS.TRANSACTIONS, filtered);
  console.log('[LocalStorage] Transaction deleted:', id);
}

export async function bulkSaveTransactions(transactions: LocalTransaction[]): Promise<void> {
  await setItem(STORAGE_KEYS.TRANSACTIONS, transactions);
  console.log('[LocalStorage] Bulk save:', transactions.length, 'transactions');
}

// === КАТЕГОРИИ ===

export interface LocalCategory {
  id: string;
  user_id: string;
  name: string;
  icon: string;
  color: string;
  budget_amount: number;
  created_at: string;
  synced: boolean;
}

export async function getCategories(): Promise<LocalCategory[]> {
  const categories = await getItem<LocalCategory[]>(STORAGE_KEYS.CATEGORIES);
  return categories || [];
}

export async function saveCategory(category: LocalCategory): Promise<void> {
  const categories = await getCategories();
  const existingIndex = categories.findIndex(c => c.id === category.id);
  
  if (existingIndex >= 0) {
    categories[existingIndex] = category;
  } else {
    categories.push(category);
  }
  
  await setItem(STORAGE_KEYS.CATEGORIES, categories);
  console.log('[LocalStorage] Category saved:', category.id);
}

export async function deleteCategory(id: string): Promise<void> {
  const categories = await getCategories();
  const filtered = categories.filter(c => c.id !== id);
  await setItem(STORAGE_KEYS.CATEGORIES, filtered);
  console.log('[LocalStorage] Category deleted:', id);
}

export async function bulkSaveCategories(categories: LocalCategory[]): Promise<void> {
  await setItem(STORAGE_KEYS.CATEGORIES, categories);
  console.log('[LocalStorage] Bulk save:', categories.length, 'categories');
}

// === ДОХОДЫ ===

export interface LocalIncome {
  id: string;
  user_id: string;
  amount: number;
  source_id: string;
  date: string;
  created_at: string;
  synced: boolean;
}

export async function getIncomes(): Promise<LocalIncome[]> {
  const incomes = await getItem<LocalIncome[]>(STORAGE_KEYS.INCOMES);
  return incomes || [];
}

export async function saveIncome(income: LocalIncome): Promise<void> {
  const incomes = await getIncomes();
  const existingIndex = incomes.findIndex(i => i.id === income.id);
  
  if (existingIndex >= 0) {
    incomes[existingIndex] = income;
  } else {
    incomes.push(income);
  }
  
  await setItem(STORAGE_KEYS.INCOMES, incomes);
  console.log('[LocalStorage] Income saved:', income.id);
}

export async function deleteIncome(id: string): Promise<void> {
  const incomes = await getIncomes();
  const filtered = incomes.filter(i => i.id !== id);
  await setItem(STORAGE_KEYS.INCOMES, filtered);
  console.log('[LocalStorage] Income deleted:', id);
}

// === ИСТОЧНИКИ ДОХОДА ===

export interface LocalIncomeSource {
  id: string;
  user_id: string;
  name: string;
  icon: string;
  color: string;
  created_at: string;
  synced: boolean;
}

export async function getIncomeSources(): Promise<LocalIncomeSource[]> {
  const sources = await getItem<LocalIncomeSource[]>(STORAGE_KEYS.INCOME_SOURCES);
  return sources || [];
}

export async function saveIncomeSource(source: LocalIncomeSource): Promise<void> {
  const sources = await getIncomeSources();
  const existingIndex = sources.findIndex(s => s.id === source.id);
  
  if (existingIndex >= 0) {
    sources[existingIndex] = source;
  } else {
    sources.push(source);
  }
  
  await setItem(STORAGE_KEYS.INCOME_SOURCES, sources);
  console.log('[LocalStorage] Income source saved:', source.id);
}

export async function deleteIncomeSource(id: string): Promise<void> {
  const sources = await getIncomeSources();
  const filtered = sources.filter(s => s.id !== id);
  await setItem(STORAGE_KEYS.INCOME_SOURCES, filtered);
  console.log('[LocalStorage] Income source deleted:', id);
}

// === СИНХРОНИЗАЦИЯ ===

export interface SyncStatus {
  lastSync: string | null;
  pendingItems: number;
  isSyncing: boolean;
}

export async function getLastSyncTime(): Promise<string | null> {
  return await getItem<string>(STORAGE_KEYS.LAST_SYNC);
}

export async function setLastSyncTime(timestamp: string): Promise<void> {
  await setItem(STORAGE_KEYS.LAST_SYNC, timestamp);
}

export async function getPendingSyncItems(): Promise<string[]> {
  const items = await getItem<string[]>(STORAGE_KEYS.PENDING_SYNC);
  return items || [];
}

export async function addPendingSyncItem(itemId: string): Promise<void> {
  const items = await getPendingSyncItems();
  if (!items.includes(itemId)) {
    items.push(itemId);
    await setItem(STORAGE_KEYS.PENDING_SYNC, items);
  }
}

export async function removePendingSyncItem(itemId: string): Promise<void> {
  const items = await getPendingSyncItems();
  const filtered = items.filter(id => id !== itemId);
  await setItem(STORAGE_KEYS.PENDING_SYNC, filtered);
}

export async function clearPendingSyncItems(): Promise<void> {
  await setItem(STORAGE_KEYS.PENDING_SYNC, []);
}

// === СТАТИСТИКА ===

export async function getStorageStats() {
  const [transactions, categories, incomes, sources, pendingSync] = await Promise.all([
    getTransactions(),
    getCategories(),
    getIncomes(),
    getIncomeSources(),
    getPendingSyncItems(),
  ]);

  return {
    transactions: transactions.length,
    categories: categories.length,
    incomes: incomes.length,
    incomeSources: sources.length,
    pendingSync: pendingSync.length,
    totalItems: transactions.length + categories.length + incomes.length + sources.length,
  };
}

// === ОЧИСТКА ===

export async function clearAllLocalData(): Promise<void> {
  await Promise.all([
    removeItem(STORAGE_KEYS.TRANSACTIONS),
    removeItem(STORAGE_KEYS.CATEGORIES),
    removeItem(STORAGE_KEYS.INCOMES),
    removeItem(STORAGE_KEYS.INCOME_SOURCES),
    removeItem(STORAGE_KEYS.LAST_SYNC),
    removeItem(STORAGE_KEYS.PENDING_SYNC),
  ]);
  console.log('[LocalStorage] All local data cleared');
}

// === ЭКСПОРТ/ИМПОРТ ===

export async function exportAllData() {
  const [transactions, categories, incomes, sources] = await Promise.all([
    getTransactions(),
    getCategories(),
    getIncomes(),
    getIncomeSources(),
  ]);

  return {
    transactions,
    categories,
    incomes,
    incomeSources: sources,
    exportedAt: new Date().toISOString(),
  };
}

export async function importAllData(data: {
  transactions?: LocalTransaction[];
  categories?: LocalCategory[];
  incomes?: LocalIncome[];
  incomeSources?: LocalIncomeSource[];
}): Promise<void> {
  if (data.transactions) await bulkSaveTransactions(data.transactions);
  if (data.categories) await bulkSaveCategories(data.categories);
  if (data.incomes) await setItem(STORAGE_KEYS.INCOMES, data.incomes);
  if (data.incomeSources) await setItem(STORAGE_KEYS.INCOME_SOURCES, data.incomeSources);
  
  console.log('[LocalStorage] Data imported successfully');
}

