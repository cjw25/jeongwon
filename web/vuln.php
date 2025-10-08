<?php
// vuln.php : 취약한 로그인 (문제: 입력을 그대로 쿼리에 붙임)
$mysqli = new mysqli("db", "demo", "demopass", "sqli_demo");
if($mysqli->connect_error) die("db error");

if($_SERVER['REQUEST_METHOD'] === 'POST'){
    $u = $_POST['username'] ?? '';
    $p = $_POST['password'] ?? '';
    // **취약 코드**: 사용자 입력을 직접 문자열에 삽입
    $sql = "SELECT * FROM users WHERE username = '$u' AND password = '$p' LIMIT 1";
    $res = $mysqli->query($sql);
    if($res && $res->num_rows === 1){
        echo "Login success: " . htmlspecialchars($u);
    } else {
        echo "Login failed";
    }
    exit;
}
?>
<form method="post">
<input name="username" placeholder="username">
<input name="password" placeholder="password">
<button>Login</button>
</form>
