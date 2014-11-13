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
num_lookback = 50
season_end = Date.new(2014,7,23)
after = Array.new(num_lookback, 0)

players.each do |player|
  puts "Inspecting player #{player.full_name}"
  stat_lines = player.stat_lines.played.before_date(season_end)
  num_lookback.times do |i|
    stat_lines[0..(i+1)*-1].each_with_index do |sl, index|
      sq_difference = 0
      sls = stat_lines[index+1..index+1+i]
      expected = median(sls)
      #expected = average(sls)
      sq_difference += (expected - sl.score_draft_kings)**2
      after[i] += sq_difference
    end
  end
end
puts after

