#!/bin/bash

echo "Changing country code in Kazoo UI.."

sed -i "s/+?1?/+?7?/g" /var/www/html/kazoo-ui/whapps/numbers/numbers_manager/numbers_manager.js
sed -i "s/'+1'/'+7'/g" /var/www/html/kazoo-ui/whapps/numbers/numbers_manager/numbers_manager.js

sed -i "s/+?1?/+?7?/g" /var/www/html/kazoo-ui/whapps/pbxs/pbxs_manager/pbxs_manager.js 
sed -i "s/'+1'/'+7'/g" /var/www/html/kazoo-ui/whapps/pbxs/pbxs_manager/pbxs_manager.js 

# Check if "/var/www/html/kazoo-ui/whapps/voip/resource/resource.js" also needed
