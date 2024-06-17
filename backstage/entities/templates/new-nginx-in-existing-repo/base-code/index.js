async function fetchBackend() {
  try {
    const response = await fetch('./api');
    if (!response.ok) {
      throw new Error("Request failed");
    }
    const data = await response.json();
    console.log(data);

    document.getElementById("backendResponse").textContent = `BACKEND RESPONSE: ${data.response}`;
  } catch (error) {
    console.error("Error:", error);
  }
}

fetchBackend();
