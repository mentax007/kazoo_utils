#!/bin/bash

####################################################################################
######  Curent KAZOO UI Russian translation needs some small corrections      ######
######  Some phrases don't fit into icons, etc                                ######
######  After problems will be nailed it should be pulled to KAZOO UI master  ######
######                                                                        ######
######  Written by Kirill Sysoev                                              ######
######             kirill.sysoev@gmail.com                                    ######
####################################################################################

#############################
######  Get Variables  ######
#############################
source /etc/kz_vars/kazoo_config_edit.vars
#############################

## sed -i 's///' $KAZOO_UI_DIR/whapps/voip/user/lang/ru.js

sed -i 's/voip_phone: "Телефон VoIP"/voip_phone: "IP Телефон"/' $KAZOO_UI_DIR/whapps/voip/device/lang/ru.js
sed -i 's/cell_phone: "Сотовый телефон"/cell_phone: "Сотовый"/' $KAZOO_UI_DIR/whapps/voip/device/lang/ru.js
sed -i 's/landline: "Городской номер"/landline: "Городской"/' $KAZOO_UI_DIR/whapps/voip/device/lang/ru.js
sed -i 's/add_device_label: "Добавить устройство"/add_device_label: "Добавить"/' $KAZOO_UI_DIR/whapps/voip/device/lang/ru.js
sed -i 's/add_user_label: "Добавить пользователя"/add_user_label: "Добавить"/' $KAZOO_UI_DIR/whapps/voip/user/lang/ru.js
sed -i 's/hot_desk_login: "Вход с присвоением телефона"/hot_desk_login: "Вход с присвоением"/' $KAZOO_UI_DIR/whapps/voip/user/lang/ru.js
sed -i 's/hot_desk_logout: "Выход с освобождением телефона"/hot_desk_logout: "Выход с освобождением"/' $KAZOO_UI_DIR/whapps/voip/user/lang/ru.js
sed -i 's/hot_desk_toggle: "Переключить присвоение телефона"/hot_desk_toggle: "Переключить присвоение"/' $KAZOO_UI_DIR/whapps/voip/user/lang/ru.js
sed -i 's/save_changes: "Сохранить изменения"/save_changes: "Сохранить"/' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js
sed -i 's/delete_callflow: "Удалить сценарий"/delete_callflow: "Удалить"/' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js
sed -i 's/add_callflow_label: "Добавить сценарий"/add_callflow_label: "Добавить"/' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js
sed -i 's/callflows_label: "Сценарии"/callflows_label: "Маршрутизация"/' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js
sed -i 's/"Нажмите чтобы добавить номер"/"Добавить номер"/' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js
sed -i 's/add_voicemail_box_label: "Добавить ящик голосовой почты"/add_voicemail_box_label: "Добавить"/' $KAZOO_UI_DIR/whapps/voip/vmbox/lang/ru.js
sed -i 's/login: "Логин \/ Почта"/login: "Логин"/' $KAZOO_UI_DIR/whapps/auth/auth/lang/ru.js
sed -i 's/account_name: "Клиент"/account_name: "Учетная запись"/' $KAZOO_UI_DIR/whapps/auth/auth/lang/ru.js
sed -i 's/hotdesking_cat: "Присвоение телефонов"/hotdesking_cat: "Присвоение телефона"/' $KAZOO_UI_DIR/config/lang/ru.js
sed -i 's/"Переадресация звонков"/"Переадресация"/' $KAZOO_UI_DIR/config/lang/ru.js
sed -i 's/"Управление номерами"/"Номера"/' $KAZOO_UI_DIR/config/lang/ru.js
sed -i 's/"Включить переадресацию звонков"/"Включить переадресацию"/' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js
sed -i 's/stop_call_recording: "Остановить запись разговора"/stop_call_recording: "Остановить запись"/' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js

sed -i "/sunday:/d" /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i "/monday:/d" /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i "/tuesday:/d" /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i "/wednesday:/d" /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i "/thursday:/d" /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i "/friday:/d" /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i "/saturday:/d" /var/www/html/whapps/voip/timeofday/lang/ru.js

sed -i 's/check_voicemail: "Проверить голосовую почту"/check_voicemail: "Проверить сообщения"/' $KAZOO_UI_DIR/whapps/voip/vmbox/lang/ru.js
#sed -i 's///' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js
#sed -i 's///' $KAZOO_UI_DIR/whapps/voip/callflow/lang/ru.js

sed -i 's/sunday: "Воскресенье"/sunday: "Sunday"/g' /var/www/html/whapps/voip/timeofday/lang/ru.js 
sed -i 's/monday: "Понедельник"/monday: "Monday"/g' /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i 's/tuesday: "Вторник"/tuesday: "Tuesday"/g' /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i 's/wednesday: "Среда"/wednesday: "Wednesday"/g' /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i 's/thursday: "Четверг"/thursday: "Thursday"/g' /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i 's/friday: "Пятница"/friday: "Friday"/g' /var/www/html/whapps/voip/timeofday/lang/ru.js
sed -i 's/saturdaty: "Суббота"/saturday: "Saturday"/g' /var/www/html/whapps/voip/timeofday/lang/ru.js

