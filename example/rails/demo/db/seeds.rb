# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Book.create(
  [
    { :title => "The Fellowship of the Ring", :author => "JRR Tolkein" },
    { :title => "The Folk of the Air", :author => "Peter S Beagle" },
    { :title => "The God Delusion", :author => "Richard Dawkins" }
  ]
)