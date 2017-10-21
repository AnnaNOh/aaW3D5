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
    self.columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      setter_method_name = col.to_s + "="
      define_method(setter_method_name) do |value|
        attributes[col] = value
      end
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
    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    parse_all(data)
  end


  def self.parse_all(results)
    result = []
    results.each_with_index do |el, i|
      result << self.new(results[i])
    end
    result
  end


  def self.find(id)
    all.each do |el|
      if el.id == id
        return el
      end
    end
    nil
  end


  def initialize(params = {})
    params.each do |key, value|
      if self.class.columns.include?(key.to_sym)
        send("#{key}=", value)
      else
        raise "unknown attribute '#{key}'"
      end
    end
  end


  def attributes
    if @attributes.nil?
      @attributes = {}
    end
    @attributes
  end


  def attribute_values
    @attributes.values
  end


  def insert
    cols = self.class.columns[1..-1]
    col_names = cols.join(",")
    question_marks = (["?"]*(cols.length)).join(",")

    data = DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL

    @attributes[:id] = DBConnection.last_insert_row_id
  end


  def update
    cols = self.class.columns[1..-1]
    p col_names = cols.join(" = ?, ") + " = ?"
    p attribute_values

    data = DBConnection.execute(<<-SQL, attribute_values[1..-1], attribute_values[0])
      UPDATE #{self.class.table_name}
      SET #{col_names}
      WHERE id = ?
    SQL
  end



  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
