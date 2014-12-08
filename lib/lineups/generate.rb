module Lineups
  module Generate

    require "rinruby"

    def self.generate_lineups_ids(pcs_ids, site_id)
      pcs = PlayerCosts.find_all_by_id(pcs_ids).primary
      generate_lineups(pcs)
    end

    def self.generate_lineups(pcs, site_id)

      locked_positions = []
      locked_actual = []
      locked = []
      pcs.each do |pc|
        if pc.locked == true
          locked << pc
        end
      end
      locked.each do |lock|
        lock_check = lock
        while locked_positions.include?(lock_check.position)
          lock_check = PlayerCost.where(game_id: lock.game_id, player_id: lock.player_id, position: lock_check.lower_position).first
        end
        locked_actual << lock_check
        locked_positions << lock_check.position
        pcs = pcs.where('position != ?', lock_check.position)
      end
      pcs_arr = pcs.to_a
      locked_actual.each do |lock|
        pcs_arr << lock
      end

      site = Site.find(site_id)
      if site.name == "Fan Duel"
        lineup = generate_lineup_fd(pcs_arr)
      elsif site.name == "Draft Kings"
        lineup = generate_lineup_dk(pcs_arr)
      end

      [lineup, lineup]
    end

    def self.generate_lineup_dk(pcs)
      R.eval "pc_matrix <- matrix(ncol=5, nrow=#{pcs.count})"
      pcs.each_with_index do |pc, index|
        R.eval "pc_matrix[#{index+1},] <- c(#{pc.id}, #{pc.player.team_id}, '#{pc.position}', #{pc.salary}, #{pc.expected_points})"
      end
      R.eval "df <- as.data.frame(pc_matrix)"
      R.eval "colnames(df) <- c('name', 'team_name', 'type_name', 'now_cost', 'total_points')"
      R.eval <<-EOF

        library(lpSolve)
        library(stringr)
        library(plyr)

        # The vector to optimize on
        objective <- df$total_points

        # Fitting Constraints
        num_g <- 3
        num_pointg <- 1
        num_shootg <- 1
        num_f <- 3
        num_smallf <- 1
        num_powf <- 1
        num_center <- 1
        num_util <- 8
        max_cost <- 50000

        # Create vectors to constrain by position
        df$Guard <- ifelse(grepl("G",df$type_name,ignore.case=TRUE), 1, 0)
        df$ShootingGuard <- ifelse(df$type_name == "SG", 1, 0)
        df$PointGuard <- ifelse(df$type_name == "PG", 1, 0)
        df$Forward <- ifelse(grepl("F",df$type_name,ignore.case=TRUE), 1, 0)
        df$SmallForward <- ifelse(df$type_name == "SF", 1, 0)
        df$PowerForward <- ifelse(df$type_name == "PF", 1, 0)
        df$Center <- ifelse(df$type_name == "C", 1, 0)
        df$Util <- 1

        # Create constraint vectors to constrain by max number of players allowed per team
        team_constraint <- unlist(lapply(unique(df$team_name), function(x, df){
                ifelse(df$team_name==x, 1, 0)
        }, df=df))

        # next we need the constraint directions
        const_dir <- c(">=", ">=", ">=", ">=", ">=", ">=", ">=", "=", rep("<=", length(unique(df$team_name))+1))

        # Now put the complete matrix together
        const_mat <- matrix(c(df$Guard, df$ShootingGuard, df$PointGuard, df$Forward, df$SmallForward, df$PowerForward, df$Center, df$Util, as.numeric(as.character(df$now_cost)), team_constraint), nrow=(9 + length(unique(df$team_name))), byrow=TRUE)
        const_rhs <- c(num_g, num_pointg, num_shootg, num_f, num_smallf, num_powf, num_center, num_util, max_cost, rep(4, length(unique(df$team_name))))

        # then solve the matrix
        asdf <- lp ("max", as.numeric(as.character(objective)), const_mat, const_dir, const_rhs, all.bin=TRUE, all.int=TRUE)

      EOF

      players = R.pull "data.matrix(df[which(asdf$solution==1),]$name)"
      lineup = DraftKingsLineup.new
      players.to_a.each do |pcid_str|
        pcid = pcid_str[0].to_i
        pc = PlayerCost.find(pcid)
        lineup.add_player(pc)
      end

      lineup

    end

    def self.generate_lineup_fd(pcs)

      R.eval "pc_matrix <- matrix(ncol=5, nrow=#{pcs.count})"
      pcs.each_with_index do |pc, index|
        R.eval "pc_matrix[#{index+1},] <- c(#{pc.id}, #{pc.player.team_id}, '#{pc.position}', #{pc.salary}, #{pc.expected_points})"
      end
      R.eval "df <- as.data.frame(pc_matrix)"
      R.eval "colnames(df) <- c('name', 'team_name', 'type_name', 'now_cost', 'total_points')"
      R.eval <<-EOF

        # The vector to optimize on
        objective <- df$total_points

        # Fitting Constraints
        num_pointg <- 2
        num_shootg <- 2
        num_smallf <- 2
        num_powf <- 2
        num_center <- 1
        max_cost <- 60000

        # Create vectors to constrain by position
        df$ShootingGuard <- ifelse(df$type_name == "SG", 1, 0)
        df$PointGuard <- ifelse(df$type_name == "PG", 1, 0)
        df$SmallForward <- ifelse(df$type_name == "SF", 1, 0)
        df$PowerForward <- ifelse(df$type_name == "PF", 1, 0)
        df$Center <- ifelse(df$type_name == "C", 1, 0)

        # Create constraint vectors to constrain by max number of players allowed per team
        team_constraint <- unlist(lapply(unique(df$team_name), function(x, df){
                ifelse(df$team_name==x, 1, 0)
        }, df=df))

        # next we need the constraint directions
        const_dir <- c("=", "=", "=", "=", "=", rep("<=", length(unique(df$team_name))+1))

        # Now put the complete matrix together
        const_mat <- matrix(c(df$ShootingGuard, df$PointGuard, df$SmallForward, df$PowerForward, df$Center,
                              as.numeric(as.character(df$now_cost)), team_constraint),
                            nrow=(6 + length(unique(df$team_name))), byrow=TRUE)
        const_rhs <- c(num_pointg, num_shootg, num_smallf, num_powf, num_center, max_cost, rep(4, length(unique(df$team_name))))

        # then solve the matrix
        optimal_lineup <- lp ("max", as.numeric(as.character(objective)), const_mat, const_dir, const_rhs, all.bin=TRUE, all.int=TRUE)

      EOF

      players = R.pull "data.matrix(df[which(optimal_lineup$solution==1),]$name)"
      lineup = FanDuelLineup.new
      players.to_a.each do |pcid_str|
        pcid = pcid_str[0].to_i
        pc = PlayerCost.find(pcid)
        lineup.add_player(pc)
      end

      lineup


    end

  end
end

