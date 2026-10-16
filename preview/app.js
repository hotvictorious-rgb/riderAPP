// Victorious MARKET — Sovereign Rider Dispatch Terminal Engine
// Synchronized with dispatch-only closed-loop fleet settlement architecture (Zero Courier Wallets)

(function() {
  'use strict';

  window.state = {
    isOnline: true,
    completedTrips: 48,
    onTimeRate: 99.4,
    corridor: 'Ikeja - Lekki Express Corridor',
    activeDeliveries: [
      {
        id: 101,
        orderNumber: 'VM-ORD-9081',
        shopName: 'Apex Retail Plaza (Hub #04)',
        shopAddress: 'Computer Village, Ikeja, Lagos',
        shopPhone: '+234 801 234 5678',
        customerName: 'Chidi Okafor',
        customerPhone: '+234 803 111 2233',
        deliveryAddress: '14 Admiralty Way, Lekki Phase 1, Lagos',
        destinationLga: 'Lekki Phase 1',
        itemsSummary: '1x iPhone 14 Pro Case, 1x Anker 65W GaN Charger',
        itemsCount: 2,
        category: 'EXPRESS COURIER',
        status: 'ready_for_pickup', // 'ready_for_pickup', 'out_for_delivery', 'delivered'
        pickupPin: '482910',
        hasArrived: false,
        customerOtp: '883921',
        manifestItems: [
          { id: 1, name: 'iPhone 14 Pro Heavy Duty Case', orderedQty: 1 },
          { id: 2, name: 'Anker 65W GaN Compact Charger', orderedQty: 1 }
        ]
      },
      {
        id: 102,
        orderNumber: 'VM-ORD-9077',
        shopName: 'Vic Tech & Electronics HQ',
        shopAddress: 'Shop 12, Ikeja City Mall, Alausa',
        shopPhone: '+234 802 333 4455',
        customerName: 'Amina Bello',
        customerPhone: '+234 802 555 9900',
        deliveryAddress: 'Plot 8, Victoria Island Financial Strip, Lagos',
        destinationLga: 'Victoria Island',
        itemsSummary: '1x Sony WH-1000XM5 Wireless Headphones',
        itemsCount: 1,
        category: 'FRAGILE DISPATCH',
        status: 'out_for_delivery',
        pickupPin: 'Verified',
        hasArrived: false,
        customerOtp: '519204',
        manifestItems: [
          { id: 3, name: 'Sony WH-1000XM5 Wireless Headphones', orderedQty: 1 }
        ]
      }
    ],
    activeReturns: [
      {
        id: 401,
        caseNumber: 'RET-9071',
        orderNumber: 'VM-ORD-9071',
        shopName: 'Apex Retail Plaza (Hub #04)',
        shopAddress: 'Computer Village, Ikeja, Lagos',
        shopPhone: '+234 801 234 5678',
        rejectionCategory: 'vendor_issue',
        rejectionCategoryLabel: 'Vendor Fault / Wrong Item',
        rejectionNotes: 'Wrong color sent by vendor, customer declined',
        itemsSummary: '1x iPhone 14 Pro Case (Matte Black)',
        status: 'in_transit_back_to_vendor',
        vendorOtp: '654321'
      }
    ],
    history: [
      {
        id: 99,
        orderNumber: 'VM-ORD-9064',
        customerName: 'Babajide Adeleke',
        destinationLga: 'Surulere',
        itemsSummary: '1x Samsung T7 Shield SSD 1TB',
        category: 'STANDARD DISPATCH',
        timestamp: 'Yesterday, 04:12 PM'
      },
      {
        id: 98,
        orderNumber: 'VM-ORD-9052',
        customerName: 'Grace Danjuma',
        destinationLga: 'Ikeja GRA',
        itemsSummary: '2x Baseus USB-C Braided Cables',
        category: 'EXPRESS COURIER',
        timestamp: 'Oct 14, 2026'
      },
      {
        id: 97,
        orderNumber: 'VM-ORD-9031',
        customerName: 'Tariq Hassan',
        destinationLga: 'Yaba Tech Corridor',
        itemsSummary: '1x Logitech MX Master 3S Mouse',
        category: 'PRIORITY CARGO',
        timestamp: 'Oct 12, 2026'
      }
    ],
    activeModalOrderId: null
  };

  // --- Tab Navigation ---
  window.switchTab = function(tabName) {
    document.querySelectorAll('.screen-view').forEach(v => v.classList.remove('active'));

    let targetViewId = 'view-' + tabName;
    const targetView = document.getElementById(targetViewId);
    if (targetView) targetView.classList.add('active');

    // Update bottom nav
    document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll(`.nav-tab[onclick*="${tabName}"]`).forEach(t => t.classList.add('active'));

    // Update studio pills
    document.querySelectorAll('.nav-pill-btn').forEach(p => p.classList.remove('active'));
    document.querySelectorAll(`.nav-pill-btn[onclick*="${tabName}"]`).forEach(p => p.classList.add('active'));

    if (tabName === 'dashboard') renderDashboard();
    if (tabName === 'deliveries') renderDeliveries();
    if (tabName === 'returns') renderReturns();
    if (tabName === 'history') renderHistory();
    updateBadges();
  };

  // --- Duty Switch ---
  window.toggleDuty = function() {
    window.state.isOnline = !window.state.isOnline;
    renderDutyStatus();
    showToast(window.state.isOnline ? '✓ You are now ON DUTY (Radar Active). Packages dispatching!' : 'You are now OFFLINE (Standby).');
  };

  function renderDutyStatus() {
    const card = document.getElementById('radar-duty-card');
    const icon = document.getElementById('radar-pulse-icon');
    const title = document.getElementById('radar-status-text');
    const btn = document.getElementById('duty-toggle-btn');

    if (window.state.isOnline) {
      if (card) card.classList.remove('offline');
      if (icon) icon.classList.remove('offline');
      if (title) {
        title.classList.remove('offline');
        title.textContent = 'DUTY ACTIVE • ONLINE';
      }
      if (btn) btn.classList.remove('offline');
    } else {
      if (card) card.classList.add('offline');
      if (icon) icon.classList.add('offline');
      if (title) {
        title.classList.add('offline');
        title.textContent = 'STANDBY • OFFLINE';
      }
      if (btn) btn.classList.add('offline');
    }
  }

  // --- Render Dashboard ---
  function renderDashboard() {
    renderDutyStatus();

    const c1 = document.getElementById('completed-count-pill');
    const badge = document.getElementById('active-trips-badge');
    const subtext = document.getElementById('active-trips-subtext');

    if (c1) c1.textContent = `${window.state.completedTrips} Trips`;
    if (badge) badge.textContent = `${window.state.activeDeliveries.length} Active`;
    if (subtext) subtext.textContent = `${window.state.activeDeliveries.length} En Route`;

    const container = document.getElementById('dashboard-assignments-list');
    if (!container) return;

    if (window.state.activeDeliveries.length === 0) {
      container.innerHTML = `
        <div class="white-card" style="text-align: center; padding: 24px;">
          <i class="fa-solid fa-circle-check" style="color: #10B981; font-size: 32px; margin-bottom: 8px;"></i>
          <div style="font-weight: 800; color: #1E1B4B;">All assigned packages delivered!</div>
          <div style="font-size: 11px; color: #6B7280;">Stay online to receive dispatch radar alerts.</div>
        </div>
      `;
      return;
    }

    container.innerHTML = window.state.activeDeliveries.map(item => createDeliveryCardHtml(item)).join('');
  }

  function createDeliveryCardHtml(item) {
    const isPickup = item.status === 'ready_for_pickup';

    return `
      <div class="white-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
          <span class="trip-step-badge ${isPickup ? 'pickup' : (item.hasArrived ? 'delivered' : 'enroute')}">
            ${isPickup ? '<i class="fa-solid fa-store"></i> STEP 1: PICKUP AT SHOP' : (item.hasArrived ? '<i class="fa-solid fa-circle-check"></i> STEP 2: ARRIVED AT DOORSTEP' : '<i class="fa-solid fa-truck-fast"></i> STEP 2: OUT FOR DELIVERY')}
          </span>
          <span style="font-size: 10px; font-weight: 800; color: #92400E; background: #FEF3C7; padding: 2px 7px; border-radius: 6px;">
            <i class="fa-solid fa-bolt"></i> ${item.category}
          </span>
        </div>
        <div style="font-size: 14px; font-weight: 900; color: #1E1B4B;">${item.orderNumber}</div>
        <div style="font-size: 11.5px; color: #6B7280; margin-top: 2px;">${item.itemsSummary}</div>

        <div class="route-step-box">
          <div class="route-step-row">
            <i class="fa-solid fa-store" style="color: #F59E0B; margin-top: 2px;"></i>
            <div style="flex: 1;">
              <div style="display: flex; justify-content: space-between;">
                <span style="font-size: 12px; font-weight: 800; color: #1E1B4B;">${item.shopName}</span>
                <span style="font-size: 10px; color: #D97706; font-weight: 700;">${item.shopPhone}</span>
              </div>
              <div style="font-size: 10.5px; color: #6B7280;">${item.shopAddress}</div>
            </div>
          </div>
          <div class="route-step-row">
            <i class="fa-solid fa-location-dot" style="color: #10B981; margin-top: 2px;"></i>
            <div style="flex: 1;">
              <div style="display: flex; justify-content: space-between;">
                <span style="font-size: 12px; font-weight: 800; color: #1E1B4B;">${item.customerName}</span>
                <span style="font-size: 10px; color: #15803D; font-weight: 700;">${item.customerPhone}</span>
              </div>
              <div style="font-size: 10.5px; color: #6B7280;">${item.deliveryAddress} (${item.destinationLga})</div>
            </div>
          </div>
        </div>

        ${isPickup ? `
          <div class="pin-reveal-box">
            <i class="fa-solid fa-key"></i> COURIER PIN FOR SHOP HANDOVER: <strong>${item.pickupPin}</strong>
          </div>
          <button class="btn-primary" onclick="verifyPickup(${item.id})">
            <i class="fa-solid fa-clipboard-check"></i> Merchant Verified Handover • Start Route
          </button>
        ` : `
          ${!item.hasArrived ? `
            <button class="btn-primary" style="background: linear-gradient(135deg, #5E17EB, #7C3AED); margin-bottom: 8px;" onclick="riderMarkArrived(${item.id})">
              <i class="fa-solid fa-location-crosshairs"></i> 📍 I'm Here • Notify Customer Doorstep Arrival
            </button>
          ` : `
            <div style="background: #F0FDF4; border: 1px solid #86EFAC; border-radius: 8px; padding: 10px; margin-bottom: 8px; text-align: center;">
              <div style="color: #15803D; font-weight: 800; font-size: 12px;"><i class="fa-solid fa-circle-check"></i> Customer Phone Alerted at Doorstep!</div>
              <div style="color: #166534; font-size: 11px; margin-top: 2px;">Ask recipient for their 6-digit delivery security PIN.</div>
            </div>
          `}
          <button class="btn-emerald" onclick="openDoorstepModal(${item.id}, '${item.customerName}')">
            <i class="fa-solid fa-clipboard-check"></i> Complete Doorstep Handover (PIN &amp; Manifest)
          </button>
        `}
      </div>
    `;
  }

  // --- Handover and Doorstep OTP Logic ---
  window.riderMarkArrived = function(orderId) {
    const item = window.state.activeDeliveries.find(d => d.id == orderId);
    if (!item) return;

    item.hasArrived = true;
    renderDashboard();
    renderDeliveries();
    showToast(`📍 "I'm Here" sent! Doorstep arrival logged & customer notified.`);
  };

  window.verifyPickup = function(orderId) {
    const item = window.state.activeDeliveries.find(d => d.id == orderId);
    if (!item) return;

    item.status = 'out_for_delivery';
    renderDashboard();
    renderDeliveries();
    showToast(`✓ Package picked up from ${item.shopName}! En route to recipient.`);
  };

  window.openDoorstepModal = function(orderId, customerName) {
    window.state.activeModalOrderId = orderId;
    const modal = document.getElementById('modal-doorstep-otp');
    const numEl = document.getElementById('modal-doorstep-order-num');
    const pinInp = document.getElementById('doorstep-pin-input');
    const manifestEl = document.getElementById('manifest-items-list');

    const item = window.state.activeDeliveries.find(d => d.id == orderId) || window.state.activeDeliveries[0];
    if (numEl) numEl.textContent = `Order #${item ? item.orderNumber : 'VM-ORD-9081'}`;
    if (pinInp) {
      pinInp.value = item ? item.customerOtp : '883921';
    }

    if (manifestEl && item) {
      manifestEl.innerHTML = `
        <div style="font-size: 11px; font-weight: 800; color: #ffd700; margin-bottom: 6px;">ITEMIZED ACCEPTANCE MANIFEST:</div>
        ${(item.manifestItems || []).map((m, idx) => `
          <div style="background: rgba(255,255,255,0.05); padding: 8px; border-radius: 8px; margin-bottom: 6px; border: 1px solid rgba(255,255,255,0.08);">
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span style="font-size: 11px; font-weight: 800; color: #fff;">${m.name}</span>
              <span style="font-size: 10px; color: #9ca3af;">Qty: ${m.orderedQty}</span>
            </div>
            <div style="margin-top: 6px;">
              <select id="item-status-${idx}" style="width: 100%; font-size: 10.5px; background: #1f1438; color: #fff; border: 1px solid #5e17eb; padding: 4px 6px; border-radius: 6px;">
                <option value="accepted">✓ Accepted by Customer (Good Condition)</option>
                <option value="vendor_issue">❌ Reject: Vendor Fault / Wrong Item</option>
                <option value="transit_damage">❌ Reject: Transit Damage en route</option>
                <option value="customer_change_of_mind">❌ Reject: Customer Change of Mind</option>
              </select>
            </div>
          </div>
        `).join('')}
      `;
    }

    if (modal) modal.classList.add('active');
  };

  window.submitDoorstepManifest = function() {
    const pin = document.getElementById('doorstep-pin-input')?.value.trim();
    if (!pin || pin.length !== 6) {
      alert('Please enter the 6-digit delivery security PIN presented by the recipient.');
      return;
    }

    const orderId = window.state.activeModalOrderId || window.state.activeDeliveries[0]?.id;
    const item = window.state.activeDeliveries.find(d => d.id == orderId) || window.state.activeDeliveries[0];

    if (!item) return;

    let rejectedCount = 0;
    let rejectedSummary = [];
    (item.manifestItems || []).forEach((m, idx) => {
      const select = document.getElementById(`item-status-${idx}`);
      if (select && select.value !== 'accepted') {
        rejectedCount++;
        const reason = select.value;
        const label = select.options[select.selectedIndex].text.replace('❌ Reject: ', '');
        rejectedSummary.push(m.name);

        // Add to active reverse logistics return custody
        window.state.activeReturns.push({
          id: Date.now() + idx,
          caseNumber: `RET-${item.orderNumber.replace('VM-ORD-', '')}-${idx+1}`,
          orderNumber: item.orderNumber,
          shopName: item.shopName,
          shopAddress: item.shopAddress,
          shopPhone: item.shopPhone,
          rejectionCategory: reason,
          rejectionCategoryLabel: label,
          rejectionNotes: `Customer inspection rejected line during doorstep handover.`,
          itemsSummary: `1x ${m.name}`,
          status: 'in_transit_back_to_vendor',
          vendorOtp: '654321'
        });
      }
    });

    // Delivery certified & logged to fleet
    window.state.completedTrips += 1;

    // Move to history
    window.state.history.unshift({
      id: item.id,
      orderNumber: item.orderNumber,
      customerName: item.customerName,
      destinationLga: item.destinationLga,
      itemsSummary: item.itemsSummary + (rejectedCount > 0 ? ` (${rejectedCount} items returned)` : ''),
      category: item.category,
      timestamp: 'Just Now'
    });

    window.state.activeDeliveries = window.state.activeDeliveries.filter(d => d.id != item.id);

    closeModals();
    renderDashboard();
    renderDeliveries();
    renderReturns();
    renderHistory();
    updateBadges();

    if (rejectedCount > 0) {
      showToast(`✓ Handover Certified with Partial Return! ${rejectedCount} parcel(s) entered courier custody for vendor return drop-off.`);
    } else {
      showToast(`✓ Delivery Certified! Full order ${item.orderNumber} successfully delivered & logged to Fleet Dispatch.`);
    }
  };

  // --- Render Returns ---
  window.renderReturns = function() {
    const list = document.getElementById('returns-full-list');
    if (!list) return;

    updateBadges();

    if (window.state.activeReturns.length === 0) {
      list.innerHTML = `
        <div class="white-card" style="text-align: center; color: #6B7280; padding: 28px;">
          <i class="fa-solid fa-circle-check" style="font-size: 32px; color: #10B981; margin-bottom: 8px;"></i>
          <div style="font-size: 14px; font-weight: 800; color: #1E1B4B;">No Pending Return Dropoffs</div>
          <div style="font-size: 11px; color: #9CA3AF; margin-top: 4px;">Zero customer-rejected parcels in courier custody. All reverse logistics cleared.</div>
        </div>
      `;
      return;
    }

    list.innerHTML = window.state.activeReturns.map(item => `
      <div class="white-card" style="border-left: 4px solid #F59E0B; margin-bottom: 12px;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="background: rgba(245, 158, 11, 0.15); color: #D97706; font-size: 10px; font-weight: 900; padding: 2px 8px; border-radius: 6px;">
            ${item.caseNumber}
          </span>
          <span style="background: rgba(239, 68, 68, 0.12); color: #EF4444; font-size: 9.5px; font-weight: 800; padding: 2px 6px; border-radius: 4px;">
            ${item.rejectionCategoryLabel}
          </span>
        </div>
        <div style="font-size: 13px; font-weight: 900; color: #1E1B4B; margin-top: 8px;">${item.orderNumber}</div>
        <div style="font-size: 11px; color: #4B5563; margin-top: 2px;">${item.itemsSummary}</div>
        <div style="font-size: 10px; color: #9CA3AF; margin-top: 2px; font-style: italic;">Note: ${item.rejectionNotes}</div>
        <div style="margin: 10px 0; padding-top: 8px; border-top: 1px dashed rgba(0,0,0,0.08); font-size: 11px;">
          <div style="font-weight: 800; color: #1E1B4B;"><i class="fa-solid fa-store" style="color: #F59E0B;"></i> RETURN TO: ${item.shopName}</div>
          <div style="color: #6B7280; font-size: 10.5px;">${item.shopAddress}</div>
          <div style="color: #D97706; font-size: 10px; font-weight: 700; margin-top: 2px;">Shop Tel: ${item.shopPhone}</div>
        </div>
        <button onclick="openVendorReturnModal(${item.id})" style="width: 100%; background: #FFD700; color: #000; font-weight: 800; border: none; padding: 9px; border-radius: 8px; cursor: pointer; font-size: 11px; display: flex; align-items: center; justify-content: center; gap: 6px;">
          <i class="fa-solid fa-store"></i> Handover Parcel at Shop &amp; Enter Vendor PIN
        </button>
      </div>
    `).join('');
  };

  window.openVendorReturnModal = function(caseId) {
    window.state.activeReturnCaseId = caseId;
    const item = window.state.activeReturns.find(r => r.id == caseId) || window.state.activeReturns[0];
    if (!item) return;

    const numEl = document.getElementById('modal-return-case-num');
    const shopEl = document.getElementById('modal-return-shop-name');
    const pinInp = document.getElementById('vendor-return-pin-input');

    if (numEl) numEl.textContent = `Case #${item.caseNumber} • ${item.orderNumber}`;
    if (shopEl) shopEl.textContent = item.shopName;
    if (pinInp) pinInp.value = item.vendorOtp || '654321';

    const m = document.getElementById('modal-vendor-return-otp');
    if (m) m.classList.add('active');
  };

  window.submitVendorReturnPin = function() {
    const pin = document.getElementById('vendor-return-pin-input')?.value.trim();
    if (!pin || pin.length !== 6) {
      alert('Please enter the 6-digit Return Confirmation PIN provided by the merchant at the shop counter.');
      return;
    }

    const caseId = window.state.activeReturnCaseId;
    const item = window.state.activeReturns.find(r => r.id == caseId);
    if (!item) return;

    window.state.activeReturns = window.state.activeReturns.filter(r => r.id != caseId);

    closeModals();
    renderReturns();
    updateBadges();
    showToast(`✓ Return Handover Certified! Parcel returned to ${item.shopName} counter.`);
  };

  window.openPayrollModal = function() {
    const m = document.getElementById('modal-fleet-payroll');
    if (m) m.classList.add('active');
  };

  function updateBadges() {
    const retCount = window.state.activeReturns.length;
    const navBadge = document.getElementById('nav-return-badge');
    const pillBadge = document.getElementById('pill-return-badge');

    if (navBadge) {
      navBadge.textContent = retCount;
      navBadge.style.display = retCount > 0 ? 'inline-block' : 'none';
    }
    if (pillBadge) {
      pillBadge.textContent = retCount;
    }
  }

  window.closeModals = function() {
    document.querySelectorAll('.modal-backdrop').forEach(m => m.classList.remove('active'));
    window.state.activeModalOrderId = null;
  };

  // --- Render Deliveries ---
  function renderDeliveries() {
    const list = document.getElementById('deliveries-full-list');
    if (!list) return;

    if (window.state.activeDeliveries.length === 0) {
      list.innerHTML = `<div class="white-card" style="text-align: center; color: #6B7280; padding: 24px;"><i class="fa-solid fa-box-open" style="font-size: 28px; margin-bottom: 8px;"></i><p>No active missions assigned</p></div>`;
      return;
    }

    list.innerHTML = window.state.activeDeliveries.map(item => createDeliveryCardHtml(item)).join('');
  }

  // --- Render History ---
  function renderHistory() {
    const list = document.getElementById('history-full-list');
    if (!list) return;

    list.innerHTML = window.state.history.map(item => `
      <div class="white-card" style="display: flex; justify-content: space-between; align-items: center;">
        <div>
          <div style="font-size: 13px; font-weight: 800; color: #1E1B4B;">${item.orderNumber}</div>
          <div style="font-size: 11px; color: #6B7280; margin-top: 2px;">${item.customerName} (${item.destinationLga}) • ${item.timestamp}</div>
          <div style="font-size: 10px; color: #9CA3AF; margin-top: 2px;">${item.itemsSummary}</div>
        </div>
        <div style="text-align: right;">
          <span style="background: rgba(16, 185, 129, 0.15); color: #10B981; border: 1px solid rgba(16, 185, 129, 0.3); font-size: 9.5px; font-weight: 900; padding: 3px 8px; border-radius: 6px;">
            <i class="fa-solid fa-circle-check"></i> VERIFIED
          </span>
          <div style="font-size: 9.5px; color: #9CA3AF; font-weight: 700; margin-top: 3px;">${item.category}</div>
        </div>
      </div>
    `).join('');
  }

  // --- Security Barrier Role Invariant Testing Modal ---
  window.openSecurityProofModal = function() {
    const m = document.getElementById('modal-security-proof');
    if (m) m.classList.add('active');
  };

  window.simulateBlockedRole = function(role) {
    const box = document.getElementById('sim-result-box');
    if (!box) return;
    box.style.display = 'block';
    box.style.background = 'rgba(239, 68, 68, 0.15)';
    box.style.border = '1px solid #ef4444';
    box.style.color = '#ef4444';

    if (role === 'logistics_company') {
      box.innerHTML = `<strong>⛔ HTTP 403 FORBIDDEN:</strong> Access Denied: Logistics company accounts cannot log into the rider app. Even fleet owners cannot operate this terminal; only their employed riders can log in.`;
    } else {
      box.innerHTML = `<strong>⛔ HTTP 403 FORBIDDEN:</strong> Access Denied: Only registered delivery riders can authenticate into the Rider Terminal. Merchants and customers are strictly prohibited.`;
    }
  };

  window.simulateValidRider = function(rider) {
    const box = document.getElementById('sim-result-box');
    if (!box) return;
    box.style.display = 'block';
    box.style.background = 'rgba(16, 185, 129, 0.15)';
    box.style.border = '1px solid #10b981';
    box.style.color = '#10b981';

    if (rider === 'musa') {
      box.innerHTML = `<strong>✓ AUTHENTICATED:</strong> Musa Haruna<br><strong>Fleet:</strong> Speedy Parcel Express (Active)<br><strong>Vehicle:</strong> Bajaj Boxer 150cc (KJA-104-XY)<br><strong>Status:</strong> All logistics company invariants satisfied!`;
    } else {
      box.innerHTML = `<strong>✓ AUTHENTICATED:</strong> Ubong Etim<br><strong>Fleet:</strong> Van Logistics Ltd (Active)<br><strong>Vehicle:</strong> Transit Cargo Van (IKT-789-AK)<br><strong>Status:</strong> All logistics company invariants satisfied!`;
    }
  };

  window.saveApiUrl = function() {
    const url = document.getElementById('api-server-url')?.value.trim();
    showToast(`API Server configured to: ${url}`);
  };

  function showToast(msg) {
    let toast = document.getElementById('studio-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'studio-toast';
      toast.style.cssText = `
        position: fixed;
        bottom: 24px;
        left: 50%;
        transform: translateX(-50%);
        background: #100726;
        color: #10B981;
        border: 1px solid #10B981;
        padding: 12px 24px;
        border-radius: 30px;
        font-size: 13px;
        font-weight: 800;
        box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        z-index: 999999;
        display: none;
        transition: all 0.3s ease;
      `;
      document.body.appendChild(toast);
    }
    toast.textContent = msg;
    toast.style.display = 'block';
    setTimeout(() => {
      toast.style.display = 'none';
    }, 4000);
  }

  function init() {
    renderDashboard();
    renderDeliveries();
    renderHistory();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
