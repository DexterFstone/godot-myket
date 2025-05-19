<p align="center"> <img src="https://myket.ir/core/images/logo/icon.svg" width="256" height="256"> </p>

<h1 align="center"> گودو مایکت </h1>

<p align="center">  پلاگین مایکت برای موتور بازی سازی گودو </p>

این پلاگین امکان یکپارچه‌سازی آسان با سرویس پرداخت درون‌برنامه‌ای مایکت را در پروژه‌های گودو فراهم می‌کند. با استفاده از این پلاگین، می‌توانید به سادگی قابلیت خرید محصولات مجازی، دریافت اطلاعات آن‌ها و مصرف آن‌ها را به بازی یا برنامه خود اضافه کنید.

**فهرست مطالب:**

* [ویژگی‌ها](#ویژگی‌ها)
* [نصب](#نصب)
* [استفاده](#استفاده)
    * [پیکربندی](#پیکربندی)
    * [اتصال به مایکت](#اتصال-به-مایکت)
    * [دریافت اطلاعات محصولات (Query Inventory)](#دریافت-اطلاعات-محصولات-query-inventory)
    * [شروع فرآیند خرید](#شروع-فرآیند-خرید)
    * [مصرف محصول](#مصرف-محصول)
    * [قطع اتصال از مایکت](#قطع-اتصال-از-مایکت)
* [سیگنال‌ها](#سیگنال‌ها)
* [کلاس `Intent`](#کلاس-intent)

## ویژگی‌ها

* اتصال آسان به سرویس مایکت.
* دریافت اطلاعات محصولات درون‌برنامه‌ای (شامل جزئیات و خریدهای کاربر).
* شروع فرآیند خرید محصولات.
* مصرف محصولات یک‌بار مصرف.
* امکان باز کردن صفحات مختلف مایکت از طریق Intent (صفحه نظرات، جزئیات برنامه، صفحه دانلود و صفحه توسعه‌دهنده).

## نصب

1.  پوشه `myket` موجود در این ریپو را به پوشه `addons` پروژه گودو خود کپی کنید.
2.  در ویرایشگر گودو، به `Project > Project Settings > Plugins` بروید و پلاگین `Myket` را فعال کنید.

## استفاده

### پیکربندی

1.  یک نود از نوع `Myket` به صحنه دلخواه خود اضافه کنید.
2.  در پنل Inspector نود `Myket`، مقدار متغیر `Public Key` را با کلید عمومی برنامه خود در مایکت تنظیم کنید.

### اتصال به مایکت

اتصال به مایکت به صورت خودکار هنگام آماده شدن نود (`_ready`) انجام می‌شود. همچنین می‌توانید با فراخوانی متد `connect_to_myket(public_key: String = "")` به صورت دستی این کار را انجام دهید.

```gdscript
var myket_node = get_node("Myket")

func _ready():
	myket_node.connection_succeed.connect(_on_connected)
	myket_node.connection_failed.connect(_on_connection_failed)

func _on_connected():
	print("Myket: با موفقیت متصل شد.")

func _on_connection_failed(message: String):
	printerr("Myket: خطا در اتصال - ", message)
```

### دریافت اطلاعات محصولات (Query Inventory)

از متد `query_inventory_async(refresh: bool, skus: Array[String])` برای دریافت لیست محصولات قابل فروش و خریدهای کاربر استفاده کنید.

```gdscript
func fetch_inventory(skus: Array[String]):
	var myket_node = get_node("Myket")
	myket_node.query_inventory_finished.connect(_on_inventory_received)
	myket_node.query_inventory_failed.connect(_on_inventory_failed)
	myket_node.query_inventory_async(true, skus)

func _on_inventory_received(is_success: bool, message: String, inventory: Inventory):
	if is_success:
		print("Myket: اطلاعات محصولات دریافت شد.")
		for purchase in inventory.purchases:
			print("خرید: ", purchase.sku, " - وضعیت: ", purchase.purchase_state)
		for detail in inventory.sku_details:
			print("جزئیات محصول: ", detail.sku, " - قیمت: ", detail.price)
	else:
		printerr("Myket: خطا در دریافت اطلاعات محصولات - ", message)

func _on_inventory_failed(message: String):
	printerr("Myket: خطا در دریافت اطلاعات محصولات - ", message)

# مثال استفاده:
func _ready():
	fetch_inventory(["sku_item_1", "sku_item_2"])
```

### شروع فرآیند خرید

برای شروع فرآیند خرید یک محصول، از متد `launch_purchase_flow(sku: String, developer_payload: String = "")` استفاده کنید.

```gdscript
func purchase_item(sku: String, developer_payload: String = ""):
	var myket_node = get_node("Myket")
	myket_node.iab_purchase_finished.connect(_on_purchase_success)
	myket_node.iab_purchase_failed.connect(_on_purchase_failed)
	myket_node.launch_purchase_flow(sku, developer_payload)

func _on_purchase_success(is_success: bool, message: String, purchase: Purchase):
	if is_success:
		print("Myket: خرید موفقیت‌آمیز بود - ", purchase.order_id)
		# اعطای محصول به کاربر
	else:
		printerr("Myket: خطا در خرید - ", message)

func _on_purchase_failed(message: String):
	printerr("Myket: خطا در خرید - ", message)

# مثال استفاده:
func on_buy_button_pressed(product_sku):
	purchase_item(product_sku)
```

### مصرف محصول

برای مصرف یک محصول خریداری شده (محصولات یک‌بار مصرف)، از متد `consume_async(purchase: Purchase)` استفاده کنید.

```gdscript
func consume_item(purchase_data: Purchase):
	var myket_node = get_node("Myket")
	myket_node.consume_finished.connect(_on_consume_success)
	myket_node.consume_failed.connect(_on_consume_failed)
	myket_node.consume_async(purchase_data)

func _on_consume_success(is_success: bool, message: String, purchase: Purchase):
	if is_success:
		print("Myket: مصرف محصول موفقیت‌آمیز بود.")
	else:
		printerr("Myket: خطا در مصرف محصول - ", message)

func _on_consume_failed(message: String):
	printerr("Myket: خطا در مصرف محصول - ", message)

# مثال استفاده (فرض بر اینکه یک شیء Purchase در دسترس دارید):
func process_purchase_for_consumption(purchase: Purchase):
	consume_item(purchase)
```

### قطع اتصال از مایکت

برای قطع اتصال از سرویس مایکت و آزادسازی منابع، از متد `disconnect_from_myket()` استفاده کنید.

```gdscript
func disconnect_myket_service():
	var myket_node = get_node("Myket")
	myket_node.disconnect_from_myket()
	print("Myket: اتصال قطع شد.")
```

## سیگنال‌ها

* سیگنال `connection_succeed`: بدون پارامتر. هنگامی که اتصال به مایکت با موفقیت برقرار شود، این سیگنال منتشر می‌شود.
* `connection_failed(message: String)`: پارامتر `message` از نوع `String`. در صورت بروز خطا در اتصال به مایکت، این سیگنال به همراه پیام خطا منتشر می‌شود.
* سیگنال `query_inventory_finished(is_success: bool, message: String, inventory: Inventory)`: پارامتر `inventory` از نوع `Inventory`. پس از دریافت اطلاعات محصولات و خریدهای کاربر، این سیگنال منتشر می‌شود.
* سیگنال `query_inventory_failed(message: String)`: پارامتر `message` از نوع `String`. در صورت بروز خطا در دریافت اطلاعات محصولات، این سیگنال به همراه پیام خطا منتشر می‌شود.
* سیگنال `iab_purchase_finished(is_success: bool, message: String, purchase: Purchase)`: پارامتر `purchase` از نوع `Purchase`. پس از تکمیل موفقیت‌آمیز فرآیند خرید، این سیگنال منتشر می‌شود.
* سیگنال `iab_purchase_failed(message: String)`: پارامتر `message` از نوع `String`. در صورت بروز خطا در فرآیند خرید، این سیگنال به همراه پیام خطا منتشر می‌شود.
* سیگنال `consume_finished(is_success: bool, message: String, purchase: Purchase)`: پارامتر `purchase` از نوع `Purchase`. پس از مصرف موفقیت‌آمیز یک محصول، این سیگنال منتشر می‌شود.
* سیگنال `consume_failed(message: String)`: پارامتر `message` از نوع `String`. در صورت بروز خطا در فرآیند مصرف محصول، این سیگنال به همراه پیام خطا منتشر می‌شود.

## کلاس `Intent`

کلاس `Intent` شامل متدهای استاتیک برای باز کردن صفحات مختلف اپلیکیشن مایکت از طریق Intent است:

* متد `show_comment(package_name: String = "")`: پارامتر `package_name` از نوع `String`. باز کردن صفحه نظرات برنامه با نام بسته مشخص.
* متد `show_details(package_name: String = "")`: پارامتر `package_name` از نوع `String`. باز کردن صفحه جزئیات برنامه با نام بسته مشخص.
* متد `show_download(package_name: String = "")`: پارامتر `package_name` از نوع `String`. باز کردن صفحه دانلود برنامه با نام بسته مشخص.
* متد `show_developer(package_name: String = "")`: پارامتر `package_name` از نوع `String`. باز کردن صفحه توسعه‌دهنده با نام بسته مشخص.

```gdscript
func _on_rate_button_pressed():
	Myket.Intent.show_comment() # استفاده از نام بسته فعلی

func _on_view_details_button_pressed():
	Myket.Intent.show_details()

func _on_other_app_button_pressed(developer_package: String):
	Myket.Intent.show_developer(developer_package)
```

آیا منظور شما به این شکل بود؟ من سعی کردم تا حد امکان نوع پارامترها را در مثال‌های کد مشخص کنم.
