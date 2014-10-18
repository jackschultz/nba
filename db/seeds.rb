# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


ec = Conference.create(name: 'Eastern')
wc = Conference.create(name: 'Western')

Division.create(name: 'Atlantic', conference_id: ec.id)
Division.create(name: 'Central', conference_id: ec.id)
Division.create(name: 'Southeast', conference_id: ec.id)
Division.create(name: 'Northwest', conference_id: wc.id)
Division.create(name: 'Pacific', conference_id: wc.id)
Division.create(name: 'Southwest', conference_id: wc.id)

Team.create(nickname: 'Clippers', city: 'Los Angeles', nba_id: '1610612746', alt_nickname: '', division: Division.find_by_name('Pacific'))
Team.create(nickname: 'Lakers', city: 'Los Angeles', nba_id: '1610612747', alt_nickname: '', division: Division.find_by_name('Pacific'))
Team.create(nickname: 'Grizzlies', city: 'Memphis', nba_id: '1610612763', alt_nickname: '', division: Division.find_by_name('Southwest'))
Team.create(nickname: 'Timberwolves', city: 'Minnesota', nba_id: '1610612750', alt_nickname: '', division: Division.find_by_name('Northwest'))
Team.create(nickname: 'Pelicans', city: 'New Orleans', nba_id: '1610612740', alt_nickname: '', division: Division.find_by_name('Southwest'))
Team.create(nickname: 'Thunder', city: 'Oklahoma City', nba_id: '1610612760', alt_nickname: '', division: Division.find_by_name('Northwest'))
Team.create(nickname: 'Suns', city: 'Phoenix', nba_id: '1610612756', alt_nickname: '', division: Division.find_by_name('Pacific'))
Team.create(nickname: 'Kings', city: 'Sacramento', nba_id: '1610612758', alt_nickname: '', division: Division.find_by_name('Pacific'))
Team.create(nickname: 'Spurs', city: 'San Antonio', nba_id: '1610612759', alt_nickname: '', division: Division.find_by_name('Southwest'))
Team.create(nickname: 'Jazz', city: 'Utah', nba_id: '1610612762', alt_nickname: '', division: Division.find_by_name('Northwest'))
Team.create(nickname: '76ers', city: 'Philadelphia', nba_id: '1610612755', alt_nickname: 'Sixers', division: Division.find_by_name('Atlantic'))
Team.create(nickname: 'Trail Blazers', city: 'Portland', nba_id: '1610612757', alt_nickname: 'Blazers', division: Division.find_by_name('Northwest'))
Team.create(nickname: 'Celtics', city: 'Boston', nba_id: '1610612738', alt_nickname: '', division: Division.find_by_name('Atlantic'))
Team.create(nickname: 'Nets', city: 'Brooklyn', nba_id: '1610612751', alt_nickname: '', division: Division.find_by_name('Atlantic'))
Team.create(nickname: 'Hawks', city: 'Atlanta', nba_id: '1610612737', alt_nickname: '', division: Division.find_by_name('Southeast'))
Team.create(nickname: 'Hornets', city: 'Charlotte', nba_id: '1610612766', alt_nickname: '', division: Division.find_by_name('Southeast'))
Team.create(nickname: 'Bulls', city: 'Chicago', nba_id: '1610612741', alt_nickname: '', division: Division.find_by_name('Central'))
Team.create(nickname: 'Cavaliers', city: 'Cleveland', nba_id: '1610612739', alt_nickname: '', division: Division.find_by_name('Central'))
Team.create(nickname: 'Pistons', city: 'Detroit', nba_id: '1610612765', alt_nickname: '', division: Division.find_by_name('Central'))
Team.create(nickname: 'Pacers', city: 'Indiana', nba_id: '1610612754', alt_nickname: '', division: Division.find_by_name('Central'))
Team.create(nickname: 'Heat', city: 'Miami', nba_id: '1610612748', alt_nickname: '', division: Division.find_by_name('Southeast'))
Team.create(nickname: 'Bucks', city: 'Milwaukee', nba_id: '1610612749', alt_nickname: '', division: Division.find_by_name('Central'))
Team.create(nickname: 'Knicks', city: 'New York', nba_id: '1610612752', alt_nickname: '', division: Division.find_by_name('Atlantic'))
Team.create(nickname: 'Magic', city: 'Orlando', nba_id: '1610612753', alt_nickname: '', division: Division.find_by_name('Southeast'))
Team.create(nickname: 'Raptors', city: 'Toronto', nba_id: '1610612761', alt_nickname: '', division: Division.find_by_name('Atlantic'))
Team.create(nickname: 'Wizards', city: 'Washington', nba_id: '1610612764', alt_nickname: '', division: Division.find_by_name('Southeast'))
Team.create(nickname: 'Mavericks', city: 'Dallas', nba_id: '1610612742', alt_nickname: '', division: Division.find_by_name('Southwest'))
Team.create(nickname: 'Nuggets', city: 'Denver', nba_id: '1610612743', alt_nickname: '', division: Division.find_by_name('Northwest'))
Team.create(nickname: 'Warriors', city: 'Golden State', nba_id: '1610612744', alt_nickname: '', division: Division.find_by_name('Pacific'))
Team.create(nickname: 'Rockets', city: 'Houston', nba_id: '1610612745', alt_nickname: '', division: Division.find_by_name('Southwest'))
