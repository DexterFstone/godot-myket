# راهنمای استفاده از Godot Myket Plugin 

این پلاگین برای یکپارچه‌سازی سرویس خرید درون‌برنامه‌ای Myket با Godot استفاده می‌شود.
نسخه **4.5.0** پلاگین، تمام متدها را به صورت **static** ارائه می‌دهد و پاسخ‌ها از طریق `Callable` مدیریت می‌شوند.

## ایجاد اتصال به Myket

برای برقراری اتصال با Myket و آماده‌سازی برای عملیات خرید:

```gdscript
Myket.open_connection(PUBLIC_KEY,
    func connection_succeed() -> void:
        # اتصال موفق
    func connection_failed(message: String) -> void:
        # اتصال ناموفق
)
```

## استعلام موجودی و محصولات

برای دریافت اطلاعات محصولات و خریدهای کاربر:

```gdscript
Myket.query_inventory_async(QUERY_SKU_DETAILS, ITEM_SKUS,
    func query_inventory_finished(is_success: bool, message: String, inventory: Myket.Inventory) -> void:
        # استعلام موفق
    func query_inventory_failed(message: String) -> void:
        # استعلام ناموفق
)
```

## راه‌اندازی خرید درون‌برنامه‌ای

برای خرید یک محصول:

```gdscript
Myket.launch_purchase_flow(SKU, PAYLOAD,
    func iab_purchase_finished(is_success: bool, message: String, purchase: Myket.Purchase) -> void:
        # خرید موفق
    func iab_purchase_failed(message: String) -> void:
        # خرید ناموفق
)
```

## مصرف خرید (Consume)

برای محصولاتی که قابلیت مصرف دارند:

```gdscript
Myket.consume_async(purchase, 
    func consume_finished(is_success: bool, message: String, purchase: Myket.Purchase) -> void:
        # مصرف موفق
    func consume_failed(message: String) -> void:
        # مصرف ناموفق
)
```

## بستن اتصال

پس از اتمام عملیات، می‌توانید اتصال را ببندید:

```gdscript
Myket.close_connection()
```

## کلاس‌های اصلی پلاگین

* کلاس **Product:** اطلاعات محصولات Myket شامل `sku`، `type`، `price`، `title` و `description`.
* کلاس **Purchase:** اطلاعات خریدها شامل `sku`، `order_id`، `purchase_time`، `developer_payload` و `signature`.
* کلاس **Inventory:** شامل لیست محصولات و خریدهای کاربر با متدهای `has_product(sku)` و `has_purchase(sku)` و قابلیت حذف خرید یا محصول.

##  نمایش صفحات Myket

برای باز کردن صفحات مختلف Myket:

* متد `Intent.show_comment(package_name)` - نمایش بخش نظرات برنامه.
* متد `Intent.show_details(package_name)` - نمایش جزئیات برنامه.
* متد `Intent.show_download(package_name)` - نمایش صفحه دانلود برنامه.
* متد `Intent.show_developer(package_name)` - نمایش صفحه توسعه‌دهنده.

## نکات مهم

* تمام متدها به صورت **static** هستند و از طریق `Callable` پاسخ دریافت می‌کنند.
* قبل از هر عملیات، اتصال با `open_connection` باید برقرار شود.
* برای پاک‌سازی منابع، `close_connection` را فراخوانی کنید.

با استفاده از این پلاگین می‌توانید خریدهای درون‌برنامه‌ای را به صورت ایمن و ساده در بازی‌ها و برنامه‌های Godot خود مدیریت کنید.
