import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';

class ViewImage extends StatefulWidget {
  ViewImage(this.thisImages, this.page,
      {super.key, this.isNetworkImage = true});
  bool isNetworkImage;
  int page;
  List<String> thisImages;
  int currPage = 0;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  void initState() {
    super.initState();
    widget.currPage = widget.page;
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController =
        PageController(initialPage: widget.page - 1);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          centerTitle: true,
          title: StyledTitle(
              '${widget.currPage.toString()} / ${widget.thisImages.length}'),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: PhotoViewGallery.builder(
          onPageChanged: (page) {
            setState(() {
              log('Setting page');
              widget.currPage = page + 1;
            });
          },
          pageController: pageController,
          scrollPhysics: const BouncingScrollPhysics(),

          builder: (BuildContext context, int index) {
            return _isNetworkImage(widget.thisImages[index])
                ? PhotoViewGalleryPageOptions.customChild(
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
                    // heroAttributes: PhotoViewHeroAttributes(tag: galleryItems[index].id),
                  );
          },
          // itemCount: galleryItems.length,
          itemCount: widget.thisImages.length,
          loadingBuilder: (context, event) => const Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: Loading(),
            ),
          ),
          // backgroundDecoration: widget.backgroundDecoration,
          // pageController: widget.pageController,
          // onPageChanged: onPageChanged,
        ));
  }
}
