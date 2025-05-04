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
    Member.delete_all
    
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
    
    # Sample data structure for categories
    categories = {
      'Rod' => [6,8,10,12,16,20,25,28,30,32,35,36,40,45,50,55,60,63,65,70,75,80,85,90,95,100,110,120,125,140,150],
      'Induction Rod' => [6,8,10,12,16,20,25,28,30,32,35,36,40,45,50,55,60,63,65,70,75,80,85,90,95,100,110,120,125,140,150],
      'Honning Tube' => ['32*42','40*50','45*55','50*60','55*65','60*72','60*73','63*73','63*75','63*76','70*80','70*82',
                         '70*85','75*88','75*90','80*90','80*92','80*95','80*100','85*100','90*105','95*110','100*112','100*114',
                         '100*115','100*120','100*121','100*125','105*120','110*125','110*130','110*135','115*130','115*135',
                         '115*140','120*140','120*150','120*152','125*140','125*145','125*151','130*155','130*160','135*155',
                         '135*160','140*160','140*165','140*170','150*170','150*180','160*180','160*185',
                         '160*190','180*203','180*210','180*220','200*220','200*225','200*230','200*232','200*245','200*250',
                         '220*273','250*280','250*286','250*300','280*325','300*350']
    }

    # Create categories and their subcategories
    categories.each do |category_name, sizes|
      puts "Creating category: #{category_name}"
      category = Category.create!(
        name: category_name,
        measurement_types: ['length'] # All categories use length measurement
      )
      
      sizes.each do |size|
        subcategory_name = category_name == 'Honning Tube' ? size.to_s : "#{size} inch dia"
        puts "  Creating subcategory: #{subcategory_name}"
        subcategory = category.sub_categories.create!(name: subcategory_name)
        
        # Create items for each company
        Company.all.each do |company|
          puts "    Creating items for company: #{company.name}"
          
          # Create sample quantities for each size
          Item.create!(
            company: company,
            category: category,
            sub_category: subcategory,
            name: "#{subcategory_name} #{category_name}",
            quantity: 100, # Default quantity
            remaining_quantity: 100,
            measurements: { 'meters' => 100.0 } # Default length
          )
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

  desc 'Adding subcategory data'
  task add_category_and_sub_catgories: :environment do
    OrderItem.delete_all
    Order.delete_all
    Item.delete_all
    SubCategory.delete_all
    Category.delete_all
    categories = {
    'Rod' => [6,8,10,12,16,20,25,28,30,32,35,36,40,45,50,55,60,63,65,70,75,80,85,90,95,100,110,120,125,140,150],
    'Induction Rod' => [6,8,10,12,16,20,25,28,30,32,35,36,40,45,50,55,60,63,65,70,75,80,85,90,95,100,110,120,125,140,150],
    'Honning Tube' => ['32*42','40*50','45*55','50*60','55*65','60*72','60*73','63*73','63*75','63*76','70*80','70*82',
                       '70*85','75*88','75*90','80*90','80*92','80*95','80*100','85*100','90*105','95*110','100*112','100*114',
                       '100*115','100*120','100*121','100*125','105*120','110*125','110*130','110*135','115*130','115*135',
                       '115*140','120*140','120*150','120*152','125*140','125*145','125*151','130*155','130*160','135*155',
                       '135*160','140*160','140*165','140*170','150*170','150*180','160*180','160*185',
                       '160*190','180*203','180*210','180*220','200*220','200*225','200*230','200*232','200*245','200*250',
                       '220*273','250*280','250*286','250*300','280*325','300*350']
    }

    # Insert categories in bulk
    category_records = categories.keys.map { |name| { name: name } }
    Category.insert_all(category_records)

    # Prepare subcategory records
    subcategory_records = []
    categories.each do |category_name, values|
      category_id = Category.find_by(name: category_name).id
      values.each do |value|
        name = category_name == 'Honning Tube' ? value.to_s : "#{value} inch dia"
        subcategory_records << { category_id: category_id, name: name }
      end
    end

    # Bulk insert subcategories
    SubCategory.insert_all(subcategory_records)
  end
end 