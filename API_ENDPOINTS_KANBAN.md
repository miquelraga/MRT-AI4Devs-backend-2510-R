# Documentación API - Endpoints Kanban

Esta documentación describe los nuevos endpoints creados para gestionar candidatos en una interfaz tipo Kanban.

## 📋 Índice
- [Obtener Candidatos por Posición](#1-obtener-candidatos-por-posición)
- [Actualizar Etapa del Candidato](#2-actualizar-etapa-del-candidato)
- [Actualizar Etapa por Aplicación](#3-actualizar-etapa-por-aplicación-alternativo)

---

## 1. Obtener Candidatos por Posición

### **Endpoint**
```
GET /positions/:id/candidates
```

### **Descripción**
Obtiene todos los candidatos en proceso para una posición específica. Devuelve información básica del candidato, su etapa actual en el proceso de entrevistas y su puntuación media.

### **Parámetros de URL**
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| id | number | Sí | ID de la posición |

### **Respuesta Exitosa (200 OK)**

```json
{
  "positionId": 1,
  "totalCandidates": 3,
  "candidates": [
    {
      "candidateId": 1,
      "fullName": "Juan Pérez",
      "currentInterviewStep": 1,
      "currentInterviewStepName": "Entrevista Técnica",
      "averageScore": 8.5,
      "applicationId": 5
    },
    {
      "candidateId": 2,
      "fullName": "María García",
      "currentInterviewStep": 2,
      "currentInterviewStepName": "Entrevista HR",
      "averageScore": 9.2,
      "applicationId": 6
    },
    {
      "candidateId": 3,
      "fullName": "Carlos López",
      "currentInterviewStep": 1,
      "currentInterviewStepName": "Entrevista Técnica",
      "averageScore": null,
      "applicationId": 7
    }
  ]
}
```

### **Respuesta de Error**

#### 400 Bad Request - ID inválido
```json
{
  "error": "Invalid position ID format",
  "message": "Position ID must be a valid number"
}
```

#### 404 Not Found - Posición no existe
```json
{
  "error": "Position not found",
  "message": "Position with ID 999 does not exist"
}
```

#### 500 Internal Server Error
```json
{
  "error": "Error fetching position candidates",
  "message": "Database connection error"
}
```

### **Ejemplo de Uso**

#### cURL
```bash
curl -X GET http://localhost:3010/positions/1/candidates
```

#### JavaScript (Fetch)
```javascript
fetch('http://localhost:3010/positions/1/candidates')
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

#### JavaScript (Axios)
```javascript
import axios from 'axios';

try {
  const response = await axios.get('http://localhost:3010/positions/1/candidates');
  console.log(response.data);
} catch (error) {
  console.error('Error:', error.response.data);
}
```

### **Notas**
- `averageScore` será `null` si el candidato no ha tenido ninguna entrevista con puntuación.
- El score es el promedio de todas las entrevistas realizadas por el candidato.
- Los resultados incluyen solo candidatos con aplicaciones activas.

---

## 2. Actualizar Etapa del Candidato

### **Endpoint**
```
PUT /candidates/:id/stage
```

### **Descripción**
Actualiza la etapa del proceso de entrevista de un candidato específico. Busca la aplicación más reciente del candidato y actualiza su `currentInterviewStep`.

### **Parámetros de URL**
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| id | number | Sí | ID del candidato |

### **Body de la Petición**

```json
{
  "currentInterviewStep": 2,
  "notes": "Candidato pasó exitosamente la entrevista técnica. Programar entrevista con HR."
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| currentInterviewStep | number | Sí | ID de la nueva etapa de entrevista |
| notes | string | No | Notas adicionales sobre el cambio |

### **Respuesta Exitosa (200 OK)**

```json
{
  "message": "Candidate stage updated successfully",
  "data": {
    "id": 5,
    "positionId": 1,
    "candidateId": 1,
    "applicationDate": "2024-01-15T10:00:00.000Z",
    "currentInterviewStep": 2,
    "notes": "Candidato pasó exitosamente la entrevista técnica. Programar entrevista con HR.",
    "candidate": {
      "id": 1,
      "firstName": "Juan",
      "lastName": "Pérez",
      "email": "juan.perez@example.com"
    },
    "interviewStep": {
      "id": 2,
      "name": "Entrevista HR",
      "orderIndex": 2
    },
    "position": {
      "id": 1,
      "title": "Senior Software Engineer"
    }
  }
}
```

### **Respuesta de Error**

#### 400 Bad Request - ID inválido
```json
{
  "error": "Invalid candidate ID format",
  "message": "Candidate ID must be a valid number"
}
```

#### 400 Bad Request - Campo requerido faltante
```json
{
  "error": "Missing required field",
  "message": "currentInterviewStep is required"
}
```

#### 400 Bad Request - Tipo de dato inválido
```json
{
  "error": "Invalid data type",
  "message": "currentInterviewStep must be a number"
}
```

#### 404 Not Found - Candidato no existe
```json
{
  "error": "Candidate not found",
  "message": "Candidate with ID 999 does not exist"
}
```

#### 404 Not Found - Etapa de entrevista no existe
```json
{
  "error": "Interview step not found",
  "message": "The specified interview step does not exist"
}
```

#### 404 Not Found - Sin aplicación activa
```json
{
  "error": "No active application",
  "message": "No active application found for this candidate"
}
```

#### 500 Internal Server Error
```json
{
  "error": "Error updating candidate stage",
  "message": "Database connection error"
}
```

### **Ejemplo de Uso**

#### cURL
```bash
curl -X PUT http://localhost:3010/candidates/1/stage \
  -H "Content-Type: application/json" \
  -d '{
    "currentInterviewStep": 2,
    "notes": "Pasó la entrevista técnica con éxito"
  }'
```

#### JavaScript (Fetch)
```javascript
fetch('http://localhost:3010/candidates/1/stage', {
  method: 'PUT',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    currentInterviewStep: 2,
    notes: 'Pasó la entrevista técnica con éxito'
  })
})
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error('Error:', error));
```

#### JavaScript (Axios)
```javascript
import axios from 'axios';

try {
  const response = await axios.put('http://localhost:3010/candidates/1/stage', {
    currentInterviewStep: 2,
    notes: 'Pasó la entrevista técnica con éxito'
  });
  console.log(response.data);
} catch (error) {
  console.error('Error:', error.response.data);
}
```

### **Notas**
- Este endpoint actualiza la aplicación más reciente del candidato.
- Si un candidato tiene múltiples aplicaciones activas, solo se actualizará la más reciente.
- El campo `notes` es opcional y puede contener información adicional sobre el cambio de etapa.

---

## 3. Actualizar Etapa por Aplicación (Alternativo)

### **Endpoint**
```
PUT /applications/:id/stage
```

### **Descripción**
Actualiza la etapa del proceso de entrevista de una aplicación específica. Este endpoint es más preciso cuando se conoce el ID exacto de la aplicación.

### **Parámetros de URL**
| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| id | number | Sí | ID de la aplicación |

### **Body de la Petición**

```json
{
  "currentInterviewStep": 3,
  "notes": "Aprobado para entrevista final con el director"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| currentInterviewStep | number | Sí | ID de la nueva etapa de entrevista |
| notes | string | No | Notas adicionales sobre el cambio |

### **Respuesta Exitosa (200 OK)**

```json
{
  "message": "Application stage updated successfully",
  "data": {
    "id": 5,
    "positionId": 1,
    "candidateId": 1,
    "applicationDate": "2024-01-15T10:00:00.000Z",
    "currentInterviewStep": 3,
    "notes": "Aprobado para entrevista final con el director",
    "candidate": {
      "id": 1,
      "firstName": "Juan",
      "lastName": "Pérez",
      "email": "juan.perez@example.com"
    },
    "interviewStep": {
      "id": 3,
      "name": "Entrevista Final",
      "orderIndex": 3
    },
    "position": {
      "id": 1,
      "title": "Senior Software Engineer"
    }
  }
}
```

### **Respuesta de Error**

Similar a las respuestas de error del endpoint anterior, pero con mensajes adaptados para aplicaciones.

### **Ejemplo de Uso**

#### cURL
```bash
curl -X PUT http://localhost:3010/applications/5/stage \
  -H "Content-Type: application/json" \
  -d '{
    "currentInterviewStep": 3,
    "notes": "Aprobado para entrevista final"
  }'
```

### **Notas**
- Este endpoint es preferible cuando se trabaja directamente con IDs de aplicación (como en un Kanban donde cada tarjeta tiene el `applicationId`).
- Es más preciso que actualizar por candidato, ya que apunta a una aplicación específica.

---

## 🎯 Casos de Uso

### Caso 1: Vista Kanban de Candidatos

```javascript
// 1. Cargar candidatos de una posición
const response = await fetch('http://localhost:3010/positions/1/candidates');
const { candidates } = await response.json();

// 2. Agrupar por etapa para el Kanban
const kanbanColumns = candidates.reduce((acc, candidate) => {
  const stepName = candidate.currentInterviewStepName;
  if (!acc[stepName]) {
    acc[stepName] = [];
  }
  acc[stepName].push(candidate);
  return acc;
}, {});

// 3. Cuando se mueve una tarjeta, actualizar la etapa
async function moveCandidate(candidateId, newStepId) {
  await fetch(`http://localhost:3010/candidates/${candidateId}/stage`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      currentInterviewStep: newStepId
    })
  });
}
```

### Caso 2: Dashboard de Reclutamiento

```javascript
// Obtener estadísticas de una posición
async function getPositionStats(positionId) {
  const response = await fetch(`http://localhost:3010/positions/${positionId}/candidates`);
  const { candidates, totalCandidates } = await response.json();
  
  // Calcular estadísticas
  const stats = {
    total: totalCandidates,
    byStage: {},
    averageScore: candidates
      .filter(c => c.averageScore !== null)
      .reduce((sum, c) => sum + c.averageScore, 0) / candidates.length
  };
  
  candidates.forEach(candidate => {
    const stage = candidate.currentInterviewStepName;
    stats.byStage[stage] = (stats.byStage[stage] || 0) + 1;
  });
  
  return stats;
}
```

---

## 🔄 Flujo Completo de Trabajo

### 1. Obtener candidatos de una posición
```bash
GET /positions/1/candidates
```

### 2. Visualizar en interfaz Kanban
Los candidatos se agrupan por `currentInterviewStepName`.

### 3. Mover candidato a nueva etapa
```bash
PUT /candidates/1/stage
Body: { "currentInterviewStep": 2 }
```

### 4. Actualizar vista (refetch)
```bash
GET /positions/1/candidates
```

---

## 📊 Estructura de Datos

### Modelo de Datos Relacionados

```
Position
  ├── Application (múltiples)
  │   ├── Candidate (uno)
  │   ├── InterviewStep (uno, current)
  │   └── Interview (múltiples)
  │       └── score (opcional)
  └── InterviewFlow
      └── InterviewStep (múltiples, ordenadas)
```

---

## 🛡️ Validaciones

### Endpoint GET /positions/:id/candidates
- ✅ Position ID debe ser un número válido
- ✅ La posición debe existir en la base de datos

### Endpoint PUT /candidates/:id/stage
- ✅ Candidate ID debe ser un número válido
- ✅ El candidato debe existir
- ✅ `currentInterviewStep` es requerido y debe ser un número
- ✅ El interview step debe existir
- ✅ El candidato debe tener al menos una aplicación

### Endpoint PUT /applications/:id/stage
- ✅ Application ID debe ser un número válido
- ✅ La aplicación debe existir
- ✅ `currentInterviewStep` es requerido y debe ser un número
- ✅ El interview step debe existir

---

## 🚀 Próximas Mejoras Sugeridas

- [ ] Agregar filtros por estado (activo, rechazado, contratado)
- [ ] Endpoint para obtener historial de cambios de etapa
- [ ] Webhook/notificación cuando cambia la etapa de un candidato
- [ ] Paginación para posiciones con muchos candidatos
- [ ] Búsqueda y filtrado de candidatos
- [ ] Validación de transiciones de etapa permitidas
- [ ] Logs de auditoría para cambios de etapa

---

**Versión**: 1.0  
**Fecha**: Enero 2026  
**Autor**: Equipo de Desarrollo LTI
