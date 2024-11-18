#!/bin/bash
#
# via: https://docs.nextcloud.com/server/latest/admin_manual/occ_command.html#apps-commands
# via: https://docs.nextcloud.com/server/latest/admin_manual/occ_command.html#ldap-commands-label

# -- enable and configure ldap app ---------------------------------------------

php /var/www/html/occ app:enable user_ldap
php /var/www/html/occ ldap:create-empty-config
php /var/www/html/occ ldap:set-config s01 ldapHost "$LDAP_HOST"
php /var/www/html/occ ldap:set-config s01 ldapPort "$LDAP_PORT"
php /var/www/html/occ ldap:set-config s01 ldapBase "$LDAP_BASE_DN"
php /var/www/html/occ ldap:set-config s01 ldapAgentName "$LDAP_BIND_DN"
php /var/www/html/occ ldap:set-config s01 ldapAgentPassword "$LDAP_BIND_PASSWORD"
php /var/www/html/occ ldap:set-config s01 ldapLoginFilter "(&(objectclass=*)(uid=%uid))"
php /var/www/html/occ ldap:test-config s01
