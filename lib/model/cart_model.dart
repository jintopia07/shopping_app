class Cart {
  final String productId;
  final String productName;
  final double productPrice; // Change this to double
  final String? productImage;
  final String productTag;

  Cart({
    required this.productId,
    required this.productName,
    required this.productPrice, // Now accepts double
    required this.productImage,
    required this.productTag,
  });

  factory Cart.fromMap(Map<String, dynamic> res) {
    return Cart(
      productId: res['productId'] ?? '',
      productName: res['productName'] ?? '',
      productPrice:
          double.tryParse(res['productPrice']?.toString() ?? '0.0') ?? 0.0,
      productImage: res['productImage'] ?? '',
      productTag: res['productTag'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice':
          productPrice.toString(), // Convert double to String when saving to DB
      'productImage': productImage,
      'productTag': productTag,
    };
  }
}
