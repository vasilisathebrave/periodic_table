#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if ! [[ $1 ]]
then
  echo 'Please provide an element as an argument.'
fi

NOT_FOUND="I could not find that element in the database."


if [[ $1 ]]
then
  # check if argument is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$1
    ELEMENT_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $ATOMIC_NUMBER;")
    # if atomic number not in database
    if [[ -z $ELEMENT_RESULT ]]
    then
      echo $NOT_FOUND
    fi
  # see if it's a 1-2 letter symbol
  elif [[ ${#1} -le 2 ]]
  then
    ELEMENT_SYMBOL=$1
    ELEMENT_RESULT=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$ELEMENT_SYMBOL';")
    if [[ -z $ELEMENT_RESULT ]]
    then
      echo $NOT_FOUND
    else
      # get atomic_number
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$ELEMENT_SYMBOL';")
    fi
  # input is not a number and is longer than 2 letters
  else
    ELEMENT_NAME=$1
    ELEMENT_RESULT=$($PSQL "SELECT name FROM elements WHERE name = '$ELEMENT_NAME';")
    if [[ -z $ELEMENT_RESULT ]] 
    then
      echo $NOT_FOUND
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$ELEMENT_NAME';")
    fi
  fi
  if ! [[ -z $ATOMIC_NUMBER ]]
  then
    # look up element by atomic number
    ELEMENT=$($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number JOIN types ON types.type_id = properties.type_id WHERE elements.atomic_number = $ATOMIC_NUMBER;")
    # read the query result into variables
    echo $ELEMENT | while IFS=" |" read NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
    # format & print the final statement
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
fi