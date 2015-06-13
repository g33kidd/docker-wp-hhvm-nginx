#!/bin/bash

php -r "
define('WP_SITEURL', getenv('WP_SITEURL'));
include '/app/wp-admin/install.php';
wp_install(getenv('WP_SITE'), 'admin', getenv('WP_EMAIL'), 1, '', getenv('DB_PASSWORD'));"