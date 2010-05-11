module Pm
	class LibVersion
		vs = VersionRoot.new("2010050519240009", "project123", "project123") #update
		vs.add_nodes FileNode.new("2010050519240001", "filename123.xml", "/filename1.xml") #add
		
		folder1 = FolderNode.new("2010050519240006", "folder3") #add
		folder1.add_nodes FileNode.new("2010050519240008", "filename3.xml", "folder1/filename2.xml") #add
		folder2 = FolderNode.new("2010050519240003", "folder2") #update
		folder2.add_nodes FileNode.new("2010050519240001", "filename2.xml", "folder1/filename2.xml") #update
		
		folder_same = FolderNode.new("2010050519240003", "folderS") #same
		folder_same.add_nodes FileNode.new("2010050519240001", "filenameS.xml", "folder1/filenameS.xml") #update
		
		vs.add_nodes folder1
		vs.add_nodes folder2
		vs.add_nodes folder_same
		vs.add_nodes FolderNode.new("2010050519240006", "folder_new") #add
		
		def initialize(page_lib)
			@pm_lib = page_lib
		end
		
		def parse_version_tree
			root = lib_to_vnode @pm_lib
			@pm_lib.children.each{|e|add_node(root, e)}
			root
		end
		
		def add_node(parent_node, db_node)
			current_node = folder_to_vnode(db_node)
			parent_node.add_nodes(current_node)
			if !db_node.children.empty?
				db_node.children.each{|e|add_node(current_node, e)}
			end
		end
		
		
		private
		def lib_to_vnode(pm_lib)
			folder_root = pm_lib.folder_root
			VersionRoot.new(version(root), project.name)
		end
		
		def folder_to_vnode(folder)
			FolderNode.new(version(folder), folder.name )
		end
		
		def version(obj)
			obj.updated_at.to_s(:db)
		end
		
	end
end