<?

// =========
// = prefs =
// =========

define('HOMEPAGE_URL', 'http://www.poolradio.org/');
define('FEED_URL', 'http://www.poolradio.org/rss');
define('LASTFM_USERNAME', 'poolradio');

// ==============
// = main setup =
// ==============

define('SITE_ROOT', '/Users/mongo/Documents/code/poolradio');
define('INC_ROOT', SITE_ROOT.'/include');
define('LIB_ROOT', SITE_ROOT.'/lib');
define('WWW_ROOT', SITE_ROOT.'/www');

ini_set('include_path', ini_get('include_path') . ':' . LIB_ROOT);
#require_once('DB/DB.php');


require_once('tools.inc.php');
require_once('db_queries.inc.php');
require_once('db_getters.inc.php');
require_once('html_builders.inc.php');


// ======
// = DB =
// ======

function getDB() {
    $db = mysql_connect('127.0.0.1:3306', 'radiobot', 'radiobot');
    if (!$db || false==mysql_select_db('poolradio_org')) {
        return null;
    }
    return $db;
}

?>