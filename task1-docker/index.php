<?php
// DB connection settings come from environment variables so the same
// image works with docker run --env or docker-compose.
$host = getenv('DB_HOST') ?: 'mysql';
$user = getenv('DB_USER') ?: 'root';
$pass = getenv('DB_PASSWORD') ?: 'rootpassword';
$db   = getenv('DB_NAME') ?: 'lampdb';

$conn = @mysqli_connect($host, $user, $pass, $db);

echo "<h1>LAMP Stack Demo</h1>";

if (!$conn) {
    echo "<p style='color:red;'>Hello, World! MySQL connection FAILED: "
         . htmlspecialchars(mysqli_connect_error()) . "</p>";
} else {
    echo "<p style='color:green;'>Hello, World! Your MySQL connection is successful.</p>";
    echo "<p>Connected to database: " . htmlspecialchars($db) . " on host: " . htmlspecialchars($host) . "</p>";
    mysqli_close($conn);
}
