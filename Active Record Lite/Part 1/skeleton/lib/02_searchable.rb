require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    keys = params.keys.join(" = ? AND ") + " = ?"
    values = params.values

    data = DBConnection.execute(<<-SQL, values)
      SELECT  *
      FROM  #{self.table_name}
      WHERE #{keys}
    SQL
    
    parse_all(data)
  end
end

class SQLObject
  extend Searchable
end
