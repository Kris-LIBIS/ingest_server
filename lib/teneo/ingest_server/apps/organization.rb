# frozen_string_literal: true

RodaApp.route('organizations') do |r|

  user_orgs = current_user.member_organizations

  r.is do
    user_orgs.each_with_object([]) do |(org, roles), a|
      a << {
          id: org.id,
          name: org.name,
          roles: roles
      }
    end
  end

  r.get Integer do |id|
    r.halt(401) unless (org = user_orgs.keys.find { |o| o.id == id })
    session[:org_id] = org.id
    {
        name: org.name,
        description: org.description,
        code: org.inst_code
    }
  end

end
