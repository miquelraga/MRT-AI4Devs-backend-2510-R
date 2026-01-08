import { Request, Response } from 'express';
import { getCandidatesByPosition } from '../../application/services/positionService';

/**
 * Controller para obtener todos los candidatos de una posición
 * GET /positions/:id/candidates
 */
export const getPositionCandidates = async (req: Request, res: Response) => {
    try {
        const positionId = parseInt(req.params.id);
        
        if (isNaN(positionId)) {
            return res.status(400).json({ 
                error: 'Invalid position ID format',
                message: 'Position ID must be a valid number'
            });
        }

        const candidates = await getCandidatesByPosition(positionId);
        
        res.status(200).json({
            positionId,
            totalCandidates: candidates.length,
            candidates
        });
    } catch (error: unknown) {
        if (error instanceof Error) {
            if (error.message === 'Position not found') {
                return res.status(404).json({ 
                    error: 'Position not found',
                    message: `Position with ID ${req.params.id} does not exist`
                });
            }
            res.status(500).json({ 
                error: 'Error fetching position candidates', 
                message: error.message 
            });
        } else {
            res.status(500).json({ 
                error: 'Error fetching position candidates', 
                message: 'Unknown error' 
            });
        }
    }
};
