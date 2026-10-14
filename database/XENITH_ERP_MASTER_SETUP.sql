-- ====================================================================
-- XENITH ERP / NHT ENTERPRISE - DEMO DATABASE MASTER SETUP
-- Target Database: https://syhxwmnplpkahdzuhvke.supabase.co
-- ====================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. TENANTS
CREATE TABLE IF NOT EXISTS public.tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(128),
    business_activity VARCHAR(255) DEFAULT 'Commercial / Tiles & Sanitary',
    allowed_modules JSONB DEFAULT '["sales", "purchase", "inventory", "crm", "accounts", "reports"]'::jsonb,
    seller_address TEXT,
    location_id VARCHAR(64),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. COMPANIES / BRANCH ENTITIES
CREATE TABLE IF NOT EXISTS public.companies (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(64),
    email VARCHAR(128),
    ntn VARCHAR(64),
    strn VARCHAR(64),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. CUSTOMERS
CREATE TABLE IF NOT EXISTS public.customers (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    "customerName" VARCHAR(255) NOT NULL,
    customername VARCHAR(255),
    customer_code VARCHAR(64),
    "customerCode" VARCHAR(64),
    account_code VARCHAR(64),
    coa_code VARCHAR(64),
    page_no VARCHAR(64),
    "pageNo" VARCHAR(64),
    registrationType VARCHAR(64) DEFAULT 'Retail / General',
    "primaryPhone" VARCHAR(64),
    phone VARCHAR(64),
    secondaryPhone VARCHAR(64),
    email VARCHAR(128),
    website VARCHAR(255),
    address TEXT,
    city VARCHAR(64) DEFAULT 'Hyderabad',
    province VARCHAR(64) DEFAULT 'Sindh',
    company VARCHAR(255),
    "cnicNo" VARCHAR(32),
    "ntnNo" VARCHAR(32),
    ntn_strn VARCHAR(64),
    "stRegNo" VARCHAR(32),
    notes TEXT,
    "followUpDate" DATE,
    "currentBalance" NUMERIC(15, 2) DEFAULT 0.00,
    balance NUMERIC(15, 2) DEFAULT 0.00,
    opening_balance NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.customer_recoveries (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    customer_id BIGINT,
    customer_name VARCHAR(255),
    amount NUMERIC(15, 2) DEFAULT 0.00,
    recovery_date DATE DEFAULT CURRENT_DATE,
    bank_id BIGINT,
    receipt_no VARCHAR(64),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. VENDORS / SUPPLIERS
CREATE TABLE IF NOT EXISTS public.vendors (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    vendor_name VARCHAR(255) NOT NULL,
    company_name VARCHAR(255),
    vendor_code VARCHAR(64),
    page_no VARCHAR(64),
    phone VARCHAR(64),
    email VARCHAR(128),
    address TEXT,
    province VARCHAR(64) DEFAULT 'Sindh',
    ntn VARCHAR(32),
    cnic VARCHAR(32),
    strn VARCHAR(32),
    "currentBalance" NUMERIC(15, 2) DEFAULT 0.00,
    balance NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. INVENTORY: CATEGORIES, BRANDS, FINISHES, LOCATIONS & UOM
CREATE TABLE IF NOT EXISTS public.inventory_categories (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_id BIGINT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.inventory_brands (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.inventory_surface_finishes (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.inventory_locations (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    name VARCHAR(255) NOT NULL,
    address TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.inventory_uom (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    short_code VARCHAR(32) NOT NULL,
    full_name VARCHAR(128) NOT NULL,
    category VARCHAR(64) DEFAULT 'Count & Units',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. PRODUCTS & STOCK
CREATE TABLE IF NOT EXISTS public.products (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    product_name VARCHAR(255) NOT NULL,
    item_sr_no VARCHAR(128),
    category VARCHAR(128),
    sub_category VARCHAR(128),
    sub_sub_category VARCHAR(128),
    brand VARCHAR(128),
    bin VARCHAR(128),
    uom VARCHAR(64) DEFAULT 'EACH',
    product_description TEXT,
    profit NUMERIC(15, 2) DEFAULT 0.00,
    purchase_price NUMERIC(15, 2) DEFAULT 0.00,
    retail_price NUMERIC(15, 2) DEFAULT 0.00,
    mrp NUMERIC(15, 2) DEFAULT 0.00,
    current_stock NUMERIC(15, 2) DEFAULT 0.00,
    min_stock_alert NUMERIC(15, 2) DEFAULT 5.00,
    pieces_per_box NUMERIC(10, 2),
    pcs_per_box NUMERIC(10, 2),
    pieces_per_packing NUMERIC(10, 2),
    hs_code VARCHAR(64) DEFAULT '',
    item_type VARCHAR(64) DEFAULT 'goods',
    scenario_name VARCHAR(128) DEFAULT '',
    sro_schedule_no VARCHAR(64),
    service_charges NUMERIC(15, 2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.opening_stocks (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    product_id BIGINT,
    location_id BIGINT,
    quantity NUMERIC(15, 2) DEFAULT 0.00,
    cost_price NUMERIC(15, 2) DEFAULT 0.00,
    retail_price NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.warehouse_inventory (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    product_id BIGINT,
    location_id BIGINT,
    quantity NUMERIC(15, 2) DEFAULT 0.00,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.stock_transfers (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    transfer_no VARCHAR(64) NOT NULL,
    source_location_id BIGINT,
    destination_location_id BIGINT,
    items JSONB DEFAULT '[]'::jsonb,
    notes TEXT,
    status VARCHAR(32) DEFAULT 'Completed',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. SALESMEN
CREATE TABLE IF NOT EXISTS public.salesmen (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    user_id UUID,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(64),
    email VARCHAR(128),
    commission_rate NUMERIC(5, 2) DEFAULT 0.00,
    area VARCHAR(128),
    invoice_name VARCHAR(255),
    invoice_names JSONB DEFAULT '[]'::jsonb,
    linked_salesmen JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. CRM: LEADS & QUOTATIONS
CREATE TABLE IF NOT EXISTS public.crm_leads (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    client VARCHAR(255),
    contact VARCHAR(255),
    phone VARCHAR(64),
    items JSONB DEFAULT '[]'::jsonb,
    interest TEXT,
    est_value NUMERIC(15, 2) DEFAULT 0.00,
    stage VARCHAR(64) DEFAULT 'New Inquiry',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.crm_quotations (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    quote_no VARCHAR(64),
    customer VARCHAR(255),
    customer_name VARCHAR(255),
    date DATE DEFAULT CURRENT_DATE,
    valid_until DATE,
    amount NUMERIC(15, 2) DEFAULT 0.00,
    total_amount NUMERIC(15, 2) DEFAULT 0.00,
    status VARCHAR(64) DEFAULT 'Draft',
    items JSONB DEFAULT '[]'::jsonb,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. SALES: INVOICES, RETURNS, DELIVERY CHALLANS & RECEIPTS
CREATE TABLE IF NOT EXISTS public.sales_invoices (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    invoice_no VARCHAR(64) NOT NULL,
    customer_id BIGINT,
    customer_name VARCHAR(255) NOT NULL,
    buyer_ntn VARCHAR(32),
    buyer_cnic VARCHAR(32),
    buyer_province VARCHAR(64) DEFAULT 'Sindh',
    buyer_address TEXT,
    buyer_registration_type VARCHAR(32) DEFAULT 'Unregistered',
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    total_amount NUMERIC(15, 2) DEFAULT 0.00,
    discount_amt NUMERIC(15, 2) DEFAULT 0.00,
    sales_tax_amt NUMERIC(15, 2) DEFAULT 0.00,
    further_tax_amt NUMERIC(15, 2) DEFAULT 0.00,
    extra_tax_amt NUMERIC(15, 2) DEFAULT 0.00,
    net_amount NUMERIC(15, 2) DEFAULT 0.00,
    amount_paid NUMERIC(15, 2) DEFAULT 0.00,
    balance_due NUMERIC(15, 2) DEFAULT 0.00,
    sale_status VARCHAR(32) DEFAULT 'Completed',
    receipt_status VARCHAR(32) DEFAULT 'Paid',
    fbr_fiscal_number VARCHAR(128),
    fbr_status VARCHAR(32) DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.sales_returns (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    return_no VARCHAR(64) NOT NULL,
    invoice_no VARCHAR(64),
    customer_id BIGINT,
    customer_name VARCHAR(255),
    return_date DATE DEFAULT CURRENT_DATE,
    items JSONB DEFAULT '[]'::jsonb,
    total_amount NUMERIC(15, 2) DEFAULT 0.00,
    refund_amount NUMERIC(15, 2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.sales_return_receipts (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    receipt_no VARCHAR(64) NOT NULL,
    return_no VARCHAR(64),
    customer_id BIGINT,
    customer_name VARCHAR(255),
    amount NUMERIC(15, 2) DEFAULT 0.00,
    payment_mode VARCHAR(64) DEFAULT 'Cash',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.delivery_challans (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    challan_no VARCHAR(64) NOT NULL,
    invoice_no VARCHAR(64),
    customer_name VARCHAR(255),
    dispatch_warehouse VARCHAR(255),
    items JSONB DEFAULT '[]'::jsonb,
    status VARCHAR(64) DEFAULT 'Pending',
    is_printed BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. PURCHASES: SUPPLIER PURCHASES, GRN & RETURNS
CREATE TABLE IF NOT EXISTS public.supplier_purchases (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    purchase_no VARCHAR(64),
    po_no VARCHAR(64),
    vendor_id BIGINT,
    vendor_name VARCHAR(255),
    purchase_date DATE DEFAULT CURRENT_DATE,
    items JSONB DEFAULT '[]'::jsonb,
    total_amount NUMERIC(15, 2) DEFAULT 0.00,
    paid_amount NUMERIC(15, 2) DEFAULT 0.00,
    balance_due NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.purchase_returns (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    return_no VARCHAR(64) NOT NULL,
    bill_no VARCHAR(64),
    vendor_id BIGINT,
    vendor_name VARCHAR(255),
    items JSONB DEFAULT '[]'::jsonb,
    total_amount NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.purchase_return_receipts (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    receipt_no VARCHAR(64),
    return_no VARCHAR(64),
    vendor_name VARCHAR(255),
    amount NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.grn_receipts (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    grn_no VARCHAR(64) NOT NULL,
    vendor_id BIGINT,
    vendor_name VARCHAR(255),
    inward_challan_no VARCHAR(64),
    status VARCHAR(64) DEFAULT 'Received',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.grn_items (
    id BIGSERIAL PRIMARY KEY,
    grn_id BIGINT,
    product_id BIGINT,
    product_name VARCHAR(255),
    quantity NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. BANKING, CHART OF ACCOUNTS & FINANCIAL VOUCHERS
CREATE TABLE IF NOT EXISTS public.chart_of_accounts (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    account_code VARCHAR(32) NOT NULL,
    account_title VARCHAR(255) NOT NULL,
    control_code VARCHAR(64),
    category_code VARCHAR(64),
    sub_category_code VARCHAR(64),
    account_type VARCHAR(64),
    opening_balance NUMERIC(15, 2) DEFAULT 0.00,
    balance_nature VARCHAR(16) DEFAULT 'Debit',
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.banks (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    "bankName" VARCHAR(255) NOT NULL,
    "accountTitle" VARCHAR(255) NOT NULL,
    "accountNumber" VARCHAR(64) NOT NULL,
    branch VARCHAR(128),
    iban VARCHAR(64),
    "initialBalance" NUMERIC(15, 2) DEFAULT 0.00,
    "currentBalance" NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.financial_vouchers (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    voucher_no VARCHAR(64) NOT NULL,
    voucher_type VARCHAR(32) NOT NULL,
    voucher_date DATE DEFAULT CURRENT_DATE,
    account_code VARCHAR(32),
    account_title VARCHAR(255),
    debit NUMERIC(15, 2) DEFAULT 0.00,
    credit NUMERIC(15, 2) DEFAULT 0.00,
    narration TEXT,
    salesman_id BIGINT,
    bank_id BIGINT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. AUDIT LOGS
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    action_type VARCHAR(64),
    table_name VARCHAR(64),
    performed_by VARCHAR(128),
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. HUMAN RESOURCES (HR)
CREATE TABLE IF NOT EXISTS public.hr_employees (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    name VARCHAR(255) NOT NULL,
    designation VARCHAR(128),
    phone VARCHAR(64),
    email VARCHAR(128),
    basic_salary NUMERIC(15, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.hr_attendance (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    employee_id BIGINT,
    attendance_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(32) DEFAULT 'Present',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.hr_pay_heads (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    name VARCHAR(128) NOT NULL,
    type VARCHAR(64) DEFAULT 'Earnings',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. PERMISSIONS & DATA API GRANTS
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

-- 16. PERMISSIVE RLS POLICIES FOR ALL TABLES
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' ENABLE ROW LEVEL SECURITY;';
        EXECUTE 'DROP POLICY IF EXISTS allow_all_' || quote_ident(r.tablename) || ' ON public.' || quote_ident(r.tablename) || ';';
        EXECUTE 'CREATE POLICY allow_all_' || quote_ident(r.tablename) || ' ON public.' || quote_ident(r.tablename) || ' FOR ALL TO public USING (true) WITH CHECK (true);';
    END LOOP;
END $$;

-- 17. INITIAL STARTER SEED DATA
INSERT INTO public.tenants (slug, name, email)
VALUES
    ('bashir', 'NHT ENTERPRISE - Master', 'admin@nhtenterprise.com'),
    ('demo', 'Xenith ERP Demo', 'demo@xenitherp.com')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO public.companies (name, address, phone)
VALUES
    ('NHT ENTERPRISE (Main Showroom)', 'Plot 12-A, Commercial Area, Hyderabad', '0300-1234567'),
    ('Al-Madina Traders', 'Shop # 4, Ceramic Market, Saddar', '0312-7654321')
ON CONFLICT DO NOTHING;

INSERT INTO public.inventory_locations (name, address, description)
VALUES
    ('Main Warehouse (Site A)', 'Industrial Zone, Hyderabad', 'Primary central inventory warehouse'),
    ('City Center Showroom', 'Commercial Market, Saddar', 'Retail and display stock')
ON CONFLICT DO NOTHING;

INSERT INTO public.inventory_uom (short_code, full_name, category)
VALUES
    ('SQFT', 'Square Feet', 'Area & Surface'),
    ('SQM', 'Square Meter', 'Area & Surface'),
    ('BOX', 'Carton / Box', 'Packaging'),
    ('EACH', 'Each / Single Unit', 'Count & Units'),
    ('PCS', 'Pieces', 'Count & Units'),
    ('MTR', 'Meter', 'Length & Distance'),
    ('KG', 'Kilogram', 'Weight & Mass')
ON CONFLICT DO NOTHING;

INSERT INTO public.inventory_categories (name, description)
VALUES
    ('Wall Tiles', 'Glazed ceramic and porcelain wall tiles'),
    ('Floor Tiles', 'Vitrified polished and matte floor tiles'),
    ('Porcelain Tiles', 'Heavy duty outdoor and indoor porcelain'),
    ('Sanitary Ware', 'Commode, wash basins, vanities and bidets'),
    ('Bath Fittings', 'Mixers, taps, showers, and accessories')
ON CONFLICT DO NOTHING;

INSERT INTO public.inventory_surface_finishes (name, description)
VALUES
    ('Master Tiles', 'Master ceramic & porcelain tiles'),
    ('Karam Ceramics', 'Premium floor and wall collection'),
    ('Sonex', 'Sanitary fixtures and fittings'),
    ('Porta', 'Luxury sanitary ware'),
    ('RAK Ceramics', 'Imported luxury tiles')
ON CONFLICT DO NOTHING;

INSERT INTO public.customers ("customerName", customer_code, "primaryPhone", city, province, company, "currentBalance")
VALUES
    ('Al-Razi Construction Co.', '1020-001', '0300-8889991', 'Hyderabad', 'Sindh', 'NHT ENTERPRISE (Main Showroom)', 45000.00),
    ('Haji Muhammad Ismail & Sons', '1020-002', '0312-3334445', 'Karachi', 'Sindh', 'Al-Madina Traders', 125000.00),
    ('Malik Builders & Developers', '1020-003', '0333-5556667', 'Sukkur', 'Sindh', 'NHT ENTERPRISE (Main Showroom)', 0.00)
ON CONFLICT DO NOTHING;

INSERT INTO public.products (product_name, category, brand, uom, purchase_price, retail_price, current_stock, min_stock_alert)
VALUES
    ('Super White Glossy 60x120', 'Floor Tiles', 'Master Tiles', 'SQFT', 180.00, 240.00, 1500.00, 100.00),
    ('Calacatta Gold Marble Finish 60x60', 'Floor Tiles', 'Karam Ceramics', 'SQFT', 160.00, 210.00, 2200.00, 150.00),
    ('Matte Grey Subway Tile 30x60', 'Wall Tiles', 'Master Tiles', 'SQFT', 140.00, 185.00, 850.00, 50.00),
    ('One-Piece Smart Commode Ivory', 'Sanitary Ware', 'Porta', 'EACH', 18500.00, 24000.00, 25.00, 5.00),
    ('Single Lever Basin Mixer Chrome', 'Bath Fittings', 'Sonex', 'EACH', 4200.00, 5800.00, 60.00, 10.00)
ON CONFLICT DO NOTHING;

INSERT INTO public.crm_leads (client, contact, phone, interest, est_value, stage, notes)
VALUES
    ('Apex Construction - Gulberg Tower', 'Engr. Tariq', '0300-1122334', 'Porcelain Floor Tiles 60x120 (3,500 sqft)', 840000.00, 'Quotation Sent', 'Quotation submitted with 5% discount option'),
    ('Hassan Residency Bathroom Renovation', 'Mr. Hassan', '0313-9988776', 'Sanitary Ware & Bath Fittings', 165000.00, 'New Inquiry', 'Wants modern wall-hung commodes and chrome mixers')
ON CONFLICT DO NOTHING;
