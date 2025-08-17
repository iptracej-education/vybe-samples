#!/bin/bash

read -p "Enter the migration message: " user_input

escaped_input=$(echo $user_input | sed 's/"/\\"/g')

alembic revision --autogenerate -m \"$escaped_input\"