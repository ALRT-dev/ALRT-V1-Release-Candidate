import type { NextFunction, Request, Response } from 'express';
import prisma from '../utils/prisma_client.util.js';

/** Current leaf taxonomy for authenticated ingestion workers. No media URLs,
 * credentials, user data, alert writes or direct database access are exposed. */
export async function getWebhookCategories(_req: Request, res: Response, next: NextFunction) {
  try {
    const categories = await prisma.hazardCategory.findMany({
      where: { parentId: { not: null } },
      select: { id: true, name: true, parentId: true, description: true, keywords: true },
      orderBy: { id: 'asc' },
    });
    res.setHeader('Cache-Control', 'private, no-store');
    res.status(200).json(categories);
  } catch (error) { next(error); }
}
