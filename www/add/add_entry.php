<? 
require_once('../../include/app.inc.php');

$db = getDB();
if (!$db) {
  die('Could not connect: ' . mysql_error());
}

$source_id = getPOSTParameter('source_id');
if (is_null($source_id) || !is_numeric($source_id)) { die('no source id!'); }

$title = getPOSTParameter('title');
if (is_null($title)) { die('no title!'); }

$radiourl = getPOSTParameter('radiourl');
if (is_null($radiourl)) { die('no radiourl!'); }

$link = getPOSTParameter('link');
if (is_null($link)) { die('no link!'); }

$username = getPOSTParameter('username');
if (is_null($username)) { die('no username!'); }

$message = getPOSTParameter('message');
if (is_null($message)) { die('no message!'); }

$result = mysql_query(
    sprintf(
        "INSERT INTO events(source_id, title, radiourl, link, username, message) " .
        "VALUES (%d, '%s', '%s', '%s', '%s', '%s')",
        mysql_real_escape_string(intval($source_id)), 
        mysql_real_escape_string($title), 
        mysql_real_escape_string($radiourl), 
        mysql_real_escape_string($link), 
        mysql_real_escape_string($username), 
        mysql_real_escape_string($message)),
    $db);

if (!$result) {
    die('Error during insert: ' . mysql_error());
}

header('Location: ./');

?>
