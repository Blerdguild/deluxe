# Testing Guide: B2B & B2C E-Commerce Flow

## Overview
This guide covers end-to-end testing for the complete B2B (Farmer → Dispensary) and B2C (Dispensary → Consumer) flows.

## Test Accounts Needed
- **Farmer Account** - To create products and manage wholesale orders
- **Dispensary Account** - To purchase from farmers and sell to consumers
- **Consumer Account** - To browse and purchase from dispensaries

---

## Phase 1: B2B Wholesale Flow Testing

### 1.1 Farmer - Product Creation
- [ ] Login as Farmer
- [ ] Navigate to Inventory tab
- [ ] Create a new harvest/product with:
  - Name, type, weight, price
  - Upload image
  - Set initial quantity (e.g., 100g)
- [ ] Verify product appears in inventory
- [ ] Verify product appears in Browse Products (Dispensary view)

### 1.2 Dispensary - Wholesale Ordering
- [ ] Login as Dispensary
- [ ] Navigate to Browse tab
- [ ] Search for farmer's product
- [ ] Tap product to view details
- [ ] Select quantity (e.g., 50g)
- [ ] Place wholesale order
- [ ] Verify order appears in "Purchases" tab with "Pending" status
- [ ] Verify total price is correct (price × quantity)

### 1.3 Farmer - Order Management
- [ ] Login as Farmer
- [ ] Navigate to Orders tab
- [ ] Verify new order appears with "Pending" status
- [ ] Test "Accept Order":
  - Tap Accept button
  - Confirm in dialog
  - **Verify inventory is deducted** (100g → 50g)
  - Verify order status changes to "Accepted"
- [ ] Test "Mark as Shipped":
  - Tap "Mark as Shipped" button
  - Confirm in dialog
  - Verify status changes to "Shipped"
- [ ] Test "Mark as Delivered":
  - Tap "Mark as Delivered" button
  - Confirm in dialog
  - Verify status changes to "Delivered"

### 1.4 Dispensary - Inventory Verification
- [ ] Login as Dispensary
- [ ] Navigate to Inventory tab
- [ ] **Verify new product appears** (received from farmer)
- [ ] Verify quantity matches order (50g)
- [ ] Verify product details are correct
- [ ] Check stock status indicator (should be "Low" if ≤10)

### 1.5 Currency & Metrics Verification
- [ ] Verify all prices show "R" (Rands) not "$"
- [ ] Verify weights show "g" (grams)
- [ ] Check order totals use Rands
- [ ] Check dashboard metrics use Rands

---

## Phase 2: B2C Consumer Flow Testing

### 2.1 Consumer - Product Browsing
- [ ] Login as Consumer
- [ ] Navigate to Home/Dashboard
- [ ] Verify "Popular Products" section shows dispensary products
- [ ] Verify products have:
  - Dispensary name (not farmer name)
  - Correct pricing in Rands
  - Product images load correctly
- [ ] Test search functionality
- [ ] Test product filters

### 2.2 Consumer - Order Placement
- [ ] Tap on a product
- [ ] Verify product detail screen shows:
  - Correct price
  - Dispensary as seller
  - Available quantity
- [ ] Select quantity
- [ ] Place order
- [ ] Verify success message
- [ ] **Verify dispensary inventory is deducted**

### 2.3 Dispensary - Sales Management
- [ ] Login as Dispensary
- [ ] Navigate to "Sales" tab
- [ ] Verify consumer order appears with "Pending" status
- [ ] Verify customer name shows correctly
- [ ] Test "Accept Order":
  - Tap Accept button
  - Confirm in dialog
  - Verify status changes to "Accepted"
- [ ] Test "Decline Order":
  - Create another order
  - Tap Decline button
  - Verify status changes to "Declined"
- [ ] Test "Mark Ready for Pickup":
  - For accepted order
  - Tap "Mark Ready for Pickup"
  - Verify status changes to "Ready for Pickup"

### 2.4 Inventory Deduction Verification
- [ ] Before consumer order: Note product quantity
- [ ] Place consumer order for X units
- [ ] Check Dispensary Inventory tab
- [ ] **Verify quantity decreased by X units**
- [ ] Verify stock status updates (OK → Low → Out)

---

## Phase 3: Dispensary Inventory Management

### 3.1 Inventory Screen
- [ ] Navigate to Inventory tab
- [ ] Verify all products display correctly
- [ ] Test search functionality
- [ ] Test filters:
  - All
  - In Stock (>10 units)
  - Low Stock (1-10 units)
  - Out of Stock (0 units)
- [ ] Verify stock badges:
  - Green "OK" for >10
  - Orange "LOW" for 1-10
  - Red "OUT" for 0
- [ ] Verify product cards show:
  - Image
  - Name, type
  - Price in Rands
  - Current quantity

---

## Phase 4: Analytics & Dashboard

### 4.1 Dispensary Dashboard
- [ ] Navigate to Home tab
- [ ] Verify Summary Cards show:
  - **Total Sales** (R amount from completed orders)
  - **Pending Orders** (count of pending consumer orders)
  - **Low Stock Items** (count of products ≤10 units)
  - **Pending Purchases** (count of pending wholesale orders)
- [ ] Verify "Recent Sales" section:
  - Shows last 5 consumer orders
  - Displays customer names
  - Shows order totals in Rands
  - Status badges are color-coded
- [ ] Verify "Inventory Alerts" section:
  - Only appears if low stock items exist
  - Shows top 3 low stock products
  - Displays current quantities
  - Color-coded badges (orange/red)

### 4.2 Farmer Dashboard
- [ ] Login as Farmer
- [ ] Verify dashboard shows:
  - Total Products count
  - Orders Pending count
  - Earnings in Rands
  - Top Buyer name
  - Sales Overview chart (7 days)

---

## Phase 5: UI/UX Consistency

### 5.1 Navigation
- [ ] **Consumer**: 4 tabs (Home, Dispensaries, Products, Profile)
- [ ] **Farmer**: 4 tabs (Dashboard, Inventory, Orders, Profile)
- [ ] **Dispensary**: 6 tabs (Home, Inventory, Browse, Purchases, Sales, Profile)
- [ ] Verify tab icons are appropriate
- [ ] Verify tab labels are clear

### 5.2 Color Consistency
- [ ] Order Status Colors:
  - Orange = Pending
  - Blue = Accepted
  - Red = Declined
  - Purple = Shipped / Ready for Pickup
  - Green = Delivered / Completed
- [ ] Stock Status Colors:
  - Green = OK (>10)
  - Orange = Low (1-10)
  - Red = Out (0)
- [ ] Primary color used consistently
- [ ] Card backgrounds consistent

### 5.3 Typography & Spacing
- [ ] Headers use consistent font sizes
- [ ] Body text is readable
- [ ] Spacing between elements is uniform
- [ ] Padding/margins are consistent

---

## Edge Cases & Error Handling

### 6.1 Inventory Edge Cases
- [ ] **Overselling Prevention**:
  - Try to order more than available stock
  - Verify error handling
- [ ] **Zero Stock**:
  - Deplete inventory to 0
  - Verify "Out of Stock" indicator
  - Verify product still displays but can't be ordered
- [ ] **Negative Stock Prevention**:
  - Verify batch operations prevent negative quantities

### 6.2 Order Edge Cases
- [ ] **Concurrent Orders**:
  - Multiple users ordering same product
  - Verify inventory updates correctly
- [ ] **Order Cancellation**:
  - Test declining orders
  - Verify inventory is NOT restored (as designed)
- [ ] **Status Transitions**:
  - Verify can't skip statuses
  - Verify can't go backwards

### 6.3 Authentication
- [ ] Verify unauthenticated users can't:
  - Place orders
  - View inventory
  - Access dashboards
- [ ] Verify role-based access:
  - Farmers can't access dispensary features
  - Consumers can't access farmer features
  - Dispensaries can't access farmer inventory

---

## Performance Testing

### 7.1 Load Testing
- [ ] Test with 100+ products
- [ ] Test with 50+ orders
- [ ] Verify scroll performance
- [ ] Verify search performance

### 7.2 Network Conditions
- [ ] Test with slow network
- [ ] Verify loading indicators appear
- [ ] Verify error messages for network failures
- [ ] Test offline behavior

---

## Regression Testing Checklist

After any code changes, verify:
- [ ] All existing features still work
- [ ] No console errors
- [ ] No lint warnings
- [ ] Currency displays as Rands (R)
- [ ] Weights display in grams (g)
- [ ] Inventory updates correctly
- [ ] Order statuses update correctly
- [ ] Navigation works on all tabs

---

## Known Limitations

1. **Inventory Restoration**: Declined orders do NOT restore inventory (by design)
2. **Price Markup**: Dispensaries receive products at wholesale price (no automatic markup)
3. **Stock Validation**: Frontend validation only (should add backend validation)
4. **Concurrent Updates**: Firestore handles concurrency, but UI may need refresh

---

## Success Criteria

✅ **Phase 1 (B2B)**: Farmers can sell to dispensaries with automatic inventory management
✅ **Phase 2 (B2C)**: Consumers can buy from dispensaries with automatic stock deduction
✅ **Phase 3**: Dispensaries can view and manage inventory with stock alerts
✅ **Phase 4**: Dashboards show relevant metrics and analytics
✅ **Phase 5**: UI is consistent, responsive, and user-friendly

---

## Reporting Issues

When reporting bugs, include:
1. User role (Farmer/Dispensary/Consumer)
2. Steps to reproduce
3. Expected behavior
4. Actual behavior
5. Screenshots if applicable
6. Console errors if any
