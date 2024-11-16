import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

Future<XFile?> compressImage(XFile pickedFile,
    {int height = 240, int width = 240, int quality = 100}) async {
  final tempDir = await getTemporaryDirectory();
  final targetPath =
      join(tempDir.path, 'compressed_${basename(pickedFile.path)}');

  // Compress and resize the image
  final compressedImage = await FlutterImageCompress.compressAndGetFile(
    pickedFile.path,
    targetPath,
    quality: quality, // Compression quality: adjust as needed (0-100)
    minWidth: height, // Set a max width if desired
    minHeight: width, // Set a max height if desired
  );

  return compressedImage;
}
