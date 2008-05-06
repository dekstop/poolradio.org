<? 
require_once('../../include/app.inc.php');

$db = getDB();
if (!$db) {
  die('Could not connect: ' . mysql_error());
}

$username = getPOSTParameter('username');
if (is_null($username)) { die('no username!'); }

$result = mysql_query(
    sprintf(
        "INSERT INTO usertags_users(username) VALUES ('%s')",
        mysql_real_escape_string($username)),
    $db);

if (!$result) {
    die('Error during insert: ' . mysql_error());
}

header('Location: ./');

?>
