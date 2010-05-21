require "sequel"
module Dm
	
	class DbNotFound < Exception
	end
	
	class DBRepository
		attr_accessor :db_hash
		include Singleton	
		def initialize
			@db_hash = {}
			@connection_cache = {}
		end
		
		def [](key)
			@connection_cache[key]||=do_connect(key)
		end	
		
		def setup(hash)
			@db_hash ||= {}
			@db_hash.merge!(hash)
		end
		
		def size
			@db_hash.values.size
		end
		
		def empty?
			@db_hash.empty?
		end
		
		private
		def do_connect(key)			
			if uri = @db_hash[key]
				Sequel.connect(uri)
			else
				raise(DbNotFound) 
			end
		end
	end
	DBPool = DBRepository.instance
end