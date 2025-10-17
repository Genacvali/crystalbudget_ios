import { useState, useEffect } from 'react';
import { 
  isBiometricAvailable, 
  authenticateWithBiometric,
  isNative
} from '@/utils/capacitor';

export type BiometricType = 'faceId' | 'touchId' | 'none';

export function useBiometric() {
  const [isAvailable, setIsAvailable] = useState(false);
  const [biometricType, setBiometricType] = useState<BiometricType>('none');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    checkAvailability();
  }, []);

  const checkAvailability = async () => {
    if (!isNative) {
      setIsAvailable(false);
      setBiometricType('none');
      setIsLoading(false);
      return;
    }

    try {
      const result = await isBiometricAvailable();
      setIsAvailable(result.available);
      setBiometricType(result.type);
    } catch (error) {
      console.error('[useBiometric] Check error:', error);
      setIsAvailable(false);
      setBiometricType('none');
    } finally {
      setIsLoading(false);
    }
  };

  const authenticate = async (reason?: string) => {
    return await authenticateWithBiometric(reason);
  };

  const getBiometricName = () => {
    switch (biometricType) {
      case 'faceId':
        return 'Face ID';
      case 'touchId':
        return 'Touch ID';
      default:
        return 'Биометрия';
    }
  };

  const getBiometricIcon = () => {
    switch (biometricType) {
      case 'faceId':
        return '👤'; // или можно использовать lucide-react ScanFace
      case 'touchId':
        return '👆'; // или Fingerprint
      default:
        return '🔒';
    }
  };

  return {
    isAvailable,
    biometricType,
    isLoading,
    authenticate,
    checkAvailability,
    getBiometricName,
    getBiometricIcon,
  };
}

