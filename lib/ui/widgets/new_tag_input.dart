import 'package:flutter/material.dart';
import 'package:material_color_picker_wns/material_color_picker_wns.dart';
import 'package:provider/provider.dart';
import 'package:room_app/data/moor_database.dart';

class NewTagInput extends StatefulWidget {
  const NewTagInput({Key? key}) : super(key: key);

  @override
  _NewTagInputState createState() => _NewTagInputState();
}

class _NewTagInputState extends State<NewTagInput> {
  Color pickedColor = Colors.red;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final dao = Provider.of<TagDao>(context);
    return ListTile(
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'Enter Tag'),
        onSubmitted: (value) {
          Tag tag = Tag(name: value, color: pickedColor.value);
          dao.insertTag(tag);
          setState(() {
            controller.clear();
            print('Controller Value : ${controller.text}');
          });
        },
      ),
      trailing: GestureDetector(
        child: Container(
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pickedColor,
          ),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: MaterialColorPicker(
                    allowShades: false,
                    selectedColor: pickedColor,
                    onMainColorChange: (color) {
                      setState(() {
                        pickedColor = color;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                );
              });
        },
      ),
    );
  }
}
