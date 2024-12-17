const app = document.getElementById('app');

// Simple routes object mapping the hash to the corresponding HTML file and JS module
const routes = {
    '': '/views/home.html',  // Default route (Login page)
    '#home': '/views/home.html',
    '#players': '/views/players.html',
    '#registration': '/views/registration.html'
};

// Function to load HTML content
const loadContent = async (path) => {
    try {
        const response = await fetch(path);
        const content = await response.text();
        app.innerHTML = content;

        // Dynamically load JS module based on route
        if (window.location.hash === '#players') {
            import('./players.js').then(module => module.init());
        } else if (window.location.hash === '#home') {
            import('./home.js').then(module => module.init());
        } else if (window.location.hash === '#registration') {
            import('./registration.js').then(module => module.init());
        }
    } catch (err) {
        console.error('Error loading content:', err);
    }
};

// Router function to handle route changes
const router = () => {
    const route = window.location.hash || ''; // Default to login if no hash
    const path = routes[route] || routes[''];
    loadContent(path);
};

// Add hashchange listener to trigger routing when URL changes
window.addEventListener('hashchange', router);

// Initialize the router when the page loads
window.addEventListener('load', router);


const userData = document.getElementById('registerForm');
userData.addEventListener('submit', async (event) => {
    event.preventDefault();
    const formData = new FormData(userData);

    const avFile = formData.get('avatar');

    console.log("formData:", formData.get('avatar'));
   
    const fileToBase64 = (file) => {
        return new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onload = () => resolve(reader.result);
          reader.onerror = (error) => reject(error);
          reader.readAsDataURL(file); // Převádí soubor na Base64 ve formátu Data URL
        });
    };

    const base64File = await fileToBase64(avFile);

    console.log("base64File:", base64File);

    fetch('/api/auth/register', {
        method: 'POST',
        body: JSON.stringify({
            username: formData.get('nickName'),
            password: formData.get('password'),
            email: formData.get('email'),
            avatar: base64File
        }),
        headers: {
            'Content-type': 'application/json; charset=UTF-8',
        },
    })
        .then((response) => response.json())
        .then((json) => {
            console.log('Response:', json);
        });

    showContent();
});

function showContent() {
    document.getElementById('post-btn').hidden="true";
    document.getElementById('mainNav').removeAttribute("hidden");
    document.getElementById('app').removeAttribute("hidden");
    document.getElementById('loginPage').setAttribute("hidden", "");
}
