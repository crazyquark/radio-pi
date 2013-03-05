#!/bin/dash
# Inspired by http://www.zeroathome.de/wordpress/lighttpd-mit-vhosts-unter-ubuntu-hardy/

# has to match simple-vhost.server-root from /etc/lighttpd/conf-available/10-simple-vhost.conf
base=/srv

echo "#"
echo "# per-vhost config generated by $0"
echo "# vhost base: $base"

for server_conf in $base/*/server.conf
do
  VHOST="$(basename "$(dirname "$server_conf")")"
  echo "\$HTTP[\"host\"] == \"$VHOST\" {"
  echo "#  var.vhost_name = \"$VHOST\""
  echo "#  var.vhost_path = \"$base/$VHOST/public_html\""
  cat "$base/$VHOST/server.conf"
  echo "#  server.errorlog = \"$base/$VHOST/logs/error.log\"",
  echo "  accesslog.filename = \"$base/$VHOST/logs/access.log\""
  echo "  server.kbytes-per-second = 1024"
  echo "}"
  if [ $VHOST = www* ] ; then
    echo "\$HTTP[\"host\"] == \"${VHOST:4}\" {"
    echo "#  url.redirect-code = 301"
    echo "  url.redirect = ( \"^/(.*)\" => \"http://${VHOST}/\$1\" )"
    echo "}"
  fi
done

