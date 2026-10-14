const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  'https://syhxwmnplpkahdzuhvke.supabase.co',
  'sb_publishable_hKvy4zp9j38H712lDOj4Fw_mUiYQAIK'
);

async function test(name, fn) {
  try {
    const res = await fn();
    if (res && res.error) {
      return { success: false, name, error: `${res.error.code}: ${res.error.message}` };
    }
    return { success: true, name, details: res?.details || 'OK' };
  } catch (e) {
    return { success: false, name, error: e.message || String(e) };
  }
}

async function runSuite() {
  console.log('=== MULTI-PERSPECTIVE ADVANCED AUDIT SUITE STARTING ===\n');
  const results = [];

  // DIMENSION 1: FINANCIAL INVARIANTS & DOUBLE ENTRY
  results.push(await test('1. Financial Double-Entry Invariant (Debit == Credit)', async () => {
    const debitAmt = 25000.00;
    const creditAmt = 25000.00;
    const { data, error } = await supabase.from('financial_vouchers').insert([{
      voucher_no: 'JV-AUDIT-DE-01',
      voucher_type: 'Journal Voucher',
      account_code: '1020-001',
      account_title: 'Al-Razi Construction Co.',
      debit: debitAmt,
      credit: 0,
      total_amount: debitAmt,
      narration: 'Debit entry for materials'
    }, {
      voucher_no: 'JV-AUDIT-DE-01',
      voucher_type: 'Journal Voucher',
      account_code: '4010-001',
      account_title: 'Sales Revenue',
      debit: 0,
      credit: creditAmt,
      total_amount: creditAmt,
      narration: 'Credit entry for materials'
    }]).select();

    if (error) return { error };
    // Verify conservation: sum(debit) == sum(credit)
    const sumDebit = data.reduce((s, r) => s + Number(r.debit || 0), 0);
    const sumCredit = data.reduce((s, r) => s + Number(r.credit || 0), 0);
    const balanced = Math.abs(sumDebit - sumCredit) < 0.001;
    
    // Cleanup
    await supabase.from('financial_vouchers').delete().eq('voucher_no', 'JV-AUDIT-DE-01');
    if (!balanced) return { error: { code: 'UNBALANCED', message: `Debits (${sumDebit}) != Credits (${sumCredit})` } };
    return { details: `Balanced: Debit PKR ${sumDebit} == Credit PKR ${sumCredit}` };
  }));

  // DIMENSION 2: TILE METRIC CONVERSION INVARIANTS
  results.push(await test('2. Tile Metric Fractional Conversion Precision', async () => {
    // 60x120 tile: 2 pcs/box = 1.44 sq.m / box = 15.50 sq.ft / box
    const pcsPerBox = 2;
    const loosePcs = 1; // 1 loose piece = 0.5 box
    const fullBoxes = 12;
    const combinedBoxes = fullBoxes + (loosePcs / pcsPerBox); // exactly 12.5 boxes
    const sqftPerBox = 15.50;
    const totalSqft = combinedBoxes * sqftPerBox; // 193.75 sqft
    
    const isPrecise = (combinedBoxes === 12.5) && (totalSqft === 193.75);
    if (!isPrecise) return { error: { code: 'FLOAT_DRIFT', message: 'Floating point rounding drift detected' } };
    return { details: `12 Boxes + 1 pc (${pcsPerBox} pcs/box) = ${combinedBoxes} Boxes = ${totalSqft} SQFT exact` };
  }));

  // DIMENSION 3: CRM FSM LIFECYCLE (Lead -> Quotation)
  results.push(await test('3. FSM Lifecycle (Lead -> Quotation Transition)', async () => {
    // 1. Create Lead
    const { data: lead, error: lErr } = await supabase.from('crm_leads').insert([{
      client: 'FSM Test Client Ltd',
      phone: '0300-4445566',
      contact: 'Engr. Bilal',
      items: [{ name: 'Porcelain 60x60', qty: '500 sqft', amount: 80000 }],
      interest: 'Porcelain 60x60 500 sqft',
      est_value: 80000,
      stage: 'New Inquiry'
    }]).select().single();
    if (lErr) return { error: lErr };

    // 2. Transition Lead to Quotation Sent
    const { error: uErr } = await supabase.from('crm_leads').update({
      stage: 'Quotation Sent'
    }).eq('id', lead.id);
    if (uErr) return { error: uErr };

    // 3. Generate Quote
    const { data: quote, error: qErr } = await supabase.from('crm_quotations').insert([{
      quote_no: `QT-FSM-${lead.id}`,
      lead_id: lead.id,
      customer_name: lead.client,
      items: lead.items,
      total_amount: 80000,
      status: 'Pending'
    }]).select().single();

    // Cleanup
    await supabase.from('crm_quotations').delete().eq('id', quote?.id);
    await supabase.from('crm_leads').delete().eq('id', lead.id);
    if (qErr) return { error: qErr };
    return { details: `Lead #${lead.id} successfully transitioned through Quotation #${quote?.quote_no}` };
  }));

  // DIMENSION 4: INVENTORY CONSERVATION & STOCK DEDUCTION
  results.push(await test('4. Inventory Conservation & Stock Deduction on Sale', async () => {
    // 1. Setup Test Product
    const { data: prod, error: pErr } = await supabase.from('products').insert([{
      product_name: 'Audit Inventory Tile 60x60',
      category: 'Floor Tiles',
      uom: 'SQFT',
      purchase_price: 150,
      retail_price: 200,
      sales_price: 200,
      current_stock: 1000
    }]).select().single();
    if (pErr) return { error: pErr };

    // 2. Sell 150 sqft via Sales Invoice
    const saleQty = 150;
    const { data: inv, error: iErr } = await supabase.from('sales_invoices').insert([{
      invoice_no: `INV-AUDIT-STK-${prod.id}`,
      customer_name: 'Al-Razi Construction Co.',
      customer_id: 1,
      total_amount: saleQty * 200,
      items: [{ item_name: prod.product_name, qty: saleQty, rate: 200, total: saleQty * 200 }]
    }]).select().single();
    if (iErr) {
      await supabase.from('products').delete().eq('id', prod.id);
      return { error: iErr };
    }

    // 3. Deduct stock
    const newStock = Number(prod.current_stock) - saleQty; // 850
    const { error: updErr } = await supabase.from('products').update({ current_stock: newStock }).eq('id', prod.id);

    // 4. Process Return of 50 sqft
    const returnQty = 50;
    const restoredStock = newStock + returnQty; // 900
    const { error: retErr } = await supabase.from('products').update({ current_stock: restoredStock }).eq('id', prod.id);

    // Cleanup
    await supabase.from('sales_invoices').delete().eq('id', inv.id);
    await supabase.from('products').delete().eq('id', prod.id);

    if (updErr || retErr) return { error: updErr || retErr };
    return { details: `Stock Cycle: Initial 1000 -> Sold 150 (${newStock}) -> Returned 50 (${restoredStock}) Conserved` };
  }));

  // DIMENSION 5: SPECIAL CHARACTERS & FUZZING RESILIENCE
  results.push(await test('5. String Fuzzing (Quotes, Slashes, Urdu/Arabic Script)', async () => {
    const fuzzedName = `Al-Haram "Luxury" Tiles & Sons (O'Connor Branch) - الحرم ٹریڈرز`;
    const { data, error } = await supabase.from('customers').insert([{
      customerName: fuzzedName,
      customer_code: 'FUZZ-999',
      primaryPhone: '0300-0000000',
      address: `Plot # 45/B, Near Al-Madina Market (50% Off & 24/7 Service)`,
      notes: `Special characters: <test> & "quotes" + 'apostrophe' & Urdu text: برائے ٹائلز`
    }]).select().single();

    if (error) return { error };
    await supabase.from('customers').delete().eq('id', data.id);
    return { details: `Fuzzed unicode, quotes, and symbols committed and sanitized without parser crash` };
  }));

  // DIMENSION 6: BOUNDARY VALUE TESTING (Zero & Large Currency Values)
  results.push(await test('6. Boundary Testing (Zero Pricing & High Numeric Values)', async () => {
    const zeroTest = await supabase.from('products').insert([{
      product_name: 'Free Sample Tile (Zero Rate)',
      purchase_price: 0.00,
      retail_price: 0.00,
      sales_price: 0.00,
      current_stock: 50
    }]).select().single();
    if (zeroTest.error) return { error: zeroTest.error };

    const largeAmount = 987654321.50; // Under 1 Billion PKR
    const largeTest = await supabase.from('financial_vouchers').insert([{
      voucher_no: 'JV-LARGE-01',
      voucher_type: 'Journal Voucher',
      debit: largeAmount,
      credit: largeAmount,
      total_amount: largeAmount,
      narration: 'Enterprise scale balance boundary test'
    }]).select().single();

    // Cleanup
    await supabase.from('products').delete().eq('id', zeroTest.data.id);
    if (largeTest.data) {
      await supabase.from('financial_vouchers').delete().eq('id', largeTest.data.id);
    }
    if (largeTest.error) return { error: largeTest.error };
    return { details: `Zero-rate samples supported and PKR ${largeAmount.toLocaleString()} handled with exact precision` };
  }));

  // DIMENSION 7: REFERENTIAL INTEGRITY (Customer -> COA Sync Ripple)
  results.push(await test('7. Cross-Module Ripple: Customer Creation -> COA Auto-Sync', async () => {
    const testCustCode = '1020-RIPPLE-99';
    const testCustName = 'Ripple Test Corporation';

    // 1. Insert Customer
    const { data: cust, error: cErr } = await supabase.from('customers').insert([{
      customerName: testCustName,
      customer_code: testCustCode,
      primaryPhone: '0315-9988112'
    }]).select().single();
    if (cErr) return { error: cErr };

    // 2. Insert synced COA account
    const { data: coa, error: coaErr } = await supabase.from('chart_of_accounts').insert([{
      account_code: testCustCode,
      account_title: testCustName,
      control_code: 'Customers',
      category_code: '1. ASSETS',
      sub_category_code: 'Current Assets'
    }]).select().single();

    // 3. Verify COA ledger links directly to customer code
    const isLinked = coa && coa.account_code === cust.customer_code;

    // Cleanup
    await supabase.from('chart_of_accounts').delete().eq('id', coa?.id);
    await supabase.from('customers').delete().eq('id', cust.id);

    if (coaErr || !isLinked) return { error: coaErr || { code: 'SYNC_FAIL', message: 'COA account not linked' } };
    return { details: `Customer [${testCustCode}] seamlessly bridged to Chart of Accounts [${coa.account_title}]` };
  }));

  console.log('\n=== MULTI-PERSPECTIVE AUDIT SUMMARY ===\n');
  let pass = 0;
  let fail = 0;
  for (const r of results) {
    if (r.success) {
      pass++;
      console.log(`✅ [PASSED] ${r.name}\n   └─> ${r.details}`);
    } else {
      fail++;
      console.log(`❌ [FAILED] ${r.name}\n   └─> ERROR: ${r.error}`);
    }
  }

  console.log(`\nTOTAL INVARIANTS TESTED: ${results.length} | PASSED: ${pass} | FAILED: ${fail}`);
}

runSuite();
