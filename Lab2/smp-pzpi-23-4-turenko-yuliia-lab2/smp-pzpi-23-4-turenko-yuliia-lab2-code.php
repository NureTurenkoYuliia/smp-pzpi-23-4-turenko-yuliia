<?php

$products = [
    ["name" => "Молоко пастеризоване", "price" => 12],
    ["name" => "Хліб чорний", "price" => 9],
    ["name" => "Сир білий", "price" => 21],
    ["name" => "Сметана 20%", "price" => 25],
    ["name" => "Кефір 1%", "price" => 19],
    ["name" => "Вода газована", "price" => 18],
    ["name" => "Печиво \"Весна\"", "price" => 14],
];

$cart = [];
$user = ["name" => "", "age" => 0];

function menu() {
    echo "\n################################\n";
    echo "# ПРОДОВОЛЬЧИЙ МАГАЗИН \"ВЕСНА\" #\n";
    echo "################################\n";
    echo "1 Вибрати товари\n";
    echo "2 Отримати підсумковий рахунок\n";
    echo "3 Налаштувати свій профіль\n";
    echo "0 Вийти з програми\n";
    echo "Введіть команду: ";
}

function my_strlen($str) {
    return preg_match_all("/./u", $str, $matches);
}

function my_pad($str, $length, $padChar = ' ') {
    $strLen = my_strlen($str);
    return $str . str_repeat($padChar, max(0, $length - $strLen));
}

function showProducts($products) {
    echo my_pad("№", 2) . my_pad("НАЗВА", 22) . my_pad("ЦІНА", 4) . PHP_EOL;
    $i = 1;
    foreach ($products as $product) {
        echo my_pad($i++, 2) .
             my_pad($product["name"], 22) .
             my_pad($product["price"], 4) . PHP_EOL;
    }

    echo "   -----------\n";
    echo "0  ПОВЕРНУТИСЯ\n";
    echo "Виберіть товар: ";
}

function showCart($cart) {
    if (empty($cart)) {
        echo "\nКОШИК ПОРОЖНІЙ\n";
        return;
    }

    echo "\nУ КОШИКУ:\n". my_pad("НАЗВА", 22) . my_pad("КІЛЬКІСТЬ", 4) . PHP_EOL;
    foreach ($cart as $name => $qty) {
        echo my_pad($name, 22) .  my_pad($qty, 4) . PHP_EOL;
    }
}

function buyProducts(&$products, &$cart) {
    while (true) {
        showProducts($products);
        $choice = trim(fgets(STDIN));
        if ($choice === "0") return;

        if (!isset($products[(int)$choice - 1])) {
            echo "\nПОМИЛКА! ВКАЗАНО НЕПРАВИЛЬНИЙ НОМЕР ТОВАРУ\n";
            continue;
        }

        $product = $products[(int)$choice - 1];
        echo "\nВибрано: {$product['name']}\n";
        echo "Введіть кількість, штук: ";
        $qty = trim(fgets(STDIN));
        if (!is_numeric($qty) || (int)$qty < 0 || (int)$qty > 99) {
            echo "ПОМИЛКА! Введіть кількість від 0 до 99\n";
            continue;
        }

        $qty = (int)$qty;
        if ($qty === 0) {
            echo "ВИДАЛЯЮ З КОШИКА\n";
            unset($cart[$product['name']]);
        } else {
            $cart[$product['name']] = $qty;
        }

        showCart($cart);
    }
}

function showBill($cart, $products) {
    if (empty($cart)) {
        echo "\nКОШИК ПОРОЖНІЙ\n";
        return;
    }

    echo my_pad("№", 2) . my_pad("НАЗВА", 22) . my_pad("ЦІНА", 5) . my_pad("КІЛЬКІСТЬ", 10) . my_pad("ВАРТІСТЬ", 9) . PHP_EOL;
    $i = 1;
    $total = 0;
    foreach ($cart as $name => $qty) {
        $price = 0;
        foreach ($products as $p) {
            if ($p['name'] === $name) {
                $price = $p['price'];
                break;
            }
        }
        $sum = $price * $qty;
        $total += $sum;
        echo my_pad($i++, 2) . my_pad($name, 22) . my_pad($price, 5) . my_pad($qty, 10) . my_pad($sum, 9) . PHP_EOL;
    }

    echo "\nРАЗОМ ДО CПЛАТИ: $total\n";
}

function setProfile(&$user) {
    while (true) {
        echo "\nВаше імʼя: ";
        $name = trim(fgets(STDIN));

        if ($name === '') {
            echo "ПОМИЛКА! Імʼя не може бути порожнім\n";
            continue;
        }

        if (preg_match('/^[a-zA-Zа-яА-ЯіІїЇєЄ\'\-\s]+$/u', $name)) {
            $user['name'] = $name;
            break;
        } else {
            echo "ПОМИЛКА! Імʼя повинно містити лише літери\n";
        }
    }
    while (true) {
        echo "Ваш вік: ";
        $age = trim(fgets(STDIN));
        if (is_numeric($age) && $age >= 7 && $age <= 150) {
            $user['age'] = (int)$age;
            break;
        }
        
        echo "ПОМИЛКА! Вік повинен бути від 7 до 150\n";
    }
}

while (true) {
    menu();
    $input = trim(fgets(STDIN));
    switch ($input) {
        case "1":
            buyProducts($products, $cart);
            break;
        case "2":
            showBill($cart, $products);
            break;
        case "3":
            setProfile($user);
            break;
        case "0":
            echo "До побачення!\n";
            exit;
        default:
            echo "ПОМИЛКА! Введіть правильну команду\n";
    }
}