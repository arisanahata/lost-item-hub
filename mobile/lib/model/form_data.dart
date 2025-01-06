class FormData {
  final String itemName;
  final int cash;
  final String color;
  final String description;
  final bool needsReceipt;
  final String routeName;
  final String vehicleNumber;
  final String otherLocation;
  final List<String>? images;

  FormData({
    required this.itemName,
    this.cash = 0,
    required this.color,
    required this.description,
    required this.needsReceipt,
    required this.routeName,
    required this.vehicleNumber,
    required this.otherLocation,
    this.images,
  });

  factory FormData.fromJson(Map<String, dynamic> json) {
    return FormData(
      itemName: json['itemName'] as String? ?? '',
      cash: json['cash'] as int? ?? 0,
      color: json['itemColor'] as String? ?? '',
      description: json['itemDescription'] as String? ?? '',
      needsReceipt: json['needsReceipt'] as bool? ?? false,
      routeName: json['routeName'] as String? ?? '',
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      otherLocation: json['otherLocation'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'cash': cash,
      'itemColor': color,
      'itemDescription': description,
      'needsReceipt': needsReceipt,
      'routeName': routeName,
      'vehicleNumber': vehicleNumber,
      'otherLocation': otherLocation,
      'images': images,
    };
  }
}
