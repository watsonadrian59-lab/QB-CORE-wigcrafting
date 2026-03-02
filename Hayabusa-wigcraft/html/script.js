const canvas = document.getElementById('particles');
const ctx = canvas.getContext('2d');
let particles = [];
let particleActive = false;
let recipes = {};

// resize
function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}
window.addEventListener('resize', resize);
resize();

// particles
function createParticles() {
    particles = [];
    for (let i = 0; i < 60; i++) {
        particles.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            r: Math.random() * 2,
            vx: (Math.random() - 0.5) * 0.3,
            vy: (Math.random() - 0.5) * 0.3
        });
    }
}

function drawParticles() {
    if (!particleActive) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.fillStyle = 'rgba(123, 44, 255, 0.8)';
    particles.forEach(p => {
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fill();

        p.x += p.vx;
        p.y += p.vy;

        if (p.x < 0 || p.x > canvas.width) p.vx *= -1;
        if (p.y < 0 || p.y > canvas.height) p.vy *= -1;
    });

    requestAnimationFrame(drawParticles);
}

function startParticles() {
    if (particleActive) return;
    particleActive = true;
    createParticles();
    drawParticles();
}

function stopParticles() {
    particleActive = false;
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

// NUI messages
window.addEventListener('message', function(event) {

    if (event.data.action === "open") {
        recipes = event.data.recipes || {};
        buildMaterials();
        document.getElementById('ui').classList.remove('hidden');
        startParticles();
    }

    if (event.data.action === "close") {
        document.getElementById('ui').classList.add('hidden');
        stopParticles();
    }
});

// close UI
function closeUI() {
    document.getElementById('ui').classList.add('hidden');
    stopParticles();

    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
}

function buildMaterials() {
    Object.keys(recipes).forEach(item => {
        const container = document.getElementById(item + "_materials");
        if (!container) return;

        container.innerHTML = "";

        const materials = recipes[item].materials || {};
        let output = "";

        Object.keys(materials).forEach(mat => {
            output += `<li>${materials[mat]}x ${formatName(mat)}</li>`;
        });

        container.innerHTML = output;
    });
}

function formatName(str) {
    return str.replace(/_/g, " ")
              .replace(/\b\w/g, l => l.toUpperCase());
}

function craft(item) {

    // close UI so we can see progress
    document.getElementById('ui').classList.add('hidden');
    stopParticles();

    fetch(`https://${GetParentResourceName()}/craft`, {
        method: 'POST',
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ item })
    });
}

function startProgress(callback) {
    let container = document.getElementById("progressContainer");
    let bar = document.getElementById("progressBar");

    if (!container) return;

    container.classList.remove("hidden");
    bar.style.width = "0%";

    let width = 0;
    const interval = setInterval(() => {
        width += 2;
        bar.style.width = width + "%";

        if (width >= 100) {
            clearInterval(interval);

            setTimeout(() => {
                container.classList.add("hidden");
                if (callback) callback();
            }, 400);
        }
    }, 50);
}