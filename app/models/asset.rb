class Asset < ActiveRecord::Base
  def self.search_in_fields(fields, word)
    field_filter_sql = []
    fields.each do |f|
      field_filter_sql << "LOWER(#{f}) LIKE :word"
    end
    where(field_filter_sql.join(' OR '), word: word)
  end
end
