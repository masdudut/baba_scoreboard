const root = document.getElementById("root");
const el = (id) => document.getElementById(id);

function money(n){
  try { return new Intl.NumberFormat('en-US').format(Number(n || 0)); }
  catch { return String(n || 0); }
}

const JOBS = [
  { key: "ambulance", icon: "img/icons/ambulance.png", label: "EMS" },
  { key: "burger",    icon: "img/icons/burger.png",    label: "BURGER" },
  { key: "mechanic",  icon: "img/icons/mechanic.png",  label: "MECH" },
  { key: "police",    icon: "img/icons/police.png",    label: "POLICE" },
  { key: "taxi",      icon: "img/icons/taxi.png",      label: "TAXI" },
];

function renderGrid(counters = {}) {
  const grid = el("jobGrid");
  grid.innerHTML = "";

  JOBS.forEach((job) => {
    const count = counters[job.key] ?? 0;

    const tile = document.createElement("div");
    tile.className = "tile";

    const ico = document.createElement("div");
    ico.className = "ico";

    const img = document.createElement("img");
    img.src = job.icon;
    img.alt = job.key;
    img.onerror = () => img.remove();

    ico.appendChild(img);

    const label = document.createElement("div");
    label.className = "jobInline";
    label.textContent = job.label;

    const c = document.createElement("div");
    c.className = "jobCount";
    c.textContent = count;

    tile.appendChild(ico);
    tile.appendChild(label);
    tile.appendChild(c);

    grid.appendChild(tile);
  });
}

function applyPayload(p){
  if (!p) return;

  el("playerId").textContent = `ID ${p.id ?? 0}`;
  el("playerName").textContent = (p.name ?? "UNKNOWN").toUpperCase();
  el("playerJob").textContent = (p.jobLabel ?? "Unemployed");

  el("salary").textContent = `$${money(p.salary)}`;
  el("cash").textContent   = `$${money(p.cash)}`;
  el("crafting").textContent = p.craftingLevel ?? 0;

  renderGrid(p.counters || {});
}

window.addEventListener("message", (event) => {
  const { action, payload } = event.data || {};

  if (action === "open"){
    root.classList.remove("hidden");
    applyPayload(payload);
  }

  if (action === "close"){
    root.classList.add("hidden");
  }

  if (action === "update"){
    applyPayload(payload);
  }
});
