#!/bin/bash
set -euo pipefail

echo "::group::Download UniFi.unix.zip"
wget --quiet --show-progress --progress=dot:giga --output-document UniFi.unix.zip "$URL"
echo

echo "::group::Verify UniFi.unix.zip"
if [ -n "$MD5" ]; then
	echo 'check MD5...'
	md5sum --status --check <<-EOF
		$MD5  UniFi.unix.zip
	EOF
fi
if [ -n "$SHA256" ]; then
	echo 'check SHA256...'
	sha256sum --status --check <<-EOF
		$SHA256  UniFi.unix.zip
	EOF
fi
if [ -z "$MD5" ] && [ -z "$SHA256" ]; then
	echo "::warning::no checksum available for UniFi.unix.zip"
fi

cd docker

echo "::group::Extract UniFi.unix.zip"
unzip -q ../UniFi.unix.zip

cd UniFi

echo "::group::Remove unnecessary files"
rm bin/mongod
rm -rf lib/native/Mac
rm -rf lib/native/Windows
rm -rf lib/native/Linux/armv7
rm -rf lib/native/Linux/aarch64
rm lib/native/Linux/x86_64/libubnt_sdnotify_jni.so
rm readme.txt

echo "::group::Adjust directory structure"
rmdir bin
mkdir data
mkdir logs
mkdir -p run/work/ROOT

cd ..

echo "::group::Build Docker image"
docker build --no-cache --squash --tag "$IMAGE_PATH:$VERSION" .

if [ -n "$REGISTRY_PASSWORD" ]; then
	echo "::group::Push Docker image"
	docker login --username "$REGISTRY_USERNAME" --password-stdin "${IMAGE_PATH%%/*}" <<<"$REGISTRY_PASSWORD"
	docker push "$IMAGE_PATH:$VERSION"
fi
