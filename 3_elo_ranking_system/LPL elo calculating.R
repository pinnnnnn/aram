seventeenth <- read.csv(file="seventeenth.csv")
View(seventeenth)


elocalculate <- function(file) {
    team_no <- 1        ##Team count
    new_elo_vec <- c()  ##to store the vector of new elo
    while(team_no <= 12)
    {   
        ##Check if this team has match or not. 
        ##If yes, then calculate new elo in else if statment; if not, keep the old elo.
        if(file$match_check[team_no] == 0)
        {
            new_elo_vec[team_no] <- file$pre_elo_own[team_no]
            team_no <- team_no + 1  ##Team count increment
        }
        
        else if (file$match_check[team_no] == 1)
        {   
            ##Calculate the team's kda of that BO3
            own_ka_one <- (file$own_kill_one[team_no] + file$own_ass_one[team_no])
            own_ka_two <- (file$own_kill_two[team_no] + file$own_ass_two[team_no])
            own_ka_three <- (file$own_kill_three[team_no] + file$own_ass_three[team_no])
            own_kda_one <- own_ka_one/file$own_death_one[team_no]
            own_kda_two <- own_ka_two/file$own_death_two[team_no]
            own_kda_three <- own_ka_three/file$own_death_three[team_no]
            own_kda <- own_kda_one + own_kda_two + own_kda_three
            
            ##Calculate the team's opponent's kda of that BO3
            op_ka_one <- (file$op_kill_one[team_no] + file$op_ass_one[team_no])
            op_ka_two <- (file$op_kill_two[team_no] + file$op_ass_two[team_no])
            op_ka_three <- (file$op_kill_three[team_no] + file$op_ass_three[team_no])
            op_kda_one <- op_ka_one/file$op_death_one[team_no]
            op_kda_two <- op_ka_two/file$op_death_two[team_no]
            op_kda_three <- op_ka_three/file$op_death_three[team_no]
            op_kda <- op_kda_one + op_kda_two + op_kda_three
            
            ##calculate K multiplier, depending on the result of game
            if(file$win_check[team_no] == 1)
              {
                multiplier <- (log(10*abs(own_kda - op_kda)))*(2.2/((file$pre_elo_own[team_no]-file$pre_elo_op[team_no])*0.01+2.2))
              }
            else
              {
                multiplier <- (log(10*abs(own_kda - op_kda)))*(2.2/((file$pre_elo_op[team_no]-file$pre_elo_own[team_no])*0.01+2.2))
              }
            
            
            ##calculate elo difference, depending on whether the team has the blue side advantage
            if(file$blueside_check[team_no] == 1)
              {
                elo_difference <- (file$pre_elo_own[team_no] + 50) - file$pre_elo_op[team_no]
              }
            else
              {
                 elo_difference <- file$pre_elo_own[team_no] - (file$pre_elo_op[team_no] + 50)
              }
            
            #calculate the win_expectancy
            win_expectancy <- 1/((10^(-elo_difference/400))+1)

            new_elo_vec[team_no] <- file$pre_elo_own[team_no] +  multiplier * 20 * (file$win_check[team_no] - win_expectancy)
            team_no <- team_no + 1
        }
    }
    return(new_elo_vec)
}


winprediction <- function(file) {
    team_no <- 1        ##Team count
    elo_difference <- c()  ##to store the vector of elo_difference
    win_expectancy <- c()  ##to store the vector of win expectancy
    while(team_no <= 12)
    { 
    
        ##calculate elo difference, depending on whether the team has the blue side advantage
        if(file$blueside_check[team_no] == 1)
        {
            elo_difference[team_no] <- (file$pre_elo_own[team_no] + 50) - file$pre_elo_op[team_no]
        }
        else
        {
            elo_difference[team_no] <- file$pre_elo_own[team_no] - (file$pre_elo_op[team_no] + 50)
        }
    
        #calculate the win_expectancy
        win_expectancy[team_no] <- 1/((10^(-elo_difference[team_no]/400))+1)
        team_no <- team_no + 1
    }
    return(win_expectancy)
}

elocalculate(seventeenth)
winprediction(seventeenth)
