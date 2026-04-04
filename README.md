# 🚀 GitHub Actions ile Otomatik APK Build

Her `git push`'ta APK + AAB otomatik derlenir, indirmeye hazır!

---

## ⚡ Hızlı Başlangıç (5 adım)

### Adım 1 — Projeyi GitHub'a yükle

```bash
# Terminal'de proje klasörüne gir
cd vipdiziler-pro

# Git başlat
git init
git add .
git commit -m "İlk commit 🎬"

# GitHub'da yeni repo oluştur (github.com → New repository)
# Sonra:
git remote add origin https://github.com/KULLANICI_ADIN/vipdiziler.git
git branch -M main
git push -u origin main
```

### Adım 2 — Keystore oluştur

**Mac/Linux:**
```bash
chmod +x generate_keystore.sh
./generate_keystore.sh
```

**Windows (PowerShell):**
```powershell
keytool -genkeypair `
  -storetype PKCS12 `
  -keystore vipdiziler-keystore.jks `
  -alias vipdiziler `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -storepass SIFREN `
  -keypass SIFREN `
  -dname "CN=Adın, O=VipDiziler, L=Istanbul, ST=Istanbul, C=TR"

# Base64'e çevir:
[Convert]::ToBase64String([IO.File]::ReadAllBytes("vipdiziler-keystore.jks")) | Out-File keystore_base64.txt
```

### Adım 3 — GitHub Secrets'a ekle

GitHub'da: **Repo → Settings → Secrets and variables → Actions → New repository secret**

| Secret Adı | Değer |
|-----------|-------|
| `KEYSTORE_BASE64` | keystore_base64.txt dosyasının içeriği |
| `STORE_PASSWORD` | Keystore şifresi |
| `KEY_ALIAS` | `vipdiziler` |
| `KEY_PASSWORD` | Key şifresi (genelde aynı) |
| `GOOGLE_SERVICES_JSON` | Firebase'den indirdiğin JSON dosyasının içeriği *(opsiyonel)* |

> **İpucu:** `GOOGLE_SERVICES_JSON` yoksa Firebase devre dışı bırakılır, build yine çalışır.

### Adım 4 — Workflow dosyasını yükle

`.github/workflows/build.yml` dosyası zaten projede var.  
Commit et ve push'la:

```bash
git add .github/
git commit -m "GitHub Actions workflow eklendi"
git push
```

### Adım 5 — APK'yı indir

1. GitHub'da repo sayfasına git
2. **Actions** sekmesine tıkla
3. En son build'e tıkla
4. Sayfa altındaki **Artifacts** bölümünden indir:
   - `VipDiziler-Release-APK-vX` → APK (telefona yüklemek için)
   - `VipDiziler-Release-AAB-vX` → AAB (Google Play için)

---

## 🕐 Ne Zaman Build Çalışır?

| Durum | Debug | Release |
|-------|-------|---------|
| `main`/`master`'a push | ✅ | ✅ |
| Pull request açılınca | ✅ | ❌ |
| Manuel tetikleme | Seçime göre | Seçime göre |
| `v1.0.0` gibi tag push'u | ❌ | ✅ + GitHub Release |

### Manuel Tetikleme:
```
GitHub → Actions → "VIP Diziler — APK & AAB Build" → Run workflow → Build tipi seç
```

---

## 🏷️ Versiyonlu Release (Önerilen)

Yeni versiyon çıkarmak için:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Bu komut:
1. ✅ İmzalı APK + AAB derler
2. ✅ GitHub Release sayfası oluşturur
3. ✅ Dosyaları otomatik ekler

---

## ⏱️ Build Süreleri

| Build Tipi | Süre |
|-----------|------|
| İlk build (Gradle cache yok) | ~8-12 dakika |
| Sonraki buildler (cache var) | ~3-5 dakika |

GitHub Actions → ücretsiz planda ayda **2.000 dakika** hakkın var.  
Bu yaklaşık **~400 build** demek — fazlasıyla yeterli.

---

## ❌ Sık Karşılaşılan Hatalar

### "Keystore file not found"
→ `KEYSTORE_BASE64` secret'ı doğru eklenmemiş.  
→ Base64 değerinde boşluk/satır sonu olmamasına dikkat et.

### "Build failed: google-services.json not found"
→ `GOOGLE_SERVICES_JSON` secret'ı ekle ya da Firebase'i kaldır.

### "Keystore tamper exception"
→ Base64 encode ederken bozulmuş. Script'i yeniden çalıştır.

### "License not accepted"
→ Build adımlarına şunu ekle:
```yaml
- name: Android lisanslarını kabul et
  run: yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
```

---

## 🔒 Güvenlik Notları

- ✅ Keystore ASLA repo'ya commit edilmez
- ✅ Şifreler GitHub Secrets'ta şifreli saklanır
- ✅ Build sonrası keystore dosyası silinir
- ✅ Artifact'lar 30 gün sonra otomatik silinir
- ⚠️ `generate_keystore.sh` çalıştırdıktan sonra terminal geçmişini temizle

---

## 📁 Dosya Yapısı

```
.github/
└── workflows/
    └── build.yml        ← Ana workflow (bu dosya)
generate_keystore.sh     ← Keystore oluşturucu (Mac/Linux)
```
