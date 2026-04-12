import os
import sys
import subprocess
import streamlit as st
import pyodbc
import pandas as pd
from datetime import datetime

try:
    from streamlit.runtime.scriptrunner import get_script_run_ctx
    if not get_script_run_ctx():
        cmd = [sys.executable, "-m", "streamlit", "run", sys.argv[0]]
        subprocess.run(cmd)
        sys.exit(0)
except: pass

DB_CONFIG = {
    'DRIVER': '{ODBC Driver 17 for SQL Server}',
    'SERVER': 'localhost', 
    'DATABASE': 'RepairShopDB',
    'Trusted_Connection': 'yes',
}

def get_connection():
    conn_str = ';'.join([f'{k}={v}' for k, v in DB_CONFIG.items()])
    return pyodbc.connect(conn_str)

st.set_page_config(page_title="RepairShop Pro ERP", page_icon="🏎️", layout="wide")

st.markdown("""
<style>
    .main { background-color: #0e1117; color: #ffffff; }
    .stTabs [data-baseweb="tab-list"] { gap: 24px; }
    .stTabs [data-baseweb="tab"] { 
        height: 50px; background-color: #1e2129; border-radius: 10px; 
        padding: 10px 20px; color: #808495; border: 1px solid #3d404a;
    }
    .stTabs [aria-selected="true"] { background-color: #ff4b4b !important; color: white !important; border: none; }
    .stButton>button { border-radius: 10px; border: 1px solid #ff4b4b; background-color: transparent; color: white; transition: 0.3s; }
    .stButton>button:hover { background-color: #ff4b4b; box-shadow: 0 4px 15px rgba(255,75,75,0.3); }
    div[data-testid="stMetricValue"] { color: #ff4b4b; font-weight: bold; }
    .stDataFrame { border: 1px solid #3d404a; border-radius: 10px; }
</style>
""", unsafe_allow_html=True)

if 'role' not in st.session_state:
    st.session_state.role = None
    st.session_state.user_info = None

def safe_delete_vehicle(vID):
    with get_connection() as conn:
        cursor = conn.cursor()
        try:
            vID = int(vID)
            cursor.execute("DELETE FROM RepairItemPart WHERE iID IN (SELECT iID FROM RepairItem WHERE oID IN (SELECT oID FROM RepairOrder WHERE vID = ?))", (vID,))
            cursor.execute("DELETE FROM RepairItem WHERE oID IN (SELECT oID FROM RepairOrder WHERE vID = ?)", (vID,))
            cursor.execute("DELETE FROM RepairOrder WHERE vID = ?", (vID,))
            cursor.execute("DELETE FROM Vehicle WHERE vID = ?", (vID,))
            conn.commit()
            return True
        except Exception as e:
            st.error(f"❌ 刪除失敗：{e}")
            return False

def technician_portal():
    tech = st.session_state.user_info
    st.title(f"👨‍🔧 技師工作站 | 負責技師：{tech['eName']}")
    
    t1, t2 = st.tabs(["🔧 維修任務管理 (CRUD)", "🚗 新車登記與刪除"])
    
    with get_connection() as conn:
        with t1:
            col1, col2 = st.columns([1, 1.5])
            with col1:
                st.subheader("📝 維修內容")
                order_q = "SELECT o.oID, v.licensePlate FROM RepairOrder o JOIN Vehicle v ON o.vID = v.vID WHERE o.status != N'已領車'"
                orders = pd.read_sql(order_q, conn)
                
                if not orders.empty:
                    sel_oid = st.selectbox("🔎 選擇維修車牌", options=orders['oID'], 
                                          format_func=lambda x: f"車牌: {orders[orders['oID']==x]['licensePlate'].values[0]}")
                    with st.form("tech_add_form", clear_on_submit=True):
                        item = st.text_input("維修細項內容", placeholder="如：更換原廠機油")
                        l_c = st.number_input("維修工錢", min_value=0, step=100)
                        p_c = st.number_input("零件價錢", min_value=0, step=100)
                        stat = st.selectbox("更新狀態", ["維修中", "已完成", "待領車"])
                        if st.form_submit_button("確認提交紀錄"):
                            conn.cursor().execute("INSERT INTO RepairItem (iName, laborCost, partsCost, oID) VALUES (?,?,?,?)", (item, float(l_c), float(p_c), int(sel_oid)))
                            conn.cursor().execute("UPDATE RepairOrder SET status = ? WHERE oID = ?", (stat, int(sel_oid)))
                            conn.commit(); st.success("✅ 紀錄已成功更新！"); st.rerun()
                
                st.divider()
                st.subheader("🗑️ 刪除誤植紀錄")
                items = pd.read_sql("SELECT i.iID, i.iName, v.licensePlate FROM RepairItem i JOIN RepairOrder o ON i.oID = o.oID JOIN Vehicle v ON o.vID = v.vID", conn)
                if not items.empty:
                    del_id = st.selectbox("選擇要刪除的維修細項", options=items['iID'], 
                                          format_func=lambda x: f"車牌:{items[items['iID']==x]['licensePlate'].values[0]} - {items[items['iID']==x]['iName'].values[0]}")
                    if st.button("🔴 刪除選中紀錄"):
                        conn.cursor().execute("DELETE FROM RepairItem WHERE iID = ?", (int(del_id),))
                        conn.commit(); st.success("項目已刪除"); st.rerun()

            with col2:
                st.subheader("📊 廠內維修即時分布")
                st.caption("ℹ️ 提示：工單數量與清單數量不同是正常的，一個維修工單(單號)下可包含多個零件/工資清單項目。")
                st.dataframe(pd.read_sql("""
                    SELECT o.oID as 單號, v.licensePlate as 車牌, i.iName as 項目, 
                           (i.laborCost + i.partsCost) as 金額, o.status as 狀態 
                    FROM RepairOrder o 
                    JOIN Vehicle v ON o.vID = v.vID 
                    LEFT JOIN RepairItem i ON o.oID = i.oID
                """, conn), use_container_width=True)

        with t2:
            st.subheader("🚗 車輛入庫與同步開單")
            c1, c2 = st.columns(2)
            with c1:
                with st.form("new_v_auto"):
                    st.write("第一步：輸入車輛資訊")
                    plate = st.text_input("輸入新車牌")
                    model = st.text_input("車型名稱")
                    custs = pd.read_sql("SELECT cID, cName FROM Customer", conn)
                    cid = st.selectbox("選擇業主", custs['cID'], format_func=lambda x: custs[custs['cID']==x]['cName'].values[0])
                    if st.form_submit_button("✨ 登記車輛並自動同步開單"):
                        cursor = conn.cursor()
                        # 1. 插入車輛
                        cursor.execute("INSERT INTO Vehicle (licensePlate, model, year, cID, brandID) VALUES (?,?,2025,?,1)", (plate, model, int(cid)))
                        # 2. 【核心優化】自動幫這台新車開一張待維修工單
                        cursor.execute("INSERT INTO RepairOrder (date, status, vID, eID) VALUES (GETDATE(), N'待維修', (SELECT TOP 1 vID FROM Vehicle ORDER BY vID DESC), ?)", (int(tech['eID'])))
                        conn.commit(); st.success(f"🎊 車牌 {plate} 已成功登記並開啟維修單！"); st.rerun()
            
            with c2:
                st.write("第二步：錯誤車輛移除")
                v_list = pd.read_sql("SELECT vID, licensePlate, model FROM Vehicle", conn)
                v_del_id = st.selectbox("選擇要移除的車輛", v_list['vID'], format_func=lambda x: f"車牌: {v_list[v_list['vID']==x]['licensePlate'].values[0]}")
                if st.button("🚨 執行車輛連鎖刪除", type="primary"):
                    if safe_delete_vehicle(v_del_id): st.success("車輛及其紀錄已完全清除！"); st.rerun()

def admin_portal():
    st.title("🛡️ 系統最高權限後台")
    t1, t2 = st.tabs(["📊 經營大數據", "⚙️ 資料維護中心"])
    with get_connection() as conn:
        with t1:
            rev = pd.read_sql("SELECT SUM(laborCost + partsCost) as r FROM RepairItem", conn).iloc[0]['r'] or 0
            st.metric("累積營業額 (工資+零件)", f"NT$ {rev:,.0f}")
            st.subheader("全廠即時監控清單 (完整欄位)")
            st.dataframe(pd.read_sql("""
                SELECT v.licensePlate as 車牌, c.cName as 車主, o.status as 狀態, i.iName as 項目, i.laborCost as 工錢, i.partsCost as 零件
                FROM RepairOrder o JOIN Vehicle v ON o.vID = v.vID JOIN Customer c ON v.cID = c.cID LEFT JOIN RepairItem i ON o.oID = i.oID
            """, conn), use_container_width=True)
        
        with t2:
            st.subheader("管理員專屬資料維護")
            mode = st.radio("類別", ["客戶管理", "車輛管理"], horizontal=True)
            if mode == "客戶管理":
                with st.expander("➕ 新增客戶資料"):
                    with st.form("adm_add_c"):
                        n, p, a = st.text_input("姓名"), st.text_input("電話"), st.text_input("地址")
                        if st.form_submit_button("完成客戶新增"):
                            conn.cursor().execute("INSERT INTO Customer (cName, phone, address) VALUES (?,?,?)", (n, p, a))
                            conn.commit(); st.success("已新增"); st.rerun()
                df = pd.read_sql("SELECT * FROM Customer", conn)
                st.dataframe(df, use_container_width=True)
                tid = st.selectbox("選取要刪除的客戶 ID", df['cID'], format_func=lambda x: f"{df[df['cID']==x]['cName'].values[0]}")
                if st.button("🗑️ 刪除此客戶"):
                    conn.cursor().execute("DELETE FROM Customer WHERE cID=?", (int(tid),))
                    conn.commit(); st.success("已完全清除"); st.rerun()
            else:
                df = pd.read_sql("SELECT * FROM Vehicle", conn)
                st.dataframe(df, use_container_width=True)
                tid = st.selectbox("選取要刪除的車輛 ID", df['vID'], format_func=lambda x: f"車牌: {df[df['vID']==x]['licensePlate'].values[0]}")
                if st.button("🗑️ 徹底刪除此車輛"):
                    if safe_delete_vehicle(tid): st.success("已移除"); st.rerun()

if st.session_state.role is None:
    st.title("🏁 RepairShop ERP 智慧修車廠系統")
    st.markdown("---")
    with st.expander("📌 快速登入提示", expanded=True):
        st.write("管理員: `admin123` | 技師: `李組長` | 客戶: `0910-123-456`")
    choice = st.radio("🔑 請選擇", ["客戶", "技師", "管理員"], horizontal=True)
    
    with st.container():
        if choice == "客戶":
            tel = st.text_input("請輸入電話號碼")
            if st.button("車主登入"):
                with get_connection() as conn:
                    res = pd.read_sql("SELECT * FROM Customer WHERE phone = ?", conn, params=[tel])
                    if not res.empty: st.session_state.role, st.session_state.user_info = "Customer", res.iloc[0]; st.rerun()
                    else: st.error("❌ 登入失敗：查無此電話資訊，請重新輸入正確資訊！")
        elif choice == "技師":
            name = st.text_input("請輸入技師姓名")
            if st.button("技師登入"):
                with get_connection() as conn:
                    res = pd.read_sql("SELECT * FROM Employee WHERE eName = ?", conn, params=[name])
                    if not res.empty: st.session_state.role, st.session_state.user_info = "Technician", res.iloc[0]; st.rerun()
                    else: st.error("❌ 登入失敗：技師姓名不正確，請重新輸入正確資訊！")
        elif choice == "管理員":
            pw = st.text_input("管理密碼", type="password")
            if st.button("管理員登入"):
                if pw == "admin123": st.session_state.role = "Admin"; st.rerun()
                else: st.error("❌ 登入失敗：密碼錯誤，請重新輸入正確資訊！")
else:
    if st.sidebar.button("🚪 登出系統"): st.session_state.role = None; st.rerun()
    if st.session_state.role == "Customer": 
        cust = st.session_state.user_info
        st.title(f"👋 哈囉，{cust['cName']} 車主")
        with get_connection() as conn:
            st.dataframe(pd.read_sql("SELECT v.licensePlate as 車牌, o.status as 狀態, i.iName as 項目, (i.laborCost+i.partsCost) as 總費用 FROM Vehicle v LEFT JOIN RepairOrder o ON v.vID = o.vID LEFT JOIN RepairItem i ON o.oID = i.oID WHERE v.cID = ?", conn, params=[int(cust['cID'])]), use_container_width=True)
    elif st.session_state.role == "Technician": technician_portal()
    elif st.session_state.role == "Admin": admin_portal()