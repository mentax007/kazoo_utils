#!/bin/bash

KAZOO_UI_DIR="/var/www/html/v3"
CROSSBAR_SERVER="94.125.5.27"

echo "Deleting previous installation"

rm -rf /var/www/html/v3

echo "Retrieving KAZOO_UI master"

git clone https://github.com/2600hz/kazoo_ui.git /var/www/html/v3

echo "Retrieving config.js"

wget https://github.com/onnet/kazoo_utils/raw/master/tmp/config.js -O /var/www/html/v3/config/config.js

echo "Changing country code in Kazoo UI.."

sed -i "s/+?1?/+?7?/g" /var/www/html/v3/whapps/numbers/numbers_manager/numbers_manager.js
sed -i "s/'+1'/'+7'/g" /var/www/html/v3/whapps/numbers/numbers_manager/numbers_manager.js

sed -i "s/+?1?/+?7?/g" /var/www/html/v3/whapps/pbxs/pbxs_manager/pbxs_manager.js 
sed -i "s/'+1'/'+7'/g" /var/www/html/v3/whapps/pbxs/pbxs_manager/pbxs_manager.js 

# Check if "/var/www/html/kazoo-ui/whapps/voip/resource/resource.js" also needed

echo "Removing unused elements..."

#########  Get rid of Credit widget  ###########################################
sed -i "/'credits': false/d" /var/www/html/v3/whapps/myaccount/myaccount.js
sed -i "s/'statistics': false,/'statistics': false/g" /var/www/html/v3/whapps/myaccount/myaccount.js
######### Get rid of Carrier menu in PBX Advanced settings ########
sed -i "/'resource': false,/d" /var/www/html/v3/whapps/voip/voip.js
#########  Get rid some staff in myaccount  ####################################
sed -i "/'billing': false,/d" /var/www/html/v3/whapps/myaccount/myaccount.js 
sed -i "/'report': false,/d" /var/www/html/v3/whapps/myaccount/myaccount.js 
#########  Get rid some Emergency  ####################################
## Account
sed -i "/_emergency/d" /var/www/html/v3/whapps/voip/account/account.js 
sed -i "/form_data.caller_id.emergency.number/d" /var/www/html/v3/whapps/voip/account/account.js 
sed -i "/mergency/d" /var/www/html/v3/whapps/voip/account/tmpl/edit.html
################################################################################
