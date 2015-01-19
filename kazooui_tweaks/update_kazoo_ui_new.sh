#!/bin/bash

########################################################################
######  A little pice of automatition to upgrade KAZOO_UI easier  ######
######  Written by Kirill Sysoev                                  ######
######             kirill.sysoev@gmail.com                        ######
########################################################################

#########################################
######  Change your settings here  ######
#########################################

#KAZOO_UI_DIR="/var/www/html"
#CROSSBAR_SERVER="192.168.1.27"
#COUNTRY_CODE="7"
#PROVISIONING_SERVER="p.tld.com"

#############################
######  Get Variables  ######
#############################
source /etc/kz_vars/kazoo_config_edit.vars
#############################

echo "Deleting previous installation"

rm -rf $KAZOO_UI_DIR

echo "Retrieving KAZOO_UI master"

git clone -b v3.18 https://github.com/2600hz/kazoo_ui.git $KAZOO_UI_DIR

echo "`date '+%Y-%m-%d'`" > $KAZOO_UI_DIR/VERSION

wget --no-check-certificate https://raw.github.com/onnet/mod_zonnet/b9e5f3cbe4d9f320027bc8d048c2b0a4d172895a/lib/images/OnNet36x36.png -O $KAZOO_UI_DIR/img/wsLogo.png

wget --no-check-certificate https://raw.github.com/onnet/mod_zonnet/master/lib/images/logo_for_kazoo.png -O $KAZOO_UI_DIR/config/images/logo.png

wget --no-check-certificate https://raw.github.com/onnet/mod_zonnet/master/lib/images/big_onnet_img_for_kazoo.png -O $KAZOO_UI_DIR/config/images/onnet.png

wget --no-check-certificate https://raw.github.com/onnet/kazoo_utils/master/kazooui_tweaks/files/left_welcome.html -O $KAZOO_UI_DIR/config/tmpl/left_welcome.html

################################
######  Config.js tweaks #######
################################

echo "Changing config.js"

sed -i "s/api.2600hz.com/$CROSSBAR_SERVER/g" $KAZOO_UI_DIR/config/config.js
sed -i "s/10.26.0.41/$CROSSBAR_SERVER/g" $KAZOO_UI_DIR/config/config.js
sed -i "s/api.zswitch.net/$CROSSBAR_SERVER/g" $KAZOO_UI_DIR/config/config.js

###########################################################
###### Change your preferred options here by analogy ######
###########################################################

sed -i "s/hide_registration: false/hide_registration: true/g" $KAZOO_UI_DIR/config/config.js
sed -i "s/company_name: '2600hz'/company_name: 'OnNet - Virtual Office'/g" $KAZOO_UI_DIR/config/config.js

################################################################################
###### Change default infite_format in pbx_manager to 'e164_without_plus' ######
################################################################################

sed -i "s/inbound_format: 'e.164',/inbound_format: 'e164_without_plus',/g" $KAZOO_UI_DIR/whapps/pbxs/pbxs_manager/pbxs_manager.js

#############################################################
###### Change country code in number_manager's regexps ######
#############################################################

echo "Changing country code in Kazoo UI.."

sed -i "s/+?1?/+?$COUNTRY_CODE?/g" $KAZOO_UI_DIR/whapps/numbers/numbers_manager/numbers_manager.js
sed -i "s/'+1'/'+$COUNTRY_CODE'/g" $KAZOO_UI_DIR/whapps/numbers/numbers_manager/numbers_manager.js

sed -i "s/+?1?/+?$COUNTRY_CODE?/g" $KAZOO_UI_DIR/whapps/pbxs/pbxs_manager/pbxs_manager.js 
sed -i "s/'+1'/'+$COUNTRY_CODE'/g" $KAZOO_UI_DIR/whapps/pbxs/pbxs_manager/pbxs_manager.js 

########################################################################################
##########  Running localization if needed                                  ############
########################################################################################
sed -i "s/language = 'en'/language = 'ru'/g" $KAZOO_UI_DIR/config/load.js
sh /root/kazoo_utils/kazooui_tweaks/localization/siplabs_translation_corrections.sh
########################################################################################

########################################################################################
##########  Change default timezone to MSK                                  ############
########################################################################################
sed -i "s/America\/Los_Angeles/Europe\/Moscow/g" $KAZOO_UI_DIR/whapps/voip/vmbox/vmbox.js
########################################################################################

########################################################################################
#######################  Internal scripts ##############################################
########################################################################################
ln -s /var/www/create_account.html /var/www/html/create_account.html
ln -s /var/www/last_records_remove.sh /var/www/html/last_records_remove.sh
ln -s /var/www/cfgs.sh /var/www/html/cfgs.sh
ln -s /var/www/anti_fraud_checker.php /var/www/html/anti_fraud_checker.php
########################################################################################

