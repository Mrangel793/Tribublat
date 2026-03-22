# Guía de configuración iOS en Mac

## Requisitos previos
- Mac con macOS 13 (Ventura) o superior
- Xcode 15+ instalado desde App Store
- Apple Developer Account (apple.com/developer)
- Flutter instalado en el Mac

---

## Paso 1 — Instalar Flutter en el Mac

```bash
# Descargar Flutter SDK
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.41.5-stable.zip

# Extraer y agregar al PATH
unzip flutter_macos_arm64_3.41.5-stable.zip -d ~/
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verificar
flutter doctor
```

## Paso 2 — Instalar CocoaPods

```bash
sudo gem install cocoapods
# O con Homebrew (recomendado):
brew install cocoapods
```

## Paso 3 — Clonar / copiar el proyecto al Mac

```bash
cd ~/Documentos
git clone <url-del-repositorio> parcheApp
cd parcheApp
flutter pub get
```

## Paso 4 — Configurar Firebase para iOS

1. Ve a [console.firebase.google.com](https://console.firebase.google.com)
2. Selecciona el proyecto **tribulat-397a5**
3. Clic en **Agregar app → iOS**
4. Bundle ID: `com.tribulat.parcheapp`
5. Descarga `GoogleService-Info.plist`
6. **Reemplaza** el archivo placeholder:
   ```
   ios/Runner/GoogleService-Info.plist  ← reemplazar con el real
   ```

## Paso 5 — Actualizar Info.plist con REVERSED_CLIENT_ID

Abre `ios/Runner/Info.plist`, busca:
```
REEMPLAZAR_CON_REVERSED_CLIENT_ID
```
Reemplázalo con el valor de `REVERSED_CLIENT_ID` del `GoogleService-Info.plist`.
Ejemplo: `com.googleusercontent.apps.768480369704-xxxxxxxxxx`

## Paso 6 — Actualizar firebase_options.dart

Abre `lib/firebase_options.dart`, busca los comentarios `REEMPLAZAR_CON_...` y llena:
- `apiKey` → valor de `API_KEY` del GoogleService-Info.plist
- `appId` → valor de `GOOGLE_APP_ID` del GoogleService-Info.plist

## Paso 7 — Instalar dependencias iOS (CocoaPods)

```bash
cd ios
pod install
cd ..
```

## Paso 8 — Configurar Bundle ID y Signing en Xcode

```bash
open ios/Runner.xcworkspace
```

En Xcode:
1. Selecciona el target **Runner**
2. Tab **Signing & Capabilities**
3. Team: selecciona tu Apple Developer Account
4. Bundle Identifier: `com.tribulat.parcheapp`

## Paso 9 — Activar Capabilities en Xcode

En **Signing & Capabilities**, clic en **+ Capability** y agrega:
- ✅ **Push Notifications**
- ✅ **Background Modes** → marcar "Remote notifications" y "Background fetch"
- ✅ **Sign In with Apple**

## Paso 10 — Configurar APNs para Firebase Messaging

1. Ve a [developer.apple.com](https://developer.apple.com) → Certificates, IDs & Profiles
2. Crea un **APNs Key** (Authentication Key)
3. Descarga el archivo `.p8`
4. En Firebase Console → Proyecto → Configuración → Cloud Messaging → iOS
5. Sube el archivo `.p8` junto con el Key ID y el Team ID

## Paso 11 — Ejecutar la app

```bash
# En simulador
flutter run

# En dispositivo físico (conectado por USB)
flutter run --release
```

---

## Verificación final

```bash
flutter doctor -v
```

Deberías ver:
```
[✓] Flutter
[✓] Xcode
[✓] iOS toolchain
[✓] Connected device
```

---

## Si algo falla

```bash
# Limpiar caché
flutter clean
cd ios && pod deintegrate && pod install && cd ..
flutter pub get
flutter run
```
