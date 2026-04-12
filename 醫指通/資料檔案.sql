-- ============================================================
-- MediMatch 智慧醫療系統 — MSSQL 資料表結構
-- Windows 驗證登入，執行前請確認已選擇正確資料庫
-- ============================================================

-- 建立資料庫（若尚未存在）
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'mediamatch')
BEGIN
    CREATE DATABASE mediamatch
        COLLATE Chinese_Taiwan_Stroke_CI_AS;
END
GO

USE mediamatch;
GO

-- ────────────────────────────────────────
-- 1. 使用者帳號
-- ────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='users' AND xtype='U')
BEGIN
    CREATE TABLE users (
        id          INT             NOT NULL IDENTITY(1,1),
        email       NVARCHAR(120)   NOT NULL,
        phone       NVARCHAR(20)        NULL,
        name        NVARCHAR(60)    NOT NULL,
        password    NVARCHAR(255)   NOT NULL,
        created_at  DATETIME2       NOT NULL DEFAULT GETDATE(),
        updated_at  DATETIME2       NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_users PRIMARY KEY (id),
        CONSTRAINT UQ_users_email UNIQUE (email)
    );
END
GO

-- ────────────────────────────────────────
-- 2. 症狀評估紀錄
-- ────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='assessments' AND xtype='U')
BEGIN
    CREATE TABLE assessments (
        id              INT             NOT NULL IDENTITY(1,1),
        user_id         INT             NOT NULL,
        display_text    NVARCHAR(200)   NOT NULL,
        category        NVARCHAR(60)    NOT NULL,
        severity        NVARCHAR(10)    NOT NULL DEFAULT N'輕症',  -- 輕症 / 重症
        recommendation  NVARCHAR(10)    NOT NULL DEFAULT N'成藥',  -- 成藥 / 就醫
        department      NVARCHAR(60)    NOT NULL,
        advice          NVARCHAR(300)       NULL,
        created_at      DATETIME2       NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_assessments PRIMARY KEY (id),
        CONSTRAINT FK_assess_user FOREIGN KEY (user_id)
            REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IX_assessments_user ON assessments(user_id);
END
GO

-- ────────────────────────────────────────
-- 3. 掛號紀錄
-- ────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='bookings' AND xtype='U')
BEGIN
    CREATE TABLE bookings (
        id          INT             NOT NULL IDENTITY(1,1),
        user_id     INT             NOT NULL,
        clinic      NVARCHAR(100)   NOT NULL,
        dept        NVARCHAR(60)    NOT NULL,
        appt_date   DATE            NOT NULL,
        appt_time   NVARCHAR(10)    NOT NULL,
        queue_no    SMALLINT        NOT NULL,
        status      NVARCHAR(10)    NOT NULL DEFAULT N'預約中',  -- 預約中 / 已就診 / 已取消
        created_at  DATETIME2       NOT NULL DEFAULT GETDATE(),
        updated_at  DATETIME2       NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_bookings PRIMARY KEY (id),
        CONSTRAINT FK_booking_user FOREIGN KEY (user_id)
            REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IX_bookings_user ON bookings(user_id);
END
GO

-- ────────────────────────────────────────
-- 4. 成藥資料庫
-- ────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='medicines' AND xtype='U')
BEGIN
    CREATE TABLE medicines (
        id          INT             NOT NULL IDENTITY(1,1),
        name        NVARCHAR(100)   NOT NULL,
        category    NVARCHAR(40)    NOT NULL,
        symptoms    NVARCHAR(300)   NOT NULL,
        dosage      NVARCHAR(200)       NULL,
        warnings    NVARCHAR(300)       NULL,
        created_at  DATETIME2       NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_medicines PRIMARY KEY (id),
        CONSTRAINT UQ_medicines_name UNIQUE (name)
    );
    CREATE INDEX IX_medicines_category ON medicines(category);
END
GO

-- ────────────────────────────────────────
-- 5. 健保署特約醫事機構資料表
-- ────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='clinics' AND xtype='U')
BEGIN
    CREATE TABLE clinics (
        id                  INT             NOT NULL IDENTITY(1,1),
        med_code            NVARCHAR(20)    NOT NULL,
        med_name            NVARCHAR(100)   NOT NULL,
        med_type            NVARCHAR(10)    NOT NULL,
        phone               NVARCHAR(30)        NULL,
        address             NVARCHAR(200)       NULL,
        division            NVARCHAR(30)        NULL,
        contract_type       NVARCHAR(5)     NOT NULL,
        service_items       NVARCHAR(200)       NULL,
        departments         NVARCHAR(300)       NULL,
        end_date            NVARCHAR(20)        NULL,
        schedule            NVARCHAR(500)       NULL,
        note                NVARCHAR(200)       NULL,
        county_code         NVARCHAR(5)     NOT NULL,
        contract_start      NVARCHAR(20)        NULL,
        synced_at           DATETIME2       NOT NULL DEFAULT GETDATE(),
        lat FLOAT NULL,
        lng FLOAT NULL,
        geocode_quality NVARCHAR(10) NULL
        CONSTRAINT PK_clinics PRIMARY KEY (id),
        CONSTRAINT UQ_clinics_code UNIQUE (med_code)
    );
    CREATE INDEX IX_clinics_county    ON clinics(county_code);
    CREATE INDEX IX_clinics_type      ON clinics(contract_type);
    CREATE INDEX IX_clinics_county_type ON clinics(county_code, contract_type);
    CREATE INDEX IX_clinics_latng ON clinics(lat, lng);
END
GO

-- ────────────────────────────────────────
-- 示範資料
-- ────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'demo@example.com')
BEGIN
    INSERT INTO users (email, phone, name, password) VALUES
        (N'demo@example.com', N'0912-345-678', N'示範用戶', N'demo1234'),
        (N'123', N'0912-345-678', N'示範用戶', N'123'),
        (N'test@example.com', N'0923-456-789', N'測試用戶', N'test1234');

    INSERT INTO assessments (user_id, display_text, category, severity, recommendation, department, advice) VALUES
        (1, N'頭痛、喉嚨痛、輕微發燒', N'感冒',    N'輕症', N'成藥', N'內科',    N'多休息、多補充水分，可服用解熱鎮痛藥'),
        (1, N'腹痛、腹瀉、噁心嘔吐', N'腸胃炎',    N'輕症', N'成藥', N'腸胃科', N'建議清淡飲食，補充電解質'),
        (2, N'喉嚨劇痛、高燒38.5度', N'扁桃腺炎', N'重症', N'就醫', N'耳鼻喉科', N'建議盡快就醫，可能需要抗生素治療');

    INSERT INTO bookings (user_id, clinic, dept, appt_date, appt_time, queue_no, status) VALUES
        (1, N'大安診所',       N'內科',     '2026-03-20', N'09:30', 12, N'預約中'),
        (1, N'健康耳鼻喉診所', N'耳鼻喉科', '2026-03-18', N'14:00',  5, N'已就診'),
        (2, N'台中市立醫院',   N'外科',     '2026-03-22', N'10:00', 28, N'預約中');
END
GO
 
IF NOT EXISTS (SELECT 1 FROM medicines WHERE name = N'普拿疼')
BEGIN
    INSERT INTO medicines (name, category, symptoms, dosage, warnings) VALUES
    (N'普拿疼',             N'止痛', N'發燒、頭痛、肌肉痠痛、牙痛、生理痛',       N'成人每次1~2錠，每4~6小時一次，每日不超過8錠', N'肝功能不佳者慎用；勿與含乙醯胺酚藥物併用'),
    (N'布洛芬',             N'止痛', N'頭痛、牙痛、肌肉痠痛、發燒、關節痛',       N'成人每次200~400mg，每4~6小時一次，飯後服用', N'胃潰瘍、腎臟病、孕婦禁用；勿空腹服用'),
    (N'斯斯感冒膠囊',       N'感冒', N'感冒、鼻塞、流鼻水、喉嚨痛、頭痛',         N'成人每次1~2粒，每日3次，飯後服用',           N'高血壓、心臟病患者慎用；服用後勿開車'),
    (N'善胃胃腸藥',         N'腸胃', N'胃脹氣、消化不良、胃酸過多、胃灼熱',       N'成人每次2錠，每日3次，飯前服用',             N'長期服用請諮詢醫師；腎臟病患者慎用'),
    (N'正露丸',             N'腸胃', N'腹瀉、軟便、腸胃不適',                     N'成人每次5粒，每日3次',                       N'連續服用超過3天應就醫；孕婦慎用'),
    (N'膚利舒抗組織胺',     N'過敏', N'過敏性鼻炎、皮膚搔癢、蕁麻疹、花粉症',     N'成人每次1錠，每日1~2次',                     N'服後嗜睡，開車者慎用；青光眼患者禁用'),
    (N'開瑞坦',             N'過敏', N'過敏性鼻炎、蕁麻疹、皮膚過敏',             N'成人每次1錠，每日1次',                       N'非嗜睡型；肝腎功能不佳者減量'),
    (N'沙利痰化痰錠',       N'咳嗽', N'多痰、咳嗽帶痰、痰液黏稠',                 N'成人每次1錠，每日3次，飯後服用，多喝水',     N'急性發炎期間請先就醫'),
    (N'曼秀雷敦薄荷膏',     N'止痛', N'頭痛、肌肉痠痛、蚊蟲叮咬、鼻塞',           N'適量塗抹患處，每日數次',                     N'勿接觸眼睛及黏膜；2歲以下禁用'),
    (N'保麗淨含漱液',       N'感冒', N'口腔潰瘍、喉嚨紅腫、口臭、牙齦炎',         N'以清水1:1稀釋，漱口30秒後吐出，每日2~3次', N'勿吞嚥；12歲以下兒童不建議使用'),
    (N'氧化鋅軟膏',         N'皮膚', N'輕微燙傷、尿布疹、皮膚紅腫',               N'清潔後薄塗患處，每日2~3次',                 N'傷口感染時請就醫'),
    (N'電解質補充液',       N'腸胃', N'腹瀉嘔吐後補充電解質、輕度脫水',           N'依包裝指示沖泡，少量多次飲用',               N'嚴重脫水或持續嘔吐請立即就醫'),
    (N'白蘭氏雞精感冒顆粒', N'感冒', N'感冒初期、鼻水、打噴嚏、頭痛',             N'每次1包，每日3次，溫開水沖服',               N'12歲以下兒童諮詢醫師後使用'),
    (N'百應膏',             N'腸胃', N'腸胃悶脹、消化不良',                       N'成人每次2粒，每日3次，飯後服用',             N'對成分過敏者禁用'),
    (N'可待因咳嗽糖漿',     N'咳嗽', N'乾咳、久咳、刺激性咳嗽',                   N'成人每次10ml，每日3~4次',                    N'12歲以下禁用；勿過量');
END
GO

ALTER TABLE clinics ADD geocode_quality NVARCHAR(10) NULL;
 
SELECT COUNT(*) AS medicines_count FROM medicines;
GO

select * from clinics 
select * from assessments

select * from clinics where med_name like '中山醫學大學%'
update clinics set lat = 24.11813910927943, lng = 120.65871390990698 where med_name = '中山醫學大學附設醫院中興分院'

SELECT COUNT(*) AS total, SUM(CASE WHEN lat IS NOT NULL THEN 1 ELSE 0 END) AS geocoded FROM clinics;
GO

SELECT COUNT(*) AS clinics_count FROM clinics;
GO

UPDATE clinics SET lat = NULL, lng = NULL, geocode_quality = NULL ;