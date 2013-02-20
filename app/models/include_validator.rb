class IncludeValidator < ActiveModel::EachValidator
  
  def validate_each(record,attribute,value)
    return if value == nil
    record.errors.add attribute, "must be in #{self.options[:with]}" unless self.options[:with].include?(value)
  end
  
end