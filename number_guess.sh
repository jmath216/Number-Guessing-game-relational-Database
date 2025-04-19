#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0

# Ask for username
echo "Enter your username:"
read USERNAME

# Check if user exists
USER_RESULT=$($PSQL "SELECT username FROM games WHERE username='$USERNAME'")

if [[ -z $USER_RESULT ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO games(username, games_played, best_game) VALUES('$USERNAME', 0, 1000)" > /dev/null
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Start game
echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  ((GUESSES++))

  # Check for integer input
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Compare guess with secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update best game if needed
CURRENT_BEST=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")
if [[ $GUESSES -lt $CURRENT_BEST ]]; then
  $PSQL "UPDATE games SET best_game=$GUESSES WHERE username='$USERNAME'" > /dev/null
fi

# Increment games played
$PSQL "UPDATE games SET games_played = games_played + 1 WHERE username='$USERNAME'" > /dev/null
