hugo --cleanDestinationDir
rsync --rsh="ssh -p2633" --exclude '.git' --delete \
--chmod=Du=rwx,Dgo=rx,Fu=rw,Fog=r \
-rtvzP ./public/. wancat@linchpins.cloud:/var/www/wancat.cc/
