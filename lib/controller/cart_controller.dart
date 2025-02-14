import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_cart/database/db_helper.dart';
import 'package:shopping_cart/model/cart_model.dart';

class CartController extends GetxController {
  DBHelper db = DBHelper();

  var cartList = <Cart>[].obs;
  var _counter = 0.obs;
  var _totalPrice = 0.0.obs;
  var _discount = 0.0.obs;

  // Track applied campaigns (to ensure only one campaign per category)
  var isCouponApplied = false.obs;
  var isOnTopApplied = false.obs;
  var isSeasonalApplied = false.obs;
  var totalPriceAfterDiscount = 0.0.obs;
  var enteredPoints = 0.obs;

  // Track the campaign being used
  var currentCouponIndex = 0.obs;
  var currentOnTopIndex = 0.obs;
  var isUseSeasonal = false.obs;

  int get counter => _counter.value;
  double get totalPrice => _totalPrice.value - _discount.value;
  double get discount => _discount.value;

  // Maximum discount allowed (20% of total price)
  double get maxDiscount => _totalPrice.value * 0.20;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
    _getPrefItems();
  }

  void fetchCart() async {
    var data =
        await db.getCartList(); // Assuming you have this method in DBHelper
    if (data != null) {
      cartList
          .assignAll(data); // Assign the cart data to the cartList observable
    }
  }

  // This method applies the discount based on the coupon index
  void useDiscountByCoupon(int couponIndex) {
    // Apply only if no coupon has been applied yet
    if (!isCouponApplied.value) {
      currentCouponIndex.value = couponIndex;
      _applyCouponDiscount();
      isCouponApplied.value = true; // Mark coupon as applied
    }
  }

  void useDiscountByOnTop(int onTopIndex) {
    if (cartList.isNotEmpty) {
      currentOnTopIndex.value = onTopIndex;
      _applyDiscountByOnTop(); // Apply all discounts (Coupon, OnTop, Seasonal)
    }
  }

  void useDiscountBySeasonal() {
    double totalPrice = _totalPrice.value;
    double discount = 0.0;

    if (isUseSeasonal.value && totalPrice >= 300) {
      discount = 40; // ลดราคาแค่ 40 บาทเท่านั้น
    }

    // อัพเดทราคาหลังหักส่วนลด
    totalPriceAfterDiscount.value = totalPrice - discount;
  }

  // Apply the discount logic based on the coupon index
  void _applyCouponDiscount() {
    double discountAmount = 0.0;

    switch (currentCouponIndex.value) {
      case 1:
        discountAmount = 50; // Fixed 50 THB discount
        break;
      case 2:
        discountAmount = _totalPrice.value * 0.10; // 10% discount
        break;
      case 3:
        discountAmount =
            _totalPrice.value * 0.15; // 15% discount on clothing category
        break;
      case 4:
        discountAmount = (_totalPrice.value >= 300) ? 40 : 0;
        break;

      default:
        discountAmount = 0.0; // No discount
    }

    _discount.value = discountAmount; // Apply the discount
    _setPrefItems(); // Save the discount in shared preferences
  }

  void _applyDiscountByOnTop() {
    double discountAmount = 0.0;

    switch (currentOnTopIndex.value) {
      case 1:
        discountAmount = 50; // Fixed 50 THB discount
        break;
      case 2:
        discountAmount = _totalPrice.value * 0.10; // 10% discount
        break;
      case 3:
        double clothingTotal = cartList
            .where((item) =>
                item.productTag ==
                "clothing") // คัดกรองสินค้าโดยใช้ "Clothing" tag
            .fold(
                0.0,
                (sum, item) =>
                    sum +
                    item.productPrice); // บวกสินค้าทั้งหมดที่มี tag "Clothing"

        print(
            "Clothing total price: $clothingTotal"); // เพิ่มบรรทัดนี้เพื่อดูยอดรวมของสินค้าที่เป็นเสื้อผ้า

        discountAmount = clothingTotal * 0.15; // คำนวณส่วนลด 15%
        break;
      case 4: // ส่วนลด 15% สำหรับสินค้าประเภทเสื้อผ้า
        discountAmount = (_totalPrice.value >= 300)
            ? 40
            : 0; // Seasonal discount for spending 300 THB or more
        break;

      default:
        discountAmount = 0.0; // No discount
    }

    _discount.value = discountAmount; // Store discount amount
    _setPrefItems(); // Save to preferences if necessary

    // Do NOT update price here, just store the discount
    // We will update the price after applying all discounts elsewhere
  }

  // Method to clear the current applied coupon and reset discount
  void clearCoupon() {
    currentCouponIndex.value = 0;
    _discount.value = 0.0;
    isCouponApplied.value = false; // Reset coupon applied status
    _setPrefItems(); // Update shared preferences
  }

  // Method to clear the applied on-top discount
  void clearOnTopDiscount() {
    currentOnTopIndex.value = 0;
    _discount.value = 0.0;
    isOnTopApplied.value = false; // Reset on-top discount applied status
    _setPrefItems(); // Update shared preferences
  }

  // Method to clear the seasonal discount
  void clearSeasonalDiscount() {
    isUseSeasonal.value = false;
    _discount.value = 0.0;
    isSeasonalApplied.value = false; // Reset seasonal discount applied status
    _setPrefItems(); // Update shared preferences
  }

  void _setPrefItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('cart_item', _counter.value);
      prefs.setDouble('total_price', _totalPrice.value);
      prefs.setDouble(
          'discount', _discount.value); // Store discount in shared preferences
    } catch (e) {
      print('Error setting shared preferences: $e');
    }
  }

  void _getPrefItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _counter.value = prefs.getInt('cart_item') ?? 0;
      _totalPrice.value = prefs.getDouble('total_price') ?? 0.0;
      _discount.value = prefs.getDouble('discount') ?? 0.0;
      update(); // Update the UI
    } catch (e) {
      print('Error getting shared preferences: $e');
    }
  }

  void removeItem(String productId, double price) async {
    await db.delete(productId);
    cartList.removeWhere((item) => item.productId == productId);
    removeTotalPrice(price);
    removeCounter();

    if (cartList.isEmpty) {
      _totalPrice.value = 0.0;

      // รีเซ็ตราคาคูปองที่เลือก
      currentCouponIndex.value = -1; // สมมุติว่า -1 คือค่าไม่เลือกคูปอง
      currentOnTopIndex.value = -1; // ค่าไม่เลือก on-top discount
      isUseSeasonal.value = false; // ไม่เลือก seasonal

      update();
    }
  }

  void addTotalPrice(double productPrice) {
    _totalPrice.value += productPrice;
    _setPrefItems();
  }

  void removeTotalPrice(double productPrice) {
    _totalPrice.value -= productPrice;
    _setPrefItems();
  }

  void addCounter() {
    _counter.value++;
    _setPrefItems();
  }

  void removeCounter() {
    if (_counter.value > 0) {
      _counter.value--;
      _setPrefItems();
    }
  }

  int get counterValue => _counter.value;

  void updateTotalPriceAfterDiscount() {
    // We now calculate the final discounted price with all discounts applied
    double discountedPrice = _totalPrice.value;
    discountedPrice =
        _applyCouponDiscountAmount(discountedPrice); // Coupon discount
    discountedPrice =
        _applyOnTopDiscountAmount(discountedPrice); // On-top discount
    discountedPrice =
        _applySeasonalDiscountAmount(discountedPrice); // Seasonal discount

    // Update the total price after discount
    totalPriceAfterDiscount.value = discountedPrice;

    totalPriceAfterDiscount.value = calculatedTotalPriceAfterDiscount;

    update(); // Notify the UI to update the displayed price
  }

// คำนวณส่วนลดจาก Coupon
  double _applyCouponDiscountAmount(double price) {
    double discountAmount = 0.0;

    switch (currentCouponIndex.value) {
      case 1:
        discountAmount = 50; // Fixed 50 THB discount
        break;
      case 2:
        discountAmount = price * 0.10; // 10% discount
        break;
      case 3:
        double clothingTotal = cartList
            .where((item) =>
                item.productTag ==
                "clothing") // คัดกรองสินค้าโดยใช้ "Clothing" tag
            .fold(
                0.0,
                (sum, item) =>
                    sum +
                    item.productPrice); // บวกสินค้าทั้งหมดที่มี tag "Clothing"

        print(
            "Clothing total price: $clothingTotal"); // เพิ่มบรรทัดนี้เพื่อดูยอดรวมของสินค้าที่เป็นเสื้อผ้า

        discountAmount = clothingTotal * 0.15; // คำนวณส่วนลด 15%
        break;
      case 4:
        discountAmount = (price >= 300) ? 40 : 0; // Seasonal discount
        break;

      default:
        discountAmount = 0.0; // No discount
    }

    return price - discountAmount;
  }

// คำนวณส่วนลดจาก OnTop
  double _applyOnTopDiscountAmount(double price) {
    double discountAmount = 0.0;

    switch (currentOnTopIndex.value) {
      case 1:
        discountAmount = 50; // Fixed 50 THB discount
        break;
      case 2:
        discountAmount = price * 0.10; // 10% discount
        break;
      case 3:
        double clothingTotal = cartList
            .where((item) =>
                item.productTag ==
                "clothing") // คัดกรองสินค้าโดยใช้ "Clothing" tag
            .fold(
                0.0,
                (sum, item) =>
                    sum +
                    item.productPrice); // บวกสินค้าทั้งหมดที่มี tag "Clothing"

        print(
            "Clothing total price: $clothingTotal"); // เพิ่มบรรทัดนี้เพื่อดูยอดรวมของสินค้าที่เป็นเสื้อผ้า

        discountAmount = clothingTotal * 0.15; // คำนวณส่วนลด 15%
        break;
      case 4:
        discountAmount = (price >= 300) ? 40 : 0; // Seasonal discount
        break;

      default:
        discountAmount = 0.0; // No discount
    }

    return price - discountAmount;
  }

// คำนวณส่วนลดจาก Seasonal
  double _applySeasonalDiscountAmount(double price) {
    if (isUseSeasonal.value) {
      return price - 40; // Seasonal discount 40 THB
    }
    return price;
  }

  double get calculatedTotalPriceAfterDiscount {
    double discountedPrice = _totalPrice.value;

    // คำนวณส่วนลดจากคะแนน
    discountedPrice = discountedPrice - calculatePointsDiscount();

    // คำนวณส่วนลดจากคูปอง, on-top, seasonal (ถ้ามี)
    discountedPrice = _applyCouponDiscountAmount(discountedPrice);
    discountedPrice = _applyOnTopDiscountAmount(discountedPrice);
    discountedPrice = _applySeasonalDiscountAmount(discountedPrice);

    return discountedPrice;
  }

  void setTotalPrice(double price) {
    _totalPrice.value = price;
    updateTotalPriceAfterDiscount(); // เรียกเมื่อ _totalPrice เปลี่ยนแปลง
  }

  // Function to calculate the discount
  double calculatePointsDiscount() {
    double discount = enteredPoints.value.toDouble(); // 1 point = 1 THB
    // Ensure the discount doesn't exceed 20% of total price
    return discount > maxDiscount ? maxDiscount : discount;
  }

  void useDiscountByPoints() {
    double discount = calculatePointsDiscount(); // คำนวณส่วนลดจากคะแนน
    _discount.value = discount; // กำหนดส่วนลดที่คำนวณจากคะแนน
    totalPriceAfterDiscount.value =
        _totalPrice.value - discount; // หักส่วนลดจากราคาสินค้า

    // คำนวณราคาใหม่หลังหักส่วนลดและอัปเดต
    updateTotalPriceAfterDiscount();

    update(); // รีเฟรชข้อมูลเพื่อให้ UI อัปเดต
  }
}
