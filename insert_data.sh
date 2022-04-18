#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi



# Do not change code above this line. Use the PSQL variable above to query your database.


cat <(tail -n +2 games.csv) | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  for TEAM in "$WINNER" "$OPPONENT"
  do
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) SELECT '$TEAM' WHERE NOT EXISTS(SELECT 1 FROM teams WHERE name = '$TEAM')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams, $TEAM"
    fi
  done

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER' LIMIT 1")
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) SELECT $YEAR, '$ROUND', $WINNER_ID, $($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT' LIMIT 1"), $WINNER_GOALS, $OPPONENT_GOALS WHERE NOT EXISTS(SELECT 1 FROM games WHERE YEAR = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_ID )")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then
    echo "Inserted into games, $YEAR $ROUND: $WINNER vs $OPPONENT"
  fi
done
