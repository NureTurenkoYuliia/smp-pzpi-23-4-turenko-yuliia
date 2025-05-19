<?php
session_start();

if (isset($_POST['remove_id'])) {
    $removeId = $_POST['remove_id'];
    foreach ($_SESSION['cart'] as $key => $item) {
        if ($item['id'] == $removeId) {
            unset($_SESSION['cart'][$key]);
            break;
        }
    }

    if (empty($_SESSION['cart'])) {
        unset($_SESSION['cart']);
    }
}

header('Location: basket.php');
exit;