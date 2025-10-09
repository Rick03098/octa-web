#!/bin/bash

# Development server startup script

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Octa Backend - Development Server${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${BLUE}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created. Please update with your credentials.${NC}"
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${BLUE}Creating virtual environment...${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment
source venv/bin/activate

# Check if dependencies are installed
if [ ! -f "venv/lib/python*/site-packages/fastapi/__init__.py" ]; then
    echo -e "${BLUE}Installing dependencies...${NC}"
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Dependencies installed${NC}"
fi

# Start server
echo -e "${GREEN}Starting development server...${NC}"
echo -e "${BLUE}API docs will be available at: http://localhost:8000/docs${NC}"
echo -e "${BLUE}Press Ctrl+C to stop${NC}"
echo ""

python app/main.py