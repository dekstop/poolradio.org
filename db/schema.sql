DROP TABLE IF EXISTS events;
CREATE TABLE events (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  created_at TIMESTAMP NOT NULL,
  
  source_id INTEGER NOT NULL,
  
  username VARCHAR(200) NOT NULL,
  link VARCHAR(1024) NOT NULL,
  radiourl VARCHAR(1024) NOT NULL,
  
  title VARCHAR(100),
  message VARCHAR(1000)
) CHARACTER SET utf8;

DROP TABLE IF EXISTS sources;
CREATE TABLE sources (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(500) NOT NULL,
  description VARCHAR(1000)
) CHARACTER SET utf8;

INSERT INTO sources(id,code,name,description) values(1,'system', 'Admin\'s Choice', null);
INSERT INTO sources(id,code,name,description) values(2,'manualrecs-feed', 'Last.fm User Recommendations Feed', null);
INSERT INTO sources(id,code,name,description) values(3,'usertags', 'Last.fm User Tags', null);
INSERT INTO sources(id,code,name,description) values(4,'globaltags', 'Last.fm Global Tags', null);

INSERT INTO events(source_id,username,link,radiourl,title,message) VALUES (
  1, 'martind',
  'http://www.last.fm/listen/globaltags/doujin',
  'lastfm://globaltags/doujin',
  'doujin Tag Radio',
  'Hey, I think you might like the doujin Tag Radio radio, check it out.'
);
INSERT INTO events(source_id,username,link,radiourl,title,message) VALUES (
  1, 'martind',
  'http://www.last.fm/group/Underground+hip+hop',
  'lastfm://group/Underground+hip+hop',
  'Underground hip hop group radio',
  'Hey, I think you might like the Underground hip hop group radio, check it out.'
);
INSERT INTO events(source_id,username,link,radiourl,title,message) VALUES (
  1, 'martind',
  'http://www.last.fm/music/Alva%2BNoto%2B%252B%2BRyuichi%2BSakamoto',
  'lastfm://artist/Alva%2BNoto%2B%252B%2BRyuichi%2BSakamoto/similarartists',
  'Alva Noto + Ryuichi Sakamoto',
  'Hey, I think you might like Alva Noto + Ryuichi Sakamoto, check it out.'
);
  