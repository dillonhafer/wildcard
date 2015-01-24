class Asset < ActiveRecord::Base
  scope :search_in_fields, -> (fields=[], word) {
    sql = []
    fields.each do |f|
      sql.push("LOWER(#{f}) LIKE :word")
    end
    where(sql.join(' OR '), word: word)
  }
end
