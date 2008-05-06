<? 
require_once('../../include/app.inc.php');

$db = getDB();
if (!$db) {
  die('Could not connect: ' . mysql_error());
}

$groupname = getPOSTParameter('groupname');
if (is_null($groupname)) { die('no groupname!'); }

$forum_id = getPOSTParameter('forum_id');
if (is_null($forum_id) || !is_numeric($forum_id)) { die('no forum id!'); }

$result = mysql_query(
    sprintf(
        "INSERT INTO group_forums(groupname, forum_id) " .
        "VALUES ('%s', %d)",
        mysql_real_escape_string($groupname), 
        mysql_real_escape_string(intval($forum_id))),
    $db);

if (!$result) {
    die('Error during insert: ' . mysql_error());
}

header('Location: ./');

?>
