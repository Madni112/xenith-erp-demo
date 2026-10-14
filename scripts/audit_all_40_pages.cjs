const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://syhxwmnplpkahdzuhvke.supabase.co',
  'sb_publishable_hKvy4zp9j38H712lDOj4Fw_mUiYQAIK'
);

const pages = [
  { name: '1. CRM / Leads', fn: () => supabase.from('crm_leads').select('*').limit(5) },
  { name: '2. CRM / Quotations', fn: () => supabase.from('crm_quotations').select('*').limit(5) },
  { name: '3. CRM / Customer Due List', fn: () => supabase.from('customers').select('*').limit(5) },
  { name: '4. Sales / Add Customer', fn: () => supabase.from('customers').select('id, customerName, registrationType, customer_code, customerCode').limit(5) },
  { name: '5. Sales / Customer History', fn: () => supabase.from('customers').select('*').order('customerName').limit(5) },
  { name: '6. Sales / New Invoice', fn: () => Promise.all([supabase.from('products').select('*').limit(5), supabase.from('customers').select('*').limit(5)]) },
  { name: '7. Sales / Sales History', fn: () => supabase.from('sales_invoices').select('*').limit(5) },
  { name: '8. Sales / Add Delivery Challan', fn: () => supabase.from('delivery_challans').select('*').limit(5) },
  { name: '9. Sales / Challan Queue', fn: () => supabase.from('delivery_challans').select('*').limit(5) },
  { name: '10. Sales / Sales Returns', fn: () => supabase.from('sales_returns').select('*').limit(5) },
  { name: '11. Sales / Return Receipts', fn: () => supabase.from('sales_return_receipts').select('*').limit(5) },
  { name: '12. Sales / Salesmen History', fn: () => supabase.from('salesmen').select('*').limit(5) },
  { name: '13. Purchase / Vendor List', fn: () => supabase.from('vendors').select('*').limit(5) },
  { name: '14. Purchase / Add Purchases', fn: () => Promise.all([supabase.from('vendors').select('*').limit(5), supabase.from('products').select('*').limit(5)]) },
  { name: '15. Purchase / Purchase List', fn: () => supabase.from('supplier_purchases').select('*').limit(5) },
  { name: '16. Purchase / Purchase Return', fn: () => supabase.from('purchase_returns').select('*').limit(5) },
  { name: '17. Purchase / Purchase Return Receipt', fn: () => supabase.from('purchase_return_receipts').select('*').limit(5) },
  { name: '18. Purchase / Add GRN', fn: () => Promise.all([supabase.from('vendors').select('*').limit(5), supabase.from('products').select('*').limit(5)]) },
  { name: '19. Inventory / Product Catalog', fn: () => supabase.from('products').select('*').limit(5) },
  { name: '20. Inventory / Categories', fn: () => supabase.from('inventory_categories').select('*').limit(5) },
  { name: '21. Inventory / Brands', fn: () => supabase.from('inventory_brands').select('*').limit(5) },
  { name: '22. Inventory / Surface Finishes', fn: () => supabase.from('inventory_surface_finishes').select('*').limit(5) },
  { name: '23. Inventory / UOM Manager', fn: () => supabase.from('inventory_uom').select('*').limit(5) },
  { name: '24. Inventory / Locations', fn: () => supabase.from('inventory_locations').select('*').limit(5) },
  { name: '25. Inventory / Stock Transfers', fn: () => supabase.from('stock_transfers').select('*').limit(5) },
  { name: '26. Accounts / Chart of Accounts', fn: () => supabase.from('chart_of_accounts').select('*').limit(5) },
  { name: '27. Accounts / Banks', fn: () => supabase.from('banks').select('*').limit(5) },
  { name: '28. Accounts / Vouchers', fn: () => supabase.from('financial_vouchers').select('*').limit(5) },
  { name: '29. HR / Employees List', fn: () => supabase.from('hr_employees').select('*').limit(5) },
  { name: '30. HR / Attendance', fn: () => supabase.from('hr_attendance').select('*').limit(5) },
  { name: '31. HR / Pay Heads', fn: () => supabase.from('hr_pay_heads').select('*').limit(5) },
  { name: '32. Reports / Sales Report', fn: () => supabase.from('sales_invoices').select('*').limit(5) },
  { name: '33. Reports / Purchase Report', fn: () => supabase.from('supplier_purchases').select('*').limit(5) },
  { name: '34. Reports / Stock Report', fn: () => supabase.from('products').select('*').limit(5) },
  { name: '35. Reports / Account Report', fn: () => supabase.from('chart_of_accounts').select('*').limit(5) },
  { name: '36. Reports / Holding Report', fn: () => supabase.from('sales_invoices').select('*').limit(5) },
  { name: '37. Administration / Companies', fn: () => supabase.from('companies').select('*').limit(5) },
  { name: '38. Administration / Logistics', fn: () => supabase.from('logistics_transportation').select('*').limit(5) },
  { name: '39. Administration / Tenants', fn: () => supabase.from('tenants').select('*').limit(5) },
  { name: '40. Administration / Audit Logs', fn: () => supabase.from('audit_logs').select('*').limit(5) }
];

async function run() {
  console.log(`=== AUDITING ALL ${pages.length} PAGES AND MODULES ===\n`);
  let passed = 0;
  let failed = 0;

  for (const page of pages) {
    try {
      const res = await page.fn();
      const err = Array.isArray(res) ? res.find(r => r.error)?.error : res.error;
      if (err) {
        failed++;
        console.log(`❌ [FAIL] ${page.name} -> ${err.message}`);
      } else {
        passed++;
        console.log(`✅ [PASS] ${page.name}`);
      }
    } catch (e) {
      failed++;
      console.log(`❌ [FAIL] ${page.name} -> ${e.message}`);
    }
  }

  console.log(`\n=== FINAL AUDIT RESULT: ${passed}/${pages.length} PAGES PASSED (${failed} FAILED) ===`);
}

run();
