#!/bin/bash

# GameOfLifeIOS IPA Builder
# À placer dans /Users/yaroslavyakovlev/ACoding/coding 2025/projects/GameOfLifeIOS/

echo "=== Construction IPA pour GameOfLifeIOS ==="
echo "📁 Dossier actuel: $(pwd)"

# Vérifier que le projet existe
if [ ! -d "GameOfLifeIOS.xcodeproj" ]; then
    echo "❌ ERREUR: GameOfLifeIOS.xcodeproj non trouvé"
    echo "Recherche en cours..."
    find . -name "*.xcodeproj" -type d
    exit 1
fi

# Création du fichier ExportOptions.plist
if [ ! -f "ExportOptions.plist" ]; then
    echo "📝 Création de ExportOptions.plist..."
    cat > ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
    echo "✅ ExportOptions.plist créé"
fi

# Nettoyage
echo "🧹 Nettoyage..."
rm -rf build
mkdir -p build

# Archive
echo "📦 Création archive..."
xcodebuild archive \
    -project GameOfLifeIOS.xcodeproj \
    -scheme GameOfLifeIOS \
    -configuration Release \
    -archivePath build/GameOfLifeIOS.xcarchive \
    -destination 'generic/platform=iOS' \
    -allowProvisioningUpdates

# Vérifier l'archive
if [ ! -d "build/GameOfLifeIOS.xcarchive" ]; then
    echo "❌ Échec de la création de l'archive"
    exit 1
fi

# Export IPA
echo "📤 Export IPA..."
xcodebuild -exportArchive \
    -archivePath build/GameOfLifeIOS.xcarchive \
    -exportOptionsPlist ExportOptions.plist \
    -exportPath build \
    -allowProvisioningUpdates

# Résultat
if [ -f "build/GameOfLifeIOS.ipa" ]; then
    echo ""
    echo "✅ SUCCÈS!"
    echo "IPA: $(pwd)/build/GameOfLifeIOS.ipa"
    echo "Taille: $(du -h build/GameOfLifeIOS.ipa | cut -f1)"
    echo ""
    echo "📱 Installation avec AltStore:"
    echo "   1. Transférez build/GameOfLifeIOS.ipa sur iPhone"
    echo "   2. Ouvrez AltStore → My Apps → +"
    echo "   3. Sélectionnez le fichier"
    echo ""
    open build
else
    echo ""
    echo "❌ Échec - IPA non créé"
    echo "Contenu du dossier build:"
    ls -la build/
fi
