import 'package:deluxe/features/dashboard/bloc/dispensary_bloc.dart';
import 'package:deluxe/features/dashboard/bloc/product_bloc.dart';
import 'package:deluxe/features/dashboard/presentation/widgets/dispensary_card.dart';
import 'package:deluxe/features/dashboard/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConsumerDashboard extends StatelessWidget {
  const ConsumerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Trigger data loading for Consumer view
    context.read<ProductBloc>().add(LoadRetailProducts());
    context.read<DispensaryBloc>().add(LoadDispensaries());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ITALVIBES x DeluxeBudSt',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  // Profile icon will be handled by the bottom nav or separate screen
                ],
              ),
              const SizedBox(height: 24),

              // --- Search Bar ---
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
              const SizedBox(height: 24),

              // --- Hero Section ---
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1603909223429-69bb71a1f420?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Browse Dispensaries ---
              Text(
                'Browse Dispensaries',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: BlocBuilder<DispensaryBloc, DispensaryState>(
                  builder: (context, state) {
                    if (state is DispensaryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is DispensaryLoaded) {
                      if (state.dispensaries.isEmpty) {
                        return Center(
                            child: Text('No dispensaries found',
                                style: theme.textTheme.bodyMedium));
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.dispensaries.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              width: 160,
                              child: DispensaryCard(
                                dispensary: state.dispensaries[index],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    if (state is DispensaryError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 32),

              // --- Popular Products ---
              Text(
                'Popular Products',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      return Center(
                          child: Text('No products found',
                              style: theme.textTheme.bodyMedium));
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: state.products[index],
                          purpose: ProductCardPurpose.forConsumer,
                        );
                      },
                    );
                  }
                  if (state is ProductError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
