
// 1. 初始化資料 (模擬 SQL Server 資料庫)
const initialData = {
    customers: [
        { cID: 1, cName: '陳一明', phone: '0910-123-456', address: '台北市信義區市府路1號' },
        { cID: 2, cName: '林美惠', phone: '0928-765-432', address: '新北市板橋區文化路一段100號' }
    ],
    employees: [
        { eID: 1, eName: '王經理', role: '廠長', specialty: '管理' },
        { eID: 2, eName: '李組長', role: '技師長', specialty: '引擎診斷' }
    ],
    vehicles: [
        { vID: 1, licensePlate: 'ABC-1234', model: 'Camry', cID: 1 },
        { vID: 2, licensePlate: 'DEF-5678', model: 'Civic', cID: 2 }
    ],
    repairOrders: [
        { oID: 1, date: '2024-10-01', status: '已完成', vID: 1, eID: 2 }
    ],
    repairItems: [
        { iID: 1, iName: '5000公里定期保養', laborCost: 1200, partsCost: 0, oID: 1 },
        { iID: 2, iName: '更換機油', laborCost: 0, partsCost: 1800, oID: 1 }
    ]
};

// 從 LocalStorage 讀取或初始化
let db = JSON.parse(localStorage.getItem('RepairShopDB')) || initialData;
function saveDB() { localStorage.setItem('RepairShopDB', JSON.stringify(db)); }

// 2. 登入邏輯
let currentRole = 'Customer';
let currentUser = null;

function setLoginRole(role) {
    currentRole = role;
    document.querySelectorAll('.role-selector button').forEach(b => b.classList.remove('active'));
    document.getElementById(`btn-role-${role.toLowerCase().substring(0,4)}`).classList.add('active');
    
    const inputArea = document.getElementById('login-inputs');
    if (role === 'Customer') {
        inputArea.innerHTML = '<input type="text" id="login-val" placeholder="請輸入電話號碼 (如: 0910-123-456)">';
    } else if (role === 'Technician') {
        inputArea.innerHTML = '<input type="text" id="login-val" placeholder="請輸入技師姓名 (如: 李組長)">';
    } else {
        inputArea.innerHTML = '<input type="password" id="login-val" placeholder="管理密碼 (admin123)">';
    }
}

function handleLogin() {
    const val = document.getElementById('login-val').value;
    
    if (currentRole === 'Admin') {
        if (val === 'admin123') {
            currentUser = { name: '系統管理員' };
            showDashboard('Admin');
        } else alert('密碼錯誤！');
    } else if (currentRole === 'Technician') {
        const tech = db.employees.find(e => e.eName === val);
        if (tech) { currentUser = tech; showDashboard('Technician'); }
        else alert('查無此技師！');
    } else {
        const cust = db.customers.find(c => c.phone === val);
        if (cust) { currentUser = cust; showDashboard('Customer'); }
        else alert('查無此電話！');
    }
}

// 3. 儀表板渲染
function showDashboard(role) {
    document.getElementById('login-screen').style.display = 'none';
    document.getElementById('main-app').style.display = 'flex';
    document.getElementById('display-user-name').innerText = currentUser.cName || currentUser.eName || currentUser.name;
    document.getElementById('display-user-role').innerText = role;

    renderContent(role);
}

function renderContent(role) {
    const area = document.getElementById('content-area');
    if (role === 'Customer') {
        const myVehicles = db.vehicles.filter(v => v.cID === currentUser.cID);
        let html = `<h2>🚗 我的車輛維修狀態</h2><table><thead><tr><th>車牌</th><th>狀態</th><th>費用</th></tr></thead><tbody>`;
        myVehicles.forEach(v => {
            const order = db.repairOrders.find(o => o.vID === v.vID);
            const items = order ? db.repairItems.filter(i => i.oID === order.oID) : [];
            const total = items.reduce((sum, i) => sum + i.laborCost + i.partsCost, 0);
            html += `<tr><td>${v.licensePlate}</td><td>${order ? order.status : '無紀錄'}</td><td>NT$ ${total}</td></tr>`;
        });
        html += `</tbody></table>`;
        area.innerHTML = html;
    } else if (role === 'Admin') {
        const totalRevenue = db.repairItems.reduce((sum, i) => sum + i.laborCost + i.partsCost, 0);
        area.innerHTML = `
            <h2>🛡️ 管理員後台</h2>
            <div class="card">
                <p>累積總營業額</p>
                <div class="metric">NT$ ${totalRevenue.toLocaleString()}</div>
            </div>
            <h3>客戶清單</h3>
            <table><thead><tr><th>姓名</th><th>電話</th><th>操作</th></tr></thead>
            <tbody>${db.customers.map(c => `<tr><td>${c.cName}</td><td>${c.phone}</td><td><button onclick="deleteCust(${c.cID})">刪除</button></td></tr>`).join('')}</tbody>
            </table>
        `;
    } else {
        area.innerHTML = `<h2>👨‍🔧 技師任務看板</h2><p>此版本模擬技師查看目前工單...</p>
            <table><thead><tr><th>車牌</th><th>狀態</th></tr></thead>
            <tbody>${db.repairOrders.map(o => `<tr><td>${db.vehicles.find(v => v.vID === o.vID).licensePlate}</td><td>${o.status}</td></tr>`).join('')}</tbody>
            </table>`;
    }
}

function deleteCust(id) {
    db.customers = db.customers.filter(c => c.cID !== id);
    saveDB();
    renderContent('Admin');
}

function handleLogout() { location.reload(); }

// 初始化預設輸入框
setLoginRole('Customer');
