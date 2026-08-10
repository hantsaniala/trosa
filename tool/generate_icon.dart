// Generates the Trosa launcher icon artwork (brand yellow + dark
// double-headed arrow) with no external dependencies:
//
//   dart run tool/generate_icon.dart
//
// Outputs (all 1024x1024 unless noted):
//   assets/icons/main_icon.png               — Android legacy: rounded yellow
//                                              square + arrow, transparent corners
//   assets/icons/main_icon_ios.png           — iOS: full-bleed yellow square + arrow
//   assets/icons/main_icon_foreground.png    — adaptive foreground: arrow only
//   assets/icons/main_icon-512x512.png       — 512px legacy version
//
// The PNG encoder writes an uncompressed (stored) zlib stream, which every
// PNG decoder accepts; no image packages required.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int N = 1024; // render size
const double c = 512; // canvas center

// Palette — must match lib/theme.dart.
const double brandR = 0xFE / 255.0; // #FECE00
const double brandG = 0xCE / 255.0;
const double brandB = 0x00 / 255.0;
const double inkR = 0x24 / 255.0; // #241D00
const double inkG = 0x1D / 255.0;
const double inkB = 0x00 / 255.0;

// ---------------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------------

class Pt {
  final double x, y;
  const Pt(this.x, this.y);
}

double segDist(double px, double py, double ax, double ay, double bx,
    double by) {
  final vx = bx - ax, vy = by - ay;
  final wx = px - ax, wy = py - ay;
  final l2 = vx * vx + vy * vy;
  final t = l2 == 0 ? 0.0 : (wx * vx + wy * vy) / l2;
  final t2 = t.clamp(0.0, 1.0);
  final dx = px - (ax + vx * t2), dy = py - (ay + vy * t2);
  return math.sqrt(dx * dx + dy * dy);
}

/// Signed distance to a triangle: negative inside, exact on the boundary.
double distTri(double px, double py, Pt a0, Pt b0, Pt c0) {
  var a = a0, b = b0, c = c0;
  // Ensure counter-clockwise winding so the edge cross products are all
  // positive inside the triangle.
  final area = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
  if (area < 0) {
    final tmp = b;
    b = c;
    c = tmp;
  }
  final inside = ((b.x - a.x) * (py - a.y) - (b.y - a.y) * (px - a.x) >= 0) &&
      ((c.x - b.x) * (py - b.y) - (c.y - b.y) * (px - b.x) >= 0) &&
      ((a.x - c.x) * (py - c.y) - (a.y - c.y) * (px - c.x) >= 0);
  final d = math.min(
      segDist(px, py, a.x, a.y, b.x, b.y),
      math.min(segDist(px, py, b.x, b.y, c.x, c.y),
          segDist(px, py, c.x, c.y, a.x, a.y)));
  return inside ? -d : d;
}

/// Signed distance to a rounded rectangle (negative inside).
double distRR(double px, double py, double x0, double y0, double x1,
    double y1, double r) {
  final cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
  final hw = (x1 - x0) / 2 - r, hh = (y1 - y0) / 2 - r;
  final qx = (px - cx).abs() - hw, qy = (py - cy).abs() - hh;
  final ox = math.max(qx, 0.0), oy = math.max(qy, 0.0);
  return math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0.0) - r;
}

/// 0 outside → 1 inside over a 1px antialiasing ramp.
double cov(double d) {
  if (d <= -0.5) return 1.0;
  if (d >= 0.5) return 0.0;
  return 0.5 - d;
}

// Arrow geometry. The double-headed arrow sits on the y = -x + 1024 diagonal:
// north-east head = money to pay, south-west head = money to receive (same
// metaphor as the in-app card icons).
class Arrow {
  final double s; // head-tip half extent from center
  final double headLen;
  final double baseHalf;
  final double shaftR;
  late final Pt tNe, bNe, tSw, bSw; // tips and base centers
  late final Pt c1Ne, c2Ne, c1Sw, c2Sw; // head base corners

  Arrow(this.s, this.headLen, this.baseHalf, this.shaftR) {
    final d = math.sqrt(2) / 2;
    // Perpendicular of the shaft axis is (d, d); the base corners sit on both
    // sides of the axis (the same y sign for both would make a degenerate,
    // collinear triangle).
    tNe = Pt(c + s, c - s);
    bNe = Pt(tNe.x - headLen * d, tNe.y + headLen * d);
    c1Ne = Pt(bNe.x - baseHalf * d, bNe.y - baseHalf * d);
    c2Ne = Pt(bNe.x + baseHalf * d, bNe.y + baseHalf * d);
    tSw = Pt(c - s, c + s);
    bSw = Pt(tSw.x + headLen * d, tSw.y - headLen * d);
    c1Sw = Pt(bSw.x - baseHalf * d, bSw.y - baseHalf * d);
    c2Sw = Pt(bSw.x + baseHalf * d, bSw.y + baseHalf * d);
  }

  double shaftDist(double px, double py) =>
      segDist(px, py, bNe.x, bNe.y, bSw.x, bSw.y) - shaftR;

  double triNe(double px, double py) => distTri(px, py, tNe, c1Ne, c2Ne);

  double triSw(double px, double py) => distTri(px, py, tSw, c1Sw, c2Sw);
}

// ---------------------------------------------------------------------------
// Rasterizer
// ---------------------------------------------------------------------------

enum Kind { legacy, ios, foreground }

Uint8List render(Kind kind) {
  final img = Uint8List(N * N * 4);
  // Same arrow for every variant; the adaptive icon XML adds the 16% inset
  // that keeps the glyph inside the launcher's circular safe zone.
  final arrow = Arrow(240, 185, 80, 66);

  for (var y = 0; y < N; y++) {
    for (var x = 0; x < N; x++) {
      final px = x + 0.5, py = y + 0.5;
      double bgA = 0;
      double bgR = 0, bgG = 0, bgB = 0;
      if (kind == Kind.legacy) {
        bgA = cov(distRR(px, py, 0, 0, N.toDouble(), N.toDouble(), 210));
        bgR = brandR;
        bgG = brandG;
        bgB = brandB;
      } else if (kind == Kind.ios) {
        bgA = 1;
        bgR = brandR;
        bgG = brandG;
        bgB = brandB;
      }

      final dArrow = math.min(
          arrow.shaftDist(px, py),
          math.min(arrow.triNe(px, py), arrow.triSw(px, py)));
      final arrowA = cov(dArrow);

      double r, g, b, alpha;
      if (kind == Kind.foreground) {
        r = inkR;
        g = inkG;
        b = inkB;
        alpha = arrowA;
      } else {
        // Ink blends over the yellow background.
        r = inkR * arrowA + bgR * (1 - arrowA);
        g = inkG * arrowA + bgG * (1 - arrowA);
        b = inkB * arrowA + bgB * (1 - arrowA);
        alpha = bgA;
      }

      final i = (y * N + x) * 4;
      img[i] = (r * 255).round().clamp(0, 255);
      img[i + 1] = (g * 255).round().clamp(0, 255);
      img[i + 2] = (b * 255).round().clamp(0, 255);
      img[i + 3] = (alpha * 255).round().clamp(0, 255);
    }
  }
  return img;
}

// ---------------------------------------------------------------------------
// PNG encoder (stored zlib blocks — no external libs)
// ---------------------------------------------------------------------------

Uint32List _crcTable() {
  final t = Uint32List(256);
  for (var n = 0; n < 256; n++) {
    var c = n;
    for (var k = 0; k < 8; k++) {
      c = (c & 1) != 0 ? 0xedb88320 ^ (c >> 1) : c >> 1;
    }
    t[n] = c;
  }
  return t;
}

final Uint32List _crcTableCached = _crcTable();

int _crc32(List<int> data) {
  var crc = 0xffffffff;
  for (final byte in data) {
    crc = _crcTableCached[(crc ^ byte) & 0xff] ^ (crc >> 8);
  }
  return crc ^ 0xffffffff;
}

int _adler32(List<int> data) {
  var a = 1, b = 0;
  for (final byte in data) {
    a = (a + byte) % 65521;
    b = (b + a) % 65521;
  }
  return (b << 16) | a;
}

void _chunk(BytesBuilder out, String type, List<int> payload) {
  final typeBytes = type.codeUnits;
  final crcInput = <int>[...typeBytes, ...payload];
  final crc = _crc32(crcInput);
  final len = payload.length;
  out.add([
    (len >> 24) & 0xff, (len >> 16) & 0xff, (len >> 8) & 0xff, len & 0xff,
  ]);
  out.add(typeBytes);
  out.add(payload);
  out.add([
    (crc >> 24) & 0xff, (crc >> 16) & 0xff, (crc >> 8) & 0xff, crc & 0xff,
  ]);
}

/// zlib stream with stored (uncompressed) deflate blocks.
List<int> _zlibStore(List<int> data) {
  final out = BytesBuilder();
  out.add([0x78, 0x01]); // zlib header, no compression
  var offset = 0;
  while (offset < data.length) {
    final n = math.min(65535, data.length - offset);
    final last = offset + n >= data.length ? 1 : 0;
    out.add([last]);
    out.add([n & 0xff, (n >> 8) & 0xff]); // LEN
    out.add([(~n) & 0xff, ((~n) >> 8) & 0xff]); // NLEN
    out.add(data.sublist(offset, offset + n));
    offset += n;
  }
  final a = _adler32(data);
  out.add([(a >> 24) & 0xff, (a >> 16) & 0xff, (a >> 8) & 0xff, a & 0xff]);
  return out.takeBytes();
}

List<int> _encodePng(Uint8List rgba, int w, int h) {
  final raw = BytesBuilder();
  for (var y = 0; y < h; y++) {
    raw.add([0]); // filter: none
    raw.add(rgba.sublist(y * w * 4, (y + 1) * w * 4));
  }
  final idat = _zlibStore(raw.takeBytes());

  final out = BytesBuilder();
  out.add([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  final ihdr = [
    (w >> 24) & 0xff, (w >> 16) & 0xff, (w >> 8) & 0xff, w & 0xff,
    (h >> 24) & 0xff, (h >> 16) & 0xff, (h >> 8) & 0xff, h & 0xff,
    8, // bit depth
    6, // color type RGBA
    0, 0, 0,
  ];
  _chunk(out, 'IHDR', ihdr);
  _chunk(out, 'IDAT', idat);
  _chunk(out, 'IEND', const []);
  return out.takeBytes();
}

Uint8List _downsample2x(Uint8List src, int w, int h) {
  final dw = w ~/ 2, dh = h ~/ 2;
  final dst = Uint8List(dw * dh * 4);
  for (var y = 0; y < dh; y++) {
    for (var x = 0; x < dw; x++) {
      var r = 0, g = 0, b = 0, a = 0;
      for (var dy = 0; dy < 2; dy++) {
        for (var dx = 0; dx < 2; dx++) {
          final i = (((y * 2 + dy) * w + (x * 2 + dx)) * 4);
          r += src[i];
          g += src[i + 1];
          b += src[i + 2];
          a += src[i + 3];
        }
      }
      final j = (y * dw + x) * 4;
      dst[j] = (r / 4).round();
      dst[j + 1] = (g / 4).round();
      dst[j + 2] = (b / 4).round();
      dst[j + 3] = (a / 4).round();
    }
  }
  return dst;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void _write(String path, List<int> bytes) {
  File(path).writeAsBytesSync(bytes);
  stdout.writeln('wrote $path (${bytes.length} bytes)');
}

void _preview(Uint8List rgba, int w, int h) {
  final cols = 48;
  final rows = 24;
  stdout.writeln('--- ASCII preview (Y=brand yellow, K=ink, .=transparent) ---');
  for (var r = 0; r < rows; r++) {
    final sb = StringBuffer();
    for (var c2 = 0; c2 < cols; c2++) {
      var rr = 0.0, gg = 0.0, aa = 0.0;
      final x0 = (c2 * w) ~/ cols, x1 = ((c2 + 1) * w) ~/ cols;
      final y0 = (r * h) ~/ rows, y1 = ((r + 1) * h) ~/ rows;
      for (var y = y0; y < y1; y++) {
        for (var x = x0; x < x1; x++) {
          final i = (y * w + x) * 4;
          rr += rgba[i] / 255.0;
          gg += rgba[i + 1] / 255.0;
          aa += rgba[i + 3] / 255.0;
        }
      }
      final n = (x1 - x0) * (y1 - y0);
      rr /= n;
      gg /= n;
      aa /= n;
      if (aa < 0.4) {
        sb.write('.');
      } else if (rr > 0.65 && gg > 0.5) {
        sb.write('Y');
      } else {
        sb.write('K');
      }
    }
    stdout.writeln(sb.toString());
  }
}

void main() {
  final legacy = render(Kind.legacy);
  final ios = render(Kind.ios);
  final fg = render(Kind.foreground);

  _preview(legacy, N, N);

  _write('assets/icons/main_icon.png', _encodePng(legacy, N, N));
  _write('assets/icons/main_icon_ios.png', _encodePng(ios, N, N));
  _write('assets/icons/main_icon_foreground.png', _encodePng(fg, N, N));

  final s512 = _downsample2x(legacy, N, N);
  _write('assets/icons/main_icon-512x512.png', _encodePng(s512, 512, 512));

  stdout.writeln('done');
}
