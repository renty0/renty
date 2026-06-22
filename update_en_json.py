import json
with open('Client/Admin/public/i18n/en.json', 'r') as f:
    data = json.load(f)

if 'ADMIN' not in data:
    data['ADMIN'] = {}

data['ADMIN']['DISPUTES'] = {
    "OPEN_DISPUTES": "Open Disputes",
    "RESOLVED_DISPUTES": "Resolved Disputes",
    "AVAILABLE_DISPUTES": "Available Disputes",
    "MY_DISPUTES": "My Disputes",
    "RENTAL_ID": "Rental ID",
    "ASSIGN_TO_ME": "Assign To Me",
    "RESOLVE_FINANCIALS": "Resolve Financials",
    "RESOLUTION_DATE": "Resolution Date",
    "RESOLVED_BY": "Resolved By",
    "FINAL_MESSAGE": "Final Message",
    "NO_AVAILABLE": "No available disputes.",
    "NO_ASSIGNED": "You have no assigned disputes.",
    "NO_RESOLVED": "No resolved disputes found.",
    "CLOSED_BY_ADMIN": "Closed by admin"
}

if 'SUPPORT' not in data:
    data['SUPPORT'] = {}
if 'TICKETS' not in data['SUPPORT']:
    data['SUPPORT']['TICKETS'] = {}

data['SUPPORT']['TICKETS'].update({
    "TICKET_ID": "Ticket ID",
    "REPORTED_BY": "Reported By",
    "STATUS": "Status",
    "CREATED_AT": "Created At",
    "ACTIONS": "Actions",
    "STATUS_TYPES": {
        "OPEN": "Open",
        "IN_PROGRESS": "In Progress",
        "RESOLVED": "Resolved",
        "CLOSED": "Closed",
        "AWAITINGSUPPORT": "Awaiting Support",
        "AWAITINGCUSTOMER": "Awaiting Customer"
    }
})

with open('Client/Admin/public/i18n/en.json', 'w') as f:
    json.dump(data, f, indent=2)
