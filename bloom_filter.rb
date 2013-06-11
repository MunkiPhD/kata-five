require 'digest/md5'

class BloomFilter

	def initialize(set, max_bits, num_hashes)
		@max_size = max_bits
		@num_hashes = num_hashes
		@dataset = set

		init_bitarray(max_bits) # initialize the bit array

		@hashes = Array.new(num_hashes) { |i| BloomMd5Hash.new(i, @max_size -1) } # create an array with the specified number of hash functions

		set.each do |word|
			@hashes.each { |hash| @bitmap[hash.hash_this(word.chomp)] = 1 } # for every word, generate the hash, and set that bit to 1 in the bitmap
		end
	end


	# 
	# Checks whether the word is in the set
	# word: the word to check if it is in the set
	#
	def is_in_set?(word)
		# iterate over the hashes and recalc the hash value for the word. If the location in the bitmap is 0, then return false, meaning that the word is DEFINITELY not in the set
		@hashes.each do |hash|
			return false if @bitmap[hash.hash_this(word.chomp)] == 0
		end

		true # return true meaning that it is likely to be in the set
	end


	#
	# Initializes the bitmap to the specified size and sets the buckets to 0
	#		max_bits: the maximum size of the bit array
	def init_bitarray(max_bits)
		@bitmap = Array.new(max_bits, 0) # create a new array with the max size and initialize it to zero
	end
end


class BloomMd5Hash
	#
	#		seed: integer (1, 2, 3..). This will serve as an offset for the MD5 hash, so it cannot be large
	#		max_value: the max value of the bit array
	#
	def initialize(seed, max_value)
		@offset = seed
		@max_value = max_value
		@digits = 0

		# since we're using hex, we want to the size to be a variable of 16 bits, so we're going to use the max_value to get that
		while max_value > 0 do
			@digits += 1
			max_value >>= 4	# bit shift right 4 bits so we get a 16 bit number (hex)
		end
	end


	#
	# Computes the bit location for the specified word
	#		word: the word to get the bit location for using this md5 hash
	def hash_this(word)
		digest = Digest::MD5.hexdigest(word) # get the hex version of the MD5 for the specified string
		digest[@offset, @digits].to_i(16) % @max_value # offset it using the initial seed value and get a subset of the md5. then modulo it to get the bit array location
	end
end
