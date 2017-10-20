require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns == nil
      data = DBConnection.execute2(<<-SQL)
        SELECT *
        FROM #{table_name}
      SQL
      col_names = []
      data.first.each do |key|
        col_names << key.to_sym
      end
      @columns = col_names
    end
    @columns
  end

  def self.finalize!
    columns.each do |col|

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    class_name = self.to_s.downcase
    @table_name = "#{class_name}s"
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    if @attributes.nil?
      @attributes = {}
    end
    @attributes
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
