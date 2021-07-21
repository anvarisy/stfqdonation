class WorkAround {
  static String httpUrl(String url) {
    int now = DateTime.now().millisecondsSinceEpoch;
    return url.contains('?')
        ? url+'&v=$now'
        : url+'?v=$now';
  }
}