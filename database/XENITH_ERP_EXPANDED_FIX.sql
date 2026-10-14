-- ====================================================================
-- XENITH ERP - EXPANDED FINAL SCHEMA ALIGNMENT (Deep Audit Fixes)
-- ====================================================================

-- 1. CRM LEADS
ALTER TABLE public.crm_leads ADD COLUMN IF NOT EXISTS items JSONB DEFAULT '[]'::jsonb;

-- 2. DELIVERY CHALLANS
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS customer_name VARCHAR(255);
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS transport_name VARCHAR(128);
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS transportation VARCHAR(128);
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS po_no VARCHAR(64);
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS total_quantity NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS total_discount NUMERIC(15, 2) DEFAULT 0.00;
ALTER TABLE public.delivery_challans ADD COLUMN IF NOT EXISTS total_net_amount NUMERIC(15, 2) DEFAULT 0.00;

-- 3. GRN RECEIPTS
ALTER TABLE public.grn_receipts ADD COLUMN IF NOT EXISTS vendor_name VARCHAR(255);

-- 4. PURCHASE RETURNS
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'purchase_returns' AND column_name = 'return_no' AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.purchase_returns ALTER COLUMN return_no DROP NOT NULL;
    END IF;
END $$;

ALTER TABLE public.purchase_returns ADD COLUMN IF NOT EXISTS return_no VARCHAR(64);
ALTER TABLE public.purchase_returns ADD COLUMN IF NOT EXISTS return_number VARCHAR(64);
ALTER TABLE public.purchase_returns ADD COLUMN IF NOT EXISTS vendor_name VARCHAR(255);

-- 5. NOTIFICATIONS & STOCK BALANCES
CREATE TABLE IF NOT EXISTS public.notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id VARCHAR(64),
    title VARCHAR(255),
    message TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.stock_balances (
    id BIGSERIAL PRIMARY KEY,
    tenant_id VARCHAR(64) DEFAULT 'bashir',
    product_name VARCHAR(255),
    warehouse_name VARCHAR(128),
    quantity NUMERIC(15, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.hr_designations ADD COLUMN IF NOT EXISTS title VARCHAR(128);
UPDATE public.hr_designations SET title = name WHERE title IS NULL;

ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS payment_term VARCHAR(64) DEFAULT 'Credit';
ALTER TABLE public.supplier_purchases ADD COLUMN IF NOT EXISTS remaining_balance NUMERIC(15, 2) DEFAULT 0.00;

ALTER TABLE public.crm_quotations ADD COLUMN IF NOT EXISTS quote_no VARCHAR(64);
UPDATE public.crm_quotations SET quote_no = quotation_number WHERE quote_no IS NULL;

ALTER TABLE public.grn_items ADD COLUMN IF NOT EXISTS accepted_qty NUMERIC(15, 2) DEFAULT 0.00;

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
