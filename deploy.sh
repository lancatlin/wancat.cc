#/bin/sh

# Your server, I use ssh config
SERVER=linchpins
# Destination dir on server
DEST=/var/www/wancat.cc/
# Save your CloudFlare token somewhere. I use pass
TOKEN=$(pass server/cloudflare-api)
# Your domain id, get it by https://api.cloudflare.com/client/v4/zones
ZONE="110a1c9faf67fbb31108d98a3d982a31"
# Your dns record id, get it by https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records
DNS="82afaac670192096d3e4d60798b723e2"

hugo --cleanDestinationDir

rsync --exclude '.git' --delete \
--chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r \
-rtvzP ./public/. $SERVER:$DEST

IPFS=$(ssh linchpins "cd $DEST && ipfs add -r -Q .") &&
echo $IPFS &&
JSON_FMT='{"type":"TXT","name":"@","content":"dnslink=/ipfs/%s","ttl":3600,"proxied":false}' &&
DATA=$(printf "$JSON_FMT" "$IPFS") &&
echo $DATA &&
curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records/$DNS" \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     --data "$DATA"
