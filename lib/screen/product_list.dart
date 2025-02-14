// ignore_for_file: prefer_const_constructors, unused_local_variable, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_cart/controller/cart_controller.dart';
import 'package:shopping_cart/database/db_helper.dart';
import 'package:shopping_cart/model/cart_model.dart';
import 'package:shopping_cart/model/product_model.dart';
import 'package:shopping_cart/screen/cart_list.dart';
import 'package:shopping_cart/screen/product_detail.dart';
import 'package:shopping_cart/utilites/tags_name.dart';
import 'package:shopping_cart/widget/text_widget.dart';
import 'package:badges/badges.dart' as badges;

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<ProductModel> products = getProducts();

  CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    DBHelper? db = DBHelper();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: TextWidget(
          value: "Product Page",
          size: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black.withOpacity(0.7),
        ),
        actions: [
          InkWell(
            onTap: () {
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 175 / 230),
        itemCount: products.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Get.to(ProductDetail(
                  name: products[index].name.toString(),
                  price: products[index].price.toString(),
                  description: products[index].description.toString(),
                  image: products[index].image.toString(),
                  id: products[index].id.toString(),
                  index: index,
                  tag: products[index].tag.toString(),
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.orangeAccent.withOpacity(0.2),
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: imageTag + index.toString(),
                        child: SizedBox(
                          height: 130,
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.network(
                              products[index].image.toString(),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      TextWidget(
                          value: products[index].name.toString(),
                          size: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              TextWidget(
                                  value:
                                      "${products[index].price.toString()} \THB",
                                  size: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(0.5)),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              db
                                  .insert(Cart(
                                productId: products[index].id,
                                productName: products[index].name,
                                productImage: products[index].image,
                                productPrice: products[index].price,
                                productTag: products[index].tag,
                              ))
                                  .then((value) {
                                print("Value:" + value.toString());
                                controller.addTotalPrice(double.parse(
                                    products[index].price.toString()));
                                controller.addCounter();
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.green,
                                  content: TextWidget(
                                    value: "Product is added to cart",
                                    size: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  duration: Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }).onError((error, stackTrace) {
                                // เมื่อเกิด error (เมื่อไอเทมซ้ำ) จะแสดง SnackBar แจ้งเตือน
                                print('Error:' + error.toString());
                                final snackBar = SnackBar(
                                  backgroundColor: Colors.red,
                                  content: TextWidget(
                                    value: "Product is already added to cart",
                                    size: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  duration: Duration(seconds: 2),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              });
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.orangeAccent,
                              child: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
