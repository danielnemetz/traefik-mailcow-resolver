#!/bin/sh
set -e

# Domain aus certs-dumper-Umgebung (compose setzt CERT_DOMAIN=${MAIN_DOMAIN})
CERT_DOMAIN="${CERT_DOMAIN}"
DUMP_DIR="/dump/${CERT_DOMAIN}"
SOURCE_CERT="$DUMP_DIR/certificate.crt"
SOURCE_KEY="$DUMP_DIR/privatekey.key"
DEST_CERT="/output/cert.pem"
DEST_KEY="/output/key.pem"
DEST_DH="/output/dhparams.pem"
DEST_DH_BACKUP="/output/private/dhparams.pem"
DEFAULT_DH="/ssl-example/dhparams.pem"

echo "Hook-Skript gestartet. Prüfe, ob Quelldateien existieren..."

if [ -f "$SOURCE_CERT" ] && [ -f "$SOURCE_KEY" ]; then
    echo "Quelldateien gefunden. Kopiere Zertifikate..."
    cp "$SOURCE_CERT" "$DEST_CERT"
    cp "$SOURCE_KEY" "$DEST_KEY"

    if [ ! -f "$DEST_DH" ]; then
        if [ -f "$DEST_DH_BACKUP" ]; then
            echo "Fehlendes dhparams.pem aus Backup wiederherstellen..."
            cp "$DEST_DH_BACKUP" "$DEST_DH"
            chmod 600 "$DEST_DH"
        elif [ -f "$DEFAULT_DH" ]; then
            echo "Fehlendes dhparams.pem aus ssl-example übernehmen..."
            cp "$DEFAULT_DH" "$DEST_DH"
            chmod 600 "$DEST_DH"
        else
            echo "WARNUNG: Kein dhparams.pem verfügbar. Bitte manuell erzeugen!"
        fi
    fi

    if [ -f "$DEST_DH" ] && [ ! -f "$DEST_DH_BACKUP" ]; then
        echo "Backup von dhparams.pem im private-Verzeichnis anlegen..."
        cp "$DEST_DH" "$DEST_DH_BACKUP"
        chmod 600 "$DEST_DH_BACKUP"
    fi

    echo "Kopieren erfolgreich. Restarts übernimmt traefik-certs-dumper."
else
    echo "Quelldateien ($SOURCE_CERT oder $SOURCE_KEY) noch nicht gefunden."
    echo "Überspringe diesen Lauf (vermutlich Race Condition, warte auf nächsten Trigger)."
fi

exit 0
