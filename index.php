<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: HEAD, GET, POST, PUT, PATCH, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method,Access-Control-Request-Headers, Authorization");
header('Content-Type: application/json');
$method = $_SERVER['REQUEST_METHOD'];
if ($method == "OPTIONS") {
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: HEAD, GET, POST, PUT, PATCH, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method Access-Control-Request-Headers, Authorization");
    header("HTTP/1.1 200 OK");
    die();
}
include_once './config/db.php';
include_once './vendor/autoload.php';

if (isset($_SERVER['REQUEST_URI'])) {
    $url = array_filter(explode('/', $_SERVER['REQUEST_URI']));
    if (array_key_exists('2', $url)) {
        if ($url['2'] == 'users') {
            include './routes/user.route.php';
        } else if ($url['2'] == 'news') {
            include './routes/news.route.php';
        } else if ($url['2'] == 'category') {
            include './routes/category.route.php';
        } else if ($url['2'] == 'products') {
            include './routes/product.route.php';
        } else if ($url['2'] == 'orders') {
            include './routes/order.route.php';
        } else if ($url['2'] == 'comments') {
            include './routes/comment.route.php';
        } else if ($url['2'] == 'uploads') {
            include './routes/resource.route.php';
        } else if ($url['2'] == 'address') {
            include './routes/address.route.php';
        } else if ($url['2'] == 'cart') {
            include './routes/cart.route.php';
        } else {
            http_response_code(404);
            echo json_encode(["message" => 'Not found API!!!']);
        }
    } else {
        http_response_code(404);
        echo json_encode(["message" => 'Not found API!!!']);
    }
} else {
    http_response_code(404);
    echo json_encode(["message" => 'Not found API!!!']);
}
?>