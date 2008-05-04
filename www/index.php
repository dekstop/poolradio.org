<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<? include '../include/app.inc.php' ?>
<?
$db = getDB();
if (!$db) {
  die('Could not connect: ' . mysql_error());
}
?>

<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>pool radio: Last.fm radio stations</title>
  <meta name="generator" content="MicroLink 5.61">

  <link rel="stylesheet" href="styles.css" type="text/css">
  <link rel="alternate" type="application/rss+xml" title="RSS" href="<?= FEED_URL ?>">
</head>
<body>

<table>
<tr>
  <td valign="top">  
    <div class="stations">
    <?
    $result = query_for_random(10);
    while ($row = mysql_fetch_assoc($result)) {
    ?>
    <p><?= build_station_html($row) ?></p>
    <?
    }
    ?>
    </div></td>
  <td valign="top">
	<p>Recommend great Last.fm tag radio stations to <a href="http://last.fm/user/poolradio/">poolradio</a>.<br/>
	<span class="credits"><a href="http://martin.dekstop.de/">martind</a> 2k8</span></p>

    <?
    $result = query_for_latest(10, 24);
	if (mysql_num_rows($result) > 0) {
	?>
	<h3>Recently Added</h3>
    <div style="font-size:0.7em" class="stations">
	<?
    	while ($row = mysql_fetch_assoc($result)) {
    ?>
    <p><?= build_station_html($row) ?></p>
    <?
    	}
	}
    ?>
    </div></td>
</tr>
</table>
<?
mysql_close($db);
?>

</body>
</html>