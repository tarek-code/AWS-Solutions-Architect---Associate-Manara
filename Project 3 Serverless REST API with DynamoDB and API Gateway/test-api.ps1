# PowerShell script to test the Todo API endpoints
# Usage: .\test-api.ps1 -ApiUrl "https://your-api-id.execute-api.us-east-1.amazonaws.com/dev"

param(
    [Parameter(Mandatory = $true)]
    [string]$ApiUrl
)

Write-Host "🧪 Testing Todo API endpoints..." -ForegroundColor Green
Write-Host "API URL: $ApiUrl" -ForegroundColor Cyan

# Test 1: List todos (should be empty initially)
Write-Host "`n📋 Test 1: List all todos" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos" -Method GET
    Write-Host "✅ Success: Found $($response.count) todos" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Create a todo
Write-Host "`n➕ Test 2: Create a new todo" -ForegroundColor Yellow
$newTodo = @{
    title       = "Learn AWS Serverless"
    description = "Complete the serverless REST API project"
    priority    = "high"
    due_date    = "2024-12-31"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos" -Method POST -Body $newTodo -ContentType "application/json"
    Write-Host "✅ Success: Todo created" -ForegroundColor Green
    $todoId = $response.todo.id
    Write-Host "Todo ID: $todoId" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Get the created todo
Write-Host "`n🔍 Test 3: Get specific todo" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos/$todoId" -Method GET
    Write-Host "✅ Success: Todo retrieved" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Update the todo
Write-Host "`n✏️ Test 4: Update todo" -ForegroundColor Yellow
$updateData = @{
    title       = "Learn AWS Serverless - Updated"
    description = "Complete the serverless REST API project with Terraform"
    completed   = $true
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos/$todoId" -Method PUT -Body $updateData -ContentType "application/json"
    Write-Host "✅ Success: Todo updated" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: List todos again (should show the created todo)
Write-Host "`n📋 Test 5: List todos after creation" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos" -Method GET
    Write-Host "✅ Success: Found $($response.count) todos" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test filtering (completed todos)
Write-Host "`n🔍 Test 6: Filter completed todos" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos?completed=true" -Method GET
    Write-Host "✅ Success: Found $($response.count) completed todos" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Delete the todo
Write-Host "`n🗑️ Test 7: Delete todo" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos/$todoId" -Method DELETE
    Write-Host "✅ Success: Todo deleted" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Verify deletion
Write-Host "`n🔍 Test 8: Verify deletion" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos/$todoId" -Method GET
    Write-Host "❌ Unexpected: Todo still exists" -ForegroundColor Red
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✅ Success: Todo not found (deleted)" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 9: Test error handling (invalid todo ID)
Write-Host "`n🚫 Test 9: Test error handling" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/todos/invalid-id" -Method GET
    Write-Host "❌ Unexpected: Should have failed" -ForegroundColor Red
}
catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✅ Success: Properly handled invalid ID" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎉 API testing completed!" -ForegroundColor Green
Write-Host "`n📊 Summary:" -ForegroundColor Yellow
Write-Host "- All CRUD operations tested" -ForegroundColor White
Write-Host "- Error handling verified" -ForegroundColor White
Write-Host "- Filtering functionality tested" -ForegroundColor White
Write-Host "- CORS headers should be present in responses" -ForegroundColor White
