module ApplicationHelper
  def set_resticted_access(user, company_id)
    return false if user&.role_type&.eql?('super_admin')
    user&.company_id&.to_i != company_id.to_i
  end
end
