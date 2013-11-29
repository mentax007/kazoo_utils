#!/bin/bash

########################################################################
######  A little pice of automatition to upgrade KAZOO_UI easier  ######
######  Written by Kirill Sysoev                                  ######
######             kirill.sysoev@gmail.com                        ######
########################################################################

#########################################
######  Change your settings here  ######
#########################################

KAZOO_UI_DIR="/var/www/html/v3"
CROSSBAR_SERVER="94.125.5.27"
COUNTRY_CODE="7"

#########################################

echo "Deleting previous installation"

rm -rf $KAZOO_UI_DIR

echo "Retrieving KAZOO_UI master"

git clone https://github.com/2600hz/kazoo_ui.git $KAZOO_UI_DIR

echo "Master `date '+%Y%m%d %H:%M'`" > $KAZOO_UI_DIR/VERSION

wget https://raw.github.com/onnet/kazoo_utils/master/tmp/OnNet36x36.png -O $KAZOO_UI_DIR/img/wsLogo.png

################################
######  Config.js tweaks #######
################################

echo "Changing config.js"

sed -i "s/api.2600hz.com/$CROSSBAR_SERVER/g" $KAZOO_UI_DIR/config/config.js

###########################################################
###### Change your preferred options here by analogy ######
###########################################################

sed -i "s/hide_registration: false/hide_registration: true/g" $KAZOO_UI_DIR/config/config.js
sed -i "s/company_name: '2600hz'/company_name: 'OnNet - Virtual Office'/g" $KAZOO_UI_DIR/config/config.js

#############################################################
###### Change country code in number_manager's regexps ######
#############################################################

echo "Changing country code in Kazoo UI.."

sed -i "s/+?1?/+?$COUNTRY_CODE?/g" $KAZOO_UI_DIR/whapps/numbers/numbers_manager/numbers_manager.js
sed -i "s/'+1'/'+$COUNTRY_CODE'/g" $KAZOO_UI_DIR/whapps/numbers/numbers_manager/numbers_manager.js

sed -i "s/+?1?/+?$COUNTRY_CODE?/g" $KAZOO_UI_DIR/whapps/pbxs/pbxs_manager/pbxs_manager.js 
sed -i "s/'+1'/'+$COUNTRY_CODE'/g" $KAZOO_UI_DIR/whapps/pbxs/pbxs_manager/pbxs_manager.js 

# Check if "/var/www/html/kazoo-ui/whapps/voip/resource/resource.js" also needed

####################################################i###################################
###### Remove unused at KAZOO_UI elements. For example:                           ######
###### - we do not use built in billing;                                          ######
###### - it is not common to use Directory in SOHO segment in Russia;             ######
###### - we do not provide an ability to route calls to third party carriers yet; ######
###### - we do not provide subaccounts yet.                                       ######
########################################################################################

echo "Removing unused elements..."

#########  Get rid of Credit widget  ###################################################

sed -i "/'credits': false/d" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js
sed -i "s/'statistics': false,/'statistics': false/g" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js

######### Get rid of Carrier and Directory menu in PBX Advanced settings ########

sed -i "/'resource': false,/d" $KAZOO_UI_DIR/whapps/voip/voip.js
sed -i "/'directory': false/d" $KAZOO_UI_DIR/whapps/voip/voip.js
sed -i "s/'cdr': false,/'cdr': false/g" $KAZOO_UI_DIR/whapps/voip/voip.js

#########  Get rid of some staff in "myaccount"  #######################################

sed -i "/'billing': false,/d" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js 
sed -i "/'report': false,/d" $KAZOO_UI_DIR/whapps/myaccount/myaccount.js 

#########  Get rid of Emergency Fields as we do not use them  ##########################
## Account

sed -i "/_emergency/d" $KAZOO_UI_DIR/whapps/voip/account/account.js 
sed -i "/form_data.caller_id.emergency.number/d" $KAZOO_UI_DIR/whapps/voip/account/account.js 
sed -i "/mergency/d" $KAZOO_UI_DIR/whapps/voip/account/tmpl/edit.html

## User

sed -i "/_emergency/d" $KAZOO_UI_DIR/whapps/voip/user/user.js
sed -i "/form_data.caller_id.emergency.number/d" $KAZOO_UI_DIR/whapps/voip/user/user.js 
sed -i "/mergency/d" $KAZOO_UI_DIR/whapps/voip/user/tmpl/edit.html

## Device

sed -i "/_emergency/d" $KAZOO_UI_DIR/whapps/voip/device/device.js 
sed -i "/form_data.caller_id.emergency.number/d" $KAZOO_UI_DIR/whapps/voip/device/device.js 
sed -i "/mergency/d" $KAZOO_UI_DIR/whapps/voip/device/tmpl/edit.html

########################################################################################
