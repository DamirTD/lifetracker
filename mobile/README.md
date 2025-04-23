---

setup-avd.ps1

# setup-avd.ps1

# Скрипт для первого запуска: установка эмулятора Android и создание AVD

# === 1. Указываем путь к Android SDK ===

$env:ANDROID_SDK_ROOT = "C:\Users\toriy\Documents\android-sdk"
$tools = "$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin"
$emulator = "$env:ANDROID_SDK_ROOT\emulator"

# Добавляем в PATH

$env:PATH += ";$tools;$emulator"

# === 2. Устанавливаем эмулятор и образ Android 11 (API 30) ===

Write-Host "👉 Установка Android Emulator и системного образа..."
& "$tools\sdkmanager.bat" "emulator" "system-images;android-30;google_apis;x86_64"

# === 3. Создаём виртуальное устройство AVD ===

Write-Host "👉 Создание AVD PixelAPI30..."
& "$tools\avdmanager.bat" create avd -n PixelAPI30 -k "system-images;android-30;google_apis;x86_64" -d "pixel_4"

# === 4. Запускаем эмулятор ===

Write-Host "🚀 Запуск эмулятора PixelAPI30..."
& "$emulator\emulator.exe" -avd PixelAPI30

Как пользоваться этим скриптом (Только при первом запуске)
Сохрани как setup-avd.ps1 в проект или на рабочий стол

Открой PowerShell и запусти:

powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup-avd.ps1
Он всё сам установит, создаст и запустит.

---

Как на повседневку запускать эмулятор
После первого запуска ты уже можешь просто запускать эмулятор в один клик:

powershell
& "C:\Users\toriy\Documents\android-sdk\emulator\emulator.exe" -avd PixelAPI30
Хочешь — сохрани это как .bat файл:

📄 run-emulator.bat:
bat
@echo off
start "" "C:\Users\toriy\Documents\android-sdk\emulator\emulator.exe" -avd PixelAPI30
И просто дважды кликай по нему — эмулятор откроется

---

remove-avd.ps1 — скрипт для удаления эмулятора

# remove-avd.ps1

# Удаляет AVD с именем PixelAPI30 и все его данные

# === 1. Указываем путь к Android SDK ===

$env:ANDROID_SDK_ROOT = "C:\Users\toriy\Documents\android-sdk"
$tools = "$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin"

# Добавляем в PATH

$env:PATH += ";$tools"

# === 2. Удаляем AVD PixelAPI30 ===

Write-Host "🧹 Удаляем AVD PixelAPI30..."
& "$tools\avdmanager.bat" delete avd -n PixelAPI30

# === 3. (Опционально) Очищаем кэш или удаляем системные образы ===

# Uncomment если хочешь удалить и образ (осторожно!)

# Remove-Item -Recurse -Force "$env:ANDROID_SDK_ROOT\system-images\android-30"

Как пользоваться:
Сохрани как remove-avd.ps1

Открой PowerShell в этой папке

Выполни:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\remove-avd.ps1

Важно:
Он удаляет только AVD (виртуальное устройство), образ остаётся на диске

Если хочешь освободить место, раскомментируй Remove-Item — он удалит всё
