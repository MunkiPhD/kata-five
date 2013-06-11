require_relative 'bloom_filter.rb'

describe BloomFilter do
	context 'is in set' do
		let(:set) { ["one", "two", "three", "four", "five"] }

		it 'returns true' do
			bloom = BloomFilter.new(set, 100, 2)
			expect(bloom.is_in_set?("one")).to be_true
		end

		it 'returns a false positive' do
			bloom = BloomFilter.new(set, 3, 2) # set a small bitmap size to ensure that they're filled
			expect(bloom.is_in_set?("eleven")).to be_true
		end
	end

	context 'is NOT in set' do
		let(:set) { ["one", "two", "three"] }

		it 'returns false for large bitmap' do
			bloom = BloomFilter.new(set, 100, 2)
			expect(bloom.is_in_set?("hello world")).to be_false
		end

		it 'returns a true (false positive) for a small bitmap' do
			bloom = BloomFilter.new(set, 2, 2)
			expect(bloom.is_in_set?("hello world")).to be_true
		end
	end
end
