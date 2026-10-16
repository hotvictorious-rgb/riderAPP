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
        id: 'ord-1',
        orderNumber: 'VM-ORD-9081',
        shopName: 'Apex Retail Plaza (Hub #04)',
        shopAddress: 'Computer Village, Ikeja, Lagos',
        customerName: 'Chidi Okafor',
        customerPhone: '+234 803 111 2233',
        deliveryAddress: '14 Admiralty Way, Lekki Phase 1, Lagos',
        itemsSummary: 'iPhone 14 Pro Case & Anker 65W GaN Fast Charger',
        category: 'EXPRESS COURIER',
        status: 'ready_for_pickup', // 'ready_for_pickup', 'out_for_delivery', 'delivered'
        pickupPin: '482910',
        customerOtp: '883921'
      },
      {
        id: 'ord-2',
        orderNumber: 'VM-ORD-9077',
        shopName: 'Vic Tech & Electronics HQ',
        shopAddress: 'Shop 12, Ikeja City Mall, Alausa',
        customerName: 'Amina Bello',
        customerPhone: '+234 802 555 9900',
        deliveryAddress: 'Plot 8, Victoria Island Financial Strip, Lagos',
        itemsSummary: 'Sony WH-1000XM5 Wireless Noise-Canceling',
        category: 'FRAGILE DISPATCH',
        status: 'out_for_delivery',
        pickupPin: 'Verified',
        customerOtp: '519204'
      }
    ],
    history: [
      {
        orderNumber: 'VM-ORD-9064',
        customerName: 'Babajide Adeleke',
        category: 'STANDARD DISPATCH',
        timestamp: 'Yesterday, 04:12 PM'
      },
      {
        orderNumber: 'VM-ORD-9052',
        customerName: 'Grace Danjuma',
        category: 'EXPRESS COURIER',
        timestamp: 'Oct 14, 2026'
      },
      {
        orderNumber: 'VM-ORD-9031',
        customerName: 'Tariq Hassan',
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
    if (tabName === 'history') renderHistory();
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
          <span class="trip-step-badge ${isPickup ? 'pickup' : 'enroute'}">
            ${isPickup ? '<i class="fa-solid fa-store"></i> STEP 1: PICKUP AT SHOP' : '<i class="fa-solid fa-truck-fast"></i> STEP 2: OUT FOR DELIVERY'}
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
            <div>
              <div style="font-size: 12px; font-weight: 800; color: #1E1B4B;">${item.shopName}</div>
              <div style="font-size: 10.5px; color: #6B7280;">${item.shopAddress}</div>
            </div>
          </div>
          <div class="route-step-row">
            <i class="fa-solid fa-location-dot" style="color: #10B981; margin-top: 2px;"></i>
            <div>
              <div style="font-size: 12px; font-weight: 800; color: #1E1B4B;">${item.customerName} (${item.customerPhone})</div>
              <div style="font-size: 10.5px; color: #6B7280;">${item.deliveryAddress}</div>
            </div>
          </div>
        </div>

        ${isPickup ? `
          <div class="pin-reveal-box">
            <i class="fa-solid fa-key"></i> COURIER PIN FOR SHOP HANDOVER: <strong>${item.pickupPin}</strong>
          </div>
          <button class="btn-primary" onclick="verifyPickup('${item.id}')">
            <i class="fa-solid fa-clipboard-check"></i> Merchant Verified Handover • Start Route
          </button>
        ` : `
          ${!item.hasArrived ? `
            <button class="btn-primary" style="background: linear-gradient(135deg, #5E17EB, #7C3AED); margin-bottom: 8px;" onclick="riderMarkArrived('${item.id}')">
              <i class="fa-solid fa-location-crosshairs"></i> 📍 I'm Here • Notify Customer Doorstep Arrival
            </button>
          ` : `
            <div style="background: #F0FDF4; border: 1px solid #86EFAC; border-radius: 8px; padding: 10px; margin-bottom: 8px; text-align: center;">
              <div style="color: #15803D; font-weight: 800; font-size: 12px;"><i class="fa-solid fa-circle-check"></i> Customer Phone Alerted!</div>
              <div style="color: #166534; font-size: 11px; margin-top: 2px;">Input box triggered open on customer's device.</div>
            </div>
          `}
          <button class="btn-emerald" onclick="openDoorstepModal('${item.id}', '${item.customerName}')">
            <i class="fa-solid fa-qrcode"></i> Enter Customer Delivery PIN
          </button>
        `}
      </div>
    `;
  }

  // --- Handover and Doorstep OTP Logic ---
  window.riderMarkArrived = function(orderId) {
    const item = window.state.activeDeliveries.find(d => d.id === orderId);
    if (!item) return;

    item.hasArrived = true;
    renderDeliveries();
    showToast(`📍 "I'm Here" sent! Doorstep PIN input box triggered on customer's phone.`);
  };

  window.verifyPickup = function(orderId) {
    const item = window.state.activeDeliveries.find(d => d.id === orderId);
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
    const custEl = document.getElementById('modal-doorstep-cust-name');
    const pinInp = document.getElementById('doorstep-pin-input');

    const item = window.state.activeDeliveries.find(d => d.id === orderId) || window.state.activeDeliveries[0];
    if (numEl) numEl.textContent = `Order #${item ? item.orderNumber : 'VM-ORD-9081'}`;
    if (custEl) custEl.textContent = item ? item.customerName : customerName;
    if (pinInp) {
      pinInp.value = item ? item.customerOtp : '883921';
    }

    if (modal) modal.classList.add('active');
  };

  window.submitDoorstepPin = function() {
    const pin = document.getElementById('doorstep-pin-input')?.value.trim();
    if (!pin || pin.length !== 6) {
      alert('Please enter the 6-digit delivery security PIN presented by the recipient.');
      return;
    }

    const orderId = window.state.activeModalOrderId || window.state.activeDeliveries[0]?.id;
    const item = window.state.activeDeliveries.find(d => d.id === orderId) || window.state.activeDeliveries[0];

    if (!item) return;

    // Delivery certified & logged! (No rider wallet credited; logged to corporate fleet terminal)
    window.state.completedTrips += 1;

    // Move to history
    window.state.history.unshift({
      orderNumber: item.orderNumber,
      customerName: item.customerName,
      category: item.category,
      timestamp: 'Just Now'
    });

    window.state.activeDeliveries = window.state.activeDeliveries.filter(d => d.id !== item.id);

    closeModals();
    renderDashboard();
    renderDeliveries();
    renderHistory();
    showToast(`✓ Delivery Certified! Order ${item.orderNumber} successfully logged to Fleet Dispatch.`);
  };

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
          <div style="font-size: 11px; color: #6B7280; margin-top: 2px;">${item.customerName} • ${item.timestamp}</div>
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
