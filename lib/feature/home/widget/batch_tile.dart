import 'package:flutter/material.dart';

class BatchTile extends StatelessWidget {
  const BatchTile({super.key, required this.batch});

  const BatchTile.empty({super.key}) : batch = null;

  final Map<String, dynamic>? batch;

  @override
  Widget build(BuildContext context) {
    return batch == null ? buildEmptyCard(context) : buildCard(context, batch!);
  }

  Widget buildEmptyCard(BuildContext context) {
    return Container(
      width: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_add_outlined,
            color: Colors.grey.shade400,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Add Batch',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade500, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Card buildCard(BuildContext context, Map<String, dynamic> batch) {
    return Card(
      child: Container(
        width: 200,
        padding: const EdgeInsets.only(top: 16, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: buildPopupMenuForBatch(context),
            ),
            const Spacer(),
            Text(
              batch['name']!.toString(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              batch['description']!.toString(),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Spacer(flex: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // students icon
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  '${batch['students']!}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    // color: Theme.of(context).brightness == Brightness.dark
                    //     ? Colors.grey.shade300
                    //     : Colors.grey.shade900,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  PopupMenuButton<dynamic> buildPopupMenuForBatch(BuildContext context) {
    final menuMap = {
      'Edit': (BuildContext context) {},
      'Delete': (BuildContext context) {},
    };
    return PopupMenuButton(itemBuilder: (c) {
      return menuMap.keys.map((String choice) {
        return PopupMenuItem(
          child: Text(choice),
          onTap: () => menuMap[choice]?.call(context),
        );
      }).toList();
    });
  }
}
