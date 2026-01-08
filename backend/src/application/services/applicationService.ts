import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface UpdateStageData {
    currentInterviewStep: number;
    notes?: string;
}

/**
 * Actualiza la etapa del proceso de entrevista de un candidato
 * @param candidateId - ID del candidato
 * @param stageData - Datos de la nueva etapa
 * @returns Application actualizada
 */
export const updateCandidateStage = async (
    candidateId: number,
    stageData: UpdateStageData
) => {
    try {
        // Verificar que el candidato existe
        const candidate = await prisma.candidate.findUnique({
            where: { id: candidateId }
        });

        if (!candidate) {
            throw new Error('Candidate not found');
        }

        // Verificar que el interview step existe
        const interviewStep = await prisma.interviewStep.findUnique({
            where: { id: stageData.currentInterviewStep }
        });

        if (!interviewStep) {
            throw new Error('Interview step not found');
        }

        // Buscar la aplicación activa del candidato
        // Asumimos que el candidato tiene una aplicación activa (la más reciente)
        const application = await prisma.application.findFirst({
            where: {
                candidateId: candidateId
            },
            orderBy: {
                applicationDate: 'desc'
            }
        });

        if (!application) {
            throw new Error('No active application found for this candidate');
        }

        // Actualizar la etapa del candidato
        const updatedApplication = await prisma.application.update({
            where: {
                id: application.id
            },
            data: {
                currentInterviewStep: stageData.currentInterviewStep,
                notes: stageData.notes
            },
            include: {
                candidate: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true
                    }
                },
                interviewStep: {
                    select: {
                        id: true,
                        name: true,
                        orderIndex: true
                    }
                },
                position: {
                    select: {
                        id: true,
                        title: true
                    }
                }
            }
        });

        return updatedApplication;
    } catch (error: any) {
        console.error('Error al actualizar la etapa del candidato:', error);
        throw error;
    }
};

/**
 * Actualiza la etapa del candidato por ID de aplicación específica
 * @param applicationId - ID de la aplicación
 * @param stageData - Datos de la nueva etapa
 * @returns Application actualizada
 */
export const updateApplicationStage = async (
    applicationId: number,
    stageData: UpdateStageData
) => {
    try {
        // Verificar que la aplicación existe
        const application = await prisma.application.findUnique({
            where: { id: applicationId }
        });

        if (!application) {
            throw new Error('Application not found');
        }

        // Verificar que el interview step existe
        const interviewStep = await prisma.interviewStep.findUnique({
            where: { id: stageData.currentInterviewStep }
        });

        if (!interviewStep) {
            throw new Error('Interview step not found');
        }

        // Actualizar la etapa
        const updatedApplication = await prisma.application.update({
            where: {
                id: applicationId
            },
            data: {
                currentInterviewStep: stageData.currentInterviewStep,
                notes: stageData.notes
            },
            include: {
                candidate: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true
                    }
                },
                interviewStep: {
                    select: {
                        id: true,
                        name: true,
                        orderIndex: true
                    }
                },
                position: {
                    select: {
                        id: true,
                        title: true
                    }
                }
            }
        });

        return updatedApplication;
    } catch (error: any) {
        console.error('Error al actualizar la etapa de la aplicación:', error);
        throw error;
    }
};
