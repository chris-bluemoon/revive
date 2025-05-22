import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';

class ViewImage extends StatefulWidget {
  const ViewImage(this.thisImages, this.page,
      {super.key, this.isNetworkImage = true});
  final bool isNetworkImage;
  final int page;
  final List<String> thisImages;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  void initState() {
    super.initState();
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController =
        PageController(initialPage: widget.page - 1);
    double width = MediaQuery.of(context).size.width;
    int currPage = widget.page;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          centerTitle: true,
          title: StyledTitle(
              '${currPage.toString()} / ${widget.thisImages.length}'),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: PhotoViewGallery.builder(
          itemCount: widget.thisImages.length,
          loadingBuilder: (context, event) => const Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: Loading(),
            ),
          ),
          backgroundDecoration: const BoxDecoration(
            color: Color.fromARGB(255, 188, 188, 188),
          ),
          onPageChanged: (page) {
            setState(() {
              log('Setting page');
              currPage = page + 1;
            });
          },
          pageController: pageController,
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return _isNetworkImage(widget.thisImages[index])
                ? PhotoViewGalleryPageOptions.customChild(
                    initialScale: PhotoViewComputedScale.contained * 0.97,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2.0,
                    child: CachedNetworkImage(
                      imageUrl: widget.thisImages[index],
                      placeholder: (context, url) =>
                          const Center(child: Loading()),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.error)),
                      fit: BoxFit.contain,
                    ))
                : PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(File(widget.thisImages[index])),
                    initialScale: PhotoViewComputedScale.contained * 1,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2.0,
                    // heroAttributes: PhotoViewHeroAttributes(tag: galleryItems[index].id),
                  );
          },
          // itemCount: galleryItems.length,
        ));
  }
}
