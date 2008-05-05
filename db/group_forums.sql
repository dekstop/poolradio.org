DROP TABLE IF EXISTS group_forums;
CREATE TABLE group_forums (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  created_at TIMESTAMP NOT NULL,

  forum_id INTEGER UNIQUE NOT NULL,
  groupname VARCHAR(200) UNIQUE
) CHARACTER SET utf8;

INSERT INTO group_forums(forum_id, groupname) VALUES (59223, 'Subscribers and their tag radio stations');
INSERT INTO group_forums(forum_id, groupname) VALUES (40095, 'Music Advice Center');
INSERT INTO group_forums(forum_id, groupname) VALUES (19636, 'netlabels');
INSERT INTO group_forums(forum_id, groupname) VALUES (74869, 'The 1 Percenters');
INSERT INTO group_forums(forum_id, groupname) VALUES (26422, 'Tag Top');
INSERT INTO group_forums(forum_id, groupname) VALUES (24779, 'Track-Tag Bitches');
INSERT INTO group_forums(forum_id, groupname) VALUES (22005, 'Genre-free tags!');
INSERT INTO group_forums(forum_id, groupname) VALUES (32175, 'We Like Playlists With Special Meaning');
INSERT INTO group_forums(forum_id, groupname) VALUES (29001, 'Obscure Music Recommendations');
INSERT INTO group_forums(forum_id, groupname) VALUES (13162, 'Next Big Things - NBTs');
INSERT INTO group_forums(forum_id, groupname) VALUES (62883, 'The Special Interest Tag Radio Collective');
