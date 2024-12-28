const fs = require('fs');

// Ruta del archivo README.md
const readmePath = './README.md';

// Badge URLs
const successBadge = '![Success](https://img.shields.io/badge/tested%20with-Cypress-04C38E.svg)';
const failureBadge = '![Failure](https://img.shields.io/badge/test-failure-red)';

// Obtener el resultado de los tests desde los argumentos
const testResult = 'success';

// Seleccionar el badge según el resultado
const badge = testResult === 'success' ? successBadge : failureBadge;

// Leer el contenido actual del README.md
const readmeContent = fs.existsSync(readmePath) ? fs.readFileSync(readmePath, 'utf-8') : '';

// Verificar si ya existe la sección de resultados
const updatedContent = readmeContent.includes('RESULTADO DE LOS ÚLTIMOS TESTS')
     ? readmeContent.replace(/RESULTADO DE LOS ÚLTIMOS TESTS.*/s, `RESULTADO DE LOS ÚLTIMOS TESTS\n\n${badge}`)
     : `${readmeContent}\n\n## RESULTADO DE LOS ÚLTIMOS TESTS\n\n${badge}`;

// Escribir el contenido actualizado en el README.md
fs.writeFileSync(readmePath, updatedContent, 'utf-8');

console.log(`README.md actualizado con el resultado de los tests (${testResult}).`);
