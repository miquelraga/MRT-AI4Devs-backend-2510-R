import { Request, Response } from 'express';
import { updateCandidateStage, updateApplicationStage } from '../../application/services/applicationService';

/**
 * Controller para actualizar la etapa de un candidato
 * PUT /candidates/:id/stage
 */
export const updateCandidateStageController = async (req: Request, res: Response) => {
    try {
        const candidateId = parseInt(req.params.id);
        
        if (isNaN(candidateId)) {
            return res.status(400).json({ 
                error: 'Invalid candidate ID format',
                message: 'Candidate ID must be a valid number'
            });
        }

        const { currentInterviewStep, notes } = req.body;

        if (!currentInterviewStep) {
            return res.status(400).json({ 
                error: 'Missing required field',
                message: 'currentInterviewStep is required'
            });
        }

        if (typeof currentInterviewStep !== 'number') {
            return res.status(400).json({ 
                error: 'Invalid data type',
                message: 'currentInterviewStep must be a number'
            });
        }

        const updatedApplication = await updateCandidateStage(candidateId, {
            currentInterviewStep,
            notes
        });

        res.status(200).json({
            message: 'Candidate stage updated successfully',
            data: updatedApplication
        });
    } catch (error: unknown) {
        if (error instanceof Error) {
            if (error.message === 'Candidate not found') {
                return res.status(404).json({ 
                    error: 'Candidate not found',
                    message: `Candidate with ID ${req.params.id} does not exist`
                });
            }
            if (error.message === 'Interview step not found') {
                return res.status(404).json({ 
                    error: 'Interview step not found',
                    message: 'The specified interview step does not exist'
                });
            }
            if (error.message === 'No active application found for this candidate') {
                return res.status(404).json({ 
                    error: 'No active application',
                    message: 'No active application found for this candidate'
                });
            }
            res.status(500).json({ 
                error: 'Error updating candidate stage', 
                message: error.message 
            });
        } else {
            res.status(500).json({ 
                error: 'Error updating candidate stage', 
                message: 'Unknown error' 
            });
        }
    }
};

/**
 * Controller alternativo para actualizar por ID de aplicación
 * PUT /applications/:id/stage
 */
export const updateApplicationStageController = async (req: Request, res: Response) => {
    try {
        const applicationId = parseInt(req.params.id);
        
        if (isNaN(applicationId)) {
            return res.status(400).json({ 
                error: 'Invalid application ID format',
                message: 'Application ID must be a valid number'
            });
        }

        const { currentInterviewStep, notes } = req.body;

        if (!currentInterviewStep) {
            return res.status(400).json({ 
                error: 'Missing required field',
                message: 'currentInterviewStep is required'
            });
        }

        if (typeof currentInterviewStep !== 'number') {
            return res.status(400).json({ 
                error: 'Invalid data type',
                message: 'currentInterviewStep must be a number'
            });
        }

        const updatedApplication = await updateApplicationStage(applicationId, {
            currentInterviewStep,
            notes
        });

        res.status(200).json({
            message: 'Application stage updated successfully',
            data: updatedApplication
        });
    } catch (error: unknown) {
        if (error instanceof Error) {
            if (error.message === 'Application not found') {
                return res.status(404).json({ 
                    error: 'Application not found',
                    message: `Application with ID ${req.params.id} does not exist`
                });
            }
            if (error.message === 'Interview step not found') {
                return res.status(404).json({ 
                    error: 'Interview step not found',
                    message: 'The specified interview step does not exist'
                });
            }
            res.status(500).json({ 
                error: 'Error updating application stage', 
                message: error.message 
            });
        } else {
            res.status(500).json({ 
                error: 'Error updating application stage', 
                message: 'Unknown error' 
            });
        }
    }
};
