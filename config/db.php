<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PATCH, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Accept, Authorization, X-Requested-With, X-Auth-Token, Origin, Application");



class Database
{

    private $serverName;
    private $username;
    private $password;
    private $dbname;
    private $conn;
    public function __construct()
    {

        $this->conn = null;
        $this->serverName = 'localhost';
        $this->username = 'root';
        $this->dbname = 'bkzone_2022';
        $this->password = '';

    }

    public function connect()
    {
        mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
        $this->conn = mysqli_connect($this->serverName, $this->username, $this->password, $this->dbname);
        $this->conn->set_charset("utf8");
        if ($this->conn->connect_errno) {
            echo "Failed to connect to MySQL: " . $this->conn->connect_error;
            exit();
        }
        echo "Connect successfully";
        return $this->conn;
    }
}
// $conn = new Database();
// $conn->connect();