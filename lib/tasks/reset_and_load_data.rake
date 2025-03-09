namespace :db do
  desc "Reset and load new sample data"
  task reset_and_load: :environment do
    puts "Cleaning up old data..."
    
    # Clean up old data
    OrderItem.delete_all
    Order.delete_all
    Item.delete_all
    SubCategory.delete_all
    Category.delete_all
    Member.delete_all  # Add this to clean up members
    
    puts "Creating members..."
    
    # Create sample members
    members = [
      { name: "Sakthi Engineering Works", phone: "9876543210", email: "sakthi@example.com" },
      { name: "Sri Amman Industries", phone: "9876543211", email: "sriamman@example.com" },
      { name: "PSG Industries", phone: "9876543212", email: "psg@example.com" },
      { name: "Lakshmi Machine Works", phone: "9876543213", email: "lmw@example.com" },
      { name: "Sharp Tools", phone: "9876543214", email: "sharp@example.com" }
    ]

    members.each do |member|
      Member.create!(member)
    end
    
    puts "Creating categories and subcategories..."
    
    # Sample data for each category and subcategory
    data = {
      "Rods" => {
        measurement_types: ['length'],
        subcategories: {
          "Steel" => [
            { meters: 1000.0, quantity: 10 },
            { meters: 500.0, quantity: 15 },
            { meters: 250.0, quantity: 20 }
          ],
          "Aluminum" => [
            { meters: 800.0, quantity: 8 },
            { meters: 400.0, quantity: 12 },
            { meters: 200.0, quantity: 16 }
          ]
        }
      },
      "Pipes" => {
        measurement_types: ['length'],
        subcategories: {
          "PVC" => [
            { meters: 600.0, quantity: 15 },
            { meters: 300.0, quantity: 20 },
            { meters: 150.0, quantity: 25 }
          ],
          "Metal" => [
            { meters: 700.0, quantity: 10 },
            { meters: 350.0, quantity: 15 },
            { meters: 175.0, quantity: 20 }
          ]
        }
      },
      "Barrell Oil" => {
        measurement_types: ['volume'],
        subcategories: {
          "Premium" => [
            { liters: 200.0, quantity: 5 },
            { liters: 100.0, quantity: 10 }
          ],
          "Standard" => [
            { liters: 200.0, quantity: 8 },
            { liters: 100.0, quantity: 15 }
          ]
        }
      }
    }

    # Create categories and their subcategories
    data.each do |category_name, category_data|
      puts "Creating category: #{category_name}"
      category = Category.create!(
        name: category_name,
        measurement_types: category_data[:measurement_types]
      )
      
      category_data[:subcategories].each do |subcategory_name, items|
        puts "  Creating subcategory: #{subcategory_name}"
        subcategory = category.sub_categories.create!(name: subcategory_name)
        
        # Create items for each company
        Company.all.each do |company|
          puts "    Creating items for company: #{company.name}"
          
          items.each do |item_data|
            measurements = if category_name == "Barrell Oil"
              { 'liters' => item_data[:liters] }
            else
              { 'meters' => item_data[:meters] }
            end
            
            Item.create!(
              company: company,
              category: category,
              sub_category: subcategory,
              name: "#{subcategory_name} #{category_name}",
              quantity: item_data[:quantity],
              remaining_quantity: item_data[:quantity],
              measurements: measurements
            )
          end
        end
      end
    end

    puts "\nCreated:"
    puts "#{Member.count} members"
    puts "#{Category.count} categories"
    puts "#{SubCategory.count} subcategories"
    puts "#{Item.count} items"
    puts "Done!"
  end
end 