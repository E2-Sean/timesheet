<cfinclude template="header.cfm">

<div class="p-5">

<h1>AI Timesheet Assistant</h1>

<p class="text-muted">Tell me about your work and I'll log it for you. For example: "I worked on Web Development for Engine No.2 from 9am to 12:30pm"</p>

<div id="chat-container" class="border rounded p-3 mb-3 bg-light" style="height: 400px; overflow-y: auto;">
    <div id="chat-messages">
        <div class="message assistant-message mb-3">
            <div class="p-2 rounded bg-white border">
                <strong>Assistant:</strong> Hi <cfoutput>#session.user#</cfoutput>! I can help you log your timesheet entries. Just tell me what you worked on, when, and for how long. You can also include a note about what you did. I'll create the entry for you after confirming the details.
            </div>
        </div>
    </div>
</div>

<form id="chat-form" class="mb-3">
    <div class="input-group">
        <input type="text" id="user-input" class="form-control form-control-lg"
               placeholder="e.g., I worked on Project X for Client Y from 9am to 12:30pm - refactoring the API"
               autocomplete="off">
        <button class="btn btn-primary btn-lg" type="submit" id="send-btn">Send</button>
    </div>
</form>

<!--- Confirmation Modal --->
<div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="confirmModalLabel">Confirm Timesheet Entry</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="confirm-details">
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-success" id="confirm-btn">Confirm & Save</button>
            </div>
        </div>
    </div>
</div>

</div>

<script>
// Chat functionality
const chatMessages = document.getElementById('chat-messages');
const chatForm = document.getElementById('chat-form');
const userInput = document.getElementById('user-input');
const sendBtn = document.getElementById('send-btn');
const confirmModal = new bootstrap.Modal(document.getElementById('confirmModal'));
const confirmDetails = document.getElementById('confirm-details');
const confirmBtn = document.getElementById('confirm-btn');

let conversationHistory = [];
let pendingEntry = null;

function addMessage(role, content) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${role}-message mb-3`;

    const innerDiv = document.createElement('div');
    innerDiv.className = `p-2 rounded ${role === 'user' ? 'bg-primary text-white' : 'bg-white border'}`;

    const label = role === 'user' ? 'You' : 'Assistant';
    innerDiv.innerHTML = `<strong>${label}:</strong> ${content.replace(/\n/g, '<br>')}`;

    messageDiv.appendChild(innerDiv);
    chatMessages.appendChild(messageDiv);

    // Scroll to bottom
    document.getElementById('chat-container').scrollTop = document.getElementById('chat-container').scrollHeight;
}

function setLoading(loading) {
    sendBtn.disabled = loading;
    userInput.disabled = loading;
    if (loading) {
        sendBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span>';
    } else {
        sendBtn.innerHTML = 'Send';
    }
}

async function sendMessage(message) {
    addMessage('user', message);
    conversationHistory.push({ role: 'user', content: message });

    setLoading(true);

    try {
        const response = await fetch('api/chat.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: message,
                history: conversationHistory
            })
        });

        const data = await response.json();

        if (data.success) {
            if (data.pendingEntry) {
                // Show confirmation dialog
                pendingEntry = data.pendingEntry;
                showConfirmation(data.pendingEntry, data.response);
            }

            if (data.response) {
                addMessage('assistant', data.response);
                conversationHistory.push({ role: 'assistant', content: data.response });
            }
        } else {
            addMessage('assistant', 'Sorry, I encountered an error: ' + (data.error || 'Unknown error'));
        }
    } catch (error) {
        addMessage('assistant', 'Sorry, I encountered a network error. Please try again.');
        console.error('Chat error:', error);
    }

    setLoading(false);
}

function showConfirmation(entry, message) {
    confirmDetails.innerHTML = `
        <table class="table table-sm">
            <tr><th>Client:</th><td>${entry.client_name}</td></tr>
            <tr><th>Project:</th><td>${entry.project}${entry.subproject ? ' - ' + entry.subproject : ''}</td></tr>
            <tr><th>Date:</th><td>${entry.shift_date}</td></tr>
            <tr><th>Time:</th><td>${entry.start_time} to ${entry.end_time}</td></tr>
            <tr><th>Hours:</th><td>${entry.hours}</td></tr>
            ${entry.notes ? '<tr><th>Notes:</th><td>' + entry.notes + '</td></tr>' : ''}
        </table>
    `;
    confirmModal.show();
}

async function confirmEntry() {
    if (!pendingEntry) return;

    confirmModal.hide();
    setLoading(true);

    try {
        const response = await fetch('api/timesheets.cfm', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                action: 'create',
                id_employee: <cfoutput>#session.userid#</cfoutput>,
                id_project: pendingEntry.id_project,
                shift_date: pendingEntry.shift_date,
                start_time: pendingEntry.start_time,
                end_time: pendingEntry.end_time,
                notes: pendingEntry.notes || ''
            })
        });

        const data = await response.json();

        if (data.success) {
            const savedMsg = `Entry saved: ${pendingEntry.client_name} / ${pendingEntry.project} on ${pendingEntry.shift_date} from ${pendingEntry.start_time} to ${pendingEntry.end_time}${pendingEntry.notes ? ' (' + pendingEntry.notes + ')' : ''}`;
            addMessage('assistant', 'Timesheet entry saved successfully! ' + savedMsg);
            conversationHistory.push({ role: 'assistant', content: savedMsg });
        } else {
            addMessage('assistant', 'Failed to save entry: ' + (data.error || 'Unknown error'));
        }
    } catch (error) {
        addMessage('assistant', 'Failed to save entry due to a network error.');
        console.error('Save error:', error);
    }

    pendingEntry = null;
    setLoading(false);
}

// Event listeners
chatForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const message = userInput.value.trim();
    if (message) {
        sendMessage(message);
        userInput.value = '';
    }
});

confirmBtn.addEventListener('click', confirmEntry);

// Focus input on load
userInput.focus();
</script>

<cfinclude template="footer.cfm">
