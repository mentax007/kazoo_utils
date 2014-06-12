#!/bin/bash

########################################################################
######  Add skype device option to KAZOO UI script                ######
######  sip_uri device taken as an example                        ######
######  it just forms sip_uri pointing to operators Skype GW      ######
######  in form of sip:skype+skype_account@skypegw.domain.tld     ######
######  Written by Kirill Sysoev                                  ######
######             kirill.sysoev@gmail.com                        ######
########################################################################

#############################
######  Get Variables  ######
#############################
source /etc/kz_vars/kazoo_config_edit.vars
#############################

cp $KAZOO_UI_DIR/whapps/voip/device/tmpl/sip_uri.html $KAZOO_UI_DIR/whapps/voip/device/tmpl/skype.html

sed -i "s/           fax: 'tmpl\/fax.html',/&\n            skype: 'tmpl\/skype.html',/" $KAZOO_UI_DIR/whapps/voip/device/device.js
sed -i "s/   clean_form_data: function(form_data) {/&\n\n            if(form_data.device_type == 'skype') {\n \
                if(form_data.sip.route.search('sip:skype+')) {\n \
                    form_data.sip.route = 'sip:skype+' + form_data.sip.route.trim() + '@skypegw.onnet.su';\n \
                }\n \
           }\n/" $KAZOO_UI_DIR/whapps/voip/device/device.js
sed -i "s/     validation: {/&\n            skype: [{ name: '#name',                regex: _t('device', 'sip_uri_name_regex') }],/" $KAZOO_UI_DIR/whapps/voip/device/device.js
sed -i "s/'smartphone', 'landline', 'cellphone', 'sip_uri'/'smartphone', 'landline', 'cellphone', 'sip_uri', 'skype'/" $KAZOO_UI_DIR/whapps/voip/device/device.js
sed -i "s/            <\/div>/\n                <span class='buttons' device_type='skype'><span class='icon white phone'\/><span class='label_device'>\${_t('skype')}<\/span><\/span>\n\n&/" $KAZOO_UI_DIR/whapps/voip/device/tmpl/general_edit.html
sed -i 's/sip_uri_type: "SIP URI",/&\n        skype_type: "Skype",/' $KAZOO_UI_DIR/whapps/voip/user/lang/en.js
sed -i 's/sip_uri_type: "SIP URI",/&\n        skype_type: "Skype",/' $KAZOO_UI_DIR/whapps/voip/user/lang/ru.js
sed -i "s/fax: _t('user', 'fax_type'),/&\n                            skype: _t('user', 'skype_type'),/" $KAZOO_UI_DIR/whapps/voip/user/user.js
sed -i 's/sip_uri: "SIP URI",/&\n        skype: "Skype", \
        edit_skype: "Редактировать Skype", \
        add_a_skype: "Добавить Skype", \
        skype_account: "Skype акаунт", \
        skype_account_content: "skype_account",/' $KAZOO_UI_DIR/whapps/voip/device/lang/ru.js
sed -i 's/sip_uri: "SIP URI",/&\n        skype: "Skype", \
        edit_skype: "Edit Skype", \
        add_a_skype: "Add Skype", \
        skype_account: "Skype account", \
        skype_account_content: "skype_account",/' $KAZOO_UI_DIR/whapps/voip/device/lang/en.js
sed -i "s/edit_sip_uri/edit_skype/" $KAZOO_UI_DIR/whapps/voip/device/tmpl/skype.html
sed -i "s/add_a_sip_uri/add_a_skype/" $KAZOO_UI_DIR/whapps/voip/device/tmpl/skype.html
sed -i "s/sip:support@company.com/skype_account/" $KAZOO_UI_DIR/whapps/voip/device/tmpl/skype.html
sed -i "s/'url'/'skype_account'/" $KAZOO_UI_DIR/whapps/voip/device/tmpl/skype.html
