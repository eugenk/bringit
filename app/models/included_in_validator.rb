class IncludedInValidator < ActiveModel::EachValidator
  
  def validate_each(record,attribute,value)
    return if value == nil
    record.errors.add attribute, "must be in #{self.options[:in]}" unless self.options[:in].include?(value)
  end
  
end