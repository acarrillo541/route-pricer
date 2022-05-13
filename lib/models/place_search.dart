// pull place data from google place api json
class PlaceSearch {
  final String? address;
  final String? placeId; // places api id, used for other api calls

  PlaceSearch({
    this.address,
    this.placeId,
  });

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    return PlaceSearch(
      address: json['description'],
      placeId: json['place_id'],
    );
  }
}
