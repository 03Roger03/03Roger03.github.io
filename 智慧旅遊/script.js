let userData = {
    name: "",
    people: 1,
    start: "",
    end: "",
    purpose: "",
    startCoords: null,
    endCoords: null,
    weather: null
};

let map, directionsService, directionsRenderer, placesService;
let currentMode = 'DRIVING';

// 切換步驟
function showStep(step) {
    document.querySelectorAll('.step-content').forEach(s => s.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    
    document.getElementById(`step${step}`).classList.add('active');
    document.querySelectorAll('.tab-btn')[step-1].classList.add('active');
}

// 核心查詢邏輯
async function handleSearch() {
    const btn = document.getElementById('search-btn');
    btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> 搜尋中...';
    
    userData.name = document.getElementById('username').value || "旅客";
    userData.people = document.getElementById('people').value;
    userData.start = document.getElementById('start_place').value;
    userData.end = document.getElementById('end_place').value;
    userData.purpose = document.getElementById('purpose').value;

    if (!userData.start || !userData.end) {
        alert("請輸入出發地與目的地");
        btn.innerHTML = '查詢交通與推薦';
        return;
    }

    try {
        // 1. 地理編碼 (OSM)
        userData.startCoords = await getCoords(userData.start);
        userData.endCoords = await getCoords(userData.end);

        // 2. 天氣預報 (Open-Meteo)
        userData.weather = await getWeather(userData.endCoords);

        // 3. 渲染結果
        renderResults();
        
        // 4. 初始化地圖
        initMap();

        // 啟用標籤
        document.getElementById('tab3-btn').disabled = false;
        document.getElementById('tab4-btn').disabled = false;
        showStep(3);
    } catch (error) {
        console.error(error);
        alert("查詢失敗，請稍後再試");
    } finally {
        btn.innerHTML = '查詢交通與推薦';
    }
}

async function getCoords(place) {
    const res = await fetch(`https://nominatim.openstreetmap.org/search?format=json&limit=1&q=${encodeURIComponent(place)}`);
    const data = await res.json();
    if (data.length > 0) return { lat: parseFloat(data[0].lat), lon: parseFloat(data[0].lon) };
    return { lat: 25.0478, lon: 121.5170 }; // 預設台北
}

async function getWeather(coords) {
    const res = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lon}&current_weather=true&timezone=auto`);
    return await res.json();
}

function renderResults() {
    const weather = userData.weather.current_weather;
    document.getElementById('welcome-msg').innerText = `親愛的 ${userData.name}，前往「${userData.end}」的計畫：`;
    
    // 天氣標籤
    const weatherHtml = `☀️ ${weather.temperature}°C (風速: ${weather.windspeed})`;
    document.getElementById('weather-summary').innerHTML = weatherHtml;
    document.getElementById('weather-summary').style.display = 'block';
    document.getElementById('weather-badge-map').innerHTML = weatherHtml;
    document.getElementById('weather-tip').innerText = `💡 目前氣溫 ${weather.temperature}度，適合您的「${userData.purpose}」行程！`;

    // 交通估算 (基於距離的模擬邏輯)
    const dist = calculateDistance(userData.startCoords, userData.endCoords);
    const transportDiv = document.getElementById('transport-results');
    
    const hsrValid = !["花蓮", "台東", "宜蘭", "南投"].some(city => userData.end.includes(city));
    if(!hsrValid) document.getElementById('hsr-btn').style.display = 'none';

    transportDiv.innerHTML = `
        <div class="trans-card" style="background:#e3f2fd; border-color:#2196f3">
            <strong><i class="fa fa-car"></i> 自行開車</strong>
            <div>約 ${Math.round(dist/50 * 60)} 分鐘</div>
            <small>油資約 NT$ ${Math.round(dist * 3)}</small>
        </div>
        ${hsrValid ? `
        <div class="trans-card" style="background:#fff3e0; border-color:#ff9800">
            <strong><i class="fa fa-bolt"></i> 高鐵</strong>
            <div>約 ${Math.round(dist/150 * 60)} 分鐘</div>
            <small>票價約 NT$ ${Math.round(dist * 4.5)}</small>
        </div>` : ''}
    `;

    // 推薦列表 (根據目的產出關鍵字)
    const queries = {
        food: ['必吃美食', '特色餐廳', '網紅甜點'],
        photo: ['熱門景點', '美拍秘境', '歷史建築'],
        stay: ['高級飯店', '特色民宿', '平價青旅'],
        fun: ['主題樂園', '購物中心', '手作體驗']
    };

    const recList = document.getElementById('recommendation-list');
    recList.innerHTML = "";
    queries[userData.purpose].forEach((q, i) => {
        const item = document.createElement('div');
        item.className = 'list-item';
        item.innerHTML = `
            <img src="https://via.placeholder.com/80?text=${userData.purpose}" id="img-${i}">
            <div>
                <strong>${userData.end} ${q}</strong>
                <p>點擊地圖查看詳細位置</p>
            </div>
        `;
        recList.appendChild(item);
    });
}

function calculateDistance(c1, c2) {
    const R = 6371;
    const dLat = (c2.lat - c1.lat) * Math.PI / 180;
    const dLon = (c2.lon - c1.lon) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(c1.lat * Math.PI / 180) * Math.cos(c2.lat * Math.PI / 180) * Math.sin(dLon/2) * Math.sin(dLon/2);
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}

// Google Maps 功能
function initMap() {
    const center = { lat: userData.endCoords.lat, lng: userData.endCoords.lon };
    map = new google.maps.Map(document.getElementById("map"), {
        zoom: 13,
        center: center,
    });
    
    directionsService = new google.maps.DirectionsService();
    directionsRenderer = new google.maps.DirectionsRenderer();
    directionsRenderer.setMap(map);
    
    placesService = new google.maps.places.PlacesService(map);
    updateRoute();
}

function updateRoute() {
    const request = {
        origin: userData.start,
        destination: userData.end,
        travelMode: google.maps.TravelMode[currentMode === 'CAR' ? 'DRIVING' : 'TRANSIT']
    };
    
    directionsService.route(request, (result, status) => {
        if (status === 'OK') directionsRenderer.setDirections(result);
    });
}

function changeTransportMode(mode) {
    currentMode = mode;
    document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('active'));
    event.currentTarget.classList.add('active');
    
    const titles = { 'CAR': '自駕遊 - 享受隨性', 'HSR': '高鐵 - 極速前進', 'TRA': '台鐵 - 鐵道紀行', 'BUS': '客運 - 經濟實惠' };
    document.getElementById('visual-mode-text').innerText = titles[mode];
    updateRoute();
}
