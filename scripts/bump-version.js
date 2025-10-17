#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

try {
  // Read package.json
  const packageJsonPath = path.join(__dirname, '..', 'package.json');
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  
  const oldVersion = packageJson.version;
  
  // Parse current version
  const [major, minor, patch] = oldVersion.split('.').map(Number);
  
  // Increment patch version
  const newVersion = `${major}.${minor}.${patch + 1}`;
  
  // Update package.json
  packageJson.version = newVersion;
  fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2) + '\n');
  
  console.log(`✅ Updated package.json: ${oldVersion} → ${newVersion}`);
  
  // Service worker removed for iOS-only app
  console.log(`\n🎉 New version: ${newVersion}`);
  
  process.exit(0);
} catch (error) {
  console.error('❌ Error updating version:', error.message);
  process.exit(1);
}

