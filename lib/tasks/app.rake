namespace :app do

  desc "*** Create Members table by parsed Keyakizaka46.com ***"
  task :create_member do
    require './create_member'
  end

  desc "*** Create All Entries table by parsed Keyakizaka46.com ***"
  task :create_entries do
    require './create_entries'
  end

  desc "*** Create All Report table by parsed Keyakizaka46.com ***"
  task :create_reports do
    require './create_reports'
  end

  desc "*** Create All Matome Feed table by parsed some matome sites ***"
  task :create_matomefeeds do
    require './create_matomefeeds'
  end

  desc "*** Create All table data by parsed Keyakizaka46.com ***"
  task :create_all do
    require './create_member'
    require './create_entries'
    require './create_reports'
    require './create_matomefeeds'
  end

end
