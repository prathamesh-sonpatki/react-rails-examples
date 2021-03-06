desc 'Ensure that code is not running in production environment'
task :not_production do
  raise 'do not run in production' if Rails.env.production?
end

desc 'Sets up the project by running migration and populating sample data'
task setup: [:environment, :not_production, 'db:drop', 'db:create', 'db:migrate'] do
  ["setup_sample_data"].each { |cmd| system "rake #{cmd}" }
end

def delete_all_records_from_all_tables
  ActiveRecord::Base.connection.schema_cache.clear!

  Dir.glob(Rails.root + 'app/models/*.rb').each { |file| require file }

  ActiveRecord::Base.descendants.each do |klass|
    klass.reset_column_information
    klass.delete_all
  end
end

desc 'Deletes all records and populates sample data'
task setup_sample_data: [:environment, :not_production] do
  delete_all_records_from_all_tables

  create_user email: 'sam@example.com'

  create_posts User.first

  puts 'sample data was added successfully'
end

def create_user( options = {} )
  user_attributes = { email: 'sam@example.com',
                      password: 'welcome',
                      first_name: "Sam",
                      last_name: "Smith",
                      role: "super_admin" }
  attributes = user_attributes.merge options
  User.create! attributes
end

def create_posts(user)
  sample_titles = ["Mindwise: How We Understand What Others Think, Believe, Feel, and Want - by Nicholas Epley", "So Good They Can't Ignore You - by Cal Newport", "The War of Art - by Steven Pressfield", "Thinking, Fast and Slow - by Daniel Kahneman

"]

  sample_titles.each_with_index do |title, index|
    Post.create! user_id: user.id, title: title, content: File.read(Rails.root.to_s + "/db/posts/#{index + 1}.txt")
  end
end
