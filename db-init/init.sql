CREATE DATABASE IF NOT EXISTS sqli_demo;
USE sqli_demo;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  password VARCHAR(100) NOT NULL
);

-- 샘플 계정 (주의: 교육용으로 평문 비밀번호)
INSERT INTO users (username, password) VALUES ('alice','alicepass'), ('bob','bobpass');

-- 최소 권한 계정(선택)
CREATE USER IF NOT EXISTS 'readonly'@'%' IDENTIFIED BY 'ro_pass';
GRANT SELECT ON sqli_demo.* TO 'readonly'@'%';
FLUSH PRIVILEGES;
