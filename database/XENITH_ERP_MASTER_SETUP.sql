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
-- ====================================================================
-- XENITH ERP - MASTER SCHEMA HARMONIZATION & COLUMN ALIGNMENT PATCH
-- Target Database: https://syhxwmnplpkahdzuhvke.supabase.co
-- Resolves ALL schema cache mismatches across all ERP modules
-- ====================================================================

-- 1. CUSTOMERS
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS "registrationType" VARCHAR(64) DEFAULT 'Retail / General';
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS "secondaryPhone" VARCHAR(64);
UPDATE public.customers SET "registrationType" = registrationtype WHERE "registrationType" IS NULL;
UPDATE public.customers SET "secondaryPhone" = secondaryphone WHERE "secondaryPhone" IS NULL;

-- 2. VENDORS / SUPPLIERS
ALTER TABLE public.vendors ADD COLUMN IF NOT EXISTS name VARCHAR(255);
ALTER TABLE public.vendors ADD COLUMN IF NOT EXISTS "vendorCode" VARCHAR(64);
ALTER TABLE public.vendors ADD COLUMN IF NOT EXISTS "pageNo" VARCHAR(64);
ALTER TABLE public.vendors ADD COLUMN IF NOT EXISTS contact_name VARCHAR(128);
ALTER TABLE public.vendors ADD COLUMN IF NOT EXISTS cell_no VARCHAR(64);
ALTER TABLE public.vendors ADD COLUMN IF NOT EXISTS phone_no VARCHAR(64);
UPDATE public.vendors SET name = vendor_name WHERE name IS NULL;
UPDATE public.vendors SET "vendorCode" = vendor_code WHERE "vendorCode" IS NULL;
UPDATE public.vendors SET "pageNo" = page_no WHERE "pageNo" IS NULL;

-- 3. PRODUCTS
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS sales_price NUMERIC(15, 2) DEFAULT 0.00;
UPDATE public.products SET sales_price = retail_price WHERE sales_price IS NULL OR sales_price = 0;

-- 4. SALES INVOICES
ALTER TABLE public.sales_invoices ADD COLUMN IF NOT EXISTS cash_amount_paid NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.sales_invoices ADD COLUMN IF NOT EXISTS bank_amount NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.sales_invoices ADD COLUMN IF NOT EXISTS dispatch_warehouse VARCHAR(128);
ALTER TABLE public.sales_invoices ADD COLUMN IF NOT EXISTS sale_status VARCHAR(64) DEFAULT 'Final';

-- 5. SALES RETURNS & RECEIPTS
ALTER TABLE public.sales_returns ADD COLUMN IF NOT EXISTS original_invoice_no VARCHAR(64);
ALTER TABLE public.sales_returns ADD COLUMN IF NOT EXISTS return_no VARCHAR(64);
ALTER TABLE public.sales_returns ADD COLUMN IF NOT EXISTS status VARCHAR(64) DEFAULT 'Completed';
ALTER TABLE public.sales_returns ADD COLUMN IF NOT EXISTS payout_amount_paid NUMERIC(15, 2) DEFAULT 0.00;

ALTER TABLE public.sales_return_receipts ADD COLUMN IF NOT EXISTS amount_paid NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.sales_return_receipts ADD COLUMN IF NOT EXISTS sales_return_id BIGINT;
ALTER TABLE public.sales_return_receipts ADD COLUMN IF NOT EXISTS invoice_no VARCHAR(64);
ALTER TABLE public.sales_return_receipts ADD COLUMN IF NOT EXISTS return_no VARCHAR(64);
ALTER TABLE public.sales_return_receipts ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- 6. DELIVERY CHALLANS
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS challan_no VARCHAR(64);
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS dispatch_warehouse VARCHAR(128);
UPDATE public.delivery_challans SET challan_no = challan_number WHERE challan_no IS NULL;

-- 7. SUPPLIER PURCHASES
ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS purchase_no VARCHAR(64);
ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS supplier_name VARCHAR(255);
ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS target_warehouse VARCHAR(128);
ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS cash_amount_paid NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS bank_amount_paid NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;
UPDATE public.supplier_purchases SET purchase_no = bill_number WHERE purchase_no IS NULL;

-- 8. PURCHASE RETURNS & RECEIPTS
ALTER TABLE public.purchase_returns ADD COLUMN IF NOT EXISTS purchase_no VARCHAR(64);
ALTER TABLE public.purchase_returns ADD COLUMN IF NOT EXISTS amount_paid NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.purchase_returns ADD COLUMN IF NOT EXISTS source_warehouse VARCHAR(128);
ALTER TABLE public.purchase_returns ADD COLUMN IF NOT EXISTS status VARCHAR(64) DEFAULT 'Completed';

ALTER TABLE public.purchase_return_receipts ADD COLUMN IF NOT EXISTS return_no VARCHAR(64);
ALTER TABLE public.purchase_return_receipts ADD COLUMN IF NOT EXISTS amount_received NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.purchase_return_receipts ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- 9. GRN (GOODS RECEIVED NOTE)
ALTER TABLE public.grn_receipts ADD COLUMN IF NOT EXISTS status VARCHAR(64) DEFAULT 'Received';

ALTER TABLE public.grn_items ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);
ALTER TABLE public.grn_items ADD COLUMN IF NOT EXISTS warehouse_name VARCHAR(128);

-- 10. STOCK & INVENTORY
ALTER TABLE public.opening_stocks ADD COLUMN IF NOT EXISTS "itemName" VARCHAR(255);
ALTER TABLE public.opening_stocks ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);
ALTER TABLE public.opening_stocks ADD COLUMN IF NOT EXISTS qty NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.opening_stocks ADD COLUMN IF NOT EXISTS location VARCHAR(128);

ALTER TABLE public.warehouse_inventory ADD COLUMN IF NOT EXISTS warehouse_name VARCHAR(128);

ALTER TABLE public.stock_transfers ADD COLUMN IF NOT EXISTS transfer_no VARCHAR(64);
ALTER TABLE public.stock_transfers ADD COLUMN IF NOT EXISTS from_location VARCHAR(128);
ALTER TABLE public.stock_transfers ADD COLUMN IF NOT EXISTS to_location VARCHAR(128);
UPDATE public.stock_transfers SET transfer_no = transfer_number WHERE transfer_no IS NULL;

-- 11. SALESMEN & HR
ALTER TABLE public.salesmen ADD COLUMN IF NOT EXISTS invoice_name VARCHAR(128);
ALTER TABLE public.salesmen ADD COLUMN IF NOT EXISTS invoice_names TEXT;
ALTER TABLE public.salesmen ADD COLUMN IF NOT EXISTS linked_salesmen JSONB DEFAULT '[]'::jsonb;

ALTER TABLE public.hr_employees ADD COLUMN IF NOT EXISTS designation_name VARCHAR(128);

-- 12. FINANCIAL VOUCHERS
ALTER TABLE public.financial_vouchers ADD COLUMN IF NOT EXISTS total_amount NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.financial_vouchers ADD COLUMN IF NOT EXISTS original_invoice_no VARCHAR(64);
ALTER TABLE public.financial_vouchers ADD COLUMN IF NOT EXISTS items JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.financial_vouchers ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- 13. INVENTORY LOCATIONS
ALTER TABLE public.inventory_locations ADD COLUMN IF NOT EXISTS location_type VARCHAR(64) DEFAULT 'Warehouse';

-- 14. NEW TABLES FOR COA, HR & LOGISTICS
CREATE TABLE IF NOT EXISTS public.coa_categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.coa_sub_categories (
    id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(128) NOT NULL,
    sub_category_name VARCHAR(128) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.coa_controls (
    id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(128) NOT NULL,
    sub_category_name VARCHAR(128) NOT NULL,
    control_name VARCHAR(128) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.hr_designations (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.logistics_transportation (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    driver_name VARCHAR(128),
    vehicle_number VARCHAR(64),
    phone VARCHAR(64),
    base_charges NUMERIC(15, 2) DEFAULT 0.00,
    status VARCHAR(32) DEFAULT 'Active',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed Essential COA Categories & Controls
INSERT INTO public.coa_categories (name)
VALUES ('1. ASSETS'), ('2. LIABILITIES'), ('3. EQUITY / CAPITAL'), ('4. REVENUE'), ('5. EXPENSES')
ON CONFLICT DO NOTHING;

INSERT INTO public.coa_sub_categories (category_name, sub_category_name)
VALUES
    ('1. ASSETS', 'Current Assets'),
    ('1. ASSETS', 'Fixed Assets'),
    ('2. LIABILITIES', 'Current Liabilities'),
    ('4. REVENUE', 'Operating Revenue'),
    ('5. EXPENSES', 'Cost of Goods Sold')
ON CONFLICT DO NOTHING;

INSERT INTO public.coa_controls (category_name, sub_category_name, control_name)
VALUES
    ('1. ASSETS', 'Current Assets', 'Customers'),
    ('1. ASSETS', 'Current Assets', 'Banks & Cash'),
    ('1. ASSETS', 'Current Assets', 'Inventory'),
    ('2. LIABILITIES', 'Current Liabilities', 'Suppliers / Vendors')
ON CONFLICT DO NOTHING;

INSERT INTO public.hr_designations (name, description)
VALUES ('Showroom Manager', 'Manager in charge of retail showroom'), ('Sales Executive', 'Direct sales and customer relations'), ('Accountant', 'Accounts & ledger management'), ('Warehouse Officer', 'Inventory and dispatches')
ON CONFLICT DO NOTHING;

INSERT INTO public.logistics_transportation (name, base_charges, status)
VALUES ('Faisal Movers Cargo', 2500.00, 'Active'), ('Daewoo Express Cargo', 3500.00, 'Active'), ('Local Truck Carriage (Hyderabad/Karachi)', 12000.00, 'Active')
ON CONFLICT DO NOTHING;

-- 15. RE-APPLY DATA API PERMISSIONS AND RLS FOR ALL PUBLIC TABLES
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

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

