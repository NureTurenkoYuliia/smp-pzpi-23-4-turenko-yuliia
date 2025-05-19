<?php
session_start();
$cart = $_SESSION['cart'] ?? [];
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
        <?php if (empty($cart)): ?>
            <p><a href="index.php">Go to shopping</a></p>
        <?php else: ?>
            <form method="POST" action="remove.php">
                <table>
                    <tr style="background-color:powderblue;"><th>ID</th><th>Name</th><th>Price</th><th>Amount</th><th>Sum</th><th>Delete</th></tr>
                    <?php $total = 0; ?>
                    <?php foreach ($cart as $item): ?>
                        <tr>
                            <td><?= $item['id'] ?></td>
                            <td><?= $item['name'] ?></td>
                            <td><?= $item['price'] ?> грн</td>
                            <td><?= $item['count'] ?></td>
                            <td><?= $item['price'] * $item['count'] ?> грн</td>
                            <td>
                                <button type="submit" name="remove_id" value="<?= $item['id'] ?>" class="trash-button">
                                    <img src="delete_icon.png" alt="Видалити" class="trash-icon">
                                </button>
                            </td>
                        </tr>
                        <?php $total += $item['price'] * $item['count']; ?>
                    <?php endforeach; ?>
                    <tr><td colspan="4"><strong>Total</strong></td><td><strong><?= $total ?> грн</strong></td><td></td></tr>
                </table>
            </form>
        <?php endif; ?>
        <div class="button-group">
            <button type="submit" name="pay">Pay</button>
            <button type="submit" name="cancel">Cancel</button>
        </div>
    </main>
</body>
<?php include 'footer.php'; ?>
</html>