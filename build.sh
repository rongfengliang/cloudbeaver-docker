#!/bin/bash
echo "Clone and build Cloudbeaver"

rm -rf ./cloudbeaver
mkdir ./cloudbeaver
mkdir ./cloudbeaver/server
mkdir ./cloudbeaver/conf
mkdir ./cloudbeaver/workspace
mkdir ./cloudbeaver/web

echo "Pull dbeaver platform"

cd ../..
if [[ ! -f dbeaver ]]
then
  git clone --depth 1 https://github.com/dbeaver/dbeaver.git
fi
echo $PWD
ls -sailh

cd dbeaver
git pull
mvn clean package install

cd ../cloudbeaver/deploy

echo "Build CloudBeaver server"

cd ../server/product/aggregate
mvn clean package -Dheadless-platform
cd ../../../deploy

echo "Copy server packages"

cp -rp ../server/product/web-server/target/products/io.cloudbeaver.product/all/all/all/* ./cloudbeaver/server
cp -p ./scripts/run-server.sh ./cloudbeaver
mkdir ./cloudbeaver/workspace/GlobalConfiguration
cp -rp ../samples/sample-databases/GlobalConfiguration cloudbeaver/workspace
cp ../samples/sample-databases/cloudbeaver.conf cloudbeaver/conf/cloudbeaver.conf
cp ../samples/sample-databases/initial-data.conf cloudbeaver/conf/initial-data.conf
cp ../samples/sample-databases/product.conf cloudbeaver/conf/product.conf

echo "Build static content"

cd ../webapp

lerna bootstrap
lerna run build --scope @dbeaver/dbeaver -- -- --pluginsList=../../../../products/default/plugins-list.js

cd ../deploy

echo "Copy static content"

cp -rp ../webapp/packages/dbeaver/dist/* cloudbeaver/web

echo "Cloudbeaver is ready. Run run-server.bat in cloudbeaver folder to start the server."