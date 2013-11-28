#!/bin/bash

###############################################################
######  Pice of automatition to upgrade KAZOO_UI easier  ######
###############################################################

KAZOO_UI_DIR="/var/www/html/v3"
CROSSBAR_SERVER="94.125.5.27"

echo "Deleting previous installation"

rm -rf $KAZOO_UI_DIR

echo "Retrieving KAZOO_UI master"

git clone https://github.com/2600hz/kazoo_ui.git $KAZOO_UI_DIR

echo "Changing config.js"

sed -i "s/api.2600hz.com/$CROSSBAR_SERVER/g" $KAZOO_UI_DIR/config/config.js
sed -i "s/hide_registration: false/hide_registration: true/g" $KAZOO_UI_DIR/config/config.js
sed -i "s/company_name: '2600hz'/company_name: 'OnNet'/g" $KAZOO_UI_DIR/config/config.js

echo "Changing country code in Kazoo UI.."

sed -i "s/+?1?/+?7?/g" $KAZOO_UI_DIR/whapps/numbers/numbers_manager/numbers_manager.js
sed -i "s/'+1'/'+7'/g" $KAZOO_UI_DIR/whapps/numbers/numbers_manager/numbers_manager.js

sed -i "s/+?1?/+?7?/g" $KAZOO_UI_DIR/whapps/pbxs/pbxs_manager/pbxs_manager.js 
sed -i "s/'+1'/'+7'/g" $KAZOO_UI_DIR/whapps/pbxs/pbxs_manager/pbxs_manager.js 

# Check if "/var/www/html/kazoo-ui/whapps/voip/resource/resource.js" also needed

echo "Removing unused elements..."

#########  Get rid of Credit widget  ###########################################
sed -i "/'credits': false/d" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js
sed -i "s/'statistics': false,/'statistics': false/g" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js
######### Get rid of Carrier menu in PBX Advanced settings ########
sed -i "/'resource': false,/d" $KAZOO_UI_DIR/whapps/voip/voip.js
#########  Get rid of some staff in "myaccount"  ####################################
sed -i "/'billing': false,/d" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js 
sed -i "/'report': false,/d" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js 
#########  Get rid of Emergency Fields  ####################################
## Account
sed -i "/_emergency/d" $KAZOO_UI_DIR/whapps/voip/account/account.js 
sed -i "/form_data.caller_id.emergency.number/d" $KAZOO_UI_DIR/whapps/voip/account/account.js 
sed -i "/mergency/d" $KAZOO_UI_DIR/whapps/voip/account/tmpl/edit.html
################################################################################
