<?
function query_for_random($num=10) {
	$query = sprintf("SELECT " .
		"s.name AS source, UNIX_TIMESTAMP(e.created_at) AS date, e.username AS username, e.link AS link, " .
		"e.radiourl AS radiourl, e.title AS title, e.message AS message, " .
		"w.link AS wikipedia_link, w.title AS wikipedia_title, w.description AS wikipedia_description " .
		"FROM events e INNER JOIN sources s ON s.id=e.source_id " .
		"LEFT OUTER JOIN wikipedia_descriptions w ON e.id=w.event_id " .
		"ORDER BY RAND() LIMIT %d",
		mysql_real_escape_string($num));
	
	return mysql_query($query);
}

function query_for_latest($num=10, $cutoff_in_hours=24) {
	$query = sprintf("SELECT " .
		"s.name AS source, UNIX_TIMESTAMP(e.created_at) AS date, e.username AS username, e.link AS link, " .
		"e.radiourl AS radiourl, e.title AS title, e.message AS message, " .
		"w.link AS wikipedia_link, w.title AS wikipedia_title, w.description AS wikipedia_description " .
		"FROM events e INNER JOIN sources s ON s.id=e.source_id " .
		"LEFT OUTER JOIN wikipedia_descriptions w ON e.id=w.event_id " .
		"WHERE e.created_at > subtime(now(), '%s') " .
		"ORDER BY e.created_at DESC LIMIT %d",
		mysql_real_escape_string(intval($cutoff_in_hours) . ':0:0.0'),
		mysql_real_escape_string($num));
	return mysql_query($query);
}
?>