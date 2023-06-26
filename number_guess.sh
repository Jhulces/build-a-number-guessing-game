#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME(){
  RANDOM_NUMBER=$((1 + RANDOM % 1000))
  COUNTER=0
  GUESS=0
  while [ $RANDOM_NUMBER -ne $GUESS ]
  do
    if [ $COUNTER -eq 0 ]
    then
      echo -e "Guess the secret number between 1 and 1000:"
    else
      if [ $GUESS -gt $RANDOM_NUMBER ]
      then
        echo -e "It's higher than that, guess again:"
      else
        echo -e "It's lower than that, guess again:"
      fi
    fi
    read GUESS
    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
      echo -e "That is not an integer, guess again:"
      read GUESS
    done
    ((COUNTER++))
  done
  NEW_GAME_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($COUNTER, $1)")
  echo -e "You guessed it in $COUNTER tries. The secret number was $GUESS. Nice job!"
}

echo -e "Enter your username:"
read USER_NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
if [[ -z $USER_ID ]]
then
  echo -e "Welcome, $USER_NAME! It looks like this is your first time here."
  NEW_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
else
  GAMES=$($PSQL "SELECT COUNT(*) FROM users FULL JOIN games USING(user_id) WHERE name='$USER_NAME'")
  BEST=$($PSQL "SELECT MIN(guesses) FROM users FULL JOIN games USING(user_id) WHERE name='$USER_NAME'")
  echo -e "Welcome back, $USER_NAME! You have played $GAMES games, and your best game took $BEST guesses."
fi
GAME $USER_ID
