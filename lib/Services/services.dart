import 'dart:convert';

import 'package:hobby/Model/new_model.dart';
import 'package:http/http.dart' as http;

class NewsApi {
  List<NewsModel> dataStore = [];
  Future<void> getNews() async {
    Uri url = Uri.parse('Api');
    var response = await http.get(url);
    var jsonData = jsonDecode(response.body);
    if (jsonData["status"] == "ok") {
      jsonData["articles"].forEach((element) {
        if (element['urlToImage'] != null &&
            element['author'] != null &&
            element['content'] != null &&
            element['description'] != null) {
          NewsModel newsModel = NewsModel(
            title: element['title'],
            urlToImage: element['urlToImage'],
            description: element['description'],
            author: element['author'],
            content: element['content'],
          );
          dataStore.add(newsModel);
        }
      });
    }
  }
}

class CategoryNews {
  List<NewsModel> dataStore = [];
  Future<void> getNews(String category) async {
    Uri url = Uri.parse('api');
    var response = await http.get(url);
    var jsonData = jsonDecode(response.body);
    if (jsonData["status"] == "ok") {
      jsonData["articles"].forEach((element) {
        if (element['urlToImage'] != null &&
            element['author'] != null &&
            element['content'] != null &&
            element['description'] != null) {
          NewsModel newsModel = NewsModel(
            title: element['title'],
            urlToImage: element['urlToImage'],
            description: element['description'],
            author: element['author'],
            content: element['content'],
          );
          dataStore.add(newsModel);
        }
      });
    }
  }
}
