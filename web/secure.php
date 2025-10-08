<?php
$mysqli = new mysqli("db", "demo", "demopass", "sqli_demo");
if($mysqli->connect_error) die("db error");

if($_SERVER['REQUEST_METHOD'] === 'POST'){
    $u = $_POST['username'] ?? '';
    $p = $_POST['password'] ?? '';

    // Prepared statement로 쿼리 보호
    $stmt = $mysqli->prepare("SELECT id, username FROM users WHERE username = ? AND password = ? LIMIT 1");
    $stmt->bind_param("ss", $u, $p);
    $stmt->execute();
    $res = $stmt->get_result();
    if($res && $res->num_rows === 1){
        $row = $res->fetch_assoc();
        echo "Login success: " . htmlspecialchars($row['username']);
    } else {
        echo "Login failed";
    }
    $stmt->close();
    exit;
}
?>
<form method="post">
<input name="username" placeholder="username">
<input name="password" placeholder="password">
<button>Login</button>
</form>
