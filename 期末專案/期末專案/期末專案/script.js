let isPumping = false;
let liters = 0;
let pumpInterval;

const currentLitersDisp = document.getElementById('current-liters');
const totalCostDisp = document.getElementById('total-cost');
const unitPriceInput = document.getElementById('unit-price');
const targetLitersInput = document.getElementById('target-liters');
const fillUpCheckbox = document.getElementById('fill-up');
const startBtn = document.getElementById('start-btn');
const stopBtn = document.getElementById('stop-btn');
const fuelBtns = document.querySelectorAll('.fuel-btn');

// 油品切換邏輯 
fuelBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        fuelBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        unitPriceInput.value = btn.dataset.price;
        resetDisplay();
    });
});

function resetDisplay() {
    liters = 0;
    currentLitersDisp.innerText = "0.00";
    totalCostDisp.innerText = "0.00";
}

// 開始加油邏輯 [cite: 1128]
startBtn.addEventListener('click', () => {
    if (isPumping) return;
    
    resetDisplay();
    isPumping = true;
    startBtn.disabled = true;
    stopBtn.disabled = false;
    
    const unitPrice = parseFloat(unitPriceInput.value);
    const target = fillUpCheckbox.checked ? 50 : parseFloat(targetLitersInput.value || 999);

    pumpInterval = setInterval(() => {
        liters += 0.05; // 模擬加油速度
        const cost = liters * unitPrice;
        
        currentLitersDisp.innerText = liters.toFixed(2);
        totalCostDisp.innerText = cost.toFixed(2);

        // 到達目標自動停止 
        if (liters >= target) {
            stopPumping();
        }
    }, 50); // 每 50 毫秒跳動一次
});

// 停止加油邏輯 [cite: 1129]
stopBtn.addEventListener('click', stopPumping);

function stopPumping() {
    clearInterval(pumpInterval);
    isPumping = false;
    startBtn.disabled = false;
    stopBtn.disabled = true;
}
