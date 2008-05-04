DROP TABLE IF EXISTS usertags_users;
CREATE TABLE usertags_users (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  created_at TIMESTAMP NOT NULL,

  username VARCHAR(200) NOT NULL,
  description VARCHAR(1000)
) CHARACTER SET utf8;

INSERT INTO usertags_users(username) VALUES('buyable');
INSERT INTO usertags_users(username) VALUES('talking_animal');
INSERT INTO usertags_users(username) VALUES('jirkanne');
INSERT INTO usertags_users(username) VALUES('Nectar_Card');
