-- ====================================================================
-- XENITH ERP - FINAL MINOR POLISH (8 Remaining Lookups)
-- ====================================================================

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
