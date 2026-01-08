# Guía Rápida de Prueba - Nuevos Endpoints Kanban

## 🚀 Inicio Rápido

### 1. Levantar el Entorno

```bash
# Terminal 1: Base de datos
docker-compose up -d

# Terminal 2: Backend
cd backend
npm run dev
```

El servidor estará disponible en `http://localhost:3010`

---

## 🧪 Pruebas con cURL

### Endpoint 1: GET /positions/:id/candidates

**Obtener candidatos de una posición**

```bash
# Obtener candidatos de la posición con ID 1
curl http://localhost:3010/positions/1/candidates

# Con formato JSON bonito (si tienes jq instalado)
curl http://localhost:3010/positions/1/candidates | jq
```

**Respuesta esperada:**
```json
{
  "positionId": 1,
  "totalCandidates": 2,
  "candidates": [
    {
      "candidateId": 1,
      "fullName": "Juan Pérez",
      "currentInterviewStep": 1,
      "currentInterviewStepName": "Screening",
      "averageScore": 8.5,
      "applicationId": 1
    }
  ]
}
```

### Endpoint 2: PUT /candidates/:id/stage

**Actualizar etapa de un candidato**

```bash
# Actualizar candidato ID 1 a la etapa 2
curl -X PUT http://localhost:3010/candidates/1/stage \
  -H "Content-Type: application/json" \
  -d '{"currentInterviewStep": 2, "notes": "Pasó la primera fase"}'

# Con formato bonito
curl -X PUT http://localhost:3010/candidates/1/stage \
  -H "Content-Type: application/json" \
  -d '{"currentInterviewStep": 2, "notes": "Pasó la primera fase"}' | jq
```

**Respuesta esperada:**
```json
{
  "message": "Candidate stage updated successfully",
  "data": {
    "id": 1,
    "candidateId": 1,
    "currentInterviewStep": 2,
    "notes": "Pasó la primera fase",
    "candidate": {
      "id": 1,
      "firstName": "Juan",
      "lastName": "Pérez",
      "email": "juan.perez@example.com"
    },
    "interviewStep": {
      "id": 2,
      "name": "Entrevista Técnica",
      "orderIndex": 2
    }
  }
}
```

### Endpoint 3 (Bonus): PUT /applications/:id/stage

**Actualizar etapa por ID de aplicación**

```bash
# Actualizar aplicación ID 1 a la etapa 3
curl -X PUT http://localhost:3010/applications/1/stage \
  -H "Content-Type: application/json" \
  -d '{"currentInterviewStep": 3}'
```

---

## 🧪 Pruebas con Postman/Insomnia

### Configuración

1. **Base URL**: `http://localhost:3010`
2. **Headers**: `Content-Type: application/json`

### Colección de Requests

#### 1. GET Candidates by Position
- **Method**: GET
- **URL**: `{{base_url}}/positions/1/candidates`
- **Headers**: None required

#### 2. Update Candidate Stage
- **Method**: PUT
- **URL**: `{{base_url}}/candidates/1/stage`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "currentInterviewStep": 2,
  "notes": "Candidato aprobado para siguiente fase"
}
```

#### 3. Update Application Stage
- **Method**: PUT
- **URL**: `{{base_url}}/applications/1/stage`
- **Headers**: `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "currentInterviewStep": 3,
  "notes": "Aprobado para entrevista final"
}
```

---

## 🧪 Pruebas con Thunder Client (VS Code)

### Instalación
```bash
code --install-extension rangav.vscode-thunder-client
```

### Colección JSON

```json
{
  "clientName": "Thunder Client",
  "collectionName": "LTI Kanban API",
  "requests": [
    {
      "name": "Get Position Candidates",
      "method": "GET",
      "url": "http://localhost:3010/positions/1/candidates",
      "headers": []
    },
    {
      "name": "Update Candidate Stage",
      "method": "PUT",
      "url": "http://localhost:3010/candidates/1/stage",
      "headers": [
        {
          "name": "Content-Type",
          "value": "application/json"
        }
      ],
      "body": {
        "type": "json",
        "raw": "{\n  \"currentInterviewStep\": 2,\n  \"notes\": \"Pasó la primera fase\"\n}"
      }
    },
    {
      "name": "Update Application Stage",
      "method": "PUT",
      "url": "http://localhost:3010/applications/1/stage",
      "headers": [
        {
          "name": "Content-Type",
          "value": "application/json"
        }
      ],
      "body": {
        "type": "json",
        "raw": "{\n  \"currentInterviewStep\": 3,\n  \"notes\": \"Aprobado para entrevista final\"\n}"
      }
    }
  ]
}
```

---

## 🎯 Escenarios de Prueba

### Escenario 1: Flujo Completo Kanban

```bash
# 1. Ver candidatos actuales de la posición 1
curl http://localhost:3010/positions/1/candidates | jq

# 2. Mover candidato 1 a la siguiente etapa
curl -X PUT http://localhost:3010/candidates/1/stage \
  -H "Content-Type: application/json" \
  -d '{"currentInterviewStep": 2}'

# 3. Verificar el cambio
curl http://localhost:3010/positions/1/candidates | jq
```

### Escenario 2: Validar Errores

```bash
# Error: Posición no existe
curl http://localhost:3010/positions/999/candidates

# Error: Candidato no existe
curl -X PUT http://localhost:3010/candidates/999/stage \
  -H "Content-Type: application/json" \
  -d '{"currentInterviewStep": 2}'

# Error: Campo requerido faltante
curl -X PUT http://localhost:3010/candidates/1/stage \
  -H "Content-Type: application/json" \
  -d '{}'

# Error: ID no numérico
curl http://localhost:3010/positions/abc/candidates
```

### Escenario 3: Datos de Prueba

**Crear datos de prueba si la BD está vacía:**

```bash
# 1. Crear un candidato
curl -X POST http://localhost:3010/candidates \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Usuario",
    "email": "test@example.com",
    "phone": "123456789"
  }'
```

---

## 📊 Verificación en Base de Datos

### Usando Prisma Studio

```bash
cd backend
npx prisma studio
```

Abre `http://localhost:5555` y navega a:
- Tabla `Position` - Ver posiciones disponibles
- Tabla `Application` - Ver aplicaciones y sus etapas
- Tabla `Candidate` - Ver candidatos
- Tabla `Interview` - Ver entrevistas y puntuaciones

### Usando psql (PostgreSQL CLI)

```bash
# Conectar a la base de datos
docker exec -it <container_name> psql -U LTIdbUser -d LTIdb

# Ver posiciones
SELECT id, title FROM "Position";

# Ver aplicaciones con candidatos
SELECT 
  a.id,
  a."candidateId",
  c."firstName" || ' ' || c."lastName" as "fullName",
  a."currentInterviewStep",
  a."positionId"
FROM "Application" a
JOIN "Candidate" c ON a."candidateId" = c.id;

# Ver puntuaciones de entrevistas
SELECT 
  i."applicationId",
  AVG(i.score) as "averageScore"
FROM "Interview" i
WHERE i.score IS NOT NULL
GROUP BY i."applicationId";
```

---

## 🐛 Solución de Problemas

### Problema: "Position not found"

**Causa**: La posición con ese ID no existe

**Solución**:
```bash
# Verificar posiciones existentes
npx prisma studio
# O crear datos de prueba con seed
cd backend
npx ts-node prisma/seed.ts
```

### Problema: "No active application found for this candidate"

**Causa**: El candidato no tiene ninguna aplicación registrada

**Solución**: Crear una aplicación para ese candidato en la base de datos

### Problema: "Interview step not found"

**Causa**: El ID del interview step no existe

**Solución**: Verificar IDs válidos de interview steps en Prisma Studio

### Problema: CORS Error desde frontend

**Solución**: El backend ya tiene CORS configurado para `http://localhost:3000`

---

## 📝 Notas Importantes

1. **IDs Válidos**: Asegúrate de usar IDs que existen en tu base de datos
2. **Datos de Prueba**: Ejecuta `npx ts-node prisma/seed.ts` para poblar la BD
3. **Puerto**: El backend debe estar corriendo en el puerto 3010
4. **Base de Datos**: Docker debe estar corriendo con PostgreSQL

---

## ✅ Checklist de Verificación

- [ ] Docker está corriendo (`docker ps`)
- [ ] Backend está corriendo (`http://localhost:3010` responde)
- [ ] Base de datos tiene datos (`npx prisma studio`)
- [ ] Existen posiciones en la tabla Position
- [ ] Existen candidatos en la tabla Candidate
- [ ] Existen aplicaciones en la tabla Application
- [ ] Los interview steps están configurados

---

## 🎓 Tips de Depuración

### Ver logs del servidor
Los logs aparecen en la consola donde ejecutaste `npm run dev`

### Ver query SQL generada por Prisma
Agregar en el archivo `.env`:
```env
DEBUG=prisma:query
```

### Reiniciar base de datos (CUIDADO: Borra datos)
```bash
cd backend
npx prisma migrate reset
npx ts-node prisma/seed.ts
```

---

## 📞 Ayuda Rápida

Si algo no funciona:

1. ✅ Verifica que Docker esté corriendo
2. ✅ Verifica que el backend esté corriendo
3. ✅ Verifica que existan datos en la BD
4. ✅ Revisa los logs del servidor
5. ✅ Consulta `API_ENDPOINTS_KANBAN.md` para detalles

---

**¡Listo para probar!** 🚀

Para documentación completa, consulta [API_ENDPOINTS_KANBAN.md](API_ENDPOINTS_KANBAN.md)
