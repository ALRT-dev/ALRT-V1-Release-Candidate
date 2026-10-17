import sharp from "sharp";

/**
 * Cost control for user-uploaded images.
 *
 * Community-report and profile photos arrive as full-resolution originals
 * (the upload middleware allows up to 50MB). Storing and serving those at
 * full size is the single biggest avoidable S3 storage + CloudFront egress
 * cost: a 20MB phone photo is stored as 20MB and re-served at 20MB on every
 * view, cached only by the 1-year cache header (which does not shrink the
 * first fetch).
 *
 * This resizes and re-encodes image uploads to a sensible ceiling and a
 * modest quality, so what is stored and served is a fraction of the source.
 * It is strictly best-effort: if sharp cannot read or process a file, the
 * original buffer is returned untouched (never fail a report over an image).
 *
 * Videos and GIFs are left untouched (sharp is for stills; GIF re-encoding
 * is lossy and the app has animated GIF category images).
 */

export interface OptimizedImage {
  buffer: Buffer;
  mimeType: string;
  /** True when sharp actually re-encoded the image. */
  changed: boolean;
}

/** Longest side a stored image may be; larger images are downscaled. */
const MAX_DIMENSION = 2000;

/** Re-encode quality for JPEG/WebP output. */
const QUALITY = 82;

const IMAGE_MIME_TYPES = new Set([
  "image/jpeg",
  "image/jpg",
  "image/png",
  "image/webp",
]);

/** True when the file is a still image sharp can process. */
export const isOptimizableImage = (mimeType: string): boolean =>
  IMAGE_MIME_TYPES.has(mimeType.toLowerCase());

/**
 * Resize (if larger than the ceiling) and re-encode an image buffer to WebP.
 * Falls back to the original buffer on any sharp error.
 */
export const optimizeImageBuffer = async (
  buffer: Buffer,
  mimeType: string,
): Promise<OptimizedImage> => {
  const originalMime = mimeType.toLowerCase();
  if (!isOptimizableImage(originalMime)) {
    return { buffer, mimeType: originalMime, changed: false };
  }

  try {
    const pipeline = sharp(buffer, { failOn: "none" }).rotate(); // honour EXIF orientation
    const meta = await pipeline.metadata();

    // Only re-encode if the image is larger than the ceiling OR is a lossless
    // PNG that would benefit from WebP compression. Small JPEGs/WebPs stay as
    // they are to avoid a pointless decode/encode round-trip.
    const needsResize =
      (meta.width ?? 0) > MAX_DIMENSION ||
      (meta.height ?? 0) > MAX_DIMENSION;
    const isPng = originalMime === "image/png";

    if (!needsResize && !isPng) {
      return { buffer, mimeType: originalMime, changed: false };
    }

    let next = pipeline;
    if (needsResize) {
      next = next.resize({
        width: MAX_DIMENSION,
        height: MAX_DIMENSION,
        fit: "inside",
        withoutEnlargement: true,
      });
    }

    const optimized = await next.webp({ quality: QUALITY }).toBuffer();

    // Only take the re-encoded result if it is actually smaller than the
    // source (a re-encode can occasionally grow a tiny/highly-compressed
    // image). Otherwise keep the original.
    if (optimized.length >= buffer.length) {
      return { buffer, mimeType: originalMime, changed: false };
    }

    return {
      buffer: optimized,
      mimeType: "image/webp",
      changed: true,
    };
  } catch (error) {
    console.warn("Image optimization skipped (unreadable image):", error);
    return { buffer, mimeType: originalMime, changed: false };
  }
};
