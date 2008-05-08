<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<? include '../../include/app.inc.php' ?>
<?
$db = getDB();
if (!$db) {
    die('Could not connect: ' . mysql_error());
}
?>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>pool radio admin</title>
    <meta name="generator" content="MicroLink 5.61">

    <link rel="stylesheet" href="../styles.css" type="text/css">
</head>
<body>

<table id="main">
<tr>
    <td valign="top" class="left">
        <h2>Add User</h2>

        <form action="add_user.php" method="POST" accept-charset="utf-8">

        <table border="0">
        <tr>
            <td>Username:</td>
            <td><input type="text" name="username" value=""></td>
        </tr>
        </table>
        <p> 
        </p>

        <p><input type="submit" value="Add"></p>
        </form>


        <h2>Add Group Forum</h2>

        <form action="add_groupforum.php" method="POST" accept-charset="utf-8">

        <table border="0">
        <tr>
            <td>Group Name:</td>
            <td><input type="text" name="groupname" value=""></td>
        </tr>
        <tr>
            <td>Forum ID:</td>
            <td><input type="text" name="forum_id" value=""></td>
        </tr>
        </table>
        <p> 
        </p>

        <p><input type="submit" value="Add"></p>
        </form>
        
        
        <h2>Add Entry</h2>
        <?
        $sources = get_all_sources();
        ?>

        <form action="add_entry.php" method="POST" accept-charset="utf-8">

        <table border="0">
        <tr>
            <td>Source:</td>
            <td><select name="source_id">
                <? foreach ($sources as $source) { ?>
                    <option value="<?= htmlspecialchars($source['id']) ?>"><?= htmlspecialchars($source['name']) ?></option>
                <? } ?>
                </select></td>
        </tr>
        <tr>
            <td>Title:</td>
            <td><input type="text" name="title" value=""></td>
        </tr>
        <tr>
            <td>Radiourl:</td>
            <td><input type="text" name="radiourl" value=""></td>
        </tr>
        <tr>
            <td>Link:</td>
            <td><input type="text" name="link" value=""></td>
        </tr>
        <tr>
            <td>Username:</td>
            <td><input type="text" name="username" value=""></td>
        </tr>
        <tr>
            <td>Message:</td>
            <td><input type="text" name="message" value=""></td>
        </tr>
        </table>
        <p> 
        </p>

        <p><input type="submit" value="Add"></p>
        </form></td>
    
    <td valign="top" class="right">        
        <?
        $result = query_for_latest(50, 9999999);
        if ($result) {
            if (mysql_num_rows($result) > 0) {
        ?>
        <h3>Recently Added</h3>
        <ul class="stations">
        <?
                while ($row = mysql_fetch_assoc($result)) {
        ?>
            <li><?= build_station_html($row) ?></li>
        <?
                }
            }
        }
        ?>
        </ul>
        </td>
</tr>
</table>


<?
mysql_close($db);
?>

</body>
</html>
