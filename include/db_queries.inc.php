<?
#
# these functions return mysql result handles
#

function _build_query($sql_suffix) {
    return "SELECT " .
        "s.code AS source, s.name AS source_name, UNIX_TIMESTAMP(e.created_at) AS date, e.username AS username, e.link AS link, " .
        "e.radiourl AS radiourl, e.title AS title, e.message AS message, " .
        "w.link AS wikipedia_link, w.title AS wikipedia_title, w.description AS wikipedia_description " .
        "FROM events e INNER JOIN sources s ON s.id=e.source_id " .
        "LEFT OUTER JOIN wikipedia_descriptions w ON e.id=w.event_id " .
        $sql_suffix;
}

# may return less than $num when rows were deleted -- it's a tradeoff for speed
function query_for_random($num=10) {
    $range_result = mysql_query("SELECT MIN(id) AS min, MAX(id) AS max FROM events");
    $range_row = mysql_fetch_assoc($range_result);
    if ($range_row['max']-$range_row['min'] < $num) {
        # not enough rows in table -> oldschool way
        $query = _build_query(
            sprintf("ORDER BY RAND() LIMIT %d", mysql_real_escape_string($num)));
    }
    else {
        $ids = array();
        while (count($ids) < $num) {
            $ids[] = mt_rand($range_row['min'], $range_row['max']);
            $ids = array_unique($ids);
        }
        $query = _build_query(
            sprintf("WHERE e.id IN (%s) ORDER BY RAND()", implode(', ', $ids)));
    }
    
    return mysql_query($query);
}

# will return null when no entries match
function query_for_random_latest($num=10, $cutoff_in_hours=24) {
    $id_result = mysql_query(
        sprintf("SELECT id FROM events WHERE created_at > subtime(now(), '%s') ",
            mysql_real_escape_string(intval($cutoff_in_hours) . ':0:0.0')));
    $recent_ids = array();
    while ($row = mysql_fetch_assoc($id_result)) {
        $recent_ids[] = $row['id'];
    }
    if (count($recent_ids)==0) {
        return null;
    }
    else if (count($recent_ids) <= $num) {
        $ids = $recent_ids;
    }
    else {
        $indices = array_rand($recent_ids, $num);
        $ids = array();
        foreach ($indices as $idx) {
            $ids[] = $recent_ids[$idx];
        }
    }
    $query = _build_query(
        sprintf("WHERE e.id IN (%s)", implode(', ', $ids)));
    return mysql_query($query);
}

# will return null when no entries match
function query_for_latest($num=10, $cutoff_in_hours=24) {
    $id_result = mysql_query(
        sprintf("SELECT id FROM events WHERE created_at > subtime(now(), '%s') ".
            "ORDER BY id DESC LIMIT %d",
            mysql_real_escape_string(intval($cutoff_in_hours) . ':0:0.0'),
            $num));
    $ids = array();
    while ($row = mysql_fetch_assoc($id_result)) {
        $ids[] = $row['id'];
    }
    if (count($ids)==0) {
        return null;
    }
    $query = _build_query(
        sprintf("WHERE e.id IN (%s) ORDER BY e.id DESC", implode(', ', $ids)));
    return mysql_query($query);
}
?>