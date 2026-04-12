<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>保費即時預估與諮詢回覆網站</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="grain"></div>
    <header class="site-header">
        <div class="brand">
            <span class="brand-icon">
                <i class="fa-solid fa-shield-heart" aria-hidden="true"></i>
            </span>
            <span class="brand-name">保費即時預估中心</span>
        </div>
        <nav class="header-actions">
            <a class="ghost-link" href="#automation">流程說明</a>
            <a class="primary-link" href="#estimator">開始預估</a>
        </nav>
    </header>

    <main class="page">
        <section class="hero">
            <div class="hero-copy">
                <h1>即時取得保費區間，</h1>
                <h1>掌握個人風險因子</h1>
                <p style="color:aqua">
                    輸入年齡、性別、BMI、是否吸菸、子女數與居住地區，
                    系統立刻推估個人化保費區間並提供健康建議，
                    協助您與業務快速完成保險前置篩選與風險溝通。
                </p>
                <div class="hero-highlights">
                    <div>
                        <span class="highlight-number">60 秒內</span>
                        <span class="highlight-label">完成預估與回覆</span>
                    </div>
                    <div>
                        <span class="highlight-number">3 步驟</span>
                        <span class="highlight-label">自動寫入、通知、回覆</span>
                    </div>
                    <div>
                        <span class="highlight-number">24/7</span>
                        <span class="highlight-label">全年無休線上諮詢入口</span>
                    </div>
                </div>
            </div>
            <div class="hero-visual">
                <div class="visual-card">
                    <p class="visual-title">教育式建議</p>
                    <ul style="color:aqua">
                        <li><i class="fa-solid fa-check"></i> BMI 與吸菸為保費上升主因</li>
                        <li><i class="fa-solid fa-check"></i> 保持規律運動可降低費率</li>
                        <li><i class="fa-solid fa-check"></i> 親子保障建議一次掌握</li>
                    </ul>
                </div>
                <div class="visual-badge">
                    <i class="fa-solid fa-bolt"></i>
                    <span>AI 推論 API</span>
                </div>
            </div>
        </section>

        <section class="estimator" id="estimator">
            <div class="form-card">
                <div class="section-heading">
                    <h2>填寫投保參數</h2>
                    <p>欄位完整送出後，透過 Make Webhook 串接推論流程，立即回傳保費區間與健康建議。</p>
                </div>
                <form id="premium-form" novalidate>
                    <div class="form-grid">
                        <label class="field">
                            <span>年齡</span>
                            <input type="number" min="18" max="100" name="age" placeholder="例：35" required>
                            <small class="hint">限制 18 至 100 歲</small>
                        </label>
                        <label class="field">
                            <span>性別</span>
                            <div class="radio-group">
                                <label><input type="radio" name="sex" value="female" required> 女性</label>
                                <label><input type="radio" name="sex" value="male"> 男性</label>
                            </div>
                        </label>
                        <label class="field">
                            <span>BMI</span>
                            <input type="number" step="0.1" min="12" max="45" name="bmi" placeholder="例：24.6" required>
                            <small class="hint">建議範圍 18.5 至 24.9</small>
                        </label>
                        <label class="field">
                            <span>是否吸菸</span>
                            <div class="radio-group">
                                <label><input type="radio" name="smoker" value="no" required> 否</label>
                                <label><input type="radio" name="smoker" value="yes"> 是</label>
                            </div>
                        </label>
                        <label class="field">
                            <span>子女數</span>
                            <input type="number" min="0" max="5" name="children" placeholder="例：2" required>
                        </label>
                        <label class="field">
                            <span>地區</span>
                            <select name="region" required>
                                <option value="" disabled selected>請選擇</option>
                                <option value="northwest">北部</option>
                                <option value="northeast">中部</option>
                                <option value="southeast">南部</option>
                                <option value="southwest">東部</option>
                            </select>
                        </label>
                    </div>
                    <div class="form-actions">
                        <button type="submit" class="primary-btn">
                            <span class="btn-label">送出預估</span>
                            <span class="btn-spinner" aria-hidden="true"></span>
                        </button>
                        <p class="privacy-note"><i class="fa-solid fa-lock"></i> 資料將僅用於試算與諮詢回覆，並符合個資保護規範。</p>
                    </div>
                </form>
            </div>
            <aside class="result-card" id="result-card" aria-live="polite">
                <div class="result-placeholder">
                    <i class="fa-regular fa-circle-play"></i>
                    <p>完成欄位填寫並送出後，系統將顯示預估保費區間、模型不確定度與個人化建議。</p>
                </div>
            </aside>
        </section>

        <section class="automation" id="automation">
            <div class="section-heading">
                <h2 style="color:white">Make 自動化流程</h2>
                <p style="color:aqua">透過自動化串接，將人工試算與回覆流程縮短為即時體驗，並確保全程留痕可稽核。</p>
            </div>
            <div class="flow-chart">
                <div class="flow-step">
                    <span class="step-count">1</span>
                    <h3 style="color:white">Webhook 接受表單</h3>
                    <p style="color:aqua">前端送出清單即觸發 Make 的自訂 Webhook，進行欄位驗證與標準化。</p>
                </div>
                <div class="flow-step">
                    <span class="step-count">2</span>
                    <h3 style="color:white">推論 API</h3>
                    <p style="color:aqua">HTTP 模組呼叫後端推論 API 或雲端函式模型，取得 charges 預測與不確定度。</p>
                </div>
                <div class="flow-step">
                    <span class="step-count">3</span>
                    <h3 style="color:white">資料寫入</h3>
                    <p style="color:aqua">結果寫入 Google 試算表，用於稽核追蹤與成效分析。</p>
                </div>
                <div class="flow-step">
                    <span class="step-count">4</span>
                    <h3 style="color:white">雙向通知</h3>
                    <p style="color:aqua">Make 同步回寄 Email 給使用者與內部業務，附上保費區間與健康建議。</p>
                </div>
            </div>
        </section>

        <section class="insights">
            <div class="section-heading">
                <h2 style="color:white">因子解析與健康提醒</h2>
                <p style="color:aqua">向使用者清楚說明各項指標如何影響保費，協助提升健康管理意識。</p>
            </div>
            <div class="insight-grid">
                <article class="insight-card">
                    <h3><i class="fa-solid fa-person-running"></i> BMI 與生活習慣</h3>
                    <p>BMI 介於 18.5 至 24.9 為費率較佳區間。保持規律運動與均衡飲食可降低長期健康成本。</p>
                </article>
                <article class="insight-card">
                    <h3><i class="fa-solid fa-ban-smoking"></i> 吸菸風險</h3>
                    <p>吸菸者保費平均高出 20% 以上，建議透過戒菸門診或替代療法降低風險與費率。</p>
                </article>
                <article class="insight-card">
                    <h3><i class="fa-solid fa-children"></i> 家庭保障</h3>
                    <p>子女數會影響保額配置，建議搭配學習型或儲蓄型產品，建構家庭風險防護網。</p>
                </article>
            </div>
        </section>
    </main>

    <footer class="site-footer">
        <p>© 2025 保費即時預估中心 Insurance Intake Hub</p>
        <p>本服務提供初步建議，最終費率以保險公司核保結果為準。</p>
    </footer>

    <script src="script.js" defer></script>
</body>
</html>
