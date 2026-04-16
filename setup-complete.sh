#!/bin/bash

# Complete IRIS Setup Script
# This script sets up the complete IRIS environment with ASTM E1238 support

echo "🚀 Starting complete IRIS setup with ASTM E1238 support..."

# 1. Start Docker containers
echo "📦 Starting Docker containers..."
docker-compose up -d

# Wait for IRIS to be ready
echo "⏳ Waiting for IRIS to be ready..."
sleep 30

# Check if IRIS is responding
echo "🔍 Checking IRIS status..."
docker exec iris-test-iris-1 iris session iris -U IRISAPP '##class(%SYSTEM.Version).Display()'

if [ $? -ne 0 ]; then
    echo "❌ IRIS is not ready yet. Please wait and try again."
    exit 1
fi

# 2. Install patient API
echo "🔧 Installing Patient API..."
docker exec iris-test-iris-1 iris session iris -U IRISAPP << 'EOF'
// Compile all classes
Do $System.OBJ.CompileAll()

// Setup Patient Web App
Do ##class(api.PatientWebApp).Setup()

// Display status
Write "Patient API Status: "
Do ##class(api.PatientWebApp).GetStatus()
Halt
EOF

# 3. Setup ASTM E1238 Schema
echo "📋 Setting up ASTM E1238 schema..."
docker exec iris-test-iris-1 iris session iris -U IRISAPP << 'EOF'
// Setup ASTM E1238 schema
Do ##class(Setup.ASTME1238).Setup()

// Test the installation
Do ##class(test.ASTME1238Test).QuickTest()
Halt
EOF

# 4. Test everything
echo "🧪 Running comprehensive tests..."

# Test Patient API
echo "Testing Patient API endpoints..."
API_BASE="http://localhost:52773/irisapp"

# Test health endpoint
curl -s "${API_BASE}/health" | grep -q "Patient API is running" && echo "✅ Health check passed" || echo "❌ Health check failed"

# Test patients list (should be empty initially)
curl -s "${API_BASE}/patients" | grep -q "\[\]" && echo "✅ Patients endpoint accessible" || echo "❌ Patients endpoint failed"

# Test ASTM processing
echo "🔬 Testing ASTM E1238 processing..."
docker exec iris-test-iris-1 iris session iris -U IRISAPP << 'EOF'
Write "Testing ASTM E1238 processing...", !
Set st = ##class(test.ASTME1238Test).TestE1238Processing()
If $$$ISERR(st) {
    Write "ERROR: ", $System.Status.GetErrorText(st), !
} else {
    Write "SUCCESS: All ASTM tests passed!", !
}
Halt
EOF

echo ""
echo "🎉 Setup complete! Your IRIS environment is ready."
echo ""
echo "📋 Available services:"
echo "   • Patient REST API: http://localhost:52773/irisapp"
echo "   • IRIS Management Portal: http://localhost:52773/csp/sys/UtilHome.csp"
echo "   • IRIS Terminal: docker exec -it iris-test-iris-1 iris session iris"
echo ""
echo "📖 API Documentation:"
echo "   • Health: GET ${API_BASE}/health"
echo "   • List patients: GET ${API_BASE}/patients"
echo "   • Get patient: GET ${API_BASE}/patient/{id}"
echo "   • Search: GET ${API_BASE}/patients/search?name=John&age=30"
echo "   • Create patient: POST ${API_BASE}/patient (with JSON body)"
echo "   • Update patient: PUT ${API_BASE}/patient/{id} (with JSON body)"
echo "   • Delete patient: DELETE ${API_BASE}/patient/{id}"
echo ""
echo "🧪 Test ASTM E1238:"
echo "   docker exec iris-test-iris-1 iris session iris -U IRISAPP"
echo "   Do ##class(test.ASTME1238Test).TestE1238Processing()"
echo ""
echo "🔧 Useful commands:"
echo "   • Restart: docker-compose restart"
echo "   • Logs: docker-compose logs -f iris"
echo "   • Stop: docker-compose down"