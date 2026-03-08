// Global variables
let apiUrl = '';
let currentFilter = 'all';

// Initialize the app
document.addEventListener('DOMContentLoaded', function() {
    // Load API URL from localStorage if available
    const savedApiUrl = localStorage.getItem('todoApiUrl');
    if (savedApiUrl) {
        document.getElementById('apiUrl').value = savedApiUrl;
        apiUrl = savedApiUrl;
    }
    
    // Load todos on page load if API URL is set
    if (apiUrl) {
        loadTodos();
    }
});

// Set API URL
function setApiUrl() {
    const url = document.getElementById('apiUrl').value.trim();
    if (!url) {
        showError('Please enter a valid API URL');
        return;
    }
    
    // Remove trailing slash if present
    apiUrl = url.replace(/\/$/, '');
    localStorage.setItem('todoApiUrl', apiUrl);
    showSuccess('API URL set successfully');
    loadTodos();
}

// Show error message
function showError(message) {
    const errorDiv = document.getElementById('errorMessage');
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
    setTimeout(() => {
        errorDiv.style.display = 'none';
    }, 5000);
}

// Show success message
function showSuccess(message) {
    const successDiv = document.getElementById('successMessage');
    successDiv.textContent = message;
    successDiv.style.display = 'block';
    setTimeout(() => {
        successDiv.style.display = 'none';
    }, 3000);
}

// Show loading indicator
function showLoading() {
    document.getElementById('loadingIndicator').style.display = 'block';
}

// Hide loading indicator
function hideLoading() {
    document.getElementById('loadingIndicator').style.display = 'none';
}

// Add new todo
document.getElementById('todoForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    if (!apiUrl) {
        showError('Please set the API URL first');
        return;
    }
    
    const todoData = {
        title: document.getElementById('todoTitle').value.trim(),
        description: document.getElementById('todoDescription').value.trim(),
        priority: document.getElementById('todoPriority').value,
        due_date: document.getElementById('todoDueDate').value || null
    };
    
    if (!todoData.title) {
        showError('Title is required');
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${apiUrl}/todos`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(todoData)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            showSuccess('Todo added successfully');
            document.getElementById('todoForm').reset();
            loadTodos();
        } else {
            showError(result.error || 'Failed to add todo');
        }
    } catch (error) {
        showError('Network error: ' + error.message);
    } finally {
        hideLoading();
    }
});

// Load all todos
async function loadTodos() {
    if (!apiUrl) {
        showError('Please set the API URL first');
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${apiUrl}/todos`);
        const result = await response.json();
        
        if (response.ok) {
            displayTodos(result.todos);
        } else {
            showError(result.error || 'Failed to load todos');
        }
    } catch (error) {
        showError('Network error: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Display todos
function displayTodos(todos) {
    const todosList = document.getElementById('todosList');
    
    if (todos.length === 0) {
        todosList.innerHTML = '<div class="text-center text-muted py-4"><i class="fas fa-inbox fa-3x mb-3"></i><p>No todos found</p></div>';
        return;
    }
    
    // Filter todos based on current filter
    let filteredTodos = todos;
    if (currentFilter === 'pending') {
        filteredTodos = todos.filter(todo => !todo.completed);
    } else if (currentFilter === 'completed') {
        filteredTodos = todos.filter(todo => todo.completed);
    }
    
    todosList.innerHTML = filteredTodos.map(todo => createTodoHTML(todo)).join('');
}

// Create HTML for a single todo
function createTodoHTML(todo) {
    const priorityClass = `priority-${todo.priority || 'medium'}`;
    const completedClass = todo.completed ? 'completed' : '';
    const dueDate = todo.due_date ? new Date(todo.due_date).toLocaleDateString() : '';
    const createdDate = new Date(todo.created_at).toLocaleDateString();
    
    return `
        <div class="card todo-item mb-3 ${priorityClass}">
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h5 class="card-title ${completedClass}">${escapeHtml(todo.title)}</h5>
                        ${todo.description ? `<p class="card-text ${completedClass}">${escapeHtml(todo.description)}</p>` : ''}
                        <div class="text-muted small">
                            <i class="fas fa-calendar-plus me-1"></i>Created: ${createdDate}
                            ${dueDate ? `<br><i class="fas fa-calendar-check me-1"></i>Due: ${dueDate}` : ''}
                            <br><i class="fas fa-flag me-1"></i>Priority: ${todo.priority || 'medium'}
                        </div>
                    </div>
                    <div class="col-md-4 text-end">
                        <div class="btn-group" role="group">
                            <button class="btn btn-sm btn-outline-primary" onclick="toggleComplete('${todo.id}', ${todo.completed})">
                                <i class="fas fa-${todo.completed ? 'undo' : 'check'}"></i>
                                ${todo.completed ? 'Undo' : 'Complete'}
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="editTodo('${todo.id}')">
                                <i class="fas fa-edit"></i> Edit
                            </button>
                            <button class="btn btn-sm btn-outline-danger" onclick="deleteTodo('${todo.id}')">
                                <i class="fas fa-trash"></i> Delete
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// Toggle todo completion status
async function toggleComplete(todoId, currentStatus) {
    if (!apiUrl) {
        showError('Please set the API URL first');
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${apiUrl}/todos/${todoId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                completed: !currentStatus
            })
        });
        
        const result = await response.json();
        
        if (response.ok) {
            showSuccess('Todo updated successfully');
            loadTodos();
        } else {
            showError(result.error || 'Failed to update todo');
        }
    } catch (error) {
        showError('Network error: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Edit todo
async function editTodo(todoId) {
    if (!apiUrl) {
        showError('Please set the API URL first');
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${apiUrl}/todos/${todoId}`);
        const result = await response.json();
        
        if (response.ok) {
            const todo = result.todo;
            document.getElementById('editTodoId').value = todo.id;
            document.getElementById('editTitle').value = todo.title;
            document.getElementById('editDescription').value = todo.description || '';
            document.getElementById('editPriority').value = todo.priority || 'medium';
            document.getElementById('editDueDate').value = todo.due_date || '';
            document.getElementById('editCompleted').checked = todo.completed || false;
            
            const modal = new bootstrap.Modal(document.getElementById('editModal'));
            modal.show();
        } else {
            showError(result.error || 'Failed to load todo');
        }
    } catch (error) {
        showError('Network error: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Update todo
async function updateTodo() {
    const todoId = document.getElementById('editTodoId').value;
    const todoData = {
        title: document.getElementById('editTitle').value.trim(),
        description: document.getElementById('editDescription').value.trim(),
        priority: document.getElementById('editPriority').value,
        due_date: document.getElementById('editDueDate').value || null,
        completed: document.getElementById('editCompleted').checked
    };
    
    if (!todoData.title) {
        showError('Title is required');
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${apiUrl}/todos/${todoId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(todoData)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            showSuccess('Todo updated successfully');
            const modal = bootstrap.Modal.getInstance(document.getElementById('editModal'));
            modal.hide();
            loadTodos();
        } else {
            showError(result.error || 'Failed to update todo');
        }
    } catch (error) {
        showError('Network error: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Delete todo
async function deleteTodo(todoId) {
    if (!confirm('Are you sure you want to delete this todo?')) {
        return;
    }
    
    if (!apiUrl) {
        showError('Please set the API URL first');
        return;
    }
    
    try {
        showLoading();
        const response = await fetch(`${apiUrl}/todos/${todoId}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (response.ok) {
            showSuccess('Todo deleted successfully');
            loadTodos();
        } else {
            showError(result.error || 'Failed to delete todo');
        }
    } catch (error) {
        showError('Network error: ' + error.message);
    } finally {
        hideLoading();
    }
}

// Filter todos
function filterTodos(filter) {
    currentFilter = filter;
    
    // Update button states
    document.querySelectorAll('.btn-group .btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    // Reload todos to apply filter
    loadTodos();
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
