import { useState, useEffect, useCallback } from 'react';
import {
  getCategories,
  saveCategory,
  deleteCategory,
  LocalCategory,
} from '@/utils/localStorage';
import { vibrate } from '@/utils/capacitor';

export function useLocalCategories(userId: string) {
  const [categories, setCategories] = useState<LocalCategory[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // Загрузить категории
  const loadCategories = useCallback(async () => {
    try {
      setLoading(true);
      const data = await getCategories();
      const userCategories = data.filter(c => c.user_id === userId);
      setCategories(userCategories);
      setError(null);
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalCategories] Load error:', err);
    } finally {
      setLoading(false);
    }
  }, [userId]);

  // Добавить категорию
  const addCategory = useCallback(async (category: Omit<LocalCategory, 'id' | 'created_at' | 'synced'>) => {
    try {
      const newCategory: LocalCategory = {
        ...category,
        id: `local_cat_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        user_id: userId,
        created_at: new Date().toISOString(),
        synced: false,
      };

      await saveCategory(newCategory);
      await vibrate('medium');
      await loadCategories();
      
      return newCategory;
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalCategories] Add error:', err);
      throw err;
    }
  }, [userId, loadCategories]);

  // Обновить категорию
  const updateCategory = useCallback(async (id: string, updates: Partial<LocalCategory>) => {
    try {
      const existing = categories.find(c => c.id === id);
      if (!existing) throw new Error('Category not found');

      const updated: LocalCategory = {
        ...existing,
        ...updates,
        synced: false,
      };

      await saveCategory(updated);
      await vibrate('light');
      await loadCategories();
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalCategories] Update error:', err);
      throw err;
    }
  }, [categories, loadCategories]);

  // Удалить категорию
  const removeCategory = useCallback(async (id: string) => {
    try {
      await deleteCategory(id);
      await vibrate('heavy');
      await loadCategories();
    } catch (err) {
      setError(err as Error);
      console.error('[useLocalCategories] Delete error:', err);
      throw err;
    }
  }, [loadCategories]);

  // Загрузить при монтировании
  useEffect(() => {
    loadCategories();
  }, [loadCategories]);

  return {
    categories,
    loading,
    error,
    addCategory,
    updateCategory,
    removeCategory,
    refresh: loadCategories,
  };
}

