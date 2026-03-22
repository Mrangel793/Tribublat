# Cómo configurar Codemagic (sin Mac)

## Paso 1 — Subir el proyecto a GitHub

Si aún no lo tienes en GitHub:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/TU_USUARIO/parcheapp.git
git push -u origin master
```

---

## Paso 2 — Crear cuenta en Codemagic

1. Ve a [codemagic.io](https://codemagic.io)
2. Clic en **Start for free**
3. Inicia sesión con tu cuenta de **GitHub**
4. Autoriza el acceso al repositorio de TribuLat

---

## Paso 3 — Conectar el repositorio

1. En el dashboard de Codemagic, clic en **Add application**
2. Selecciona **GitHub** → busca `parcheapp`
3. Codemagic detectará automáticamente el archivo `codemagic.yaml`
4. Selecciona el workflow que quieras usar

---

## Paso 4 — Configurar los secretos (variables de entorno)

En Codemagic → **Teams** → **Global variables and secrets**, crea estos grupos:

### Grupo: `firebase_ios`
| Variable | Valor | Secret |
|----------|-------|--------|
| `GOOGLE_SERVICE_INFO_PLIST` | contenido del GoogleService-Info.plist en base64 | ✅ |

**Cómo codificar en base64 (en Mac/Linux):**
```bash
base64 -i GoogleService-Info.plist | pbcopy
```
**En Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("GoogleService-Info.plist")) | clip
```

### Grupo: `firebase_android`
| Variable | Valor | Secret |
|----------|-------|--------|
| `GOOGLE_SERVICES_JSON` | contenido del google-services.json en base64 | ✅ |

**En Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/google-services.json")) | clip
```

### Grupo: `app_store_credentials`
| Variable | Valor | Secret |
|----------|-------|--------|
| `APP_STORE_CONNECT_ISSUER_ID` | Tu Issuer ID de App Store Connect | ✅ |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Tu Key ID de App Store Connect | ✅ |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Contenido del archivo .p8 | ✅ |

**Cómo obtener las credenciales de App Store Connect:**
1. Ve a [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Usuarios y Acceso → Claves de API
3. Crea una nueva clave con rol **App Manager**
4. Descarga el archivo `.p8` (solo se puede descargar una vez)
5. Copia el **Issuer ID** y el **Key ID** mostrados en la pantalla

---

## Paso 5 — Registrar la app en App Store Connect

1. Ve a [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Clic en **+** → **Nueva app**
3. Plataformas: iOS
4. Nombre: TribuLat
5. Bundle ID: `com.tribulat.parcheapp`
6. Copia el **Apple ID** de la app (número de 9-10 dígitos)
7. Pégalo en `codemagic.yaml` donde dice `REEMPLAZAR_CON_TU_APP_ID_EN_APP_STORE_CONNECT`

---

## Paso 6 — Registrar el Bundle ID en Apple Developer

1. Ve a [developer.apple.com](https://developer.apple.com) → Certificates, IDs & Profiles
2. Identifiers → **+**
3. Selecciona **App IDs** → **App**
4. Bundle ID: `com.tribulat.parcheapp`
5. Capabilities: activa **Push Notifications** y **Sign In with Apple**
6. Registra

---

## Paso 7 — Lanzar el primer build

1. En Codemagic, selecciona el workflow **iOS → TestFlight**
2. Clic en **Start new build**
3. Espera ~20-30 minutos
4. Si todo está bien, el `.ipa` se sube automáticamente a TestFlight

---

## Flujo de trabajo sugerido

```
Tú editas código en Windows
        ↓
git push origin master
        ↓
Codemagic detecta el push automáticamente
        ↓
Compila en sus Macs en la nube (~25 min)
        ↓
Sube a TestFlight automáticamente
        ↓
Tú (y tus testers) descargan la app desde TestFlight
```

---

## Errores comunes

| Error | Solución |
|-------|---------|
| `No profiles for bundle ID` | Verifica que el Bundle ID en App Store Connect coincide exactamente |
| `GoogleService-Info.plist not found` | Verifica que la variable `GOOGLE_SERVICE_INFO_PLIST` está en el grupo correcto |
| `CocoaPods error` | Agrega `pod repo update` antes de `pod install` en el script |
| `Code signing error` | Verifica que las credenciales de App Store Connect API tienen rol App Manager |
