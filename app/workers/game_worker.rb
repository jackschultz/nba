class GameWorker
  include Sidekiq::Worker

  def perform(end_date, num_days, reverse = true)
    end_date = Date.parse(end_date) #since it comes in as a string
    start_date = end_date - num_days.days
    Fetching::Games.process_games_range(start_date, end_date, reverse)
  end

end
