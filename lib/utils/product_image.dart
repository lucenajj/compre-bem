import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'device.dart';

/// Tira/seleciona a foto do produto e devolve um thumbnail JPEG
/// (base64, lado máximo 640px, qualidade 60). Retorna null se o
/// usuário cancelar ou a imagem for inválida.
///
/// No celular (app nativo ou navegador mobile) pergunta se quer tirar
/// foto ou escolher da galeria. No desktop abre o seletor de arquivo.
Future<String?> pickProductPhoto(BuildContext context) async {
  final picker = ImagePicker();
  ImageSource? source;
  if (isMobileDevice) {
    source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(c, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(c, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  } else {
    source = ImageSource.gallery; // no desktop abre o seletor de arquivo
  }
  if (source == null) return null;

  final file = await picker.pickImage(source: source, maxWidth: 1280);
  if (file == null) return null;
  try {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final resized = decoded.width > 640
        ? img.copyResize(decoded, width: 640)
        : decoded;
    return base64Encode(img.encodeJpg(resized, quality: 60));
  } catch (_) {
    return null;
  }
}

/// Thumbnail do produto: foto ou ícone padrão quando não há foto.
Widget productThumb(String? base64, {double size = 48}) {
  if (base64 == null || base64.isEmpty) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.shopping_basket_outlined,
          size: size * 0.55, color: Colors.grey.shade500),
    );
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.memory(
      base64Decode(base64),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.broken_image_outlined,
            size: size * 0.55, color: Colors.grey.shade500),
      ),
    ),
  );
}
