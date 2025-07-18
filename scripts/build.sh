#!/bin/bash

# Build backend
cd ../backend
go build -o video_platform_server

# Build frontend
cd ../frontend
flutter build
