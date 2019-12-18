# frozen_string_literal: true

RodaApp.route('user') do |r|

  r.is do
    { first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email }
  end

end