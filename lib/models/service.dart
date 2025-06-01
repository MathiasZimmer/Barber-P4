class Service {
  final String id; 
  final String name; 
  final int price; 
  final int duration; /minutes
  final List<ServiceOption>?
  options; 

 
  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.options,
  });
}

class ServiceOption {
  final String name; 
  final int additionalPrice; 
  final int
  additionalDuration; 
  
  ServiceOption({
    required this.name,
    required this.additionalPrice,
    this.additionalDuration = 15, 
  });
}


final List<Service> services = [
  Service(
    id: 'skinfade', 
    name: 'SKINFADE', 
    price: 250, 
    duration: 30, 
    options: [
      ServiceOption(name: 'Med skæg', additionalPrice: 50), 
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

