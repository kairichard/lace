module Koon extend self
	def list
		Dir.glob(File.join(KOON_DOTTIES, "**")).map do |p|
			puts Pathname.new(p).basename
		end
	end
end
