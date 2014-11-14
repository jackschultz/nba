def median(stat_lines)
  stat_lines.sort!{ |x,y| y.score_draft_kings <=> x.score_draft_kings }
  len = stat_lines.length
  if stat_lines.length == 0
    return 0
  elsif stat_lines.length == 1
    return stat_lines.first.score_draft_kings
  elsif stat_lines.length == 2
    return (stat_lines.first.score_draft_kings + stat_lines.first.score_draft_kings)/2.0
  else
    (stat_lines[(len-1) / 2].score_draft_kings + stat_lines[len/2].score_draft_kings) / 2.0
  end
end

def median_sdks(sdks)
  sorted = sdks.sort
  len = sdks.length
  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

def variance(stat_lines, mean)
end

def std(stat_lines, mean)
  Math.sqrt(variance(stat_lines, mean))
end

def average(stat_lines)
  sdk = stat_lines.map(&:score_draft_kings)
  sum  = sdk.sum
  length = sdk.length
  if length == 0
    0
  else
    sum / length
  end
end

players = Player.all#[0..20]
season_end = Date.new(2014,7,23)

lookback = 20 #i+1 is length looking back

total = Array.new(lookback,0)
outside = Array.new(lookback,0)
sum_var = Array.new(lookback,0)
sum_mean = Array.new(lookback,0)

players.each do |player|
  puts "Inspecting player #{player.full_name}"
  stat_lines = player.stat_lines.played.before_date(season_end)
  2.upto(5) do |i|
    if stat_lines.length > i+3
      lbstat_lines = stat_lines[0..(i+2)*-1]
      lbstat_lines.each_with_index do |sl, index|
        sdks = stat_lines[index+1..index+1+i].map(&:score_draft_kings)
        mean = sdks.sum / sdks.length
        mean = median_sdks(sdks)
        if mean > 20
          var = sdks.map{|sdk| (sdk-mean)**2 }.sum
          sum_var[i] += var
          sum_mean[i] += mean
          std = Math.sqrt(var)
          #if sl.score_draft_kings > (mean + 2*std) || sl.score_draft_kings < (mean - 2*std)
          if sl.score_draft_kings < (mean - 2*std)
            outside[i] += 1
          end
          total[i] += 1
        end
      end
    end
  end
end

total.each_with_index do |t, index|
  puts "#{index}: #{outside[index].to_f / total[index].to_f}, #{Math.sqrt(sum_var[index].to_f / total[index].to_f)}, #{(sum_mean[index].to_f / total[index].to_f)}"
end


=begin
def asdf
  players = Player.all#[0..20]
  num_lookback = 50
  season_end = Date.new(2014,7,23)
  after = Array.new(num_lookback, 0)

  players.each do |player|
    puts "Inspecting player #{player.full_name}"
    stat_lines = player.stat_lines.played.before_date(season_end)
    i = 2
    outside = 0
    total = 0
  #  num_lookback.times do |i|
      sq_diff_sum = 0
      if stat_lines.length > i+3
        lbstat_lines = stat_lines[0..(i+2)*-1]
        lbstat_lines.each_with_index do |sl, index|
          sq_difference = 0
          sls = stat_lines[index+1..index+1+i].map(&:score_draft_kings)
         # expected = median(sls)
          mean = sls.sum / sls.length
          var = sls.each{|sdk| (sdk-mean)**2 }.sum
          std = Math.sqrt(var)
          if 1
            outside += 1
          end
          total += 1

  #        expected = average(sls)
         # expected = sls.first.score_draft_kings
         # expected = sls[i].score_draft_kings
        #  sq_difference += (expected - sl.score_draft_kings)**2
        #  sq_diff_sum += sq_difference
        end
       # if lbstat_lines.length > 0
       #   after[i] = sq_diff_sum / lbstat_lines.length
       # end
      end
  #  end
  end
  puts after

end

=end
