import { Router } from 'express';
import { getPositionCandidates } from '../presentation/controllers/positionController';

const router = Router();

/**
 * GET /positions/:id/candidates
 * Obtiene todos los candidatos en proceso para una posición específica
 * Información para vista Kanban
 */
router.get('/:id/candidates', getPositionCandidates);

export default router;
