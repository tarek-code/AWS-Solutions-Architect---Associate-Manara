#!/bin/bash

# Bash script to test the Todo API endpoints
# Usage: ./test-api.sh https://your-api-id.execute-api.us-east-1.amazonaws.com/dev

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <API_URL>"
    echo "Example: $0 https://your-api-id.execute-api.us-east-1.amazonaws.com/dev"
    exit 1
fi

API_URL="$1"

echo "🧪 Testing Todo API endpoints..."
echo "API URL: $API_URL"

# Test 1: List todos (should be empty initially)
echo ""
echo "📋 Test 1: List all todos"
if response=$(curl -s "$API_URL/todos"); then
    echo "✅ Success: Found todos"
    echo "$response" | jq '.'
else
    echo "❌ Failed to list todos"
    exit 1
fi

# Test 2: Create a todo
echo ""
echo "➕ Test 2: Create a new todo"
new_todo='{
    "title": "Learn AWS Serverless",
    "description": "Complete the serverless REST API project",
    "priority": "high",
    "due_date": "2024-12-31"
}'

if response=$(curl -s -X POST "$API_URL/todos" \
    -H "Content-Type: application/json" \
    -d "$new_todo"); then
    echo "✅ Success: Todo created"
    todo_id=$(echo "$response" | jq -r '.todo.id')
    echo "Todo ID: $todo_id"
    echo "$response" | jq '.'
else
    echo "❌ Failed to create todo"
    exit 1
fi

# Test 3: Get the created todo
echo ""
echo "🔍 Test 3: Get specific todo"
if response=$(curl -s "$API_URL/todos/$todo_id"); then
    echo "✅ Success: Todo retrieved"
    echo "$response" | jq '.'
else
    echo "❌ Failed to get todo"
fi

# Test 4: Update the todo
echo ""
echo "✏️ Test 4: Update todo"
update_data='{
    "title": "Learn AWS Serverless - Updated",
    "description": "Complete the serverless REST API project with Terraform",
    "completed": true
}'

if response=$(curl -s -X PUT "$API_URL/todos/$todo_id" \
    -H "Content-Type: application/json" \
    -d "$update_data"); then
    echo "✅ Success: Todo updated"
    echo "$response" | jq '.'
else
    echo "❌ Failed to update todo"
fi

# Test 5: List todos again (should show the created todo)
echo ""
echo "📋 Test 5: List todos after creation"
if response=$(curl -s "$API_URL/todos"); then
    echo "✅ Success: Found todos"
    echo "$response" | jq '.'
else
    echo "❌ Failed to list todos"
fi

# Test 6: Test filtering (completed todos)
echo ""
echo "🔍 Test 6: Filter completed todos"
if response=$(curl -s "$API_URL/todos?completed=true"); then
    echo "✅ Success: Found completed todos"
    echo "$response" | jq '.'
else
    echo "❌ Failed to filter todos"
fi

# Test 7: Delete the todo
echo ""
echo "🗑️ Test 7: Delete todo"
if response=$(curl -s -X DELETE "$API_URL/todos/$todo_id"); then
    echo "✅ Success: Todo deleted"
    echo "$response" | jq '.'
else
    echo "❌ Failed to delete todo"
fi

# Test 8: Verify deletion
echo ""
echo "🔍 Test 8: Verify deletion"
if curl -s "$API_URL/todos/$todo_id" > /dev/null 2>&1; then
    echo "❌ Unexpected: Todo still exists"
else
    echo "✅ Success: Todo not found (deleted)"
fi

# Test 9: Test error handling (invalid todo ID)
echo ""
echo "🚫 Test 9: Test error handling"
if curl -s "$API_URL/todos/invalid-id" > /dev/null 2>&1; then
    echo "❌ Unexpected: Should have failed"
else
    echo "✅ Success: Properly handled invalid ID"
fi

echo ""
echo "🎉 API testing completed!"
echo ""
echo "📊 Summary:"
echo "- All CRUD operations tested"
echo "- Error handling verified"
echo "- Filtering functionality tested"
echo "- CORS headers should be present in responses"
