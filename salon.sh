#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  HAVE_CUST=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $HAVE_CUST ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERTED=$($PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED';")
    CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' AND name='$CUSTOMER_NAME';")
    SERVICE_NAME_FORMAT=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
    CUSTOMER_NAME_FORMAT=$(echo $CUST_NAME | sed 's/\s//g' -E)
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMAT, $CUSTOMER_NAME_FORMAT?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' AND name='$CUSTOMER_NAME';")
    INSERT_TIME=$($PSQL "INSERT INTO appointments (time, service_id, customer_id) VALUES('$SERVICE_TIME', '$SERVICE_ID_SELECTED', '$CUSTOMER_ID')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMAT at $SERVICE_TIME, $CUSTOMER_NAME_FORMAT."
  fi
}

LIST_SERVICES(){
  if [[ $1 ]]
  then 
    echo -e "$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
 
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    LIST_SERVICES "I could not find that service. What would you like today?"
  else
     HAVE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

    if [[ -z $HAVE_SERVICE ]]
    then
      LIST_SERVICES "I could not find that service. What would you like today?"
    else
      MAIN_MENU
    fi
  fi
}

LIST_SERVICES
