class Asset < ActiveRecord::Base
  def self.search_in_fields(fields, word)
    field_filter_sql = fields.map { |f| "LOWER(#{f}) LIKE :word" }
    where(field_filter_sql.join(' OR '), word: word)
  end
end
