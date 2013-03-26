@reverse = false;
if(ARGV[0] == '-r')
  @reverse = true;
end

@words = Array.new;
IO.foreach("abusive_words.txt") do |line|
  @parts = line.split(',');
  @words.push(@parts[0]);
end

@roots = Array.new;

@words.each {|ref|
  @root = true;
  @words.each {|w|
    #puts ref + "==" + w;
    if(ref != w && ref.index(w) != nil)
      @root = false;
      break;
    end
  }

  if( (@root && !@reverse) || (!@root && @reverse) )
    @roots.push(ref);
  end
}

@roots.each {|r|
  puts r;
}
