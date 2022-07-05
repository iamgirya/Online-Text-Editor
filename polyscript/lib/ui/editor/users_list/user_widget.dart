import 'package:flutter/material.dart';
import 'package:polyscript/ui/colors.dart';

import '../../../model/user_model.dart';

class UserWidget extends StatelessWidget {
  final User user;

  const UserWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          userBackground,
          usernameLabel,
        ],
      ),
    );
  }

  Widget get userBackground {
    return Container(
      decoration: BoxDecoration(
        color: user.color,
        borderRadius: const BorderRadius.all(
          Radius.circular(18),
        ),
      ),
    );
  }

  Widget get usernameLabel {
    return Text(
      user.name[0].toUpperCase(),
      style: const TextStyle(
        color: background,
        fontFamily: "Roboto",
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
    );
  }
}
