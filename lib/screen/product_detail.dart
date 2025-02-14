// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:shopping_cart/controller/cart_controller.dart';
import 'package:shopping_cart/database/db_helper.dart';
import 'package:shopping_cart/model/cart_model.dart';
import 'package:shopping_cart/screen/cart_list.dart';
import 'package:shopping_cart/utilites/tags_name.dart';
import 'package:shopping_cart/widget/text_widget.dart';
import 'package:badges/badges.dart' as badges;

class ProductDetail extends StatelessWidget {
  final String name;
  final String price;
  final String description;
  final String image;
  final String id;
  final int index;
  final String tag;

  const ProductDetail({
    super.key,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.id,
    required this.index,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    CartController controller = Get.put(CartController());
    DBHelper? db = DBHelper();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: TextWidget(
          value: name,
          size: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black.withOpacity(0.7),
        ),
        actions: [
          InkWell(
            onTap: () {
              //Get.to(CartPage());
              Get.to(CartList());
            },
            child: badges.Badge(
              badgeContent: Obx(() {
                return TextWidget(
                  value: Get.find<CartController>().counter.toString(),
                  size: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.7),
                );
              }),
              badgeStyle: badges.BadgeStyle(badgeColor: Colors.redAccent),
              child: Icon(Icons.shopping_cart),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: imageTag + index.toString(),
              child: SizedBox(
                height: 200,
                width: double.maxFinite,
                child: Image.network(image.toString(), fit: BoxFit.contain),
              ),
            ),
            Divider(),
            TextWidget(
              value: name,
              size: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.7),
            ),
            SizedBox(height: 10),
            TextWidget(
              value: "${price}\THB",
              size: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.7),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextWidget(
                value: description,
                size: 14,
                fontWeight: FontWeight.w300,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: MaterialButton(
          height: 50,
          minWidth: double.maxFinite,
          color: Colors.orangeAccent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: TextWidget(
            value: "Add to cart",
            size: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(0.9),
          ),
          onPressed: () {
            db
                .insert(Cart(
              productId: id,
              productName: name,
              productImage: image,
              productPrice: double.parse(price),
              productTag: tag,
            ))
                .then((value) {
              print("Value:" + value.toString());
              controller.addTotalPrice(double.parse(price.toString()));
              controller.addCounter();
              final snackBar = SnackBar(
                backgroundColor: Colors.green,
                content: TextWidget(
                    value: "Product is added to cart",
                    size: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.5)),
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }).onError((error, stackTrace) {
              print('Error:' + error.toString());
              final snackBar = SnackBar(
                backgroundColor: Colors.red,
                content: TextWidget(
                    value: "Product is already added to cart",
                    size: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.5)),
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          },
        ),
      ),
    );
  }
}
