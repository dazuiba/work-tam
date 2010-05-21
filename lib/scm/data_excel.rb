require 'parseexcel'
require 'active_support'
require File.dirname(__FILE__)+"/../ruby_extension.rb"
module Scm;
	class ExcelNotValid < Exception
		def initialize(msg, file, e=nil)
			super("Error: #{msg}, when reading #{file}")
		end
	end	
end

class Scm::DataExcel
	GBK = "GBK"
	UTF8 = "UTF-8"
	def initialize(file)		
		@file = file
    @excel = Spreadsheet::ParseExcel.parse(file, :encoding => GBK)
    @worksheet = @excel.worksheet(2)
    
		@title = parse_title
		@rows = parse_data 
		
		titles = data_result[:titles]
		if data_sample = data_result[:datas].last		
			raise_error("titles and data_sample length should be same(#{titles.size} vs #{data_sample.size}) ",titles.size != data_sample.size)   	
  		raise_error("ids and datas length should be same ", data_result[:ids].size != data_result[:datas].size)
		end
	end
	
	
	# def update_script(script)
	# 	script_ids = @rows.map{|e|e[0]}
	# 	
	# 	script.update_data!(script_ids, @title[2,@title.size], @rows.map{|e|e[2,@rows.size]})
	# end
	# 
	
	def process
		yield data_result
	end
	
	def data_result
		@data_result||= {:ids    => @rows.map{|e|e[0].to_i}, 
		 								 :titles => @title[2,@title.size],
		 								 :datas  => @rows.map{|e|e[2,e.size]} }
	end

	def inspect
		self.data_result.inspect
	end
	
	private	
	
	def setup_datacsv
		DataCSV.new(:keys=>@title, :rows => @data)
	end
	
	def parse_data
		row_index = 1
		data = []
		while !(row = @worksheet.row(row_index)).to_s.blank?
			row = row.map{|cell|cell.nil? ?	nil	: ( cell.numeric ? cell.to_s : cell.to_s(UTF8) )}
			row = cut_or_fill_array(row, @title.size)
			data <<  row
			row_index+=1
		end
		data
	end
	
	def parse_title
		row = @worksheet.row(0)
		raise_error("Row size should > 5", row.size<5)
		remove_last_empty_cells(row.map{|e|e&&e.to_s("utf-8").strip})
	end
	
	def cut_or_fill_array(array, size)
		assert array.is_a? Array
		if (diff = (array.size - size)) > 0
			array[0..size-1 ]
		elsif diff < 0
			array + [nil]*diff.abs
		else
			# do not change
			array
		end
	end
	
	def remove_last_empty_cells(cells)		
		while(cells.size > 0 && cells.last.blank?)
			cells.pop
		end
		cells
	end
	
	def raise_error(msg, condition=true)
		raise Scm::ExcelNotValid.new(msg, @file) if condition
	end
	
end
