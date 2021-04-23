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
exec /usr/bin/tini -- java -jar lib/ace.jar start
