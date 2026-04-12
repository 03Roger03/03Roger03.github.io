document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('premium-form');
    const resultCard = document.getElementById('result-card');
    const submitButton = form.querySelector('button[type="submit"]');

    const WEBHOOK_URL = 'https://hook.make.com/your-webhook-id';
    const defaultCurrency = 'TWD';

    form.addEventListener('input', (event) => {
        if (event.target instanceof HTMLInputElement || event.target instanceof HTMLSelectElement) {
            event.target.setCustomValidity('');
        }
    });

    form.addEventListener('submit', async (event) => {
        event.preventDefault();

        const formData = new FormData(form);
        const { payload, errors } = buildPayload(formData);

        if (errors.length > 0) {
            renderError(errors.join('、'));
            return;
        }

        setLoadingState(true);

        try {
            const usingPlaceholder = WEBHOOK_URL.includes('your-webhook-id');
            const responseData = usingPlaceholder
                ? mockResponse(payload.data)
                : await triggerWebhook(WEBHOOK_URL, payload);

            renderResult(normalizeResult(responseData));
        } catch (error) {
            console.error('[Premium Estimator]', error);
            renderResult(normalizeResult(mockResponse(payload.data, true)), true);
        } finally {
            setLoadingState(false);
        }
    });

    function setLoadingState(isLoading) {
        if (isLoading) {
            submitButton.disabled = true;
            submitButton.classList.add('loading');
        } else {
            submitButton.disabled = false;
            submitButton.classList.remove('loading');
        }
    }

    function renderError(message) {
        resultCard.innerHTML = `
            <div class="result-placeholder">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <p>${message}</p>
            </div>
        `;
    }

    function renderResult(result, isFallback = false) {
        const {
            lower,
            upper,
            pointEstimate,
            currency,
            uncertainty,
            recommendations,
            rawResponse,
        } = result;

        const confidence = uncertainty != null
            ? Math.max(0, 100 - Math.round(uncertainty * 100))
            : null;

        const rangeLabel = lower && upper
            ? `${formatCurrency(lower, currency ?? defaultCurrency)} - ${formatCurrency(upper, currency ?? defaultCurrency)}`
            : pointEstimate
                ? formatCurrency(pointEstimate, currency ?? defaultCurrency)
                : '尚無資料';

        const adviceItems = (recommendations && recommendations.length > 0)
            ? recommendations.map((tip) => `
                <li class="insight-item">
                    <i class="fa-solid fa-lightbulb"></i>
                    <span>${tip}</span>
                </li>
            `).join('')
            : `
                <li class="insight-item">
                    <i class="fa-solid fa-lightbulb"></i>
                    <span>建議保持健康體位與定期體檢，以獲得更佳保費條件。</span>
                </li>
            `;

        resultCard.innerHTML = `
            <div class="result-header">
                <h3>${isFallback ? '示範結果（未連線）' : '預估結果已更新'}</h3>
                ${confidence !== null ? `
                    <span class="confidence-badge">
                        <i class="fa-solid fa-signal"></i>
                        預估信心 ${confidence}%
                    </span>
                ` : ''}
            </div>
            <div class="charge-range">
                <span>預估保費區間（新臺幣 / 月繳）</span>
                <strong>${rangeLabel}</strong>
                ${pointEstimate && (!lower || !upper) ? `<span>模型單點預估：${formatCurrency(pointEstimate, currency ?? defaultCurrency)}</span>` : ''}
            </div>
            <ul class="insight-list">
                ${adviceItems}
            </ul>
            <div class="automation-footnote">
                <p>
                    <i class="fa-solid fa-cloud-arrow-up"></i>
                    Make 已將預估結果寫入 Google 試算表並觸發 Email 通知，以便稽核追蹤。
                    ${isFallback ? '（目前採示範資料，請設定 Webhook URL 後啟用正式流程。）' : ''}
                </p>
            </div>
            ${rawResponse ? `
                <details class="raw-response">
                    <summary><i class="fa-solid fa-code"></i> 技術細節</summary>
                    <pre>${escapeHTML(JSON.stringify(rawResponse, null, 2))}</pre>
                </details>
            ` : ''}
        `;
    }

    async function triggerWebhook(url, payload) {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(payload),
        });

        if (!response.ok) {
            throw new Error(`Webhook returned status ${response.status}`);
        }

        const contentType = response.headers.get('content-type') || '';
        if (!contentType.includes('application/json')) {
            throw new Error('Webhook did not return JSON');
        }

        return response.json();
    }

    function buildPayload(formData) {
        const errors = [];

        const age = Number(formData.get('age'));
        const sex = formData.get('sex');
        const bmi = Number(formData.get('bmi'));
        const smoker = formData.get('smoker');
        const children = Number(formData.get('children'));
        const region = formData.get('region');

        if (!Number.isFinite(age) || age < 18 || age > 100) {
            errors.push('年齡需介於 18 至 100 歲');
        }

        if (!sex) {
            errors.push('請選擇性別');
        }

        if (!Number.isFinite(bmi) || bmi < 12 || bmi > 45) {
            errors.push('BMI 請填入 12 至 45 之數值');
        }

        if (!smoker) {
            errors.push('請選擇是否吸菸');
        }

        if (!Number.isFinite(children) || children < 0 || children > 5) {
            errors.push('子女數需介於 0 至 5 人');
        }

        if (!region) {
            errors.push('請選擇居住地區');
        }

        const normalizedChildren = Number.isFinite(children) ? Math.round(children) : 0;

        return {
            errors,
            payload: {
                source: 'insurance-premium-estimator-web',
                triggeredAt: new Date().toISOString(),
                data: {
                    age,
                    sex,
                    bmi: Number(bmi.toFixed(1)),
                    smoker,
                    children: normalizedChildren,
                    region,
                },
            },
        };
    }

    function normalizeResult(response) {
        if (!response || typeof response !== 'object') {
            return { recommendations: ['尚未取得可解析的預測結果。'], rawResponse: response };
        }

        const charges = extractCharges(response);
        const uncertainty = typeof response.uncertainty === 'number'
            ? Math.min(Math.max(response.uncertainty, 0), 1)
            : response.confidence != null
                ? 1 - response.confidence
                : null;

        const recommendations = extractRecommendations(response);

        return {
            ...charges,
            uncertainty,
            recommendations,
            rawResponse: response,
        };
    }

    function extractCharges(response) {
        const chargesField = response.charges ?? response.premium ?? null;
        const currency = response.currency ?? (chargesField && chargesField.currency) ?? 'TWD';

        if (typeof chargesField === 'number') {
            return {
                pointEstimate: chargesField,
                currency,
            };
        }

        if (chargesField && typeof chargesField === 'object') {
            const lower = findNumber(chargesField, ['lower', 'min', 'low', 'p10']);
            const upper = findNumber(chargesField, ['upper', 'max', 'high', 'p90']);
            const point = findNumber(chargesField, ['point', 'mean', 'median', 'amount', 'value']);

            return {
                lower,
                upper,
                pointEstimate: point,
                currency,
            };
        }

        const lower = findNumber(response, ['lower', 'minCharge']);
        const upper = findNumber(response, ['upper', 'maxCharge']);
        const point = findNumber(response, ['charges', 'prediction', 'estimate']);

        return {
            lower,
            upper,
            pointEstimate: point,
            currency,
        };
    }

    function extractRecommendations(response) {
        if (Array.isArray(response.recommendations)) {
            return response.recommendations;
        }
        if (Array.isArray(response.healthTips)) {
            return response.healthTips;
        }
        if (Array.isArray(response.messages)) {
            return response.messages;
        }
        return [];
    }

    function findNumber(source, keys) {
        for (const key of keys) {
            if (key in source) {
                const value = Number(source[key]);
                if (Number.isFinite(value)) {
                    return value;
                }
            }
        }
        return null;
    }

    function formatCurrency(amount, currencyCode = defaultCurrency) {
        const code = typeof currencyCode === 'string' && currencyCode.length === 3
            ? currencyCode.toUpperCase()
            : defaultCurrency;

        try {
            return new Intl.NumberFormat('zh-TW', {
                style: 'currency',
                currency: code,
                maximumFractionDigits: 0,
            }).format(amount);
        } catch (error) {
            console.warn('[Premium Estimator] Unsupported currency code, fallback to TWD:', currencyCode, error);
            return new Intl.NumberFormat('zh-TW', {
                style: 'currency',
                currency: defaultCurrency,
                maximumFractionDigits: 0,
            }).format(amount);
        }
    }

    function mockResponse(input, fallback = false) {
        const regionFactor = {
            northwest: 1.08,
            northeast: 1.03,
            southeast: 1.12,
            southwest: 1.05,
        };

        const age = input.age || 30;
        const bmi = input.bmi || 24;
        const smoker = input.smoker === 'yes';
        const children = input.children || 0;

        let base = 9000 + age * 130;
        base *= regionFactor[input.region] ?? 1.0;
        base += Math.max(0, bmi - 24) * 160;

        if (smoker) {
            base *= 1.45;
        }

        base += children * 320;
        const lower = Math.round(base * 0.88);
        const upper = Math.round(base * 1.12);

        const recommendations = [];

        if (bmi >= 25) {
            recommendations.push('BMI 偏高，建議建立飲食與運動紀錄，達成 5% 的體重調整可有效降低保費。');
        } else if (bmi < 18.5) {
            recommendations.push('BMI 偏低，建議諮詢營養師調整飲食，避免因健康風險造成核保附加條件。');
        }

        if (smoker) {
            recommendations.push('吸菸會大幅提高保費與核保風險，建議採用戒菸治療或替代方案。');
        } else {
            recommendations.push('維持無菸生活有助於留住最佳保費；多利用定期健康檢查佐證狀況。');
        }

        if (children > 0) {
            recommendations.push('建議規畫家庭醫療與教育保障，搭配意外與實支實付型商品。');
        }

        if (recommendations.length === 0) {
            recommendations.push('健康指標良好，建議保持運動與飲食習慣，並定期檢視保障缺口。');
        }

        return {
            charges: {
                lower,
                upper,
                median: Math.round((lower + upper) / 2),
                currency: defaultCurrency,
            },
            uncertainty: fallback ? 0.28 : 0.18,
            recommendations,
            source: fallback ? 'mock-fallback' : 'mock-demo',
        };
    }

    function escapeHTML(value) {
        return value.replace(/[&<>"']/g, (char) => (
            ({
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#39;',
            })[char] || char
        ));
    }
});
