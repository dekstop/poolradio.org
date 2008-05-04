<? header("Content-Type: application/rss+xml"); ?>
<? print '<?xml version="1.0" encoding="utf-8"?>'; ?>
<? include '../include/app.inc.php' ?>
<rss version="2.0" 
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:wfw="http://wellformedweb.org/CommentAPI/"
    xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>pool radio: Last.fm radio stations</title>
    <link><?= HOMEPAGE_URL ?></link>
    <description>...</description>
    <lastBuildDate><?= date('r') ?></lastBuildDate>
    <generator>MicroLinks 5.6 (dekstop.de)</generator>
    <atom:link href="<?= FEED_URL ?>" rel="self" type="application/rss+xml" />
<?
$db = getDB();
if (!$db) {
    die('Could not connect: ' . mysql_error());
}
$result = query_for_latest(10);
while ($row = mysql_fetch_assoc($result)) {
?>
    <item>
      <title><?= $row['title'] ? $row['title'] : $row['radiourl'] ?></title>
      <link><?= $row['link'] ?></link> 
      <description><![CDATA[ 
        <p>Radio URL: <a href="<?= $row['radiourl'] ?>"><?= htmlspecialchars($row['radiourl']) ?></a></p> 
        <p>By: <a href="http://last.fm/user/<?= $row['username'] ?>"><?= htmlspecialchars($row['username']) ?></a></p> 
        <p><?= $row['message'] ?></p>
        ]]></description>
      <dc:creator><?= $row['username'] ?></dc:creator>
      <category><?= $row['source'] ?></category>
      <guid isPermaLink="false"><?= HOMEPAGE_URL . ' | ' . md5($row['link'] . $row['date']) ?></guid>
      <pubDate><?= date('r', $row['date']) ?></pubDate>
    </item>
<?
}
mysql_close($db);
?>
  </channel>
</rss>
