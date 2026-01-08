import { Router } from 'express';
import { updateApplicationStageController } from '../presentation/controllers/applicationController';

const router = Router();

/**
 * PUT /applications/:id/stage
 * Actualiza la etapa del proceso de entrevista de una aplicación específica
 */
router.put('/:id/stage', updateApplicationStageController);

export default router;
