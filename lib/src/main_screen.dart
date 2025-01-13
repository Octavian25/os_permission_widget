import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:os_permission_widget/os_permission_widget.dart';

String getAssetPath(String assetName) => "packages/os_permission_widget/assets/$assetName";

class OsPermissionList extends StatefulWidget {
  final List<OsPermissionModel> listPermission;
  final Function() handleFinish;
  final String title;
  final String loadingTitle;
  final String loadingMessage;
  final TextStyle? titleStyle;
  final String subtitle;
  final TextStyle? subtitleStyle;
  const OsPermissionList(
      {super.key,
      required this.listPermission,
      required this.handleFinish,
      required this.title,
      required this.subtitle,
      required this.loadingMessage,
      required this.loadingTitle,
      this.subtitleStyle,
      this.titleStyle});

  @override
  State<OsPermissionList> createState() => _OsPermissionListState();
}

class _OsPermissionListState extends State<OsPermissionList> {
  ScrollController scrollController = ScrollController();
  List<OsPermissionModel> permissions = [];
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        isLoadingNotifier.value = true;
        for (var permission in widget.listPermission) {
          var isGranted = await permission.permission.isGranted;
          permission.grantedNotifier.value = isGranted;
          permissions.add(permission);
        }
        isLoadingNotifier.value = false;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder(
          valueListenable: isLoadingNotifier,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator.adaptive()),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.loadingTitle,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        widget.loadingMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  )
                ],
              );
            }
            return Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverAppBar.medium(
                      expandedHeight: MediaQuery.of(context).size.height * 0.17,
                      floating: true,
                      snap: true,
                      pinned: true,
                      title: Text(widget.title),
                      backgroundColor: Color(0xffe6f2fe),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
                          child: Image.asset(
                            getAssetPath("default.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ),
                    addPadding(
                        child: Text(
                      widget.title,
                      style:
                          widget.titleStyle ?? TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                    addPadding(
                        child: Text(
                      widget.subtitle,
                      style: widget.subtitleStyle ??
                          TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w300, color: Colors.black54),
                    )),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ),
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        OsPermissionModel data = permissions[index];
                        return ValueListenableBuilder(
                          valueListenable: data.grantedNotifier,
                          builder: (context, granted, child) => ListTile(
                            onTap: () {
                              showRequestPermissionModal(context, data, index);
                            },
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            leading: Image.asset(data.leadingImage),
                            title: Text(
                              data.title,
                              style: data.titleStyle == null
                                  ? TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                                  : data.titleStyle as TextStyle,
                            ),
                            subtitle: Text(
                              data.subtitle,
                              style: data.titleStyle == null
                                  ? TextStyle(fontSize: 13, color: Colors.black54)
                                  : data.subtitleStyle as TextStyle,
                            ),
                            trailing: Icon(
                              granted ? Icons.check_circle : Icons.remove_circle_rounded,
                              color: granted ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                      itemCount: permissions.length,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 70,
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 3)
                    ]),
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                    child: Center(
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: FilledButton(
                              style: Theme.of(context).filledButtonTheme.style == null
                                  ? FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)))
                                  : Theme.of(context).filledButtonTheme.style?.copyWith(
                                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)))),
                              onPressed: () async {
                                if (permissions
                                    .where((e) => e.grantedNotifier.value == false)
                                    .isEmpty) {
                                  widget.handleFinish();
                                }
                                for (var index = 0; index < permissions.length; index++) {
                                  await showRequestPermissionModal(
                                      context, permissions[index], index);
                                }
                              },
                              child: Text("Lanjutkan"))),
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }

  Future<dynamic> showRequestPermissionModal(
      BuildContext context, OsPermissionModel data, int index) async {
    double fullWidth = MediaQuery.of(context).size.width;
    double fullHeight = MediaQuery.of(context).size.height;
    if (await data.permission.isGranted) {
      return;
    }
    if (!context.mounted) return;
    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      elevation: 100,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Image.asset(
              data.leadingImage,
              width: fullWidth * 0.3,
            )),
            SizedBox(
              height: fullWidth * 0.04,
            ),
            SizedBox(
              width: fullWidth * 0.8,
              child: Center(
                child: Text(
                  data.title,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: fullHeight * 0.005,
            ),
            SizedBox(
              width: fullWidth * 0.9,
              child: Center(
                child: Text(data.subtitle,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
              ),
            ),
            SizedBox(
              height: fullHeight * 0.03,
            ),
            SizedBox(
                width: fullWidth * 0.9,
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                          style: Theme.of(context).filledButtonTheme.style == null
                              ? FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)))
                              : Theme.of(context).filledButtonTheme.style?.copyWith(
                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)))),
                          onPressed: () async {
                            // Jalankan logika custom jika ada
                            if (data.handleOnTapGrantedPopup != null) {
                              await data.handleOnTapGrantedPopup!(context);
                            } else {
                              await data.permission.request();
                            }

                            // Update status granted
                            final isGranted = await data.permission.isGranted;
                            data.grantedNotifier.value = isGranted;
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                          child: Text("Izinkan")),
                    ),
                    SizedBox(
                      width: fullWidth * 0.05,
                    ),
                    TextButton(
                      style: Theme.of(context).filledButtonTheme.style == null
                          ? TextButton.styleFrom(
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                          : Theme.of(context).textButtonTheme.style?.copyWith(
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                      onPressed: () {
                        // Update status granted

                        data.grantedNotifier.value = false;
                        Navigator.pop(context);
                      },
                      child: Text("Tolak"),
                    )
                  ],
                )),
            SizedBox(
              height: fullHeight * 0.03,
            ),
          ],
        );
      },
    );
  }
}

SliverToBoxAdapter addPadding({required Widget child}) {
  return SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: child,
    ),
  );
}
