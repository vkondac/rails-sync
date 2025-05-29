Car.destroy_all

car_makes = ['Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes', 'Audi', 'Nissan', 'Chevrolet']
car_models = ['Sedan', 'SUV', 'Hatchback', 'Coupe', 'Truck', 'Convertible']
colors = ['Red', 'Blue', 'Black', 'White', 'Silver', 'Gray']

50.times do
  Car.create!(
    make: car_makes.sample,
    model: car_models.sample,
    year: rand(2010..2024),
    color: colors.sample,
    price: rand(15000.0..80000.0).round(2),
    mileage: rand(5000..150000)
  )
end

puts "Created #{Car.count} cars!"