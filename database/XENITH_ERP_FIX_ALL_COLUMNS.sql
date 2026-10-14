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
