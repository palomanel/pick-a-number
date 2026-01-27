// Configuration
const API_ENDPOINT = "/api/submit";

// DOM Elements
const numberButtons = document.querySelectorAll(".number-btn");
const submitBtn = document.getElementById("submit-btn");
const messageDiv = document.getElementById("message");
const selectedText = document.getElementById("selected-text");
const selectedNumberSpan = document.getElementById("selected-number");

// Initialize submit button as disabled
submitBtn.disabled = true;

// Event Listeners
numberButtons.forEach((button) => {
  button.addEventListener("click", handleNumberSelect);
});

submitBtn.addEventListener("click", handleSubmit);

// Debug: log initial state
console.log("Number buttons found:", numberButtons.length);
console.log(
  "Submit button found:",
  submitBtn !== null,
  "Disabled state:",
  submitBtn.disabled,
);

/**
 * Handle number selection
 * @param {Event} event - Click event from number button
 */
function handleNumberSelect(event) {
  // Remove previous selection
  numberButtons.forEach((btn) => btn.classList.remove("selected"));

  // Add selection to clicked button
  event.target.classList.add("selected");
  const selectedNumber = parseInt(event.target.dataset.number);

  // Update UI
  selectedNumberSpan.textContent = selectedNumber;
  selectedText.style.display = "block";

  // Enable submit button - ensure it's actually enabled
  submitBtn.removeAttribute("disabled");
  submitBtn.disabled = false;

  console.log(
    "Number selected:",
    selectedNumber,
    "Submit button disabled:",
    submitBtn.disabled,
  );

  // Clear message
  clearMessage();
}

/**
 * Get geolocation coordinates from the browser
 * @returns {Promise<Object>} Geolocation coordinates or error
 */
function getLocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error("Geolocation is not supported by this browser"));
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve(position.coords);
      },
      (error) => {
        reject(new Error(`Geolocation error: ${error.message}`));
      },
    );
  });
}

/**
 * Handle form submission
 */
async function handleSubmit() {
  const selectedButton = document.querySelector(".number-btn.selected");
  const selectedNumber = selectedButton
    ? parseInt(selectedButton.dataset.number)
    : null;

  if (selectedNumber === null) {
    showMessage("Please select a number", "error");
    return;
  }

  const timestamp = new Date().toISOString();
  const location = await getLocation().catch((error) => {
    console.warn("Could not get location:", error);
    return null;
  });

  const payload = JSON.stringify({
    number: selectedNumber,
    timestamp: timestamp,
    location: location,
  });

  console.log("Submitting payload:", payload);

  try {
    submitBtn.classList.add("loading");
    submitBtn.disabled = true;
    clearMessage();

    const response = await fetch(API_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: payload,
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();

    // Reset selection after successful submission
    setTimeout(() => {
      resetSelection();
    }, 2000);
  } catch (error) {
    console.error("Error submitting number:", error);
    showMessage(`Error: ${error.message}. Please try again.`, "error");
    submitBtn.disabled = false;
  } finally {
    submitBtn.classList.remove("loading");
  }
}

/**
 * Display message to user
 * @param {string} text - Message text
 * @param {string} type - Message type ('success' or 'error')
 */
function showMessage(text, type) {
  messageDiv.textContent = text;
  messageDiv.className = `message ${type}`;
}

/**
 * Clear message display
 */
function clearMessage() {
  messageDiv.textContent = "";
  messageDiv.className = "message";
}

/**
 * Reset the form to initial state
 */
function resetSelection() {
  numberButtons.forEach((btn) => btn.classList.remove("selected"));
  selectedText.style.display = "none";
  submitBtn.disabled = true;
  clearMessage();
}

// Initialize
console.log("Pick a Number app loaded");
console.log("API Endpoint:", API_ENDPOINT);
