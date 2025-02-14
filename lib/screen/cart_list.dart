// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shopping_cart/controller/cart_controller.dart';
import 'package:shopping_cart/widget/text_widget.dart';

class CartList extends StatefulWidget {
  const CartList({super.key});

  @override
  State<CartList> createState() => _nameState();
}

class _nameState extends State<CartList> {
  final CartController controller = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    controller.fetchCart(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () {
              if (controller.cartList.isEmpty) {
                // No data or empty cart
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: Lottie.network(
                            'https://assets6.lottiefiles.com/packages/lf20_iezsnh5g.json'),
                      ),
                      TextWidget(
                        value: "Your Cart Is Empty",
                        size: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.withOpacity(0.7),
                      ),
                    ],
                  ),
                );
              } else {
                // Data available
                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.cartList.length,
                          itemBuilder: (context, index) {
                            var cartItem = controller.cartList[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: Card(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Image.network(
                                        cartItem.productImage.toString(),
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.error);
                                        },
                                      )),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextWidget(
                                              value: cartItem.productName,
                                              size: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                            TextWidget(
                                              value:
                                                  "Price: ${cartItem.productPrice} THB",
                                              size: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black54,
                                            ),
                                            MaterialButton(
                                              onPressed: () {
                                                controller.removeItem(
                                                    cartItem.productId,
                                                    cartItem.productPrice);
                                              },
                                              child: Text('Remove'),
                                              color: Colors.orangeAccent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              double totalPrice = controller.cartList.fold(0.0, (sum, item) {
                return sum + item.productPrice;
              });
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sub Total: ${totalPrice.toStringAsFixed(2)} THB",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }),
          ),
          useCoupon(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Points: 68 points.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 10),

                  // ช่องกรอกคะแนน
                  TextField(
                    keyboardType: TextInputType.number, // รับเฉพาะตัวเลข
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter points to redeem for discount',
                      labelText: 'Points',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        // พยายามแปลงค่าที่กรอกเป็นตัวเลข
                        int enteredValue = int.tryParse(value) ?? 0;

                        // ตรวจสอบว่าไม่เกิน 68 คะแนน
                        if (enteredValue > 68) {
                          // แสดงข้อความแจ้งเตือน
                          Get.snackbar(
                            'Warning!!!',
                            'You can only enter up to 68 points.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          // รีเซ็ตคะแนนให้เป็น 68 ถ้ากรอกเกิน
                          controller.enteredPoints.value = 68;
                        } else {
                          // กำหนดค่าคะแนนที่กรอกลงในตัวแปร
                          controller.enteredPoints.value = enteredValue;
                        }
                      } else {
                        // กรณีที่ผู้ใช้ลบคะแนนออกทั้งหมด
                        controller.enteredPoints.value = 0;
                      }
                    },
                    onSubmitted: (_) {
                      // เมื่อกรอกเสร็จแล้ว ปิดคีย์บอร์ด
                      FocusScope.of(context).unfocus();
                    },
                  ),

                  SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // แสดงส่วนลดที่ใช้จากคะแนน
                        if (controller.enteredPoints.value > 0)
                          Text(
                            "Discount: ${controller.enteredPoints.value} THB", // ใช้ค่า enteredPoints ที่มีอยู่แล้ว
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              double totalPriceAfterDiscount =
                  controller.calculatedTotalPriceAfterDiscount;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price: ${totalPriceAfterDiscount.toStringAsFixed(2)} THB",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 25)
        ],
      ),
    );
  }

  Widget useCoupon() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Available Coupon',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Discount 50 THB Coupon (Fixed amount)
                // Discount 50 THB Coupon
                buildCouponCard(
                  index: 1,
                  icon: Icons.sell_outlined,
                  text: 'Discount 50 THB',
                  onTap: () {
                    if (controller.cartList.isNotEmpty) {
                      // Check if the same coupon is clicked again to remove it
                      if (controller.currentCouponIndex.value == 1) {
                        // Clear the coupon by resetting the index
                        controller.currentCouponIndex.value =
                            0; // Reset to no coupon
                        controller.useDiscountByCoupon(
                            controller.currentCouponIndex.value);

                        // Optionally clear OnTop discounts and seasonal discounts
                        controller.clearOnTopDiscount();
                        controller.isUseSeasonal.value = false;
                        controller.useDiscountBySeasonal();
                      } else {
                        // Apply Coupon 1 (Fixed amount discount)
                        controller.currentCouponIndex.value = 1;
                        controller.useDiscountByCoupon(
                            controller.currentCouponIndex.value);

                        // Clear OnTop discounts when Coupon is applied
                        controller.clearOnTopDiscount();
                        controller.isUseSeasonal.value =
                            false; // Clear seasonal
                      }
                    }
                  },
                ),

// Discount 10% Coupon (Percentage discount)
                buildCouponCard(
                  index: 2,
                  icon: Icons.sell_outlined,
                  text: 'Discount 10%',
                  onTap: () {
                    if (controller.cartList.isNotEmpty) {
                      // Check if the same coupon is clicked again to remove it
                      if (controller.currentCouponIndex.value == 2) {
                        // Clear the coupon by resetting the index
                        controller.currentCouponIndex.value =
                            0; // Reset to no coupon
                        controller.useDiscountByCoupon(
                            controller.currentCouponIndex.value);

                        // Optionally clear OnTop discounts and seasonal discounts
                        controller.clearOnTopDiscount();
                        controller.isUseSeasonal.value = false;
                        controller.useDiscountBySeasonal();
                      } else {
                        // Apply Coupon 2 (Percentage discount)
                        controller.currentCouponIndex.value = 2;
                        controller.useDiscountByCoupon(
                            controller.currentCouponIndex.value);

                        // Clear OnTop discounts when Coupon is applied
                        controller.clearOnTopDiscount();
                        controller.isUseSeasonal.value =
                            false; // Clear seasonal
                      }
                    }
                  },
                ),
              ],
            ),
            // On Top Discounts

            buildCouponCard(
              index: 3,
              icon: Icons.sell_outlined,
              text: 'Discount 15% off on clothing',
              onTap: () {
                if (controller.cartList.isNotEmpty) {
                  // Check if the user has already used points for discount
                  if (controller.enteredPoints.value > 0) {
                    // Show error if points discount is already used
                    Get.snackbar(
                      'Warning!!',
                      'You can only apply one discount at a time. Please remove the points discount first.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else {
                    // Check if there are any items with the "clothing" tag
                    double clothingTotal = controller.cartList
                        .where((item) => item.productTag == "clothing")
                        .fold(0.0, (sum, item) => sum + item.productPrice);

                    if (clothingTotal == 0) {
                      // Show error if no "clothing" items are found
                      Get.snackbar(
                        'Warning!!',
                        'You cannot apply this coupon. No clothing items found in the cart.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } else {
                      // Check if the current on-top discount is already applied
                      if (controller.currentOnTopIndex.value == 3) {
                        // If the same discount is clicked, clear it
                        controller.currentOnTopIndex.value =
                            -1; // Reset to no discount
                        controller.useDiscountByOnTop(
                            controller.currentOnTopIndex.value);

                        // Clear any other discounts (like seasonal)
                        controller.isUseSeasonal.value = false;
                        controller.useDiscountBySeasonal();
                      } else {
                        // If a new discount is clicked, apply it
                        controller.currentOnTopIndex.value =
                            3; // Set new discount index
                        controller.useDiscountByOnTop(
                            controller.currentOnTopIndex.value);

                        // Optionally clear any other discounts if needed (Seasonal)
                        controller.isUseSeasonal.value = false;
                        controller.useDiscountBySeasonal();
                      }
                    }
                  }
                }
              },
            ),

            buildCouponCard(
              index: 4,
              icon: Icons.sell_outlined,
              text: 'Discount 40 THB at every 300 THB',
              onTap: () {
                if (controller.cartList.isNotEmpty) {
                  // Check if the same coupon is clicked again to remove it
                  if (controller.currentCouponIndex.value == 4) {
                    // Clear the coupon by resetting the index
                    controller.currentCouponIndex.value =
                        0; // Reset to no coupon
                    controller.useDiscountByCoupon(
                        controller.currentCouponIndex.value);

                    // Optionally clear OnTop discounts and seasonal discounts
                    controller.clearOnTopDiscount();
                    controller.isUseSeasonal.value = false;
                    controller.useDiscountBySeasonal(); // คำนวณส่วนลดทันที
                  } else {
                    // Apply Coupon 4 (Seasonal discount for every 300 THB)
                    controller.currentCouponIndex.value = 4;
                    controller.useDiscountByCoupon(
                        controller.currentCouponIndex.value);

                    // Clear OnTop discounts when Coupon is applied
                    controller.clearOnTopDiscount();
                    controller.isUseSeasonal.value =
                        true; // Set seasonal discount
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCouponCard({
    required int index,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => IntrinsicWidth(
            child: Card(
              elevation: 8,
              color: (controller.currentCouponIndex.value == index ||
                      controller.currentOnTopIndex.value == index ||
                      (index == 5 && controller.isUseSeasonal.value))
                  ? Colors.orangeAccent
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Icon(icon),
                    Text(text),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
