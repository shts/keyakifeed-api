namespace :app do

  desc "*** Create Members table by parsed Keyakizaka46.com ***"
  task :create_member do
    require './create_member'
  end

  desc "*** Create All Entries table by parsed Keyakizaka46.com ***"
  task :create_entries do
    require './create_entries'
  end
  
end
