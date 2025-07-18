#!/bin/bash

# Start backend server
cd ../backend
go run . &

# Start frontend development server
cd ../frontend
flutter run
