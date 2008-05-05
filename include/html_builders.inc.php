<?
function build_station_html($row) {
    $html = '<div class="' . htmlspecialchars($row['source']) . '">' .
        '<div class="header"><a href="' . htmlspecialchars($row['radiourl']) . '" class="radiourl">' .
        htmlspecialchars($row['title'] ? $row['title'] : $row['radiourl']) . '</a></div> ' .
        '<div class="body"><span class="message"><a href="' . htmlspecialchars($row['link']) . '">' . htmlspecialchars($row['message']) . '</a></span>';
    if (strcasecmp(LASTFM_USERNAME, $row['username']) != 0) {
        $html .= ' by <a href="http://www.last.fm/user/' . urlencode($row['username']) . '">' .
        htmlspecialchars($row['username']) . '</a> ';
    }
    $html .= '</div> ' .
        '<div class="footer"><span class="source">' . htmlspecialchars($row['source_name']) . '</span> <span class="date">' . date('Y-m-d H:i', $row['date']) . '</span></div>';
    if (array_key_exists('wikipedia_link', $row)) {
        $html .= '<div class="context"><span class="description">' .
        '<a href="' . htmlspecialchars($row['wikipedia_link']) . '" ' .
        'title="' . htmlspecialchars($row['wikipedia_title']) . '">' . 
        htmlspecialchars($row['wikipedia_description']) . '</a></span>' . 
        '</div> ';
    }
    $html .= "</div>";
    return $html;
}

# caution: each item will get urlencoded
function build_link_sequence_html($link_prefix, $items) {
    $links = array();
    foreach ($items as $item) {
        $links[] = 
            '<a href="' . $link_prefix . urlencode($item) . '">' . htmlspecialchars($item) . '</a>';
    }
    return implode(', ', $links);
}

?>