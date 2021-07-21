import 'package:flutter/material.dart';

class MainPageSearchTextField extends StatelessWidget {

  MainPageSearchTextField(this.updateSearchQuery);

  void Function(String query) updateSearchQuery;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 12.0,),
        Expanded(
          child: Card(
            child: TextField(
              onChanged: updateSearchQuery,
              style: TextStyle(
                fontSize: 16.0,
              ),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 0.0,
                    style: BorderStyle.none,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari Barang...',
              ),
            ),
          ),
        ),
        SizedBox(width: 12.0,),
      ],
    );
  }
}

