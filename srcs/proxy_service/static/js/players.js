export function init() {
    console.log('Players page loaded');
    
    // Fetch data from the API
    fetch('/api/auth/player-info')
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        const apiData = document.getElementById('api-data');
        apiData.innerHTML = ''; // Clear previous content

        // Iterate through the users and create rectangles
        data.forEach(player => {
            const playerDiv = document.createElement('div');

            playerDiv.innerHTML = `
                <strong>Player Information:</strong><br>
                ID: ${player.id}<br>
                Name: ${player.username}<br>
                Email: ${player.email}<br>
                <img src="${player.avatar}" alt="${player.username}'s avatar" width="100" />
            `;
            playerDiv.classList.add('col-sm-5', 'mt-0', 'mb-2', 'mx-1', 'border', 'border-secondary', 'rounded', 'p-1', 'text-bg-light');
            apiData.appendChild(playerDiv);
        });
    })
    .catch(error => {
        document.getElementById('api-data').textContent = `Error: ${error.message}`;
    });
}