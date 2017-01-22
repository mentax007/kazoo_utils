#!/bin/bash

sup kz_cache flush
sup kazoo_data_maintenance flush
sup kapps_config flush
sup kapps_config flush number_manager
sup ecallmgr_config flush 
sup stepswitch_maintenance reload_resources
sup kazoo_services_maintenance refresh
sup trunkstore_maintenance flush
sup jonny5_maintenance flush
