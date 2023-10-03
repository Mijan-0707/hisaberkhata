import 'package:flutter/material.dart';
import 'package:hisaberkhata/screens/inherited_widget.dart';

class BatchTile extends StatelessWidget {
  const BatchTile({
    super.key,
    required this.batch,
    this.menuMap,
    required this.onTapBody,
    required this.onTapAdd, this.onTapEmptyCard,

  });

  const BatchTile.empty({super.key,required this.onTapEmptyCard,})
      : batch = null,
        menuMap = null,
        onTapBody = null,
        onTapAdd = null;


  final String? batch;
  final Map<String, VoidCallback>? menuMap;
  final VoidCallback? onTapBody, onTapAdd,onTapEmptyCard;

  @override
  Widget build(BuildContext context) {
    return batch == null ? buildEmptyCard(context) : buildCard(context, batch!);
  }

  Widget buildEmptyCard(BuildContext context) {
    return GestureDetector(
      onTap: onTapEmptyCard,
      child: Container(
        width: 200,
        color: Colors.transparent,
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
      ),
    );
  }

  GestureDetector buildCard(BuildContext context, String batch) {
    return GestureDetector(
      onTap: onTapBody,
      child: Card(
        child: Container(
          width: 200,
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: buildPopupMenuForBatch(),
              ),
              const Spacer(),
              Text(
                batch,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Description',
                // batch['description']!.toString(),
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
                    '10',
                    // '${batch['students']!}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onTapAdd,
                    child: Container(
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
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuButton<dynamic> buildPopupMenuForBatch() {
    return PopupMenuButton(
      itemBuilder: (c) {
        return menuMap?.keys.map(
              (String choice) {
                return PopupMenuItem(
                  child: Text(choice),
                  onTap: () => menuMap?[choice]?.call(),
                );
              },
            ).toList() ??
            [];
      },
    );
  }

  void studentListOnTapDelete(BuildContext context, String batchName) {
    Future.delayed(
      const Duration(seconds: 0),
      () async {
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Do you Really want to delete'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            AppDataProvider.of(context)
                                .appData
                                .deleteBatchName(batchName);
                            Navigator.pop(context, true);
                          },
                          child: const Text('Yes')),
                      TextButton(
                          onPressed: () {
                            return;
                          },
                          child: const Text('No'))
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
