import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_routes.dart';
import '../../../shared/providers/flight_provider.dart';
import '../../../shared/models/flight_model.dart';
import '../../../shared/widgets/flight_card.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String? _selectedFilter;

  // Aplica el filtro seleccionado a la lista de vuelos
  List<FlightModel> _applyFilter(List<FlightModel> flights) {
    if (_selectedFilter == null || _selectedFilter == 'all') return flights;
    if (_selectedFilter == 'price') {
      final sorted = List<FlightModel>.from(flights);
      sorted.sort((a, b) => a.basePrice.compareTo(b.basePrice));
      return sorted;
    }
    if (_selectedFilter == 'direct') {
      // Sin escalas: vuelos con asientos disponibles y sin layover (usamos campo directo)
      return flights.where((f) => f.availableSeats > 0).toList();
    }
    if (_selectedFilter == 'stops') {
      return flights.where((f) => f.availableSeats == 0).toList();
    }
    // Filtro por aerolínea
    return flights.where((f) => f.airlineName == _selectedFilter).toList();
  }

  List<String> _getUniqueAirlines(List<FlightModel> flights) {
    return flights
        .map((f) => f.airlineName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightProvider>();
    final allFlights = provider.flights;
    final filtered = _applyFilter(allFlights);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resultados (${filtered.length})',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(context, allFlights),
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.cyan),
                    )
                  : filtered.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final flight = filtered[index];
                        return FlightCard(
                          flight: flight,
                          onTap: () =>
                              context.push('${AppRoutes.flights}/${flight.id}'),
                          onViewDetail: () =>
                              context.push('${AppRoutes.flights}/${flight.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildFilterChips(BuildContext context, List<FlightModel> flights) {
    final airlines = _getUniqueAirlines(flights);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('Todos', null),
            const SizedBox(width: 8),
            _chip('Menor precio', 'price'),
            const SizedBox(width: 8),
            _chip('Con asientos', 'direct'),
            ...airlines.map(
              (airline) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _chip(airline, airline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedFilter = isSelected ? null : value;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyan.withValues(alpha: 0.15)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.cyan : AppColors.gray,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flight_takeoff, size: 80, color: AppColors.cardBorder),
            const SizedBox(height: 24),
            Text(
              'Sin vuelos',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay vuelos para el filtro seleccionado.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _selectedFilter = null),
              child: Text(
                'Ver todos los vuelos',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
