import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/groups/data/datasources/buttons.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:flutter/material.dart';

class GroupListEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DashboardButton(
            color: adminTile.color,
            text: adminTile.header,
            icon: adminTile.icon,
            iconColor: White,
            function: () {
              return null;
            },
          ),
          Container(
            color: Red,
            height: 100,
            width: 100,
          ),
        ],
      ),
    );
  }
}
