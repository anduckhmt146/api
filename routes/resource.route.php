<?php
include_once(dirname(__FILE__) . '/../controllers/resource.controller.php');
include_once(dirname(__FILE__) . '/../middleware/auth.php');

$url = array_filter(explode('/', $_SERVER['REQUEST_URI']));

$method = $_SERVER['REQUEST_METHOD'];
session_start();
if (array_key_exists('3', $url)) {
    // Get Resources with name
    if ($method == 'GET') {
        try {
            echo $url['3'];
            echo ResourceController::getResource($url['3']);
            http_response_code(200);
        } catch (CustomError $e) {
            echo json_encode(['msg' => $e->getMessage()]);
            http_response_code($e->getStatusCode());
        }
    } else {

        http_response_code(404);
        echo json_encode(["msg" => 'Not found API!!!']);
    }
} else {
    if ($method == 'POST') {
        try {
            echo ResourceController::editResource();
            http_response_code(200);
        } catch (CustomError $e) {
            echo json_encode(['msg' => $e->getMessage()]);
            http_response_code($e->getStatusCode());
        }
    } else {
        http_response_code(404);
        echo json_encode(["msg" => 'Not found API!!!']);
    }

}
session_destroy();
?>