# Implementation Plan: Dispensary B2B & B2C Flow

## Phase 1: B2B Wholesale Flow (Refinement)
- [x] **Order Status Updates (Farmer Side):** Implement "Shipped" and "Delivered" statuses.
- [x] **Order Status Updates (Dispensary Side):** Ensure status changes are reflected in the UI.
- [x] **Currency & Metric Updates:** Switch to Rands (R) and Metric (g/kg).
- [x] **Inventory Integration:**
    - [x] Deduct product quantity from Farmer inventory upon order acceptance.
    - [x] Add purchased stock to Dispensary inventory upon "Delivered" status.

## Phase 2: B2C Consumer Flow (New Implementation)
- [x] **Consumer Product Browsing:**
    - [x] Create a view for Consumers to browse Dispensary products.
    - [x] Filter products by Dispensary.
- [x] **Consumer Ordering:**
    - [x] Implement `ConsumerOrderModel`.
    - [x] Create `ConsumerOrderFormScreen`.
    - [x] Implement `ConsumerOrderBloc`.
- [x] **Dispensary Order Management (B2C):**
    - [x] Create `DispensarySalesBloc` to view incoming consumer orders.
    - [ ] Create `DispensaryConsumerOrdersScreen` UI.
    - [ ] Implement status updates (Accept/Decline/Ready for Pickup).
- [ ] **Inventory Integration (B2C):**
    - [ ] Deduct stock from Dispensary inventory upon Consumer order.

## Phase 3: Dispensary Inventory Management
- [ ] **Inventory Screen:**
    - [ ] Create `DispensaryInventoryScreen`.
    - [ ] Display current stock levels (derived from Wholesale orders).
    - [ ] Allow manual adjustments (optional).

## Phase 4: Analytics & Dashboard
- [ ] **Dispensary Dashboard:**
    - [ ] Show sales metrics (B2C).
    - [ ] Show inventory alerts (Low stock).
    - [ ] Show pending wholesale orders.

## Phase 5: Final Polish
- [ ] **UI/UX Review:** Ensure consistent styling and responsive design.
- [ ] **Testing:** End-to-end testing of both flows.
