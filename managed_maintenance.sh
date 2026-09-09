#!/bin/bash
echo "Beginning nightly maintenance routine"

echo "ACTION: Ensuring all scripts are set to ADMIN"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_scripts SET user_group = 'ADMIN' WHERE user_group = '---ALL---'"
echo

echo "ACTION: Ensuring all filters are set to ADMIN"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_lead_filters SET user_group = 'ADMIN' WHERE user_group = '---ALL---'"
echo

echo "ACTION: Ensuring all In-Groups are set to ADMIN"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_inbound_groups SET user_group = 'ADMIN' WHERE user_group = '---ALL---'"
echo

echo "ACTION: Ensuring all DIDs are set to ADMIN"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_inbound_dids SET user_group = 'ADMIN' WHERE user_group = '---ALL---'"
echo

echo "ACTION: Ensuring all DIDs have system-wide blocklist applied"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_inbound_dids SET filter_inbound_number = 'GROUP', filter_phone_group_id = 'NUISANCE' WHERE filter_inbound_number = 'DISABLED'"
echo

echo "ACTION: Ensuring all voicemail boxes are set to ADMIN"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_voicemail SET user_group = 'ADMIN' WHERE user_group = '---ALL---'"
echo

echo "ACTION: Ensuring all phones are set to ADMIN"
/usr/bin/mysql -vv asterisk -e "UPDATE phones SET user_group = 'ADMIN' WHERE user_group = '---ALL---'"
echo

echo "ACTION: Ensuring Persistent MySQL is enabled for all phones"
/usr/bin/mysql -vv asterisk -e "UPDATE phones SET enable_persistant_mysql = '1'"
echo

echo "ACTION: Ensuring all phones are set to proper context"
/usr/bin/mysql -vv asterisk -e "UPDATE phones SET phone_context = 'agent-nodial' WHERE phone_context = 'default'"
echo

echo "ACTION: Ensuring all phone aliases are set to ADMIN"
/usr/bin/mysql -vv asterisk -e "UPDATE phones_alias SET user_group = 'ADMIN' where user_group = '---ALL---'"
echo

echo "ACTION: Ensuring all webphones are properly configured"
/usr/bin/mysql -vv asterisk -e "UPDATE phones SET webphone_dialbox = 'N' where webphone_dialbox = 'Y'"
echo

echo "ACTION: Ensuring all user groups have proper Report permissions set"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_user_groups SET allowed_reports = ' Real-Time Main Report, Real-Time Campaign Summary, Real-Time Whiteboard Report, VERM Reports, Inbound Report, Inbound Report by DID, Inbound Service Level Report, Inbound Summary Hourly Report, Inbound Daily Report, Inbound DID Report, Inbound DID Summary Report, Agent DID Report, Inbound Forecasting Report, Advanced Forecasting Report, Outbound Calling Report, Outbound Summary Interval Report, Outbound Lead Source Report, Fronter - Closer Report, Fronter - Closer Detail Report, Lists Campaign Statuses Report, Lists Statuses Report, Campaign Status List Report, Agent Time Detail, Agent Status Detail, Agent Inbound Status Summary, Agent Performance Detail, Team Performance Detail, Performance Comparison Report, Single Agent Daily, Single Agent Daily Time, User Group Login Report, User Group Hourly Report, User Group Detail Hourly Report, Administration Change Log, List Update Stats, User Stats, User Time Sheet, Download List, Custom Reports Links, Search Leads Logs, Called Counts List IDs Report, Front Page System Summary, Recording Access Log Report, Real-Time Monitoring Log Report, LAGGED Agent Log Report, Agent Latency Report, Latency Gaps Report, Agent Disposition Report, Agent Performance Report, Agents Time On Calls, User Logins Report, Demographic Quotas Report, VERM QA Links',
allowed_custom_reports = 'Reset Campaign Lists|' WHERE user_group != 'ADMIN'"
echo

echo "ACTION: Resetting all leads with PU status"
/usr/bin/mysql -vv asterisk -e "UPDATE vicidial_list SET status = 'NA', called_since_last_reset = 'N' where status = 'PU'"
echo

echo "ACTION: Forcing password change for all active users with default passwords"
/usr/bin/mysql asterisk -e "SELECT user,full_name,user_level,user_group FROM vicidial_users WHERE pass = '1234' and force_change_password = 'N' and active = 'Y'"
/usr/bin/mysql asterisk -e "UPDATE vicidial_users SET force_change_password = 'Y' WHERE pass = '1234' and force_change_password = 'N' and active = 'Y'"
echo

echo "ACTION: Rebuilding Asterisk config files"
/usr/bin/mysql -vv asterisk -e "UPDATE servers SET rebuild_conf_files='Y', rebuild_music_on_hold='Y' where generate_vicidial_conf='Y' and active_asterisk_server='Y'"
echo

echo "ACTION: Running fstrim to reclaim free space"
/sbin/fstrim -av
echo

echo "Script complete, exiting!"
/usr/bin/date
