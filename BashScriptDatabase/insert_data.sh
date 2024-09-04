#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate tables
echo $($PSQL "TRUNCATE TABLE games, teams")

# Process CSV file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    if [[ $WINNER != "winner" ]]
    then
        # Get team_id for the winner
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
        # If winner not found, insert it
        if  [[ -z $WINNER_ID ]]
        then
            INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
            if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
            then 
                echo "Inserted into teams, $WINNER"
            fi
            WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        fi

        # Get team_id for the opponent
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

        # If opponent not found, insert it
        if  [[ -z $OPPONENT_ID ]]
        then
            INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
            if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
            then 
                echo "Inserted into teams, $OPPONENT"
            fi
            OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        fi

        # Insert the game into the games table
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        
        if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
        then 
            echo "Inserted into games, $WINNER vs $OPPONENT"
        fi
    fi
done
