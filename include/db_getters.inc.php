<?
#
# these functions return data sets
#

# returns a list of usernames
function get_usertags_users() {
    $handle = mysql_query("SELECT username FROM usertags_users ORDER BY UCASE(username) ASC");
    $result = array();
    while ($row = mysql_fetch_assoc($handle)) {
        $result[] = $row['username'];
    }
    return $result;
}

# returns a list of group names
function get_groupforum_groups() {
    $handle = mysql_query("SELECT groupname FROM group_forums ORDER BY UCASE(groupname) ASC");
    $result = array();
    while ($row = mysql_fetch_assoc($handle)) {
        $result[] = $row['groupname'];
    }
    return $result;
}
?>