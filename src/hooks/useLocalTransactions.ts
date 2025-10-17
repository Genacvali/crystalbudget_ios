import { useState, useEffect, useCallback } from 'react';
import {
  getTransactions,
  saveTransaction,
  deleteTransaction,
  LocalTransaction,
} from '@/utils/localStorage';
import { vibrate } from '@/utils/capacitor';

export function useLocalTransactions(userId: string) {
  const [transactions, setTransactions] = useState<LocalTransaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // Загрузить транзакции из локального хранилища
  const loadTransactions = useCallback(async () => {
    try {
      setLoading(true);
      const data = await getTransactions();
      // Фильтруем по пользователю
      const userTransactions = data.filter(t => t.user_id === userId);
      setTransactions(userTransactions);
      setError(null);
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalTransactions] Load error:', err);
    } finally {
      setLoading(false);
    }
  }, [userId]);

  // Добавить транзакцию
  const addTransaction = useCallback(async (transaction: Omit<LocalTransaction, 'id' | 'created_at' | 'updated_at' | 'synced'>) => {
    try {
      const newTransaction: LocalTransaction = {
        ...transaction,
        id: `local_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        user_id: userId,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        synced: false,
      };

      await saveTransaction(newTransaction);
      await vibrate('medium');
      await loadTransactions();
      
      return newTransaction;
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalTransactions] Add error:', err);
      throw err;
    }
  }, [userId, loadTransactions]);

  // Обновить транзакцию
  const updateTransaction = useCallback(async (id: string, updates: Partial<LocalTransaction>) => {
    try {
      const existing = transactions.find(t => t.id === id);
      if (!existing) throw new Error('Transaction not found');

      const updated: LocalTransaction = {
        ...existing,
        ...updates,
        updated_at: new Date().toISOString(),
        synced: false,
      };

      await saveTransaction(updated);
      await vibrate('light');
      await loadTransactions();
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalTransactions] Update error:', err);
      throw err;
    }
  }, [transactions, loadTransactions]);

  // Удалить транзакцию
  const removeTransaction = useCallback(async (id: string) => {
    try {
      await deleteTransaction(id);
      await vibrate('heavy');
      await loadTransactions();
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalTransactions] Delete error:', err);
      throw err;
    }
  }, [loadTransactions]);

  // Получить транзакции за период
  const getTransactionsByPeriod = useCallback((startDate: Date, endDate: Date) => {
    return transactions.filter(t => {
      const txDate = new Date(t.date);
      return txDate >= startDate && txDate <= endDate;
    });
  }, [transactions]);

  // Получить транзакции по категории
  const getTransactionsByCategory = useCallback((categoryId: string) => {
    return transactions.filter(t => t.category_id === categoryId);
  }, [transactions]);

  // Загрузить при монтировании
  useEffect(() => {
    loadTransactions();
  }, [loadTransactions]);

  return {
    transactions,
    loading,
    error,
    addTransaction,
    updateTransaction,
    removeTransaction,
    getTransactionsByPeriod,
    getTransactionsByCategory,
    refresh: loadTransactions,
  };
}

