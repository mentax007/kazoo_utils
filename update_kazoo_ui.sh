#!/bin/bash

echo "Deleting previous installation"

rm -rf /var/www/html/v3

echo "Retrieving KAZOO_UI master"

git clone https://github.com/2600hz/kazoo_ui.git /var/www/html/v3

echo "Retrieving config.js"

wget https://github.com/onnet/kazoo_utils/raw/master/tmp/config.js -O /var/www/html/v3/config/config.js

echo "Changing country code in Kazoo UI.."

sed -i "s/+?1?/+?7?/g" /var/www/html/kazoo-ui/whapps/numbers/numbers_manager/numbers_manager.js
sed -i "s/'+1'/'+7'/g" /var/www/html/kazoo-ui/whapps/numbers/numbers_manager/numbers_manager.js

sed -i "s/+?1?/+?7?/g" /var/www/html/kazoo-ui/whapps/pbxs/pbxs_manager/pbxs_manager.js 
sed -i "s/'+1'/'+7'/g" /var/www/html/kazoo-ui/whapps/pbxs/pbxs_manager/pbxs_manager.js 

# Check if "/var/www/html/kazoo-ui/whapps/voip/resource/resource.js" also needed
