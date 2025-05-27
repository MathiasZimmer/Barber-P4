// Represents a type of service offered by the barbershop (e.g., haircut, beard trim)
class Service {
  final String id; // Unique identifier for the service
  final String name; // Display name of the service (e.g., "SKINFADE")
  final int price; // Base price of the service in DKK
  final int duration; // Estimated duration of the service in minutes
  final List<ServiceOption>?
  options; // Optional add-ons or variations for the service

  // Constructor for creating a Service object, with required and optional fields
  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.options,
  });
}

// Represents an optional add-on to a service (e.g., adding a beard trim to a haircut)
class ServiceOption {
  final String name; // Name/label of the option (e.g., "Med skæg")
  final int additionalPrice; // Additional cost for this option
  final int
  additionalDuration; // Extra time this option adds to the base duration (default is 15 minutes)

  // Constructor for creating a ServiceOption
  ServiceOption({
    required this.name,
    required this.additionalPrice,
    this.additionalDuration = 15, // Default value is 15 minutes if not provided
  });
}

// List of services offered by the barbershop, with predefined data
final List<Service> services = [
  Service(
    id: 'skinfade', // Unique ID used internally
    name: 'SKINFADE', // Display name for customers
    price: 250, // Base price in DKK
    duration: 30, // Duration in minutes
    options: [
      ServiceOption(name: 'Med skæg', additionalPrice: 50), // Optional add-on
    ],
  ),
  Service(
    id: 'skaeg',
    name: 'SKÆG',
    price: 100,
    duration: 20,
    options: [ServiceOption(name: 'Med Lineup', additionalPrice: 50)],
  ),
  Service(
    id: 'boerneklip',
    name: 'BØRNEKLIP',
    price: 150,
    duration: 30,
    options: [ServiceOption(name: 'Skinfade', additionalPrice: 50)],
  ),
  Service(
    id: 'herreklip',
    name: 'HERREKLIP',
    price: 200,
    duration: 30,
    options: [ServiceOption(name: 'Med skæg', additionalPrice: 50)],
  ),
];
// This code defines the data model for services offered by the barbershop.
