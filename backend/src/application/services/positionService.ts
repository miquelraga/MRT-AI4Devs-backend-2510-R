import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface CandidateKanbanInfo {
    candidateId: number;
    fullName: string;
    currentInterviewStep: number;
    currentInterviewStepName: string;
    averageScore: number | null;
    applicationId: number;
}

/**
 * Obtiene todos los candidatos en proceso para una posición específica
 * con información para vista Kanban
 * @param positionId - ID de la posición
 * @returns Array de candidatos con información básica y puntuación media
 */
export const getCandidatesByPosition = async (positionId: number): Promise<CandidateKanbanInfo[]> => {
    try {
        // Verificar que la posición existe
        const position = await prisma.position.findUnique({
            where: { id: positionId }
        });

        if (!position) {
            throw new Error('Position not found');
        }

        // Obtener todas las aplicaciones para esta posición con datos relacionados
        const applications = await prisma.application.findMany({
            where: {
                positionId: positionId
            },
            include: {
                candidate: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true
                    }
                },
                interviewStep: {
                    select: {
                        id: true,
                        name: true,
                        orderIndex: true
                    }
                },
                interviews: {
                    select: {
                        score: true
                    }
                }
            }
        });

        // Transformar los datos al formato requerido
        const candidatesInfo: CandidateKanbanInfo[] = applications.map((app: any) => {
            // Calcular puntuación media
            const scores = app.interviews
                .map((interview: any) => interview.score)
                .filter((score: any): score is number => score !== null);
            
            const averageScore = scores.length > 0
                ? scores.reduce((sum: number, score: number) => sum + score, 0) / scores.length
                : null;

            return {
                candidateId: app.candidate.id,
                fullName: `${app.candidate.firstName} ${app.candidate.lastName}`,
                currentInterviewStep: app.currentInterviewStep,
                currentInterviewStepName: app.interviewStep.name,
                averageScore: averageScore ? Math.round(averageScore * 100) / 100 : null,
                applicationId: app.id!
            };
        });

        return candidatesInfo;
    } catch (error: any) {
        console.error('Error al obtener candidatos por posición:', error);
        throw error;
    }
};
