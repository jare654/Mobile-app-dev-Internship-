#!/bin/bash

# PulseNews Flutter App Setup Script
# This script sets up the development environment and generates necessary files

set -e

echo "🚀 Setting up PulseNews Flutter App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter found: $(flutter --version)"

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Generate code generation files
echo "🔧 Generating code generation files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run code generation for JSON serialization
echo "📝 Generating JSON serialization code..."
flutter packages pub run build_runner build

# Generate Hive adapters
echo "🐝 Generating Hive adapters..."
flutter packages pub run build_runner build

# Check for .env file
if [ ! -f "assets/.env" ]; then
    echo "⚠️  Creating .env file template..."
    cat > assets/.env << EOF
# NewsAPI Configuration
NEWS_API_KEY=your_newsapi_key_here

# App Configuration
APP_ENV=development
API_BASE_URL=https://api.pulsenews.app

# Debug
DEBUG_MODE=true
EOF
    echo "📝 Please edit assets/.env and add your NewsAPI key"
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p test/unit/data/repositories
mkdir -p test/unit/data/services
mkdir -p test/unit/domain/usecases
mkdir -p test/widget
mkdir -p test/integration
mkdir -p test/test_helpers

# Run tests to verify setup
echo "🧪 Running tests to verify setup..."
flutter test --coverage

# Check code quality
echo "🔍 Running static analysis..."
flutter analyze

echo "✅ Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Edit assets/.env and add your NewsAPI key"
echo "2. Run 'flutter run' to start the app"
echo "3. Run 'flutter test' to run tests"
echo "4. Run 'flutter analyze' to check code quality"
echo ""
echo "📚 Documentation available in docs/ directory"
