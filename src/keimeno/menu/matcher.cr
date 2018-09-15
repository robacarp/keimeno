class Keimeno::Matcher
  def self.search(haystack : String)
    new haystack
  end

  private getter haystack

  def initialize(@haystack : String)
    @position = 0
    @k_position = 0
  end

  def for(needles : String) : Bool
    unless needles =~ /[A-Z]/
      @haystack = haystack.downcase
    end

    needle_position = 0
    haystack_position = 0

    loop do
      needle = needles[needle_position]

      if position = haystack.index(needle, haystack_position)
        haystack_position = position + 1
      else
        return false
      end

      needle_position += 1
      break if needle_position >= needles.size
    end

    true
  end
end
