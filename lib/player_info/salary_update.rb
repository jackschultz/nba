module PlayerInfo
  class SalaryUpdate

    def self.update_draft_kings(date=nil)
      date ||= Date.today
      date_string = date.strftime('%F')
      filename = "lib/player_info/dk_salaries-#{date_string}.csv"
      PlayerCost.import_for_user_dk(filename, date)
    end

    def self.update_fan_duel(date=nil)
      date ||= Date.today
      date_string = date.strftime('%F')
      filename = "lib/player_info/fd_salaries-#{date_string}.csv"
      PlayerCost.import_for_user_fd(filename, date)
    end

  end
end
