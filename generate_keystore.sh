#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  VIP Diziler — Keystore Oluşturma ve GitHub Secret Hazırlama
#  Bu script'i bir kez çalıştır, sonuçları GitHub Secrets'a ekle
# ═══════════════════════════════════════════════════════════════

set -e

echo ""
echo "🔐 VIP Diziler Keystore Oluşturucu"
echo "════════════════════════════════════"
echo ""

# Bilgileri al
read -p "📛 Ad Soyad (örn: Ahmet Yilmaz): " FULL_NAME
read -p "🏢 Şirket/Organizasyon (örn: VipDiziler): " ORG
read -p "🌍 Şehir (örn: Istanbul): " CITY
read -p "🗺️  İl (örn: Istanbul): " STATE
read -p "🇹🇷 Ülke kodu (TR): " COUNTRY
COUNTRY=${COUNTRY:-TR}

read -sp "🔑 Keystore şifresi (en az 6 karakter): " STORE_PASS
echo ""
read -sp "🔑 Aynı şifreyi tekrar gir: " STORE_PASS_CONFIRM
echo ""

if [ "$STORE_PASS" != "$STORE_PASS_CONFIRM" ]; then
    echo "❌ Şifreler eşleşmiyor!"
    exit 1
fi

KEY_ALIAS="vipdiziler"
KEY_PASS="$STORE_PASS"
KEYSTORE_FILE="vipdiziler-keystore.jks"

echo ""
echo "⚙️  Keystore oluşturuluyor..."

keytool -genkeypair \
    -v \
    -storetype PKCS12 \
    -keystore "$KEYSTORE_FILE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STORE_PASS" \
    -keypass "$KEY_PASS" \
    -dname "CN=$FULL_NAME, O=$ORG, L=$CITY, ST=$STATE, C=$COUNTRY"

echo ""
echo "✅ Keystore oluşturuldu: $KEYSTORE_FILE"
echo ""

# Base64 encode et
KEYSTORE_BASE64=$(base64 -i "$KEYSTORE_FILE" | tr -d '\n')

echo "═══════════════════════════════════════════════════════════════"
echo "  GitHub Secrets'a şunları ekle:"
echo "  (GitHub → Repo → Settings → Secrets → Actions → New secret)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 Secret Adı: KEYSTORE_BASE64"
echo "📋 Secret Değeri (tüm metni kopyala):"
echo "---"
echo "$KEYSTORE_BASE64"
echo "---"
echo ""
echo "📋 Secret Adı: STORE_PASSWORD"
echo "📋 Secret Değeri: $STORE_PASS"
echo ""
echo "📋 Secret Adı: KEY_ALIAS"
echo "📋 Secret Değeri: $KEY_ALIAS"
echo ""
echo "📋 Secret Adı: KEY_PASSWORD"
echo "📋 Secret Değeri: $KEY_PASS"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "⚠️  UYARI: Bu şifreler ve keystore dosyasını güvenli"
echo "   bir yerde sakla! Kaybedersen uygulamayı güncelleyemezsin."
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Base64'ü dosyaya da yaz (kolaylık için)
echo "$KEYSTORE_BASE64" > keystore_base64.txt
echo "💾 Base64 değeri 'keystore_base64.txt' dosyasına da kaydedildi."
echo ""
echo "✅ Tamamlandı! Şimdi GitHub Secrets'a ekleyebilirsin."
