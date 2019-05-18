<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'instanceid' => 'xxxxxxx',
  'passwordsalt' => 'xxxxxxx',
  'secret' => 'xxxxx',
  'trusted_domains' =>
  array (
    '192.168.x.x',
    'www.example.com',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'sqlite3',
  'version' => '16.0.0.9',
  'overwritehost' => '192.168.x.x',
  'overwritewebroot' => '/nextcloud',
  'overwrite.cli.url' => 'https://www.example.com/nextcloud',
  'installed' => true,
  'ldapIgnoreNamingRules' => false,
  'ldapProviderFactory' => 'OCA\\User_LDAP\\LDAPProviderFactory',
);
