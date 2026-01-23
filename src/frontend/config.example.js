// Example configuration file
// Copy this file to config.js and update with your API endpoint

const CONFIG = {
    API_ENDPOINT: 'https://your-api-endpoint.com/api/submit',
    // Optional: Add more configuration as needed
    TIMEOUT: 5000, // 5 seconds
    RETRY_ATTEMPTS: 3
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
