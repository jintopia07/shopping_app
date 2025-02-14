import 'dart:convert';

class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price; // Changed to double for better handling
  final String description;
  final String tag;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.tag,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        price:
            double.tryParse(json['price'] ?? '0.0') ?? 0.0, // Parsing as double
        description: json['description'] ?? '',
        tag: json['tag'] ?? '',
      );
    } catch (e) {
      print('Error parsing ProductModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price.toString(), // Ensure price is returned as a string
      'description': description,
      'tag': tag,
    };
  }
}

// JSON data
const String jsonString = '''
[ 
  {
    "id": "1",
    "name": "Running Men's T-Shirt",
    "image": "https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_1000,h_1000/global/515008/23/fnd/SEA/fmt/png/Running-Men's-T-Shirt",
    "price": "350",
    "description": "Stock up on your essential running wear and get this lightweight and extremely breathable T-shirt from PUMA. Highly functional materials draw sweat away from your skin and help keep you dry and comfortable during exercise.",
    "tag": "clothing"
  
  },
  {
    "id": "2",
    "name": "Classics Relaxed Hoodie",
    "image": "https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_1000,h_1000/global/624227/65/fnd/SEA/fmt/png/Better-Classics-Relaxed-Hoodie-Women",
    "price": "700",
    "description": "Stay comfy and cosy in this Better Classcis hoodie. Cut with a drop shoulder for that relaxed look, it features ribbed cuffs and hem and an embroidered PUMA logo on the left side of the chest.",
    "tag": "clothing"
   
  },
  {
    "id": "3",
    "name": "SUCCESSO 44mm Gold",
    "image": "https://watchdirect.com.au/cdn/shop/products/9b036c16c4af4b7ddb9b1eade1411385_800x.png?v=1626916795",
    "price": "850",
    "description": "The watches from the Successo collection are characterised by a dynamic-look case and a dial with stylish elements inspired by the traditional Maserati radiator grille.",
    "tag": "electronics"
   
  },
  {
    "id": "4",
    "name": "Classics LV8 Woven",
    "image": "https://images.puma.com/image/upload/f_auto,q_auto,b_rgb:fafafa,w_1000,h_1000/global/090580/01/fnd/SEA/fmt/png/Classics-LV8-Woven-Backpack",
    "price": "640",
    "description": "Never out of style, the Classics LV8 Woven Backpack is your go-to for any city adventure. Its oversized, padded build and multiple zip pockets keep your essentials secure on the move. Elevate your look with this lightweight yet durable design. Be bold, stay classic.",
    "tag": "accessories"

  },
  {
    "id": "5",
    "name": "Black Leather 35 mm",
    "image": "https://www.montblanc.com/variants/images/1647597360237962/A/w747.jpg",
    "price": "230",
    "description": "Enhance any outfit with this 35 mm belt crafted in luxurious black leather adorned with the iconic Extreme 3.0 motif. The horseshoe pin buckle features a black PVD finish and adds a sophisticated touch.",
    "tag": "accessories"
    
  },
  {
    "id": "6",
    "name": "Mens Baseball Cap",
    "image": "https://www.kingandfifth.com/cdn/shop/files/BestLowprofilebaseballcap.jpg?v=1686899356&width=720",
    "price": "250",
    "description": "Introducing The Senna Baseball Cap, where style meets sophistication in every stitch. Crafted from premium men's wear fabric, this cap exudes refinement with its flawless tailoring and understated detailing. Designed for the modern guy, The Senna offers unrivaled comfort and style, courtesy of its soft sweatband and timeless design. ",
    "tag": "accessories"
   
  }
]
''';

// Convert JSON to List of ProductModel
List<ProductModel> getProducts() {
  List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((item) => ProductModel.fromJson(item)).toList();
}
