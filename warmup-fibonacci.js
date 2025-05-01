// Script: warmup-fibonacci.js
const axios = require('axios');

const baseUrl = 'https://scalabilitylab-functionprojectfibonacci.azurewebsites.net/api/Fibonacci'; // Cambia por tu URL
const minN = 1;
const maxN = 100000; // Ajusta el máximo según lo que quieras probar
let step = 100;   // Cuánto aumenta cada vez
const delayMs = 500; // Espera entre peticiones (ms)
const delta = 10; // Cuánto aumenta el step cada vez

async function warmup() {
    for (let n = minN; n <= maxN; n += step) {
        try {
            const res = await axios.post(baseUrl, { nth: n });
            console.log(`Fib(${n}) = ${res.data}`);
            step += delta;
        } catch (err) {
            console.error(`Error con n=${n}:`, err.response ? err.response.data : err.message);
            break;
        }
        await new Promise(r => setTimeout(r, delayMs));
    }
    console.log('Warmup terminado');
}

warmup();