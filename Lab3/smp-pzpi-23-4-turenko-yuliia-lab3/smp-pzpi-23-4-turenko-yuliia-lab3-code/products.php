<?php
session_start();

$products = [
    1 => ["name" => "Pasteurized Milk", "price" => 12],
    2 => ["name" => "Black Bread", "price" => 9],
    3 => ["name" => "White Cheese", "price" => 21],
    4 => ["name" => "Sour Cream 20%", "price" => 25],
    5 => ["name" => "Kefir 1%", "price" => 19],
    6 => ["name" => "Sparkling Water", "price" => 18],
    7 => ["name" => "Cookies \"Весна\"", "price" => 14],
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    foreach ($products as $id => $product) {
        if (isset($_POST["count_$id"]) && (int)$_POST["count_$id"] > 0) {
            $_SESSION['cart'][$id] = [
                'id' => $id,
                'name' => $product['name'],
                'price' => $product['price'],
                'count' => (int)$_POST["count_$id"],
            ];
        }
    }
    header('Location: basket.php');
    exit;
}
include 'header.php'; ?>
<!DOCTYPE html>
<html lang="uk">
<head>
    <meta charset="UTF-8">
    <title>Shop</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <main>
    <h1>Products</h1>
        <form method="POST" action="products.php">
            <table>
                <tr style="background-color:powderblue;"><th>Name</th><th>Price</th><th>Amount</th></tr>
                <?php foreach ($products as $id => $product): ?>
                <tr>
                    <td><?= $product['name'] ?></td>
                    <td><?= $product['price'] ?> грн</td>
                    <td><input type="number" name="count_<?= $id ?>" min="0" value="0"></td>
                </tr>
                <?php endforeach; ?>
            </table>
            <button type="submit">Buy</button>
        </form>
    </main>
</body>
<?php include 'footer.php'; ?>
</html>