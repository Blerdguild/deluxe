# Deluxe Cannabis Marketplace - B2B & B2C Implementation

## Overview
This application implements a complete cannabis marketplace with both B2B (Business-to-Business) and B2C (Business-to-Consumer) e-commerce flows.

## Architecture

### User Roles
1. **Farmer** - Cultivates and sells products to dispensaries (B2B)
2. **Dispensary** - Purchases from farmers (B2B) and sells to consumers (B2C)
3. **Consumer** - Purchases products from dispensaries (B2C)

### Flow Diagram
```
Farmer → Creates Products → Dispensary → Sells to → Consumer
         (Wholesale)                      (Retail)
```

---

## Features by Role

### 👨‍🌾 Farmer Features
- **Dashboard**: View sales metrics, earnings, pending orders
- **Inventory Management**: Create and manage products with quantities
- **Order Management**: 
  - Accept/Decline wholesale orders
  - Mark orders as Shipped
  - Mark orders as Delivered
- **Automatic Inventory**: Stock deducted when orders accepted

### 🏪 Dispensary Features
- **Dashboard**: Analytics with sales metrics, inventory alerts, pending orders
- **Inventory Management**: 
  - View all products with stock levels
  - Search and filter by stock status
  - Visual stock indicators (OK/Low/Out)
- **Wholesale Shopping** (B2B):
  - Browse farmer products
  - Place wholesale orders
  - Track order status
- **Sales Management** (B2C):
  - View incoming consumer orders
  - Accept/Decline orders
  - Mark orders Ready for Pickup
- **Automatic Inventory**: 
  - Stock added when wholesale orders delivered
  - Stock deducted when consumer orders placed

### 🛒 Consumer Features
- **Product Browsing**: View products from dispensaries
- **Order Placement**: Purchase products with quantity selection
- **Order Tracking**: View order history and status

---

## Technical Implementation

### State Management
- **BLoC Pattern** for reactive state management
- Separate BLoCs for each domain:
  - `FarmerOrderBloc` - Farmer order management
  - `WholesaleOrderBloc` - Dispensary purchases
  - `DispensarySalesBloc` - Dispensary sales
  - `ConsumerOrderBloc` - Consumer orders
  - `ProductBloc` - Product catalog
  - `FarmerInventoryBloc` - Farmer inventory

### Data Layer
- **Repository Pattern** for data abstraction
- **Firestore** as primary database
- **Batch Writes** for atomic operations (inventory + orders)

### Key Models
```dart
OrderModel {
  id: String
  consumerId: String  // Buyer (Dispensary or Consumer)
  sellerId: String    // Seller (Farmer or Dispensary)
  items: List<Product>
  totalPrice: double
  status: String      // Pending, Accepted, Declined, Shipped, Delivered, etc.
  createdAt: DateTime
  dispensaryName: String
}

Product {
  id: String
  name: String
  type: String
  price: double
  quantity: int       // Available stock
  weight: double      // In grams
  imageUrl: String
  farmerId: String
  dispensaryId: String
  farmerName: String
}
```

---

## Order Status Flow

### B2B (Farmer → Dispensary)
```
Pending → Accepted → Shipped → Delivered
    ↓
Declined
```

### B2C (Dispensary → Consumer)
```
Pending → Accepted → Ready for Pickup → Completed
    ↓
Declined
```

### Status Colors
- 🟠 **Orange** - Pending
- 🔵 **Blue** - Accepted
- 🔴 **Red** - Declined
- 🟣 **Purple** - Shipped / Ready for Pickup
- 🟢 **Green** - Delivered / Completed

---

## Inventory Management

### Automatic Stock Updates

#### B2B Flow (Wholesale)
1. **Order Accepted**: Farmer inventory `-= quantity`
2. **Order Delivered**: Dispensary inventory `+= quantity` (new product created)

#### B2C Flow (Retail)
1. **Order Placed**: Dispensary inventory `-= quantity`

### Stock Status Indicators
- **OK** (Green): Quantity > 10
- **Low** (Orange): Quantity 1-10
- **Out** (Red): Quantity = 0

---

## Localization

### Currency
- All prices displayed in **South African Rands (R)**
- Format: `R123.45`

### Units
- All weights in **metric** (grams, kilograms)
- Format: `50g`, `1.5kg`

---

## Navigation Structure

### Farmer (4 Tabs)
1. Dashboard - Analytics
2. Inventory - Product management
3. Orders - Wholesale orders
4. Profile - Account settings

### Dispensary (6 Tabs)
1. Home - Analytics dashboard
2. Inventory - Stock management
3. Browse - Wholesale shopping (B2B)
4. Purchases - Orders from farmers
5. Sales - Orders from consumers
6. Profile - Account settings

### Consumer (4 Tabs)
1. Home - Product discovery
2. Dispensaries - Browse dispensaries
3. Products - Product catalog
4. Profile - Account settings

---

## Security (Firestore Rules)

### Products
- **Read**: Public
- **Create**: Farmers only
- **Update**: Owner (Farmer) only
- **Delete**: Admin only

### Orders
- **Create**: Authenticated users
- **Read**: Buyer or Seller only
- **Update**: Buyer or Seller only

### Users
- **Read/Write**: Owner or Admin only

---

## Dependencies

### Core
- `flutter_bloc` - State management
- `get_it` - Dependency injection
- `equatable` - Value equality

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `cloud_functions` - Backend functions
- `firebase_storage` - File storage

### UI
- `cached_network_image` - Image caching
- `intl` - Internationalization & formatting
- `fl_chart` - Charts for analytics

### Utilities
- `uuid` - Unique ID generation
- `hive` - Local storage
- `flutter_dotenv` - Environment variables

---

## File Structure

```
lib/
├── core/
│   ├── firebase/          # Firebase services
│   ├── repositories/      # Shared repositories
│   └── theme/            # App theming
├── features/
│   ├── farmer/
│   │   ├── data/         # Farmer data layer
│   │   ├── domain/       # Farmer business logic
│   │   └── presentation/ # Farmer UI
│   ├── dispensary/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── consumer/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── dashboard/        # Shared dashboards
│   ├── auth/            # Authentication
│   └── profile/         # User profiles
├── shared/
│   ├── models/          # Shared data models
│   ├── services/        # Shared services
│   └── widgets/         # Reusable widgets
└── main.dart
```

---

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Firebase project configured
- `.env` file with Firebase config

### Installation
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Variables
Create a `.env` file:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
# ... other Firebase config
```

---

## Testing

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing instructions.

### Quick Test
```bash
# Run analyzer
flutter analyze

# Run tests
flutter test

# Build for production
flutter build apk --release
```

---

## Known Issues & Limitations

1. **Inventory Restoration**: Declined orders do NOT restore inventory (by design)
2. **Price Markup**: Dispensaries receive products at wholesale price (no automatic markup for retail)
3. **Concurrent Orders**: Multiple users can order the same product simultaneously (Firestore handles atomicity)
4. **Offline Support**: Limited offline functionality (requires network for most operations)

---

## Future Enhancements

### Phase 6 (Potential)
- [ ] Order cancellation with inventory restoration
- [ ] Automatic price markup for retail
- [ ] Product reviews and ratings
- [ ] Push notifications for order updates
- [ ] Advanced analytics (charts, trends)
- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Export orders to CSV/PDF
- [ ] Inventory forecasting
- [ ] Low stock auto-reorder

---

## Contributing

When contributing, ensure:
1. Code follows existing patterns (BLoC, Repository)
2. All features are tested
3. Currency displays as Rands (R)
4. Weights display in metric units
5. Firestore rules are updated if needed
6. Documentation is updated

---

## License

[Your License Here]

---

## Support

For issues or questions:
- Create an issue in the repository
- Contact: [Your Contact Info]

---

## Changelog

### v1.0.0 (Current)
- ✅ B2B Wholesale Flow (Farmer → Dispensary)
- ✅ B2C Retail Flow (Dispensary → Consumer)
- ✅ Automatic inventory management
- ✅ Order status tracking
- ✅ Analytics dashboards
- ✅ Currency localization (Rands)
- ✅ Metric units (grams)
