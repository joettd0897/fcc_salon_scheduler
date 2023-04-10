#!/bin/bash
# DO NOT USE 'CLEAR' COMMAND
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
MAIN_MENU() {
  #Check arg and set var
  if [[ $1 ]]
  then
    MAIN_MENU_ECHO=$1
  else
    MAIN_MENU_ECHO="Welcome! please select number!"
  fi
  #Show message and all service
  ALL_SERVICE="$($PSQL "SELECT service_id, name FROM services")"
  echo -e "\n$MAIN_MENU_ECHO"
  echo "$ALL_SERVICE" | while IFS="|" read service_id name;
    do
      echo "$service_id) $name"
    done
  #Select service ID
  read SERVICE_ID_SELECTED
  #Get PSQL SERVICE_ID_SELECTED = service_id
  SERVICE_DATA=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_DATA ]]
  then
    #if not have SERVICE_DATA, return Main Menu
    MAIN_MENU "Number is wrong! Please select number!"
  else
    #if have SERVICE_DATA
    ADD_APPOINTMENT_MENU $SERVICE_DATA
  fi
}
ADD_APPOINTMENT_MENU() {
  SERVICE_ID=$1
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  echo -e "\nNumber is checked! OK!\n\nPlease enter your phoner number!"
  read CUSTOMER_PHONE
  #Check phone number
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    #if phone number is not customer
    #INSERT customer data(phone, name)
    echo -e "\nPlease enter your name!"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    #if phone number is customer
    #get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  echo -e "\nPlease enter service time!"
  read SERVICE_TIME
  #INSERT appointment
  INSERT_APPO_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  if [[ $INSRT_APPO_RESULT="INESRT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
echo -e "\n~~ SALON SCRIPT~~"
MAIN_MENU
