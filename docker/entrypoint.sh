#!/bin/bash
set -euo pipefail
if [ ! -e data/system.properties ]; then
	cat >data/system.properties <<-EOF
		db.mongo.local=false
		unifi.config.readEnv=true
	EOF
fi
find -L /entrypoint.d -maxdepth 1 -type f -executable -print0 | sort -z | while IFS= read -r -d $'\0' HOOK; do
	echo "Executing $HOOK"
	"$HOOK"
done
exec /usr/bin/tini -- java \
-Dfile.encoding=UTF-8 \
-Djava.awt.headless=true \
-Dapple.awt.UIElement=true \
$UNIFI_JVM_OPTS \
-XX:+ExitOnOutOfMemoryError \
-XX:+CrashOnOutOfMemoryError \
-XX:ErrorFile=logs/hs_err_pid%p.log \
--add-opens java.base/java.lang=ALL-UNNAMED \
--add-opens java.base/java.time=ALL-UNNAMED \
--add-opens java.base/sun.security.util=ALL-UNNAMED \
--add-opens java.base/java.io=ALL-UNNAMED \
--add-opens java.rmi/sun.rmi.transport=ALL-UNNAMED \
-jar lib/ace.jar start
